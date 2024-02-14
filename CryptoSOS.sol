// SPDX-License-Identifier: UNLICENSED

// Βασίλης Κυριλλίδης
// f3312310

pragma solidity ^0.8.18;

contract CryptoSOS {
    /*
    * Attributes. 
    */
    address owner;
    address private player1;
    address private player2;
    uint256 private move;
    uint8[9] private boxes;
    bool private active;
    bool private turn;

    /*
    * Constants.
    */
    uint constant TICKET_PRICE = 1 ether;
    uint constant WINNER_PRIZE = 1.7 ether;
    uint constant DRAW_PRIZE = 0.8 ether;
    uint constant REMAINING_PRIZE = 0.3 ether;
    uint constant DURATION = 2 minutes;
    uint constant DURATION_SLOW_GAME = 1 minutes;
    uint constant DURATION_OWNER_SLOW_GAME = 5 minutes;


    /*
    * Events.
    */ 
    event StartGame(address, address);
    event Move(uint8, uint8, address);
    event Winner(address);
    event Tie(address, address);

    modifier currentPlayer {
        require(msg.sender == player1 || msg.sender == player2, "You are not registered to this particular game!");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You can't call this function,only the owner of the contract can");
        _;
    }

    modifier onlyAfterGameEnd() {
        require(active == false, "You can only call this function after the game has ended");
        _;
    }

    /*
    * Main constructor. 
    */
    constructor() {
        owner = msg.sender;
    }

    /*
    * Places a 'S' unit to a specified box.
    */
    function placeS(uint8 _unit) public currentPlayer {
        // Requirements.
        require(active == true && player2 != address(0), "Players should be exactly 2.");
        require((turn == true && msg.sender == player1) || (turn == false && msg.sender == player2), "You can't play again!");
        require(_unit >= 0 && _unit< 9, "You need to specify a box in the needed range [0, 8].");
        require(boxes[_unit] == 0, "Chose another box.");

        // Place an 'S'.
        boxes[_unit] = 1;
        move = block.timestamp;
        emit Move(_unit, 1, msg.sender);
        if(turn == true) {
            turn = false;
        } else {
            turn = true;
        }

        // Check for winner.
        if (checkForWinner()) {
            // There is a winner to this game!
            handleWiningState(msg.sender);
        } else if (checkIfAllBoxesAreFilled() && !checkForWinner()) {
            // There is a draw to this game.
            handleTieState();
        }
    }

    /*
    * Places an 'O' unit to a specified box.
    */
    function placeO(uint8 _unit) public {

        // Requirements.
        require(active == true && player2 != address(0), "Players should be exactly 2.");
        require((turn == true && msg.sender == player1) || (turn == false && msg.sender == player2), "You can't play again!");
        require(_unit >= 0 && _unit< 9, "You need to specify a box in the needed range [0, 8].");
        require(boxes[_unit] == 0, "Chose another box.");

        // Place an 'O'.
        boxes[_unit] = 2;
        move = block.timestamp;
        emit Move(_unit, 2, msg.sender);
        if(turn == true) {
            turn = false;
        } else {
            turn = true;
        }

        // Check for winner.
        if (checkForWinner()) {
            // There is a winner to this game!
            handleWiningState(msg.sender);
        } else if (checkIfAllBoxesAreFilled() && !checkForWinner()) {
            // There is a draw to this game.
            handleTieState();
        }
    }

    /*
    * Returns the current game state.
    */
    function getGameState() public view returns(string memory) {
        string memory gameState;
        for(uint8 box = 0; box <= 8; box++){
            if(boxes[box] == 1) {
                gameState = string(abi.encodePacked(gameState, "S"));
            } else if(boxes[box] == 2) {
                gameState = string(abi.encodePacked(gameState, "O"));
            } else {
                gameState = string(abi.encodePacked(gameState, "-"));
            }
        }
        return gameState;
    }

    /*
    * Resets the initial game state.
    */
    function resetGameState() private {
        for (uint i=0; i<9; i++) {
            boxes[i] = 0;
        }
    }

    /*
    * Returns the current balance of this smart contract.
    */
    function checkCryptoSOSBalance() public view returns (uint) {
        return address(this).balance;
    }

    /*
    * Starts the game.
    */
    function play() payable external {

        // Require 1 ether to play this game.
        require(msg.value == TICKET_PRICE, "Exactly 1 ether is required to play this game.");
        require(player1 == address(0) || player2 == address(0), "Game is already running.");
        
        if (player1 == address(0)) {
            player1 = msg.sender;
            active = true;
            move = block.timestamp;
            emit StartGame(player1, address(0));
        } else if (player2 == address(0)) {
            player2 = msg.sender;
            // Start the game
            emit StartGame(player1, player2);
            move = block.timestamp;
            turn = true; //It's player1's turn
        }
    }

    /*
    * Collects the profit and moves it into the owner's account.
    */ 
    function sweepProfit() public onlyOwner onlyAfterGameEnd {
        uint profit = checkCryptoSOSBalance();
        (bool sent, ) = payable(owner).call{value: profit}("");
        require(sent, "Collect profit failed.");
    }

    /*
    * Checks if a winner exists.
    */
    function checkForWinner() private view returns (bool) {
        // Perform brute-force checking.
        bool winnerExists = false;
        if (boxes[0] == 1 && boxes[1] == 2 && boxes[2] == 1) {
            // Horizontal case: 1.
            winnerExists = true;
        } else if (boxes[3] == 1 && boxes[4] == 2 && boxes[5] == 1) {
            // Horizontal case: 2.
            winnerExists = true;
        } else if (boxes[6] == 1 && boxes[7] == 2 && boxes[8] == 1) {
            // Horizontal case: 3.
            winnerExists = true;
        } else if (boxes[0] == 1 && boxes[3] == 2 && boxes[6] == 1) {
            // Vertical case: 1.
            winnerExists = true;
        } else if (boxes[1] == 1 && boxes[4] == 2 && boxes[7] == 1) {
            // Vertical case: 2.
            winnerExists = true;
        } else if (boxes[2] == 1 && boxes[5] == 2 && boxes[7] == 1) {
            // Vertical case: 3.
            winnerExists = true;
        } else if (boxes[0] == 1 && boxes[4] == 2 && boxes[8] == 1) {
            // Diagonal case: 1.
            winnerExists = true;
        } else if (boxes[2] == 1 && boxes[4] == 2 && boxes[6] == 1) {
            // Diagonal case: 2.
            winnerExists = true;
        }
        return winnerExists;
    }

    /*
    * Checks if all boxes are filled.
    */
    function checkIfAllBoxesAreFilled() private view returns (bool) {
        bool flag = true;
        for (uint i=0; i<9; i++) {
            if (!(boxes[i] == 1 || boxes[i] == 2)) {
                flag = false;
            }
        }
        return flag;
    }

    /*
    * Compares two strings.
    */
    function compareStrings(string memory str1, string memory str2) private pure returns (bool) {
        if (bytes(str1).length != bytes(str2).length) {
            return false;
        }
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }

    /*
    * Cancels the current player from the list of players if there is no
    * second player involved, and the duration of wait exceeds 2 minutes.
    */
    function cancel() public currentPlayer {
        // Requirements
        require(player1 != address(0) && player2 == address(0), "Only one player can cancel the game.");
        require(block.timestamp - move >= DURATION, "The time range needed for this action, was no longer than 2 minutes.");

        // Return the money to the player.
        (bool sent, ) = payable(msg.sender).call{value:TICKET_PRICE}("");
        require(sent, "Refund to player (due to long wait) failed.");
    }


    /*
    * Returns the time passed since the last move.
    */
    function timePassedSinceLastMove() private view returns (uint) {
        return block.timestamp - move;
    }

    /*
    * Returns the prize to the sender in the case the opponent did not respond 
    * in the time range of 1 minute from the sender's last move.
    */
    function tooSlow() public {
        // Requirements
        require(msg.sender == owner || (msg.sender == player1 && turn == true) || (msg.sender == player2 && turn == false), "Only the last player who placed a box or the owner, can act like this.");

        // Check if the owner is calling after 5 minutes of inactivity
        if (msg.sender == owner && timePassedSinceLastMove() >= DURATION_OWNER_SLOW_GAME) {
            handleTieState(); // End the game with a draw and return 0.8 ETH to each player
        } else if ((msg.sender == player1 && turn == true) || (msg.sender == player2 && turn == false)) {
            require(block.timestamp - move >= DURATION_SLOW_GAME, "One minute needs to be passed, in order for this action to be performed.");

            // The sender, can receive the winning prize, and end the game.
            handleWiningState(msg.sender);
        }
    }

    /*
    * Handles the case a player wins the game.
    */
    function handleWiningState(address winingPlayer) private {
        // Emit the winning event. 
        emit Winner(winingPlayer);
        
        // Send the winner's prize
        (bool sentWinner, ) = payable(winingPlayer).call{value: WINNER_PRIZE}("");
        require(sentWinner, "Could not send the prize to the winner of this game.");

        // Empty the players list
        player1 = address(0);
        player2 = address(0);
                
        // Empty the moves list
        resetGameState();

        // Reset the game state
        active = false;
    }

        /*
        * Handles the case of a draw in a game between 2 players.
        */ 
        function handleTieState() private {
        // Emit the Tie event. 
        emit Tie(player1, player2);

        // Send the draw prize to each player
        (bool sentPlayer1, ) = payable(player1).call{value: DRAW_PRIZE}("");
        require(sentPlayer1, "Could not send the draw prize to the first player.");

        (bool sentPlayer2, ) = payable(player2).call{value: DRAW_PRIZE}("");
        require(sentPlayer2, "Could not send the draw prize to the second player.");

        // Empty the players list
        player1 = address(0);
        player2 = address(0);
                
        // Empty the moves list
        resetGameState();

        // Reset the game state
        active = false;
    }

}
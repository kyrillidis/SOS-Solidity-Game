// SPDX-License-Identifier: UNLICENSED

// Βασίλης Κυριλλίδης
// f3312310

pragma solidity ^0.8.18;

contract MultiSOS {
    /*
    * Attributes. 
    */
    address owner;
    CryptoSOS[50] games;
    uint256 gameIndex = 1;

    struct CryptoSOS {
        address player1;
        address player2;
        uint256 move;
        uint8[9] boxes;
        bool active;
        bool turn;
    }

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
    event StartGame(address, address, uint256);
    event Move(uint8, uint8, address, uint256);
    event Winner(address, uint256);
    event Tie(address, address, uint256);


    modifier onlyOwner() {
        require(msg.sender == owner, "You can't call this function,only the owner of the contract can");
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
    function placeS(uint8 _unit) public {
        // Requirements.
        bool found = false;
        uint256 index = 0;
        for(uint game = 1; game <= gameIndex; game++){
            if(msg.sender == games[game].player1 || msg.sender == games[game].player2){
                found = true;
                index = game;
            }
        }
        require(found == true, "You are not registered to any particular game!");
        require(games[index].active == true && games[index].player2 != address(0), "Players should be exactly 2.");
        require((games[index].turn == true && msg.sender == games[index].player1) || (games[index].turn == false && msg.sender == games[index].player2), "You can't play again!");
        require(_unit >= 0 && _unit< 9, "You need to specify a box in the needed range [0, 8].");
        require(games[index].boxes[_unit] == 0, "Chose another box.");

        // Place an 'S'.
        games[index].boxes[_unit] = 1;
        games[index].move = block.timestamp;
        emit Move(_unit, 1, msg.sender, index);
        if(games[index].turn == true) {
            games[index].turn = false;
        } else {
            games[index].turn = true;
        }

        // Check for winner.
        if (checkForWinner(index)) {
            // There is a winner to this game!
            handleWiningState(msg.sender, index);
        } else if (checkIfAllBoxesAreFilled(index) && !checkForWinner(index)) {
            // There is a draw to this game.
            handleTieState(index);
        }
    }

    /*
    * Places an 'O' unit to a specified box.
    */
    function placeO(uint8 _unit) public {
        // Requirements.
        bool found = false;
        uint256 index = 0;
        for(uint game = 1; game <= gameIndex; game++){
            if(msg.sender == games[game].player1 || msg.sender == games[game].player2){
                found = true;
                index = game;
            }
        }
        require(found == true, "You are not registered to any particular game!");
        require(games[index].active == true && games[index].player2 != address(0), "Players should be exactly 2.");
        require((games[index].turn == true && msg.sender == games[index].player1) || (games[index].turn == false && msg.sender == games[index].player2), "You can't play again!");
        require(_unit >= 0 && _unit< 9, "You need to specify a box in the needed range [0, 8].");
        require(games[index].boxes[_unit] == 0, "Chose another box.");

        // Place an 'S'.
        games[index].boxes[_unit] = 2;
        games[index].move = block.timestamp;
        emit Move(_unit, 2, msg.sender, index);
        if(games[index].turn == true) {
            games[index].turn = false;
        } else {
            games[index].turn = true;
        }

        // Check for winner.
        if (checkForWinner(index)) {
            // There is a winner to this game!
            handleWiningState(msg.sender, index);
        } else if (checkIfAllBoxesAreFilled(index) && !checkForWinner(index)) {
            // There is a draw to this game.
            handleTieState(index);
        }
    }

    /*
    * Returns the current game state.
    */
    function getGameState() public view returns(string memory) {
        string memory gameState;
        bool found = false;
        uint256 index = 0;
        for(uint game = 1; game <= gameIndex; game++){
            if(msg.sender == games[game].player1 || msg.sender == games[game].player2){
                found = true;
                index = game;
            }
        }
        require(found == true, "You are not registered to any particular game!");
        for(uint8 box = 0; box <= 8; box++){
            if(games[index].boxes[box] == 1) {
                gameState = string(abi.encodePacked(gameState, "S"));
            } else if(games[index].boxes[box] == 2) {
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
        for(uint game = 1; game <= gameIndex; game++){
            if(games[game].active == false){
                for (uint i=0; i<9; i++) {
                    games[game].boxes[i] = 0;
                }    
            }
        }
    }

    /*
    * Returns the current balance of this smart contract.
    */
    function checkMultiSOSBalance() public view returns (uint) {
        return address(this).balance;
    }

    /*
    * Starts the game.
    */
    function play() payable external {

        // Require 1 ether to play this game.
        bool found = false;
        for(uint8 game = 1; game <= gameIndex; game++){
            if(msg.sender == games[game].player1 || msg.sender == games[game].player2)
            found = true;
        }
        require(found == false, "You are not allowed to play any more games.");
        require(msg.value == TICKET_PRICE, "Exactly 1 ether is required to play this game.");
        
        if (games[gameIndex].player1 == address(0)) {
            games[gameIndex].player1 = msg.sender;
            games[gameIndex].active = true;
            games[gameIndex].move = block.timestamp;
            emit StartGame(games[gameIndex].player1, address(0), gameIndex);
        } else if (games[gameIndex].player2 == address(0)) {
            games[gameIndex].player2 = msg.sender;
            // Start the game
            emit StartGame(games[gameIndex].player1, games[gameIndex].player2, gameIndex);
            games[gameIndex].move = block.timestamp;
            games[gameIndex].turn = true; //It's player1's turn
            gameIndex += 1;
        }
    }

    /*
    * Collects the profit and moves it into the owner's account.
    */ 
    function sweepProfit() public onlyOwner {
        bool noActive = true;
        for(uint8 game = 1; game <= gameIndex; game++){
            if(games[game].active == true){
                noActive = false;
            }
        }
        require(noActive == true, "You can't sweep because some games are still active!");
        uint profit = checkMultiSOSBalance();
        (bool sent, ) = payable(owner).call{value: profit}("");
        require(sent, "Collect profit failed.");
    }

    /*
    * Checks if a winner exists.
    */
    function checkForWinner(uint256 index) private view returns (bool) {
        // Perform brute-force checking.
        bool winnerExists = false;
        if (games[index].boxes[0] == 1 && games[index].boxes[1] == 2 && games[index].boxes[2] == 1) {
            // Horizontal case: 1.
            winnerExists = true;
        } else if (games[index].boxes[3] == 1 && games[index].boxes[4] == 2 && games[index].boxes[5] == 1) {
            // Horizontal case: 2.
            winnerExists = true;
        } else if (games[index].boxes[6] == 1 && games[index].boxes[7] == 2 && games[index].boxes[8] == 1) {
            // Horizontal case: 3.
            winnerExists = true;
        } else if (games[index].boxes[0] == 1 && games[index].boxes[3] == 2 && games[index].boxes[6] == 1) {
            // Vertical case: 1.
            winnerExists = true;
        } else if (games[index].boxes[1] == 1 && games[index].boxes[4] == 2 && games[index].boxes[7] == 1) {
            // Vertical case: 2.
            winnerExists = true;
        } else if (games[index].boxes[2] == 1 && games[index].boxes[5] == 2 && games[index].boxes[7] == 1) {
            // Vertical case: 3.
            winnerExists = true;
        } else if (games[index].boxes[0] == 1 && games[index].boxes[4] == 2 && games[index].boxes[8] == 1) {
            // Diagonal case: 1.
            winnerExists = true;
        } else if (games[index].boxes[2] == 1 && games[index].boxes[4] == 2 && games[index].boxes[6] == 1) {
            // Diagonal case: 2.
            winnerExists = true;
        }
        return winnerExists;
    }

    /*
    * Checks if all boxes are filled.
    */
    function checkIfAllBoxesAreFilled(uint256 index) private view returns (bool) {
        bool flag = true;
        for (uint i=0; i<9; i++) {
            if (!(games[index].boxes[i] == 1 || games[index].boxes[i] == 2)) {
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
    function cancel() public {
        // Requirements
        bool found = false;
        uint256 index = 0;
        for(uint8 game = 1; game <= gameIndex; game++){
            if(msg.sender == games[game].player1)
            found = true;
            index = game;
        }

        require(found == true && games[index].player2 == address(0), "Only one player can cancel the game.");
        require(block.timestamp - games[index].move >= DURATION, "The time range needed for this action, was no longer than 2 minutes.");

        // Return the money to the player.
        (bool sent, ) = payable(msg.sender).call{value:TICKET_PRICE}("");
        require(sent, "Refund to player (due to long wait) failed.");
    }


    /*
    * Returns the time passed since the last move.
    */
    function timePassedSinceLastMove(uint256 index) private view returns (uint) {
        return block.timestamp - games[index].move;
    }

    /*
    * Returns the prize to the sender in the case the opponent did not respond 
    * in the time range of 1 minute from the sender's last move.
    */
    function tooSlow() public {
        // Requirements
        uint256 index = 0;
        for(uint8 game = 1; game <= gameIndex; game++){
            if(msg.sender == games[game].player1 || msg.sender == games[game].player2)
            index = game;
        }
        require(msg.sender == owner || (msg.sender == games[index].player1 && games[index].turn == true) || (msg.sender == games[index].player2 && games[index].turn == false), "Only the last player who placed a box or the owner, can act like this.");

        // Check if the owner is calling after 5 minutes of inactivity
        if (msg.sender == owner) {
            bool ownerCancelled = false;
            for(uint256 game = 1; game <= gameIndex; game++)
            {
                if(timePassedSinceLastMove(game) >= DURATION_OWNER_SLOW_GAME){
                    handleTieState(game); // End the game with a draw and return 0.8 ETH to each player
                    ownerCancelled = true;
                }
            }
            require(ownerCancelled == true, "No game could be cancelled due to 5 minutes passed.");
        } else if ((msg.sender == games[index].player1 && games[index].turn == true) || (msg.sender == games[index].player2 && games[index].turn == false)) {
            require(block.timestamp - games[index].move >= DURATION_SLOW_GAME, "One minute needs to be passed, in order for this action to be performed.");

            // The sender, can receive the winning prize, and end the game.
            handleWiningState(msg.sender, index);
        }
    }

    /*
    * Handles the case a player wins the game.
    */
    function handleWiningState(address winingPlayer, uint256 index) private {
        // Emit the winning event. 
        emit Winner(winingPlayer, index);
        
        // Send the winner's prize
        (bool sentWinner, ) = payable(winingPlayer).call{value: WINNER_PRIZE}("");
        require(sentWinner, "Could not send the prize to the winner of this game.");

        // Empty the players list
        games[index].player1 = address(0);
        games[index].player2 = address(0);
                
        // Reset the game state
        games[index].active = false;
        
        // Empty the moves list
        resetGameState();
    }

        /*
        * Handles the case of a draw in a game between 2 players.
        */ 
        function handleTieState(uint256 index) private {
        // Emit the Tie event. 
        emit Tie(games[index].player1, games[index].player2, index);

        // Send the draw prize to each player
        (bool sentPlayer1, ) = payable(games[index].player1).call{value: DRAW_PRIZE}("");
        require(sentPlayer1, "Could not send the draw prize to the first player.");

        (bool sentPlayer2, ) = payable(games[index].player2).call{value: DRAW_PRIZE}("");
        require(sentPlayer2, "Could not send the draw prize to the second player.");

        // Empty the players list
        games[index].player1 = address(0);
        games[index].player2 = address(0);
                
        // Reset the game state
        games[index].active = false;
        
        // Empty the moves list
        resetGameState();
    }

}
# SOS Smart Contracts

## CryptoSOS

### Description
The CryptoSOS smart contract implements the classic game SOS on the Ethereum environment. Players take turns placing 'S' or 'O' on a 3x3 grid until one player forms the word "SOS" horizontally, vertically, or diagonally, or until there are no empty squares left.

### Rules of the Game
- The game is played on a 3x3 grid initially empty.
- Players take turns to place either an 'S' or an 'O' in any empty square.
- The game continues until one player forms "SOS" horizontally, vertically, or diagonally, or until there are no empty squares left.
- The first player to form "SOS" wins the game.

### CryptoSOS API
- To participate, a player must call the `play()` function.
- After two players join the game, they can place 'S' or 'O' by calling `placeS(uint8)` or `placeO(uint8)` respectively.
- `getGameState()` returns the current state of the game grid.
- The game is played with Ethereum, requiring 1 Ether to participate.
- The winner receives 1.7 Ether, and in the case of a tie, both players receive 0.8 Ether each.

### Security Measures
- If a player doesn't have an opponent within 2 minutes of joining, they can cancel their participation and get their Ether back by calling `cancel()`.
- If one player takes more than 1 minute to make a move, the other player can call `tooslow()` to end the game prematurely, receiving 1.9 Ether back while leaving 0.1 Ether in the CryptoSOS reserve.

### Events
- `StartGame(address,address)`: Emits when two players start a game.
- `Move(uint8, uint8, address)`: Emits after each move, indicating the square, the symbol ('S' or 'O'), and the player's address.
- `Winner(address)`: Emits when a player wins.
- `Tie(address, address)`: Emits in the case of a tie.

## MultiSOS

### Description
The MultiSOS smart contract extends the functionality of the original CryptoSOS contract to support the parallel execution of multiple games. It allows multiple pairs of players to start and play SOS games simultaneously.

### Changes from CryptoSOS
- **Parallel Game Execution**: Players can start multiple games simultaneously by calling the `play()` function. Each pair of players joining a game initiates a new game instance.
- **Participation Limit**: Each Ethereum address can participate in only one game at a time to ensure fair gameplay.

### MultiSOS API
The API of MultiSOS includes the same functions as CryptoSOS:

1. `play()`: Initiates a new game instance. Players join in pairs to start a game.
2. `placeS(uint8)`: Places an 'S' in the specified square.
3. `placeO(uint8)`: Places an 'O' in the specified square.
4. `getGameState()`: Retrieves the current state of the game grid.
5. `cancel()`: Allows a player to cancel participation if no opponent joins within 2 minutes.
6. `tooslow()`: Allows a player to end the game prematurely if the opponent takes more than 1 minute to make a move.

### Usage
- Deploy the MultiSOS contract on the Ethereum blockchain.
- Players interact with the contract by calling its functions using a compatible Ethereum wallet or client.
- Each address can participate in only one game at a time.
- Players can start multiple games simultaneously by calling the `play()` function repeatedly.

### Author
These smart contracts were developed by Vasilis Kyrillidis.
@vk_kappa
kyrillidisvasilis@gmail.com
-
This project was created as part of my Master's degree in cybersecurity. You can use as you wish.
-

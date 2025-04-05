
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissorsTournament {
    enum Choice { None, Rock, Paper, Scissors }
    struct Player {
        address addr;
        Choice choice;
        bool hasPlayed;
    }

    uint public entryFee;
    address[] public players;
    mapping(address => Choice) public choices;
    uint public roundNumber;
    address public winner;

    constructor(uint _entryFee) {
        entryFee = _entryFee;
        roundNumber = 1;
    }

    function joinTournament() public payable {
        require(msg.value == entryFee, "Incorrect entry fee");
        players.push(msg.sender);
    }

    function play(Choice _choice) public {
        require(_choice != Choice.None, "Invalid choice");
        require(isPlayer(msg.sender), "Not a registered player");
        require(choices[msg.sender] == Choice.None, "Already played this round");

        choices[msg.sender] = _choice;
    }

    function determineWinners() public {
        require(players.length % 2 == 0, "Players must be even");

        address[] memory nextRoundPlayers;
        for (uint i = 0; i < players.length; i += 2) {
            address winner = determineMatchWinner(players[i], players[i + 1]);
            nextRoundPlayers.push(winner);
        }

        players = nextRoundPlayers;
        roundNumber++;

        if (players.length == 1) {
            winner = players[0];
            distributePrize();
        }
    }

    function determineMatchWinner(address player1, address player2) private view returns (address) {
        Choice choice1 = choices[player1];
        Choice choice2 = choices[player2];

        if (choice1 == choice2) {
            return player1; // Tie, player1 advances.
        } else if (
            (choice1 == Choice.Rock && choice2 == Choice.Scissors) ||
            (choice1 == Choice.Paper && choice2 == Choice.Rock) ||
            (choice1 == Choice.Scissors && choice2 == Choice.Paper)
        ) {
            return player1;
        } else {
            return player2;
        }
    }

    function distributePrize() private {
        payable(winner).transfer(address(this).balance);
    }

    function isPlayer(address _addr) private view returns (bool) {
        for (uint i = 0; i < players.length; i++) {
            if (players[i] == _addr) {
                return true;
            }
        }
        return false;
    }
}

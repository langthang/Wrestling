pragma solidity ^0.4.18;

contract Wrestling {
    address public playerA;
    address public playerB;

    bool public playerAInGame;
    bool public playerBInGame;
    
    uint public depositA;
    uint public depositB;

    bool public gameFinished;
    address public theWinner;
    uint gains;

    event StartGameEvent(address wA, address wB);
    event EndRoundEvent(uint depositA, uint depositB);
    event EndGameEvent(address winner, uint gains);

    constructor() public {
        playerA = msg.sender;
    }

    function registerAsACompetitor() public {
        require(playerB == address(0));
        playerB = msg.sender;
        emit StartGameEvent(playerA, playerB);
    }

    function wrestle() public payable {
        require(!gameFinished 
            && (msg.sender == playerA || msg.sender == playerB));

        if(msg.sender == playerA){
            require(!playerAInGame);
            playerAInGame = true;
            depositA += msg.value;
        } else {
            require(!playerBInGame);
            playerBInGame = true;
            depositB += msg.value;
        }

        if(playerAInGame && playerBInGame){
            if(depositA >= depositB * 2){
                endGame(playerA);
            }
            else if (depositB >= depositA * 2) {
                endGame(playerB);
            } else {
                endRound();
            }
        }
    }

    function endGame(address winner) internal {
        gameFinished = true;
        theWinner = winner;
        gains = depositA + depositB;
        emit EndGameEvent(winner, gains);
    }

    function endRound() internal {
        playerAInGame = false;
        playerBInGame = false;
        emit EndRoundEvent(depositA, depositB);
    }

    function withdraw() public {
        require(gameFinished && theWinner == msg.sender);
        uint amount = gains;
        gains = 0;
        msg.sender.transfer(amount);
    }
}

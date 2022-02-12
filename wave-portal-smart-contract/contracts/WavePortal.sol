// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;
    event NewWave(address indexed from, uint256 timestamp, string message);
    /**
    * A struct is basically a custom datatype where we can customize what we want to hold inside it.
     */
    struct Wave {
        address waver; // The address of the user who posted.
        string message; // The message the user sent.
        uint256 timestamp; // The timestamp when the user posted.
    }

    Wave[] waves;

    mapping(address => uint256) public lastWavedAt;
    constructor() payable {
        console.log("My contract kinda smart");
        seed = (block.timestamp + block.difficulty) % 100;
    }
    /**
    Function wave requires string message from frontend
     */


    function wave(string memory _message) public {
        require(
            lastWavedAt[msg.sender] + 15 minutes < block.timestamp,
            "Wait 15m"
        );

        /*
         * Update the current timestamp we have for the user
         */
        lastWavedAt[msg.sender] = block.timestamp;
        totalWaves += 1;
        console.log("%s posted w/ message %s", msg.sender, _message);
        /*
         * This is where I actually store the post data in the array.
         */
        waves.push(Wave(msg.sender, _message, block.timestamp));
        /*
         * Added some fanciness here
         */
        /*
         * Generate a new seed for the next user that sends a wave
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        /*
         * Give a 50% chance that the user wins the prize.
         */
        if (seed <= 50){
            console.log("%s won!", msg.sender);
            uint256 prizeAmount = 0.0001 ether;

            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }
        emit NewWave(msg.sender, block.timestamp, _message);
    }
    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {

        return totalWaves;
    }
}

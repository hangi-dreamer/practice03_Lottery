// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";

contract Lottery {
    mapping (uint => mapping (address => uint16)) private solds;
    mapping (uint => mapping (address => bool)) private is_buy;
    mapping (uint => mapping (uint16 => address[])) private selected_numbers;
    mapping (address => uint) private winner_rewards;

    uint startTimestamp;
    uint endTimestamp;

    bool drawed;

    constructor() {
        starNewtPhase();
    }

    function starNewtPhase() private {
        startTimestamp = block.timestamp;
        endTimestamp = startTimestamp + 24 hours;
        drawed = true;
    }

    function buy(uint16 num) external payable {
        require(msg.value == 0.1 ether);
        require(is_buy[startTimestamp][msg.sender] == false);
        require(block.timestamp < endTimestamp);
        is_buy[startTimestamp][msg.sender] = true;
        solds[startTimestamp][msg.sender] = num;
        selected_numbers[startTimestamp][num].push(msg.sender);

        if (drawed) {
            drawed = false;
        }
    }

    function draw() external {
        require(block.timestamp >= endTimestamp);
        uint16 winningNumber = winningNumber();

        uint winner_count = selected_numbers[startTimestamp][winningNumber].length;

        for (uint i; i < winner_count; i++) {
            winner_rewards[selected_numbers[startTimestamp][winningNumber][i]] += (address(this).balance / winner_count);
        }

        starNewtPhase();
    }
    function claim() external {
        require(drawed);
        (bool sent,) = payable(msg.sender).call{value: winner_rewards[msg.sender]}("");
        require(sent, "Failed to send Ether");
    }
    function winningNumber() public returns(uint16 num) {
        num = uint16(block.timestamp);
    }
}

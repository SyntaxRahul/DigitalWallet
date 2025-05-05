// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DigitalWallet {
    mapping(address => uint256) public balances; // Stores users' money
    mapping(address => uint256) public spendingLimit; // Stores spending limit
    mapping(address => uint256) public dailySpent; // Tracks daily expenses
    mapping(address => uint256) public lastReset; // Saves last spending reset time

    event Deposit(address indexed user, uint256 amount); // Event for deposits
    event Withdraw(address indexed user, uint256 amount); // Event for withdrawals
    event LimitSet(address indexed user, uint256 limit); // Event for setting limits

    // ✅ Deposit ETH into the wallet
    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        balances[msg.sender] += msg.value; 
        emit Deposit(msg.sender, msg.value);
    }

    // ✅ Set spending limit for daily transactions
    function setSpendingLimit(uint256 limit) public {
        require(limit > 0, "Limit must be greater than zero"); // Prevents zero limit
        spendingLimit[msg.sender] = limit;
        emit LimitSet(msg.sender, limit);
    }

    // ✅ Withdraw funds with spending limit enforcement
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Reset spending if a new day has started
        if (block.timestamp - lastReset[msg.sender] >= 1 days) {
            dailySpent[msg.sender] = 0;
            lastReset[msg.sender] = block.timestamp;
        }

        require(dailySpent[msg.sender] + amount <= spendingLimit[msg.sender], "Exceeds daily limit");
        balances[msg.sender] -= amount;
        dailySpent[msg.sender] += amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    // ✅ Function to check balance
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*********************************************************************************************************************************************/
// To be noted --- 

/* This is a common smart contract template for centralized exchange, decentralized exchange and hybrid exchange.
   Contract for centralized exchange is compiled and deployed for demonstration purpose.
   Contracts for decentralized exchange and hybrid exchange are given below in commented out manner.
   Kindly uncomment the required template and use, as needed. Compilation and deployment process will be same for all. */

/*********************************************************************************************************************************************/

// 1. Smart contract for CentralizedExchange

contract CryptoExchange {
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    uint256 public tradeFee; // Fee in basis points (1/100th of a percentage)

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event TradeExecuted(address indexed user, address indexed token, uint256 amount, uint256 fee);
    event CheckBalance(string text, uint amount);

    //Uncomment the constructor and feed necessary arguments in scripts/deploy.ts, to deploy the contract.

    // constructor(uint256 _tradeFee) {
    //     owner = msg.sender;
    //     tradeFee = _tradeFee;
    // }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function deposit(address tokenAddress, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount), "Transfer failed");
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(address tokenAddress, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        require(IERC20(tokenAddress).transfer(msg.sender, amount), "Transfer failed");
        emit Withdrawal(msg.sender, amount);
    }

    function setTradeFee(uint256 _tradeFee) external onlyOwner {
        tradeFee = _tradeFee;
    }

    function executeTrade(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 toAmount
    ) external {
        uint256 fee = (fromAmount * tradeFee) / 10000; // Calculate the fee
        require(balances[msg.sender] >= fromAmount, "Insufficient balance");
        require(balances[address(this)] >= fee, "Insufficient exchange balance");

        balances[msg.sender] -= fromAmount;
        balances[address(this)] += fee;

        // Perform the actual token swap, this is highly simplified
        // In a real exchange, you would interact with the respective token contracts
        // and handle order matching, fees, and other complex logic

        emit TradeExecuted(msg.sender, toToken, toAmount, fee);
    }
    
    function getBalance(address user_account) external returns (uint){
    
       string memory data = "User Balance is : ";
       uint user_bal = user_account.balance;
       emit CheckBalance(data, user_bal );
       return (user_bal);

    }
}

/*********************************************************************************************************************************************/

// 2. Smart contract for De-centralized Exchange

/*
contract CryptoExchange {
    address public owner;

    event TradeExecuted(
        address indexed trader,
        address indexed fromToken,
        address indexed toToken,
        uint256 fromAmount,
        uint256 toAmount
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function executeTrade(
        address fromToken,
        address toToken,
        uint256 fromAmount
    ) external {
        require(fromToken != toToken, "Cannot trade the same token");
        require(fromAmount > 0, "Amount must be greater than 0");

        // In a real DEX, you would perform order matching, handle liquidity pools, and other complex logic.
        // This example assumes a 1:1 token swap for simplicity.

        require(IERC20(fromToken).transferFrom(msg.sender, address(this), fromAmount), "Transfer failed");
        uint256 toAmount = fromAmount;
        require(IERC20(toToken).transfer(msg.sender, toAmount), "Transfer failed");

        emit TradeExecuted(msg.sender, fromToken, toToken, fromAmount, toAmount);
    }

    // Additional functions for managing liquidity pools, order books, and other DEX features can be added.
}
*/

/*********************************************************************************************************************************************/

// 3. Smart contract for Hybrid Exchange

/*
contract CryptoExchange {
    address public owner;
    mapping(address => uint256) public balances;
    uint256 public tradeFee; // Fee in basis points (1/100th of a percentage)
    uint256 public orderIdCounter;

    struct Order {
        address trader;
        address fromToken;
        address toToken;
        uint256 fromAmount;
        uint256 toAmount;
        bool isBuyOrder;
        bool isExecuted;
    }

    Order[] public orders;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event TradeExecuted(
        address indexed user,
        uint256 orderId,
        address indexed fromToken,
        address indexed toToken,
        uint256 fromAmount,
        uint256 toAmount,
        uint256 fee
    );

    constructor(uint256 _tradeFee) {
        owner = msg.sender;
        tradeFee = _tradeFee;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function deposit(address tokenAddress, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount), "Transfer failed");
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(address tokenAddress, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        require(IERC20(tokenAddress).transfer(msg.sender, amount), "Transfer failed");
        emit Withdrawal(msg.sender, amount);
    }

    function createOrder(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 toAmount,
        bool isBuyOrder
    ) external {
        require(fromToken != toToken, "Invalid token pair");
        require(fromAmount > 0 && toAmount > 0, "Invalid order amount");
        require(fromAmount * toAmount > 0, "Invalid order value");
        require(balances[msg.sender] >= fromAmount, "Insufficient balance");

        orders.push(Order({
            trader: msg.sender,
            fromToken: fromToken,
            toToken: toToken,
            fromAmount: fromAmount,
            toAmount: toAmount,
            isBuyOrder: isBuyOrder,
            isExecuted: false
        }));
    }

    function executeTrade(uint256 orderId) external {
        require(orderId < orders.length, "Invalid order ID");
        Order storage order = orders[orderId];
        require(!order.isExecuted, "Order already executed");

        uint256 fee = (order.fromAmount * tradeFee) / 10000; // Calculate the fee
        uint256 toAmount = order.toAmount - fee;

        if (order.isBuyOrder) {
            require(balances[msg.sender] >= toAmount, "Insufficient balance");
            balances[msg.sender] -= toAmount;
            balances[order.trader] += order.fromAmount;
        } else {
            require(balances[msg.sender] >= order.fromAmount, "Insufficient balance");
            balances[msg.sender] -= order.fromAmount;
            balances[order.trader] += toAmount;
        }

        order.isExecuted = true;

        emit TradeExecuted(
            msg.sender,
            orderId,
            order.fromToken,
            order.toToken,
            order.fromAmount,
            toAmount,
            fee
        );
    }

    // Additional functions for managing order books, order matching, and other hybrid exchange features can be added.
}
*/

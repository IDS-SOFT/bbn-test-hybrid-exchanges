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

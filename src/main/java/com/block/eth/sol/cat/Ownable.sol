pragma solidity ^0.4.20;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner; // 地址变量owner
    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() { // 构造函数
        owner = msg.sender; // owner初始化为智能合约拥有者的地址
    }
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() { //修改器
        require(msg.sender == owner); //如果操作为非拥有者，则抛出异常
        _;
    }
    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner {  //被onlyOwner修饰的修改合约拥有者方法
        if (newOwner != address(0)) { // 判断地址newOwner是否合法
            owner = newOwner; // 修改合约拥有者为newOwner
        }
    }
}
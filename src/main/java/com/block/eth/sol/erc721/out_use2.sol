pragma solidity ^0.4.23;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
contract ERCInterface {
    function addCount(address _to, uint256 _count) public returns (bool success);
    function balanceOf(address _owner) public view returns (uint256 balance);
}
contract EggNumberTemp is ERCInterface{
    using SafeMath for uint256;

    mapping(address => uint256) totalNum;

    function addCount(address _to, uint256 _count) public returns (bool success){
        totalNum[_to] = totalNum[_to].add(_count);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance){
        return totalNum[_owner];
    }
}

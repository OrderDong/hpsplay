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
contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}
contract ERCInterface {
    function addCount(address _to, uint256 _count) public returns (bool success);
    function balanceOf(address _owner) public view returns (uint256 balance);
}
contract EggAuctionTemp is Ownable{
    using SafeMath for uint256;
    using SafeMath for uint8;
    ERCInterface public acceptedToken;

    constructor(address _acceptedToken) public {
        acceptedToken = ERCInterface(_acceptedToken);
    }

    function addToDDC(uint256 _count,address _to) public {
        require(acceptedToken.addCount(
                _to,
                _count
            ));
    }

    function payInfo(uint8 _count) public payable{
        require(_count > 0);
    }
    function getBalan(address _adde) public view returns (uint256){
        return acceptedToken.balanceOf(_adde);
    }

    function getOwnerAddr() external view returns(address,address,address){
        return (owner,address(this),address(0));
    }

}

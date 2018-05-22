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
contract ERC20Interface {
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function totalSupply() public view returns (uint256 total);
}
contract EggAuctionTemp is Ownable{
    using SafeMath for uint256;
    using SafeMath for uint8;
    ERC20Interface public acceptedToken;
    uint256 public publicationFeeInWei = 10 ether;


    constructor(address _acceptedToken) public {
        acceptedToken = ERC20Interface(_acceptedToken);
    }

    event ExchangeCreated(
        uint256 id,
        address indexed from,
        address indexed to,
        uint256 priceInWei,
        uint256 time,
        uint256 count,
        uint8 eType);

    function exchangeEggToDDC(uint256 _count,address _to) public {
        /*uint256 eggCount = _getEggCount(msg.sender,_eType);
        require(eggCount > _count);
        uint256 auctionCount = _getAuctionByType(_eType,msg.sender);
        require(_count.add(auctionCount) <= eggCount );
*/
        //require(acceptedToken.approve(address(_to),_count));
        require(acceptedToken.transfer(
                _to,
                _count
            ));

        //require(_transferEggMk(msg.sender,owner,_count,_eType,_level));
        //emit ExchangeCreated(_auctionId,msg.sender,owner,publicationFeeInWei.mul(_count),now,_count,_eType);
    }

    function exchangeDDCToEgg(uint256 _count,address _from) public {
        /*require(_count > 0);
        require(_eType >= 0 && _eType<=20);
        uint256 eggCount = _getEggCount(msg.sender,_eType);
        require(eggCount > _count);
        require(acceptedToken.balanceOf(msg.sender) >= _count);*/

        require(acceptedToken.transferFrom(
                address(_from),
                owner,
                publicationFeeInWei.mul(_count)
            ));
        //require(_transferEggMk(msg.sender,owner,_count,_eType,_level));

        //emit ExchangeCreated(0,owner,msg.sender,publicationFeeInWei.mul(_count),now,_count,_eType);
    }

    function payInfo(uint8 _count) public payable{
        require(_count > 0);
    }
    function getBalan(address _adde) public view returns (uint256){
        return acceptedToken.balanceOf(_adde);
    }

    function withdrawBalance(uint256 amount,address _owner) external {
        uint256 balance = address(this).balance;
        if (balance > amount) {
            address(_owner).transfer(amount);
        }
    }

    function getOwnerAddr() external view returns(address,address,address){
        return (owner,address(this),address(0));
    }

}

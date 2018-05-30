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
//权限控制
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
contract Destructible is Ownable {
    constructor() public payable { }
    function destroy() onlyOwner public {
        selfdestruct(owner);
    }
    function destroyAndSend(address _recipient) onlyOwner public {
        selfdestruct(_recipient);
    }
}
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    modifier whenPaused() {
        require(paused);
        _;
    }
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}
contract ERC20Interface {
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function totalSupply() public view returns (uint256 total);
}

contract ERC721Interface {
    function ownerOf(uint256 tokenId) public view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    function allowance(address _owner,uint256 _tokenId) public view returns (bool);
}

contract EggAuction is Ownable,Pausable{
    using SafeMath for uint256;
    using SafeMath for uint8;

    ERC20Interface public acceptedToken;
    ERC721Interface public nonFungibleRegistry;

    struct Auction {
        uint256 id;
        address seller;
        string name;
        uint256 price;
        uint256 expiresAt;
        uint256 salesCount;
        uint256 time;
    }
    uint256[] public indexArr;
    mapping (uint256 => Auction) public auctionOnwer;
    mapping (address => uint256) public ownerCount;
    uint256 public auctionIndex;


    uint256 public publicationFeeInWei = 1 ether;

    /* EVENTS */
    event AuctionCreated(
        uint256 id,
        address indexed seller,
        uint256 price,
        uint256 expiresAt,
        uint256 salesCount,
        uint256 time
    );
    event AuctionSuccessful(
        uint256 id,
        address indexed seller,
        address indexed winner,
        uint256 price,
        uint256 salesCount,
        uint256 time);
    event AuctionCancelled(
        uint256 id,
        address indexed seller,
        uint256 time);

    function _getIndex(uint256 _auctionId) internal view returns (uint256){
        uint256 i;
        for(i=0; i<indexArr.length;i++){
            if(indexArr[i] == _auctionId){
                break;
            }
        }
        return i;
    }
    function _getAuctionOwnerCount(address _owner) internal view returns (uint256){
        uint256 i;
        uint256 count;
        for(i=0;i<indexArr.length;i++){
            if(auctionOnwer[indexArr[i]].seller == _owner){
                count = count.add(1);
            }
        }
        return count;
    }
    function createEggAuction(uint256 _price,uint256 expiresAt,uint256 _count,string _name)
    public payable whenNotPaused {
        require(msg.sender != address(0));
        require(_count >= 1);
        require(_count.add(ownerCount[msg.sender]) <= acceptedToken.balanceOf(msg.sender) );
        auctionIndex = auctionIndex.add(1);
        uint256 auctionId = auctionIndex;
        auctionOnwer[auctionId] = Auction({id: auctionId,seller: msg.sender,name:_name,price:_price,
            salesCount: _count,expiresAt: expiresAt,time: now});
        indexArr.push(auctionId);
        ownerCount[msg.sender]  = ownerCount[msg.sender].add(_count);
        emit AuctionCreated(auctionId,msg.sender,_price,expiresAt,_count,now);
    }
    function cancelEggAuction(uint256 _auctionId) public whenNotPaused {
        require(auctionOnwer[_auctionId].seller == msg.sender || msg.sender == owner);
        ownerCount[msg.sender] = ownerCount[msg.sender].sub(auctionOnwer[_auctionId].salesCount);
        uint256 i = _getIndex(_auctionId);
        indexArr[i] = indexArr[indexArr.length-1];
        indexArr.length--;
        delete auctionOnwer[_auctionId];

        emit AuctionCancelled(_auctionId,msg.sender,now);
    }

    function executeEggAuction(uint256 _auctionId,uint256 _count) public payable whenNotPaused {
        address seller = auctionOnwer[_auctionId].seller;
        //require(seller != address(0));
        require(seller != msg.sender);
        require(auctionOnwer[_auctionId].salesCount > 0 &&
        auctionOnwer[_auctionId].salesCount >=_count);
        require(auctionOnwer[_auctionId].price.mul(_count) == msg.value);

        uint price = msg.value;
        if(seller != owner){
            uint saleFeeAmount = price.div(100);
            uint256 sellerProceeds = price.sub(saleFeeAmount);
            seller.transfer(sellerProceeds);
        }
        require(acceptedToken.transferFrom(seller,msg.sender,_count.mul(publicationFeeInWei)));
        if(auctionOnwer[_auctionId].salesCount == _count){
            uint256 i = _getIndex(_auctionId);
            indexArr[i] = indexArr[indexArr.length-1];
            indexArr.length--;
            delete auctionOnwer[_auctionId];
            delete ownerCount[seller];
        }else{
            auctionOnwer[_auctionId].salesCount = auctionOnwer[_auctionId].salesCount.sub(_count);
            ownerCount[seller] = ownerCount[seller].sub(_count);
        }
        emit AuctionSuccessful(_auctionId,seller,msg.sender, price, _count,now);
    }

    function getCountByOwner(address _owner) external view returns (uint256) {
        return ownerCount[_owner];
    }

    function getAuctions() external view returns (uint256[]) {
        return indexArr;
    }
    function getAuctionsByOwner(address _owner) external view returns (uint256[]) {
        uint256 ownerAuCount = _getAuctionOwnerCount(_owner);
        uint256[] memory result = new uint256[](ownerAuCount);
        uint256 i;
        uint256 re=0;
        for(i=0;i<indexArr.length;i++){
            if(auctionOnwer[indexArr[i]].seller == _owner){
                result[re] = indexArr[i];
                re = re.add(1);
            }
        }
        return result;
    }

    function getAuction(uint256 _id) external view returns (
        uint256 id,
        address seller,
        string name,
        uint256 price,
        uint256 expiresAt,
        uint256 salesCount
    ) {
        Auction storage auction = auctionOnwer[_id];
        id =auction.id;
        seller = auction.seller;
        name = auction.name;
        price = auction.price;
        expiresAt = auction.expiresAt;
        salesCount = auction.salesCount;
    }
    function withdrawBalance(uint256 amount) external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance > amount) {
            owner.transfer(amount);
        }
    }
}

contract EggAuctionWar is EggAuction{
    struct EggWar {
        address owner;
        uint256 count;
        uint256 time;
    }
    mapping (address => EggWar) eggWar;

    event WarCreated(
        address indexed ower,
        uint256 count,
        uint256 time);
    event WarExecuted(
        address indexed ower,
        uint256 cardTokenId,
        uint256 ddcCount,
        uint256 time);
    function joinWar(uint256 _count) public whenNotPaused{
        require(_count >= 1);
        require(acceptedToken.balanceOf(msg.sender) >=1 &&
        acceptedToken.balanceOf(msg.sender) >= ownerCount[msg.sender].add(_count));
        require(
            acceptedToken.transferFrom(msg.sender,owner,_count)
        );
        eggWar[msg.sender] =  EggWar({owner:msg.sender,count:_count,time:now});
        emit WarCreated(msg.sender,_count,now);
    }
    function finishWar(address _to,uint256 _count,uint256 _cardTokenId) public whenNotPaused onlyOwner {
        require(eggWar[_to].count>0);
        delete eggWar[_to];
        emit WarExecuted(_to,_cardTokenId,_count,now);
    }
}
contract EggAuctionCode is EggAuctionWar{
    constructor(address _acceptedToken, address _nonFungibleRegistry) public {
        acceptedToken = ERC20Interface(_acceptedToken);
        nonFungibleRegistry = ERC721Interface(_nonFungibleRegistry);
    }
}

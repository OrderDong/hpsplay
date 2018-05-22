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
    function approve(address _to, uint256 _tokenId) external;
}

contract Market20 is Ownable,Pausable {
    using SafeMath for uint256;
    using SafeMath for uint8;

    event EggMkCreated(uint8 _level,uint8 _eType,uint256 _count,address indexed _owner);
    event TransferEggMk(address indexed _from,address indexed _to,uint256 _count,uint8 _eType,uint8 _level);
    event EggMkUpdated(uint8 _level,uint8 _eType,uint256 _count,address indexed _owner);

    struct EggMk {
        address owner;
        uint256 mkCount;
        uint8 eType;
        uint8 level;
    }
    EggMk[] eggs;
    mapping (address => uint256[]) public mappEggMk;

    function _createEggMk(uint8 _level,uint8 _eType,uint256 _count,address _owner) internal returns (uint){
        require(_eType <= 20);
        uint i;
        bool flag = false;
        if(mappEggMk[_owner].length >0 ){
            for(i=0;i<mappEggMk[_owner].length;i++){
                if(eggs[mappEggMk[_owner][i]].eType == _eType){
                    eggs[mappEggMk[_owner][i]].mkCount = eggs[mappEggMk[_owner][i]].mkCount.add(_count);
                    emit EggMkUpdated(_level,_eType,_count,_owner);
                    flag = true;
                }
            }
        }
        if(!flag){
            EggMk memory curEggMak = EggMk(_owner,_count,_eType,_level);
            uint256 auctionId = eggs.push(curEggMak).sub(1);
            mappEggMk[_owner].push(auctionId);
            emit EggMkCreated(_level,_eType,_count,_owner);
        }
        return curEggMak.mkCount;
    }
    //EggMk[] eggs;
    //mapping (address => uint256[]) public mappEggMk;
    function _transferEggMk(address _from,address _to,uint256 _count,uint8 _eType,uint8 _level) internal returns (bool){
        require(_eType <= 20);
        require(_count >= 1);
        uint i;
        bool flag = false;
        if(mappEggMk[_from].length >0 ){
            for(i=0;i<mappEggMk[_from].length;i++){
                if(eggs[mappEggMk[_from][i]].eType == _eType){
                    if(eggs[mappEggMk[_from][i]].mkCount == _count){
                        delete eggs[mappEggMk[_from][i]];
                        delete mappEggMk[_from][i];
                    }else{
                        eggs[mappEggMk[_from][i]].mkCount = eggs[mappEggMk[_from][i]].mkCount.sub(_count);
                    }
                    _createEggMk(_level,_eType,_count,_to);
                    flag = true;
                }
            }
        }
        return flag;
    }
    function _getEggCount(address _from,uint8 _eType) internal view returns (uint256) {
        require(_eType <= 20);
        uint i;
        uint count = 0;
        if(mappEggMk[_from].length >0 ){
            for(i=0;i<mappEggMk[_from].length;i++){
                if(eggs[mappEggMk[_from][i]].eType == _eType){
                    count = count.add(eggs[mappEggMk[_from][i]].mkCount);
                }
            }
        }
        return count;
    }
}

contract MarketUse is Market20 {
    ERC20Interface public acceptedToken;
    ERC721Interface public nonFungibleRegistry;

    uint256 public constant CREATION_LIMIT = 500000;
    uint256 public constant TRANSFER_STAND = 10;
    uint256 public totalCount;
    uint256 public createdCount;

    function createInitEgg( address _owner) external onlyOwner {
        require(createdCount < CREATION_LIMIT);
        //require(acceptedToken.balanceOf(_owner).mul(TRANSFER_STAND) > CREATION_LIMIT );
        _createEggMk(0, 0,CREATION_LIMIT,_owner);
        createdCount = CREATION_LIMIT;
    }
    function createEgg(uint8 _level,uint8 _eType,uint256 _count, address _owner) external onlyOwner {
        //require(acceptedToken.balanceOf(_owner).mul(TRANSFER_STAND) > _count);
        _createEggMk(_level, _eType,_count,_owner);
    }
    function transferEggMk(address _from,address _to,uint256 _count,uint8 _eType,uint8 _level) external onlyOwner returns (bool){
        require(_eType <= 20);
        require(_count >= 1);
        _transferEggMk(_from,_to,_count,_eType,_level);
    }
    function getEggCount(uint8 _eType) external view returns (uint256) {
        require(_eType <= 20);
        return _getEggCount(msg.sender,_eType);
    }
    function getEggList(address _address) external view returns (uint256[]) {
        return mappEggMk[_address];
    }
    function getEggByType(uint256 _index) external view returns (
        address owner,
        uint256 mkCount,
        uint8 eType,
        uint8 level
    ) {
        EggMk storage mk = eggs[_index];
        return (mk.owner,mk.mkCount,mk.eType,mk.level);
    }
}

contract EggAuction is MarketUse {
    struct Auction {
        uint256 id;
        address seller;
        string name;
        uint256 price;
        uint256 expiresAt;
        uint256 salesCount;
        uint8 eType;
    }

    Auction[] public auctions;
    mapping (address => uint256[]) public auctionByTokenId;

    uint256 public publicationFeeInWei = 10 ether;

    /* EVENTS */
    event AuctionCreated(
        uint256 id,
        address indexed seller,
        uint256 priceInWei,
        uint256 expiresAt,
        uint256 salesCount,
        uint8 eType);
    event AuctionSuccessful(
        uint256 id,
        address indexed seller,
        uint256 totalPrice,
        address indexed winner,
        uint256 salesCount,
        uint256 time,
        uint8 eType);
    event AuctionCancelled(
        uint256 id,
        uint256 count,
        address indexed seller,
        uint256 time);

    function _getAuctionIndex(uint256 _auctionId,address _owner) view internal returns (uint256) {
        uint256 i;
        for(i=0;i<auctionByTokenId[_owner].length;i++){
            if(auctionByTokenId[_owner][i] == _auctionId){
                break;
            }
        }
        return i;
    }
    //auction executing count
    function _getAuctionByType(uint8 _eType,address _owner) view internal returns (uint256) {
        uint256 i;
        uint256 count = 0;
        for(i=0;i<auctionByTokenId[_owner].length;i++){
            if(auctions[auctionByTokenId[_owner][i]].eType == _eType){
                count = count.add(auctions[auctionByTokenId[_owner][i]].salesCount);
                break;
            }
        }
        return count;
    }

    function createEggAuction(uint256 priceInWei, uint256 expiresAt,uint256 _count,uint8 _eType,string _name)
    public payable whenNotPaused {
        require(msg.sender != address(0));
        require(_eType <= 20);
        require(_count >= 1);
        require(priceInWei > 0);
        uint256 auctionCount = _getAuctionByType(_eType,msg.sender);
        uint256 eggCount = _getEggCount(msg.sender,_eType);
        require(_count.add(auctionCount) <= eggCount );
        uint256 auctionId = auctions.length;
        auctions.push(Auction({id: auctionId,seller: msg.sender,name:_name,
            price: priceInWei,expiresAt: expiresAt,salesCount: _count,eType: _eType}));
        auctionByTokenId[msg.sender].push(auctionId);
        emit AuctionCreated(auctionId,msg.sender,priceInWei,now,_count,_eType);
    }
    function cancelEggAuction(uint256 _auctionId) public whenNotPaused {
        uint256 i = _getAuctionIndex(_auctionId,msg.sender);
        uint256 salesCount = auctions[_auctionId].salesCount;
        require(i>=0 || msg.sender == owner);
        delete auctionByTokenId[msg.sender][i];
        delete auctions[_auctionId];

        emit AuctionCancelled(_auctionId, salesCount, msg.sender,now);
    }

    function executeEggAuction(uint256 _auctionId,uint256 _count) public payable whenNotPaused {
        address seller = auctions[_auctionId].seller;
        //require(seller != address(0));
        require(seller != msg.sender);
        require(auctions[_auctionId].salesCount > 0);
        require(auctions[_auctionId].price.mul(_count) == msg.value);

        uint8 eType = auctions[_auctionId].eType;
        uint price = msg.value;
        if(seller != owner){
            uint saleFeeAmount = price.div(100);
            uint256 sellerProceeds = price.sub(saleFeeAmount);
            seller.transfer(sellerProceeds);
        }
        require(_transferEggMk(seller,msg.sender,_count,eType,0));
        uint256 i = _getAuctionIndex(_auctionId,seller);
        if(auctions[_auctionId].salesCount <= _count ){
            delete auctions[_auctionId];
            delete auctionByTokenId[owner][i];
        }else{
            auctions[_auctionId].salesCount = auctions[_auctionId].salesCount.sub(_count);
        }

        emit AuctionSuccessful(_auctionId,seller, price, msg.sender,_count,now,eType);
    }

    function getAuctions() external view returns (uint256,uint256[]) {
        uint256[] memory result = new uint256[](auctions.length);
        uint256 i;
        for(i=0;i<auctions.length;i++){
            result[i] = auctions[i].id;
        }
        return (auctions.length,result);
    }

    function getAuction(uint256 _id) external view returns (
        uint256 id,
        address seller,
        string name,
        uint256 price,
        uint256 expiresAt,
        uint256 salesCount,
        uint8 eType
    ) {
        Auction storage auction = auctions[_id];
        id =auction.id;
        seller = auction.seller;
        name = auction.name;
        price = auction.price;
        expiresAt = auction.expiresAt;
        salesCount = auction.salesCount;
        eType = auction.eType;
    }
    function getAuctionByType(uint8 _eType) view external returns (uint256) {
        return _getAuctionByType(_eType,msg.sender);
    }
    function withdrawBalance(uint256 amount) external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance > amount) {
            owner.transfer(amount);
        }
    }
}
contract EggAuctionCore is EggAuction{

    constructor(address _acceptedToken, address _nonFungibleRegistry) public {
        acceptedToken = ERC20Interface(_acceptedToken);
        nonFungibleRegistry = ERC721Interface(_nonFungibleRegistry);
    }

    event ExchangeCreated(
        uint256 id,
        address indexed from,
        address indexed to,
        uint256 priceInWei,
        uint256 time,
        uint256 count,
        uint8 eType);

    function exchangeEggToDDC(uint256 _auctionId,uint256 _count,uint8 _eType,uint8 _level) public whenNotPaused {
        uint256 eggCount = _getEggCount(msg.sender,_eType);
        require(eggCount > _count);
        uint256 auctionCount = _getAuctionByType(_eType,msg.sender);
        require(_count.add(auctionCount) <= eggCount );
        require(acceptedToken.transferFrom(
                owner,
                msg.sender,
                publicationFeeInWei.mul(_count)
            ));

        require(_transferEggMk(msg.sender,owner,_count,_eType,_level));
        emit ExchangeCreated(_auctionId,msg.sender,owner,publicationFeeInWei.mul(_count),now,_count,_eType);
    }

    function exchangeDDCToEgg(uint256 _count,uint8 _eType,uint8 _level) public whenNotPaused {
        require(_count > 0);
        require(_eType >= 0 && _eType<=20);
        uint256 eggCount = _getEggCount(msg.sender,_eType);
        require(eggCount > _count);
        require(acceptedToken.balanceOf(msg.sender) >= _count);

        require(acceptedToken.transferFrom(
                msg.sender,
                owner,
                publicationFeeInWei.mul(_count)
            ));
        require(_transferEggMk(msg.sender,owner,_count,_eType,_level));

        emit ExchangeCreated(0,owner,msg.sender,publicationFeeInWei.mul(_count),now,_count,_eType);
    }

}

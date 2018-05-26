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
//721接口
contract ERC721 {
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) public view returns (address owner);
    function approve(address _to, uint256 _tokenId) public;
    function transfer(address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
    function allowance(address _owner,uint256 _tokenId) public view returns (bool);

    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);
    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);
}
// @title:管理特殊访问权限的CardAccessControl的一个方面。
contract CardAccessControl {
    address public ceoAddress;
    address public cfoAddress;
    bool public paused = false;

    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }
    modifier onlyCLevel() {
        require(msg.sender == ceoAddress || msg.sender == cfoAddress);
        _;
    }
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));
        ceoAddress = _newCEO;
    }
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));
        cfoAddress = _newCFO;
    }
    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    modifier whenPaused {
        require(paused);
        _;
    }
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }
    function unpause() public onlyCEO whenPaused {
        paused = false;
    }
}

//对象基础
contract CardBase is CardAccessControl{
    using SafeMath for uint256;
    using SafeMath for uint64;
    using SafeMath for uint16;
    using SafeMath for uint8;
    event CreatedCard(address owner, uint256 cardId,uint256 eType,uint256 attrId,uint256 time, uint16 coolIndex, uint8 level);
    event Transfer(address from, address to, uint256 tokenId);

    struct Card {
        uint256 time;
        uint256 cardId;
        uint256 eType;
        uint256 attrId;
        uint16 coolIndex;
        uint16 siringWithId;
        uint8 level;
    }

    uint256 public secondsPerBlock = 15;
    Card[] cards;
    mapping (uint256 => address) public cardIndexToOwner;
    mapping (address => uint256) ownershipTokenCount;

    mapping (uint256 => address) public cardSalesToApproved;

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownershipTokenCount[_to] = ownershipTokenCount[_to].add(1);
        cardIndexToOwner[_tokenId] = _to;
        if (_from != address(0)) {
            ownershipTokenCount[_from] = ownershipTokenCount[_from].sub(1);
        }
        emit Transfer(_from, _to, _tokenId);
    }
    //create card
    function _createCard(uint256 _eType,uint256 _attrId,uint8 _level,address _owner) internal returns (uint){
        require(_level == uint256(uint8(_level)));
        require(_eType == uint256(_eType));
        require(_attrId == uint256(_attrId));

        uint256 newCardId = cards.length;
        Card memory _card = Card({
            time: uint64(now),
            cardId: newCardId,
            eType: _eType,
            attrId: _attrId,
            coolIndex: 0,
            siringWithId: 0,
            level: _level
            });
        cards.push(_card);
        emit CreatedCard(_owner,newCardId,_card.eType, _card.attrId,_card.time,uint16(_card.coolIndex),uint8(_card.level));
        _transfer(0, _owner, newCardId);
        return newCardId;
    }
    function setSecondsBlock(uint256 secs) external onlyCLevel {
        require(secs < uint32(10 minutes));
        secondsPerBlock = secs;
    }
}
//721共有方法
contract CardOwnership is CardBase, ERC721 {
    event ContractUpgrade(address newContract);
    string public constant name = "Card's War";
    string public constant symbol = "EGW";

    bytes4 constant InterfaceSignature_ERC721 =
    bytes4(keccak256('name()')) ^
    bytes4(keccak256('symbol()')) ^
    bytes4(keccak256('totalSupply()')) ^
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('ownerOf(uint256)')) ^
    bytes4(keccak256('approve(address,uint256)')) ^
    bytes4(keccak256('transfer(address,uint256)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('tokensOfOwner(address)'));

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return cardIndexToOwner[_tokenId] == _claimant;
    }
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return cardSalesToApproved[_tokenId] == _claimant;
    }
    function _approve(uint256 _tokenId, address _approved) internal {
        cardSalesToApproved[_tokenId] = _approved;
    }
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }
    function transfer( address _to, uint256 _tokenId) public whenNotPaused {
        require(_to != address(0));
        require(_to != address(this));
        require(_owns(msg.sender, _tokenId));
        _transfer(msg.sender, _to, _tokenId);
    }
    function allowance(address _claimant,uint256 _tokenId) public view returns (bool){
        return cardSalesToApproved[_tokenId] == _claimant;
    }
    function approve(address _to,uint256 _tokenId) public whenNotPaused{
        require(_owns(msg.sender, _tokenId));
        _approve(_tokenId, _to);
        emit Approval(msg.sender, _to, _tokenId);
    }
    function safeTransferFrom( address _from, address _to, uint256 _tokenId) public whenNotPaused{
        require(_to != address(0));
        require(_to != address(this));
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));
        _transfer(_from, _to, _tokenId);
    }
    function totalSupply() public view returns (uint) {
        return cards.length.sub(1);
    }
    function ownerOf(uint256 _tokenId) public view returns (address owner){
        owner = cardIndexToOwner[_tokenId];
        require(owner != address(0));
    }
    function tokensOfOwner(address _owner) public view returns(uint256[] ownerTokens) {
        uint tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalCards = totalSupply();
            uint256 resultIndex = 0;
            uint256 cardId;
            for (cardId = 1; cardId <=totalCards; cardId++) {
                if (cardIndexToOwner[cardId] == _owner) {
                    result[resultIndex] = cardId;
                    resultIndex++;
                }
            }
            return result;
        }
    }
}

contract CardCore is CardOwnership {
    address public newContractAddress;
    uint256 public constant CREATION_LIMIT = 50000;
    uint256 public createdCount;

    constructor (address _cfoAddress) public {
        paused = false;
        ceoAddress = msg.sender;
        cfoAddress = _cfoAddress;
    }
    function setNewAddress(address _newAddress) external onlyCEO whenPaused {
        newContractAddress = _newAddress;
        emit ContractUpgrade(_newAddress);
    }

    function createInitCard( address _owner) external onlyCEO {
        address cardOwner = _owner;
        if (cardOwner == address(0)) {
            cardOwner = ceoAddress;
        }
        require(createdCount < CREATION_LIMIT);
        createdCount++;
        _createCard(0, 0,0,cardOwner);
    }
    function createCard(uint256 _eType,uint256 _attrId,uint8 _level, address _owner) external onlyCEO {
        address cardOwner = _owner;
        if (cardOwner == address(0)) {
            cardOwner = ceoAddress;
        }
        _createCard(_eType,_attrId,_level,cardOwner);
    }
    function unpause() public onlyCEO whenPaused {
        require(newContractAddress == address(0));
        super.unpause();
    }
    function getCardIndex() external view returns (uint256,uint256[]){
        uint256[] memory result = new uint256[](cards.length);
        uint256 i;
        for(i=0;i<cards.length;i++){
            result[i] = cards[i].cardId;
        }
        return (cards.length,result);
    }
    function getCard(uint256 _id) external view returns (
        uint256 time,
        uint256 cardId,
        uint256 coolIndex,
        uint256 siringWithId,
        uint256 level,
        uint256 eType,
        uint256 attrId
    ) {
        Card storage card = cards[_id];
        coolIndex = uint256(card.coolIndex);
        time = uint256(card.time);
        eType = uint256(card.eType);
        level = uint256(card.level);
        siringWithId = uint256(card.siringWithId);
        cardId = uint256(card.cardId);
        attrId = uint256(card.attrId);
    }
}
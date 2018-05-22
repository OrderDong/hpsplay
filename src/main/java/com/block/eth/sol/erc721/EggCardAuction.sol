pragma solidity 0.4.23;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
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
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
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
}
contract ERC721Interface {
    function ownerOf(uint256 tokenId) public view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
}

contract EggCardMarket is Ownable, Pausable {
    using SafeMath for uint256;

    ERC20Interface public acceptedToken;
    ERC721Interface public nonRegistry;

    struct CardAuction {
        uint256 id;
        address seller;
        uint256 price;
        uint256 expiresAt;
        uint256 time;
        uint256 tokenId;
    }
    uint256[] auctionIndexs;
    mapping (uint256 => CardAuction) public auctionByTokenId;
    mapping (address => uint256) ownershipAuctionCount;

    uint256 public ownerCutFee;
    uint256 public feeInWei;

    /* EVENTS */
    event CardAuctionCreated(
        uint256 id,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 priceInWei,
        uint256 expiresAt,
        uint256 time
    );
    event CardAuctionSuccessful(
        uint256 id,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 totalPrice,
        address indexed buyer,
        uint256 time
    );
    event CardAuctionCancelled(
        uint256 id,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 time
    );

    event ChangedFee(uint256 publicationFee);
    event ChangedOwnerCut(uint256 ownerCut);

    constructor(address _acceptedToken, address _nonRegistry) public {
        acceptedToken = ERC20Interface(_acceptedToken);
        nonRegistry = ERC721Interface(_nonRegistry);
    }
    function setPublicationFee(uint256 _feeInWei) onlyOwner public {
        feeInWei = _feeInWei;
        emit ChangedFee(feeInWei);
    }
    function setOwnerCut(uint8 _ownerCutFee) onlyOwner public {
        require(_ownerCutFee < 100);
        ownerCutFee = _ownerCutFee;
        emit ChangedOwnerCut(ownerCutFee);
    }
    function _getAuctionIndexByToken(uint256 _tokenId) internal view returns (uint256){
        uint256 i;
        for(i=0; i<auctionIndexs.length; i++){
            if(auctionIndexs[i] == _tokenId){
                break;
            }
        }
        return i;
    }
    function createCardAuction(uint256 tokenId, uint256 priceInWei, uint256 expiresAt) public whenNotPaused {
        require(msg.sender == nonRegistry.ownerOf(tokenId));
        require(priceInWei > 0);
        // require(expiresAt > now.add(1 minutes));
        uint256 auctionId = uint256(keccak256(
                block.timestamp,
                msg.sender,
                tokenId,
                priceInWei
            ));
        auctionByTokenId[tokenId] = CardAuction({
            id: auctionId,
            seller: msg.sender,
            price: priceInWei,
            expiresAt: expiresAt,
            time: now,
            tokenId: tokenId
            });
        /*if (feeInWei > 0) {
            require(acceptedToken.transferFrom(
                    msg.sender,
                    owner,
                    feeInWei
                ));
        }*/
        ownershipAuctionCount[msg.sender] = ownershipAuctionCount[msg.sender].add(1);
        auctionIndexs.push(tokenId);
        emit CardAuctionCreated(
            auctionId,
            tokenId,
            msg.sender,
            priceInWei,
            expiresAt,
            now
        );
    }

    function cancelCardAuction(uint256 tokenId) public whenNotPaused {
        require(auctionByTokenId[tokenId].seller == msg.sender || msg.sender == owner);
        uint256 auctionId = auctionByTokenId[tokenId].id;
        address auctionSeller = auctionByTokenId[tokenId].seller;
        delete auctionByTokenId[tokenId];
        ownershipAuctionCount[msg.sender] = ownershipAuctionCount[msg.sender].sub(1);
        uint256 index = _getAuctionIndexByToken(tokenId);
        auctionIndexs[index] = auctionIndexs[auctionIndexs.length.sub(1)];
        delete auctionIndexs[auctionIndexs.length.sub(1)];
        emit CardAuctionCancelled(auctionId, tokenId, auctionSeller,now);
    }

    function executeCardAuction(uint256 tokenId, uint256 price) public payable whenNotPaused {
        address seller = auctionByTokenId[tokenId].seller;

        //require(seller != address(0));
        //require(seller != msg.sender);
        //require(auctionByTokenId[tokenId].price == price);
        //require(now < auctionByTokenId[tokenId].expiresAt);

        require(seller == nonRegistry.ownerOf(tokenId));

        uint saleShareAmount = 0;

        /*if (ownerCutFee > 0) {
            saleShareAmount = price.mul(ownerCutFee).div(100);
            acceptedToken.transferFrom(
                msg.sender,
                owner,
                saleShareAmount
            );
        }*/

        // Transfer sale amount to seller
        acceptedToken.transferFrom(
            msg.sender,
            seller,
            price.sub(saleShareAmount)
        );
        // Transfer asset owner
        nonRegistry.safeTransferFrom(
            seller,
            msg.sender,
            tokenId
        );
        uint256 auctionId = auctionByTokenId[tokenId].id;
        delete auctionByTokenId[tokenId];
        ownershipAuctionCount[msg.sender] = ownershipAuctionCount[msg.sender].sub(1);
        uint256 index = _getAuctionIndexByToken(tokenId);
        auctionIndexs[index] = auctionIndexs[auctionIndexs.length.sub(1)];
        delete auctionIndexs[auctionIndexs.length.sub(1)];
        emit CardAuctionSuccessful(auctionId, tokenId, seller, price, msg.sender,now);
    }
    function countAuctionOf(address _owner) public view returns (uint256 count) {
        return ownershipAuctionCount[_owner];
    }

    function auctionOfOwner(address _owner) public view returns(uint256[]){
        uint auctionCount = countAuctionOf(_owner);
        if (auctionCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](auctionCount);
            uint256 i;
            uint256 resultIndex=0;
            for (i = 0; i < auctionIndexs.length; i++) {
                if (auctionByTokenId[auctionIndexs[i]].seller == _owner) {
                    result[resultIndex] = auctionIndexs[i];
                    resultIndex ++;
                }
            }
            return result;
        }
    }
    function getCardAuction(uint256 _tokenId) public view returns (
        uint256 id,
        address seller,
        uint256 price,
        uint256 expiresAt,
        uint256 time
    ){
        CardAuction memory auc =  auctionByTokenId[_tokenId];
        id = auc.id;
        seller = auc.seller;
        price = auc.price;
        expiresAt = auc.expiresAt;
        time = auc.time;
    }
    function getAuctionIndex() public view returns (uint256,uint256[]){
        return (auctionIndexs.length,auctionIndexs);
    }
}
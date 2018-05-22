pragma solidity ^0.4.20;

contract ERC721 {
    // Required methods
    function totalSupply() public returns (uint256 total);
    function balanceOf(address _owner) public returns (uint256 balance);
    function ownerOf(uint256 _tokenId) public returns (address owner);
    function approve(address _to, uint256 _tokenId) public;
    function transfer(address _to, uint256 _tokenId) public;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) public returns (bool);
}

contract MyLwdSenPlay1 is ERC721 {
  /*** CONSTANTS ***/

  string public constant name = "MyLwdSenPlay1";
  string public constant symbol = "MLSP1";

  bytes4 constant InterfaceID_ERC165 =
    bytes4(keccak256('supportsInterface(bytes4)'));

  bytes4 constant InterfaceID_ERC721 =
    bytes4(keccak256('name()')) ^
    bytes4(keccak256('symbol()')) ^
    bytes4(keccak256('totalSupply()')) ^
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('ownerOf(uint256)')) ^
    bytes4(keccak256('approve(address,uint256)')) ^
    bytes4(keccak256('transfer(address,uint256)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('tokensOfOwner(address)'));


  /*** DATA TYPES ***/

  struct Token {
    address mintedBy;
    uint64 mintedAt;
    uint mintColor;
  }


  /*** STORAGE ***/

  Token[] tokens;
  //个人拥有toker值
  mapping (uint256 => address) public tokenIndexToOwner;
  //个人拥有token数量
  mapping (address => uint256) ownershipTokenCount;
  //已通过token
  mapping (uint256 => address) public tokenIndexToApproved;


  /*** EVENTS
  event Mint(address owner, uint256 tokenId);
    ***/
  /*** INTERNAL FUNCTIONS ***/

  function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
    return tokenIndexToOwner[_tokenId] == _claimant;
  }

  function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
    return tokenIndexToApproved[_tokenId] == _claimant;
  }

  function _approve(address _to, uint256 _tokenId) internal {
    tokenIndexToApproved[_tokenId] = _to;

    Approval(tokenIndexToOwner[_tokenId], tokenIndexToApproved[_tokenId], _tokenId);
  }

  function _transfer(address _from, address _to, uint256 _tokenId) internal {
    ownershipTokenCount[_to]++;
    tokenIndexToOwner[_tokenId] = _to;

    if (_from != address(0)) {
      ownershipTokenCount[_from]--;
      delete tokenIndexToApproved[_tokenId];
    }

    Transfer(_from, _to, _tokenId);
  }

  function _mint(address _owner) internal returns (uint256 tokenId) {
    uint randNonce = 0;
    uint _random = uint(keccak256(now, msg.sender, randNonce)) % 10;
    Token memory token = Token({
      mintedBy: _owner,
      mintedAt: uint64(now),
      mintColor: _random
    });
    tokens.push(token);
    tokenId = tokens.length -1;
   // Mint(_owner, tokenId);
    _transfer(0, _owner, tokenId);
  }


  /*** ERC721 IMPLEMENTATION ***/

  function supportsInterface(bytes4 _interfaceID) public returns (bool) {
    return ((_interfaceID == InterfaceID_ERC165) || (_interfaceID == InterfaceID_ERC721));
  }

  function totalSupply() public returns (uint256) {
    return tokens.length;
  }

  function balanceOf(address _owner) public returns (uint256) {
    return ownershipTokenCount[_owner];
  }

  function ownerOf(uint256 _tokenId) public returns (address owner) {
    owner = tokenIndexToOwner[_tokenId];

    require(owner != address(0));
  }

  function approve(address _to, uint256 _tokenId) public {
    require(_owns(msg.sender, _tokenId));

    _approve(_to, _tokenId);
  }

  function transfer(address _to, uint256 _tokenId) public {
    require(_to != address(0));
    require(_to != address(this));
    require(_owns(msg.sender, _tokenId));

    _transfer(msg.sender, _to, _tokenId);
  }
  /**执行token转移**/
  function transferFrom(address _from, address _to, uint256 _tokenId) public {
    require(_to != address(0));
    require(_to != address(this));
    require(_approvedFor(msg.sender, _tokenId));
    require(_owns(_from, _tokenId));

    _transfer(_from, _to, _tokenId);
  }
  /**查询个人拥有token**/
  function tokensOfOwner(address _owner) public returns (uint256[]) {
    uint256 balance = balanceOf(_owner);

    if (balance == 0) {
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](balance);
      uint256 maxTokenId = totalSupply();
      uint256 idx = 0;

      uint256 tokenId;
      for (tokenId = 1; tokenId <= maxTokenId; tokenId++) {
        if (tokenIndexToOwner[tokenId] == _owner) {
          result[idx] = tokenId;
          idx++;
        }
      }
    }

    return result;
  }


  /*** OTHER EXTERNAL FUNCTIONS ***/

  function createToken() public returns (uint256) {
    return _mint(msg.sender);
  }
  /**获取token属性**/
  function getToken(uint256 _tokenId) public view returns (address mintedBy, uint64 mintedAt,uint mintColor) {
    Token memory token = tokens[_tokenId];

    mintedBy = token.mintedBy;
    mintedAt = token.mintedAt;
    mintColor = token.mintColor;
  }
}

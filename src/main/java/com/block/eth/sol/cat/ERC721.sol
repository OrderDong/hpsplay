pragma solidity ^0.4.20;

contract ERC721 {
    // Required methods
    // 返回所有非同质代币的数量
    function totalSupply() public view returns (uint256 total);
    // 返回_owner的非同质代币的数量
    function balanceOf(address _owner) public view returns (uint256 balance);
    // 返回_tokenId非同质代币的拥有者的地址
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    // 将_tokenId非同质代币授权给地址_to的拥有者
    // approve()方法的目的是可以授权第三人来代替自己执行交易
    function approve(address _to, uint256 _tokenId) external;
    // 将_tokenId非同质代币转移给地址为_to的拥有者
    function transfer(address _to, uint256 _tokenId) external;
    // 从_from拥有者转移_tokenId非同质代币给_to新的拥有者
    // 内部调用transfer方法进行转移
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    // 两个事件来分别记录转移和授权
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    // 可选实现的接口：
    // 返回合约的名字
    // function name() public view returns (string name);
    // 返回合约代币的符号
    // function symbol() public view returns (string symbol);
    // 返回_owner所有的非同质代币的id
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // 返回非同质代币的元数据
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    // ERC721标准要求必须同时符合ERC165标准
    // 方法用来验证这个合约是否实现了特定的接口。
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

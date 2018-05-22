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
contract testTran{

    using SafeMath for uint256;
    using SafeMath for uint8;

    event EggMkCreated(uint8 _level,uint8 _eType,uint256 _count,address indexed _owner);
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
                if(eggs[i].eType == _eType){
                    eggs[i].mkCount = eggs[i].mkCount.add(_count);
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
    function createInitEggMk( address _owner) external {
        _createEggMk(0, 0,100,_owner);
    }
    function updateEggMk() external {
        eggs[0].mkCount = eggs[0].mkCount.add(10);
    }
    function getMkCount() view external returns (uint256){
        return eggs[0].mkCount;
    }
    function getArrIndex(address _owner) view external returns (uint256[]){
        return mappEggMk[_owner];
    }
}
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
contract ERC20Base {
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Ownable {
    address public owner;

    constructor() public{
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

contract Pausable is Ownable {
    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }
    modifier whenPaused {
        require(paused);
        _;
    }
    function pause() public onlyOwner whenNotPaused returns (bool) {
        paused = true;
        return true;
    }
    function unpause() public onlyOwner whenPaused returns (bool) {
        paused = false;
        return true;
    }
}

contract StandardCoin is ERC20Base,Pausable {
    using SafeMath for uint256;

    uint256 _totalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    function totalSupply() public view returns (uint256 total) {
        total = _totalSupply;
        return total;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        if (balances[msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] = balances[msg.sender].sub(_amount);
            balances[_to] = balances[_to].add(_amount);
            emit Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from,address _to,uint256 _amount) public returns (bool success) {
        if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {
            balances[_from] = balances[_from].sub(_amount);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
            balances[_to] = balances[_to].add(_amount);
            emit Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract ModifyToken is StandardCoin {
    event Modify(address indexed to, uint256 amount);
    event ModifyFinished();
    bool public modifyFinished = false;
    modifier canModify() {
        require(!modifyFinished);
        _;
    }

    function modify(address _to, uint256 _amount) public onlyOwner canModify returns (bool) {
        _totalSupply = _totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Modify(_to, _amount);
        return true;
    }

    function finishModifying() public onlyOwner returns (bool) {
        modifyFinished = true;
        emit ModifyFinished();
        return true;
    }
}

contract DanDanCoin is ModifyToken {
    string public constant symbol = "DDC1";
    string public constant name = "DAN DAN Coin 1";
    uint8 public constant decimals = 18;
    //initial supply
    uint256 public constant INIT_SUPPLY = 10000000000;

    constructor() public {
        owner = msg.sender;
        _totalSupply = INIT_SUPPLY * (10 ** uint256(decimals));
        balances[owner] = _totalSupply;
    }
}
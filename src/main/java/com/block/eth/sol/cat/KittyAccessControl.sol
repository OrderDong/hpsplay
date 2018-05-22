pragma solidity ^0.4.20;

/// @title:管理特殊访问权限的KittyCore的一个方面。
// @author Axiom Zen (https://www.axiomzen.co)
/// @dev查看KittyCore合同文档，了解如何安排各种合同方面。
contract KittyAccessControl {
    // This facet controls access control for CryptoKitties. There are four roles managed here:
    //     - The CEO: The CEO can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract. It is initially
    //         set to the address that created the smart contract in the KittyCore constructor.
    //     - The CFO: The CFO can withdraw funds from KittyCore and its auction contracts.
    //     - The COO: The COO can release gen0 kitties to auction, and mint promo cats.
    // It should be noted that these roles are distinct without overlap in their access abilities, the
    // abilities listed for each role above are exhaustive. In particular, while the CEO can assign any
    // address to any role, the CEO address itself doesn't have the ability to act in those roles. This
    // restriction is intentional so that we aren't tempted to use the CEO address frequently out of
    // convenience. The less we use an address, the less likely it is that we somehow compromise the
    // account.
    //这个facet控制着密码机的访问控制。这里有四个角色:
    //首席执行官:首席执行官可以重新分配其他角色，并改变我们所依赖的智能的地址。
    //合同。它也是唯一能让聪明的合同中止的角色。它最初是
    //设置在KittyCore构造器中创建智能契约的地址。
    //首席财务官:首席财务官可以从KittyCore和它的拍卖合同中提取资金。
    // - COO: COO可以释放gen0 kitties来拍卖，还有mint promo cats。
    //应该注意的是，这些角色在访问能力上是不同的，没有重叠。
    //列出的每一个角色的能力是详尽的。特别是，CEO可以分配任何。
    //对任何职位的称呼，CEO的地址本身都没有能力扮演这些角色。这
    //限制是有意的，这样我们就不会经常使用CEO的地址。
    //方便。我们使用的地址越少，我们在某种程度上妥协的可能性就越小。
    //帐户。

    /// @dev Emited when contract is upgraded - See README.md for updgrade plan
    event ContractUpgrade(address newContract);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    //跟踪合同是否暂停。当这是true的时，大多数动作都会被阻塞
    bool public paused = false;

    /// @dev Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }
    /// @dev Access modifier for CFO-only functionality
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }
    /// @dev Access modifier for COO-only functionality
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }
    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }
    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO The address of the new CFO
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

    /*** Pausable functionality adapted from OpenZeppelin ***/

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused {
        require(paused);
        _;
    }

    /// @dev Called by any "C-level" role to pause the contract. Used only when
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function unpause() public onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}
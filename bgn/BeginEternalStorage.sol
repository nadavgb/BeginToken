pragma solidity 0.5.7;

import "../ownership/Ownable.sol";
import "../zeppelin/math/SafeMath.sol";

/**
 * @title Eternal Storage for the Begin Token
 *
 * @dev Eternal Storage facilitates future upgrades.
 *
 * If Begin chooses to release an upgraded contract for the Begin in the future, Begin will
 * have the option of reusing the deployed version of this data contract to simplify migration.
 *
 * The use of this contract does not imply that Begin will choose to do a future upgrade, nor
 * that any future upgrades will necessarily re-use this storage. It merely provides option value.
 */
contract BeginEternalStorage is Ownable {

    using SafeMath for uint256;


    // ===== auth =====

    address public BeginAddress;

    event BeginAddressTransferred(
        address indexed oldBeginAddress,
        address indexed newBeginAddress
    );

    /// On construction, set auth fields.
    constructor() public {
        BeginAddress = _msgSender();
        emit BeginAddressTransferred(address(0), BeginAddress);
    }

    /// Only run modified function if sent by `BeginAddress`.
    modifier onlyBeginAddress() {
        require(_msgSender() == BeginAddress, "onlyBeginAddress");
        _;
    }

    /// Set `BeginAddress`.
    function updateBeginAddress(address newBeginAddress) external {
        require(newBeginAddress != address(0), "zero address");
        require(_msgSender() == BeginAddress || _msgSender() == owner(), "not authorized");
        emit BeginAddressTransferred(BeginAddress, newBeginAddress);
        BeginAddress = newBeginAddress;
    }



    // ===== balance =====

    mapping(address => uint256) public balance;

    /// Add `value` to `balance[key]`, unless this causes integer overflow.
    ///
    /// @dev This is a slight divergence from the strict Eternal Storage pattern, but it reduces
    /// the gas for the by-far most common token usage, it's a *very simple* divergence, and
    /// `setBalance` is available anyway.
    function addBalance(address key, uint256 value) external onlyBeginAddress {
        balance[key] = balance[key].add(value);
    }

    /// Subtract `value` from `balance[key]`, unless this causes integer underflow.
    function subBalance(address key, uint256 value) external onlyBeginAddress {
        balance[key] = balance[key].sub(value);
    }

    /// Set `balance[key]` to `value`.
    function setBalance(address key, uint256 value) external onlyBeginAddress {
        balance[key] = value;
    }



    // ===== allowed =====

    mapping(address => mapping(address => uint256)) public allowed;

    /// Set `to`'s allowance of `from`'s tokens to `value`.
    function setAllowed(address from, address to, uint256 value) external onlyBeginAddress {
        allowed[from][to] = value;
    }
}
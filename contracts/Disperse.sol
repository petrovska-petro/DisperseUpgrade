// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "deps/IERC20Upgradeable.sol";
import "deps/SafeERC20Upgradeable.sol";
import "deps/AddressUpgradeable.sol";
import "deps/SafeMathUpgradeable.sol";
import "deps/Initializable.sol";

import "interfaces/defidollar/ICore.sol";

contract Disperse is Initializable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    event PayeeAdded(address account, uint256 shares);
    event PayeeRemoved(address account);
    event PaymentReleased(address token, address to, uint256 amount);

    address public constant core = 0x2A8facc9D49fBc3ecFf569847833C380A13418a8;
    address public constant ibbtc = 0xc4E15973E6fF2A35cC804c2CF9D2a1b817a8b40F;
    /// @dev address was added post-upgrade to enable add/remove of payees permissioned
    address public constant governance =
        0xCF7346A5E41b0821b80D5B3fdc385EEB6Dc59F44;

    uint256 private _totalShares;

    mapping(address => uint256) private _shares;
    address[] private _payees;
    mapping(address => bool) private _isPayee;

    /**
     * @dev Creates an instance of `PaymentSplitter` where each account in `payees` is assigned the number of shares at
     * the matching position in the `shares` array.
     *
     * All addresses in `payees` must be non-zero. Both arrays must have the same non-zero length, and there must be no
     * duplicates in `payees`.
     */
    function initialize(address[] memory payees, uint256[] memory shares)
        public
        initializer
    {
        // solhint-disable-next-line max-line-length
        require(
            payees.length == shares.length,
            "PaymentSplitter: payees and shares length mismatch"
        );
        require(payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < payees.length; i++) {
            _addPayee(payees[i], shares[i]);
        }
    }

    /**
     * @dev Getter for the total shares held by payees.
     */
    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    /**
     * @dev Getter for the amount of shares held by an account.
     */
    function shares(address account) public view returns (uint256) {
        return _shares[account];
    }

    function payees() public view returns (address[] memory) {
        return _payees;
    }

    function isPayee(address account) public view returns (bool) {
        return _isPayee[account];
    }

    /// @dev Disperse balance of a given token in contract among recipients
    function disperseToken(IERC20Upgradeable token) external {
        // If dispersing IBBTC, collect the fee first
        if (address(token) == ibbtc) {
            ICore(core).collectFee();
        }

        require(_isPayee[msg.sender], "onlyPayees");
        uint256 tokenBalance = token.balanceOf(address(this));

        for (uint256 i = 0; i < _payees.length; i++) {
            address payee = _payees[i];
            uint256 toPayee = tokenBalance.mul(_shares[payee]).div(
                _totalShares
            );
            token.safeTransfer(payee, toPayee);
            emit PaymentReleased(address(token), payee, toPayee);
        }
    }

    /**
     * @dev Add a new payee to the contract.
     * @param account The address of the payee to add.
     * @param shares_ The number of shares owned by the payee.
     */
    function _addPayee(address account, uint256 shares_) private {
        require(
            account != address(0),
            "PaymentSplitter: account is the zero address"
        );
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(
            _shares[account] == 0,
            "PaymentSplitter: account already has shares"
        );

        _payees.push(account);
        _isPayee[account] = true;
        _shares[account] = shares_;
        _totalShares = _totalShares.add(shares_);
        emit PayeeAdded(account, shares_);
    }

    function addPayee(address account, uint256 shares) external {
        require(msg.sender == governance, "PaymentSplitter: not governance");
        _addPayee(account, shares);
    }

    function removePayee(address account, uint256 index) external {
        require(msg.sender == governance, "PaymentSplitter: not governance");
        require(
            _shares[account] != 0,
            "PaymentSplitter: account has not shares"
        );
        require(
            account == _payees[index],
            "PaymentSplitter: account to remove not matching"
        );

        uint256 accountShare = _shares[account];

        _payees[index] = _payees[_payees.length - 1];
        _payees.pop();

        delete _isPayee[account];
        delete _shares[account];

        _totalShares = _totalShares.sub(accountShare);
        emit PayeeRemoved(account);
    }
}

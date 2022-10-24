// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IDisperse {
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address token, address to, uint256 amount);

    function core() external view returns (address);

    function disperseToken(address token) external;

    function ibbtc() external view returns (address);

    function initialize(address[] memory payees, uint256[] memory shares)
        external;

    function isPayee(address account) external view returns (bool);

    function payees() external view returns (address[] memory);

    function shares(address account) external view returns (uint256);

    function totalShares() external view returns (uint256);

    function governance() external view returns (address);

    function addPayee(address account, uint256 shares) external;

    function removePayee(address account, uint256 index) external;
}

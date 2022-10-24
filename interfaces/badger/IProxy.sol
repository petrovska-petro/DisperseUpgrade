// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IProxy {
    event AdminChanged(address previousAdmin, address newAdmin);
    event Upgraded(address indexed implementation);

    fallback() external payable;

    function admin() external returns (address);

    function changeAdmin(address newAdmin) external;

    function implementation() external returns (address);

    function upgradeTo(address newImplementation) external;

    function upgradeToAndCall(address newImplementation, bytes memory data)
        external
        payable;

    receive() external payable;
}

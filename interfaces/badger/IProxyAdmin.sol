// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IProxyAdmin {
    function upgrade(address proxy, address implementation) external;

    function changeProxyAdmin(address proxy, address newAdmin) external;

    function owner() external view returns (address);
}

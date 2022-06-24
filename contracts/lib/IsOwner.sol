// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

abstract contract IsOwner {
  function isOwner() internal view virtual returns (bool);
}
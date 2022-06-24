// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts/security/Pausable.sol";
import "./IsOwner.sol";

abstract contract Pause is Pausable, IsOwner {

  function pause() external{
    require(isOwner(), "Pause: Only the owner can pause");
    _pause();
  }
  function unpause() external {
    require(isOwner(), "Pause: Only the owner can unpause");
    _unpause();
  }
}
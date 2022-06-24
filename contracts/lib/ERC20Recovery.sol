// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "./IsOwner.sol";

interface IERC20Recovery {
  function balanceOf(address) external view returns(uint256);
  function safeTransfer(address, uint256) external;
}

abstract contract ERC20Recovery is IsOwner {

    function recoverERC20(address _tokenAddress, address _receiver) external {
        require(isOwner(), "ERC20Recovery: Only the owner can recover ERC20");
        uint256 amount = IERC20Recovery(_tokenAddress).balanceOf(address(this));
        IERC20Recovery(_tokenAddress).safeTransfer(_receiver, amount);

        emit ERC20RecoveryTransfer(
            _tokenAddress,
            msg.sender,
            _receiver,
            amount
        );
    }

    event ERC20RecoveryTransfer(
        address indexed token,
        address indexed sender,
        address indexed receiver,
        uint256 amount
    );
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "./IsOwner.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface IERC20Recovery {
  function balanceOf(address) external view returns(uint256);
  function safeTransfer(address, uint256) external;
}

abstract contract ERC20Recovery is IsOwner {

    using SafeERC20 for IERC20Recovery;

    function recoverERC20(address _tokenAddress, address _receiver) external {
        require(isOwner(), "ERC20Recovery: Only the owner can recover ERC20");
        
        IERC20Recovery token = IERC20Recovery(_tokenAddress);
        
        uint256 amount = token.balanceOf(address(this));
        token.safeTransfer(_receiver, amount);

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
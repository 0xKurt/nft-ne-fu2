// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract Init {
    bool public init;

    constructor(bool _init) {
        // set true if using a proxy
        init = _init;
    }

    modifier isNotInitialized() {
        require(!init, "Init: Contract already initialized");
        init = true;
        emit Initialized(msg.sender, true);
        _;
    }

    modifier isInitialized() {
        require(init, "Init: Contract not initialized");
        _;
    }

    event Initialized(address initializer, bool flag);
}
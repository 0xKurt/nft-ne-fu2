// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "./lib/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./lib/Pause.sol";
import "./lib/ERC20Recovery.sol";
import "./lib/Init.sol";

contract NFT is ERC721A, Ownable, Pause, ERC20Recovery, Init {
    mapping(address => bool) mintWhitelist;
    mapping(address => bool) giveawayWhitelist;
    mapping(address => uint256) mintedFree;
    uint256 public maxSupply;
    uint256 public preMintPrice;
    uint256 public pubMintPrice;
    uint256 public maxMintAmount; // max allowed to mint
    uint256 public freeMintAmount;
    uint256 public giveawayAmountPerUser;
    uint256 public preMintStart;
    uint256 public publicMintStart;
    uint256 public publicMintEnd;
    bool public revealed = false;
    string public notRevealedUri;
    string public baseURI;
    string public baseExtension = ".json";

    constructor() Init(false) {}

    function initialize(
        string memory _name,
        string memory _symbol,
        string memory _notRevealedUri,
        uint256 _maxMintAmount,
        uint256 _freeMintAmount,
        uint256 _giveawayAmountPerUser,
        uint256 _preMintPrice,
        uint256 _pubMintPrice,
        uint256 _maxSupply,
        uint256 _preMintStart,
        uint256 _publicMintStart,
        uint256 _publicMintEnd
    ) external onlyOwner isNotInitialized {
        __ERC721A_Init(_name, _symbol);
        notRevealedUri = _notRevealedUri;
        maxMintAmount = _maxMintAmount;
        preMintPrice = _preMintPrice;
        pubMintPrice = _pubMintPrice;
        maxSupply = _maxSupply;
        freeMintAmount = _freeMintAmount;
        giveawayAmountPerUser = _giveawayAmountPerUser;
        preMintStart = _preMintStart;
        publicMintStart = _publicMintStart;
        publicMintEnd = _publicMintEnd;
    }

    // ================== modifier ==================

    modifier mintActive() {
        require(
            block.timestamp >= preMintStart ||
                block.timestamp >= publicMintStart,
            "Minting is not active yet"
        );
        require(block.timestamp <= publicMintEnd, "Minting ended");
        _;
    }

    // ================== public functions ==================

    function mint(address _to, uint256 _amount)
        external
        payable
        whenNotPaused
        isInitialized
        mintActive
    {
        require(
            _amount > 0 && _amount <= maxMintAmount,
            "Invalid mint amount!"
        );
        require(totalSupply() + _amount <= maxSupply, "Max supply exceeded!");
        require(
            balanceOf(msg.sender) + _amount <= maxMintAmount,
            "Max mint per wallet exceeded!"
        );

        if (block.timestamp <= publicMintStart)
            require(mintWhitelist[msg.sender], "Sender not whitelisted");

        uint256 amountToPay;
        bool isPreMint = block.timestamp >= preMintStart &&
            block.timestamp <= publicMintStart;

        amountToPay = _amount * (isPreMint ? preMintPrice : pubMintPrice);

        require(
            msg.value >= amountToPay || msg.sender == owner(),
            "Not enough ETH to pay for minting"
        );

        _safeMint(_to, _amount);
    }

    function claim(uint256 _amount)
        external
        payable
        whenNotPaused
        isInitialized
    {
        require(
            block.timestamp >= preMintStart &&
                block.timestamp < publicMintStart,
            "Claiming is not active"
        );
        require(
            _amount > 0 && _amount <= freeMintAmount,
            "Invalid mint amount!"
        );
        require(totalSupply() + _amount <= maxSupply, "Max supply exceeded!");
        require(
            mintedFree[msg.sender] + _amount <= giveawayAmountPerUser,
            "Free mint per wallet exceeded!"
        );
        require(giveawayWhitelist[msg.sender], "Sender not whitelisted");

        freeMintAmount -= _amount;
        mintedFree[msg.sender] += _amount;

        _safeMint(msg.sender, _amount);
    }

    //todo: implement giveaway mint

    function mintOwner(address _to, uint256 _amount)
        external
        whenNotPaused
        isInitialized
        onlyOwner
    {
        require(_amount > 0, "Invalid mint amount!");
        require(totalSupply() + _amount <= maxSupply, "Max supply exceeded!");
        _safeMint(_to, _amount);
    }

    function burn(uint256 _tokenId) external {
        require(
            ownerOf(_tokenId) == msg.sender,
            "Sender is nor owner of this token"
        );
        _burn(_tokenId);
    }

    // ================== internal functions ==================

    function _setBaseURI(string memory _baseUri) internal {
        baseURI = _baseUri;
        emit BaseURIChanged(_baseUri);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // ================== view functions ==================

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return notRevealedUri;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        _toString(tokenId),
                        baseExtension
                    )
                )
                : "";
    }

    // ================== owner functions ==================

    function setFreeMintAmount(uint256 _freeMintAmount)
        external
        onlyOwner
        isNotInitialized
    {
        freeMintAmount = _freeMintAmount;
        emit FreeMintAmountChanged(_freeMintAmount);
    }

    function reveal(string memory _baseUri) external onlyOwner {
        _setBaseURI(_baseUri);
        setRevealed(true);
    }

    function setBaseURI(string memory _baseUri) external onlyOwner {
        _setBaseURI(_baseUri);
    }

    function addManyToMintWhitelist(address[] memory _addresses)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _addresses.length; i++) {
            addToMintWhitelist(_addresses[i]);
        }
    }

    function removeManyFromMintWhitelist(address[] memory _addresses)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _addresses.length; i++) {
            removeFromMintWhitelist(_addresses[i]);
        }
    }

    function addToMintWhitelist(address _toAdd) public onlyOwner {
        mintWhitelist[_toAdd] = true;
        emit AddedToMintWhitelist(_toAdd);
    }

    function removeFromMintWhitelist(address _toRemove) public onlyOwner {
        mintWhitelist[_toRemove] = false;
        emit RemovedFromMintWhitelist(_toRemove);
    }

    function isWhitelistedMint(address _toCheck) external view returns (bool) {
        return mintWhitelist[_toCheck];
    }

    function addManyToGiveawayWhitelist(address[] memory _addresses)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _addresses.length; i++) {
            addToGiveawayWhitelist(_addresses[i]);
        }
    }

    function removeManyFromGiveawayWhitelist(address[] memory _addresses)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _addresses.length; i++) {
            removeFromGiveawayWhitelist(_addresses[i]);
        }
    }

    function addToGiveawayWhitelist(address _toAdd) public onlyOwner {
        giveawayWhitelist[_toAdd] = true;
        emit AddedToGiveawayWhitelist(_toAdd);
    }

    function removeFromGiveawayWhitelist(address _toRemove) public onlyOwner {
        giveawayWhitelist[_toRemove] = false;
        emit RemovedFromGiveawayWhitelist(_toRemove);
    }

    function isWhitelistedGiveaway(address _toCheck)
        external
        view
        returns (bool)
    {
        return giveawayWhitelist[_toCheck];
    }

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        require(
            _maxSupply >= totalSupply(),
            "Max supply must be equal or greater than totalSupply"
        );
        maxSupply = _maxSupply;

        emit MaxSupplySet(maxSupply);
    }

    function setMaxMintAmount(uint256 _maxMintAmount) external onlyOwner {
        require(_maxMintAmount > 0, "Max mint amount must be greater than 0");
        maxMintAmount = _maxMintAmount;

        emit MaxMintAmountSet(maxMintAmount);
    }

    function setRevealed(bool _revealed) public onlyOwner {
        revealed = _revealed;

        emit RevealedSet(revealed);
    }

    function setPreMintStart(uint256 _preMintStart) external onlyOwner {
        require(_preMintStart > 0, "Pre-mint start must be greater than 0");
        preMintStart = _preMintStart;

        emit PreMintStartSet(preMintStart);
    }

    function setPublicMintStart(uint256 _publicMintStart) external onlyOwner {
        require(
            _publicMintStart > 0 && _publicMintStart >= preMintStart,
            "Public mint start must be greater than 0"
        );
        publicMintStart = _publicMintStart;

        emit PublicMintStartSet(publicMintStart);
    }

    function setPublicMintEnd(uint256 _publicMintEnd) external onlyOwner {
        require(
            _publicMintEnd > 0 && _publicMintEnd > publicMintStart,
            "Public mint end must be greater than 0"
        );
        publicMintEnd = _publicMintEnd;

        emit PublicMintEndSet(publicMintEnd);
    }

    function setPreMintPrice(uint256 _price) external onlyOwner {
        require(_price > 0, "Price must be greater than 0");
        preMintPrice = _price;

        emit PreMintPriceSet(_price);
    }

    function setPublicMintPrice(uint256 _price) external onlyOwner {
        require(_price > 0, "Price must be greater than 0");
        pubMintPrice = _price;

        emit PublicMintPriceSet(_price);
    }

    function setGiveawayAmountPerUser(uint256 _giveawayAmountPerUser)
        external
        onlyOwner
    {
        giveawayAmountPerUser = _giveawayAmountPerUser;

        emit GiveawayAmountPerUserSet(giveawayAmountPerUser);
    }

    function withdraw() public onlyOwner {
        (bool success, ) = payable(owner()).call{value: address(this).balance}(
            ""
        );
        require(success);
    }
    
    function getInfo(address _account) external view returns(
        bool canMint, uint256 price, uint256 amount, bool canClaim, uint256 claimAmount) {
            if(block.timestamp >= preMintStart || block.timestamp >= publicMintStart) {
                if(block.timestamp >= preMintStart && block.timestamp < publicMintStart) {
                    if(mintWhitelist[_account]) {
                        if(balanceOf(_account) >= maxMintAmount) {
                            amount = 0;
                            canMint = false;
                            price = 0;
                        } else {
                            amount = maxMintAmount - balanceOf(_account);
                            canMint = true;
                            price = preMintPrice;
                        }
                    } else {
                        canMint = false;
                        price = 0;
                        amount = 0;
                    }
                    if(giveawayWhitelist[_account] && freeMintAmount > 0) {
                        if(mintedFree[_account] >= giveawayAmountPerUser) {
                            canClaim = false;
                            claimAmount = 0;
                        } else {
                            canClaim = true;
                            claimAmount = giveawayAmountPerUser - mintedFree[_account];
                            if(claimAmount > freeMintAmount) {
                                claimAmount = freeMintAmount;
                                if(claimAmount == 0) canClaim = false;
                            }
                        }
                    } else {
                        canClaim = false;
                        claimAmount = 0;
                    }
                } else {
                    if(balanceOf(_account) >= maxMintAmount) {
                        amount = 0;
                        canMint = false;
                        price = 0;
                        canClaim = false;
                        claimAmount = 0;
                        
                    } else {
                        amount = maxMintAmount - balanceOf(_account);
                        canMint = true;
                        price = pubMintPrice;
                        canClaim = false;
                        claimAmount = 0;
                    }
                }
            } else {
                canMint = false; 
                price = 0;
                amount = 0;
                canClaim = false;
                claimAmount = 0;
            }
    }


    // ================== abstract implementations  ==================

    function isOwner() internal view override returns (bool) {
        return msg.sender == owner();
    }

    // ================== events ==================

    event MaxSupplySet(uint256 newMaxSupply);
    event AddedToMintWhitelist(address newWhitelist);
    event RemovedFromMintWhitelist(address removedWhitelist);
    event AddedToGiveawayWhitelist(address newWhitelist);
    event RemovedFromGiveawayWhitelist(address removedWhitelist);
    event MaxMintAmountSet(uint256 newMaxMintAmount);
    event RevealedSet(bool newRevealed);
    event BaseURIChanged(string newBaseURI);
    event FreeMintAmountChanged(uint256 newFreeMintAmount);
    event PreMintStartSet(uint256 newPreMintStart);
    event PublicMintStartSet(uint256 newPublicMintStart);
    event PublicMintEndSet(uint256 newPublicMintEnd);
    event PreMintPriceSet(uint256 newPresalePrice);
    event PublicMintPriceSet(uint256 newPublicSalePrice);
    event GiveawayAmountPerUserSet(uint256 newFreeMintAmount);
}

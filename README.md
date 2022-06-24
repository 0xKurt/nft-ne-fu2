# NFT contract based on ERC721A
> ERC721A is an improved implementation of the IERC721 standard that supports minting multiple tokens for close to the cost of one.
> 
[Read more](https://www.erc721a.org/)

---

# Table of Contents
- [NFT contract based on ERC721A](#nft-contract-based-on-erc721a)
- [Table of Contents](#table-of-contents)
  - [Description](#description)
      - [Pre- and Public minting](#pre--and-public-minting)
      - [Free minting](#free-minting)
      - [Max mint amount](#max-mint-amount)
      - [Revealing](#revealing)
      - [Pause minting](#pause-minting)
      - [Withdraw ETH](#withdraw-eth)
      - [Recover ERC20 token](#recover-erc20-token)
      - [Burn](#burn)
  - [Deployment and Initialization](#deployment-and-initialization)
    - [Deployment using Remix](#deployment-using-remix)
    - [Initialization using Remix](#initialization-using-remix)
   #####
2. [Deployment and Initialization](#deployment-and-initialization)
   1. [Deployment using Remix](#deployment-using-remix)
   2. [Initialization using Remix](#initialization-using-remix)

---


## Description

The main contracts are `contracts/NFT.sol` and `contracts/single-file/NFT_flat.sol`. Both contracts contain the same code, the single file contract is just flattened (one file contains all libraries and related code) for easy use with remix.

The NFT contract contains the following features:
##

#### Pre- and Public minting
  The owner can define 3 timestamps to define the minting periods and two prices for each minting period. The contract implements pre-minting and public-minting. The pre-mint period starts at `_preMintStart` and ends at the moment when the public mint starts `_publicMintStart`. The public-mint ends at `_publicMintEnd`. The owner can set these periods during initialization (see below) or by using the following functions:
  `setPreMintStart(uint256 _preMintStart) `, `setPublicMintStart(uint256 _publicMintStart)` and `setPublicMintEnd(uint256 _publicMintEnd)`.
  The functions mentioned above take unix timestamps as parameter. For example 1656062195 for Fri Jun 24 2022 09:16:35 GMT+0. You can use [Dan's Tools](https://www.unixtimestamp.com/) to get the timestamp.
  The owner can set minting prices for both periods. They can be set during initialization (see below) or by using the following functions:
  `setPreMintPrice(uint256 _price)` and `setPublicMintPrice(uint256 _price)`. Both functions take a price in wei as parameter. For Example: 1000000000000000000 for 1 Ether. You can use [Eth. Unit Converter](https://eth-converter.com/) to calculate the price.
  To participate in the pre-minting process, a user must be whitelisted.
  To whitelist a user the owner can call `addToWhitelist(address _toAdd)` to add a single user or `addManyToWhitelist(address[] memory _addresses)` to add multiple users at once.
  To remove a user from the whitelist the owner can call `removeFromWhitelist(address _toRemove)` to remove a single user or `removeManyFromWhitelist(address[] memory _addresses)` to remove multiple users at once.
  
  ##

#### Free minting
  The owner can set an amount of NFTs during the initialization which are free to mint. If you set this number to 1000, the first 1000 NFTs will be free to mint. Set the number to 0 if you don't need any free NFTs.
  The user has to pay for his NFTs only after the free amount is reached.
  The free NFTs can only be minted during pre- and public minting periods.
  The owner of the contract can change this number at any time by calling `setFreeMintAmount(uint256 _freeMintAmount)`.
  If the free mint amount is set to 1000, 999 NFTs are already minted and a user wants to mint 3 NFTs at one time. The user will receive 1 free NFT and only needs to pay for 2 NFTs.
  
  ##


#### Max mint amount
  During initialization the owner can set a maximum amount a user can hold. If you set this number to 5, the maximum amount the user can hold is 5.
  If the user has 0 NFTs he can mint 5 at once. If the user already minted 1 NFT, he is only allowed to mint 4 in addition.
  The owner can change this number at any time by calling `setMaxMintAmount(uint256 _maxMintAmount)`

  ##
  
#### Revealing
  During the minting periods the user will not see their real NFT metadata.
  For this the owner must pass a URL of the metadata json which will be shown until the collection will be revealed during the initialization. (see below)
  To reveal the collection, the owner has to call `reveal(string memory _baseUri)` and pass the new baseURI.
  If something goes wrong, the owner can set `setRevealed(bool _revealed)` to true or false at any time and is able to change the metadata uri by calling `setBaseURI(string memory _baseUri)`
 
  ##

#### Pause minting
  The owner can pause and unpause minting at any time by calling `pause` or `unpause`.

  ##

#### Withdraw ETH
  Only the owner is allowed to withdraw ETH form the contract by calling `withdraw`
  
  ##

#### Recover ERC20 token
  If someone accidentally sends ERC20 Token to the NFT contract, the owner is able to withdraw them by calling `recoverERC20(_tokenAddress, _receiver)`
  ##

#### Burn
  Every token holder can burn the NFT he owns by calling `burn(tokenId)`
  
  ##

---

## Deployment and Initialization

### Deployment using Remix

- Open [Remix](https://remix.ethereum.org)
- Go to the File Explorer, create a new file, name it and in the editor paste the contract code from `contracts/single-file/NFT_flat.sol`
- With the contract above as the active tab in the Editor, compile the contract using compiler version **0.8.4**
- Go to the Deploy & Run Transactions plugin and choose the environment **Injected Web3** (make sure you connect your wallet browser extension to the correct network)
- Choose the Contract called **NFT** and click on **Deploy**

### Initialization using Remix

After deployment you need to initialize the NFT contract. Please click on the caret to the left of the instance of NFT will open it up so you can see its functions.

Search for **initialize** and click on the arrow to expand the view. You need to pass the parameters described below and click on **transact** afterwards:

- `_name`: *Name of the NFT. For example: CryptoZombies*
- `_symbol`: *Symbol of the NFT. For example: ZOMBIE*
- `_notRevealedUri`: *URL of the metadata json which will be shown until the collection will be revealed. For example: [https://gateway.ipfs.io/ipfs/bafybeibnso...xvivplfwhtpym/metadata.json](https://gateway.ipfs.io/ipfs/bafybeibnsoufr2renqzsh347nrx54wcubt5lgkeivez63xvivplfwhtpym/metadata.json)*
- `_maxMintAmount`: *Maximum amount of NFTs a user can mint.*
- `_freeMintAmount`: *Amount of free NFTs. If you set this number to 1000, the first 1000 NFTs will be free. Set the number to 0 if you don't need any free NFTs.*
- `_preMintPrice`: *The price a user has to pay for 1 NFT during pre-mint period in **wei**. For Example: 1000000000000000000 for 1 Ether. You can use [Eth. Unit Converter](https://eth-converter.com/) to calculate the amount.*
- `_pubMintPrice` *The price a user has to pay for 1 NFT during public-mint period in **wei**. Example see above.*
- `_maxSupply`: *Maximum total amount of NFTs the users can mint.*
- `_preMintStart`: *The timestamp of the date when pre-minting starts. For example 1656062195 for Fri Jun 24 2022 09:16:35 GMT+0. You can use [Dan's Tools](https://www.unixtimestamp.com/) to get the timestamp*
- `_publicMintStart`: *The timestamp of the date when public-minting starts. Example see above.*
- `_publicMintEnd`: *The timestamp of the date when public-minting ends. Example see above.*

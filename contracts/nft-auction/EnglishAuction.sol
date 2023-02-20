// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address,
        address,
        uint256
    ) external;
}

contract EnglishAuction {
    event Start();
    event Bid(address indexed sender, uint256 amount);
    event Withdraw(address indexed bidder, uint256 amount);
    event End(address winner, uint256 amount);

    // Variables
    IERC721 public nft; // NFT contract
    uint256 public nftId; // ID of the NFT being auctioned
    address payable public seller; // Address of the seller
    uint256 public endAt; // Timestamp of when the auction ends
    bool public started; // Flag indicating if the auction has started
    bool public ended; // Flag indicating if the auction has ended
    address public highestBidder; // Address of the highest bidder
    uint256 public highestBid; // Highest bid amount
    mapping(address => uint256) public bids; // Mapping of addresses to bid amounts

    // Constructor
    constructor(
        address _nft, // Address of the NFT contract
        uint256 _nftId, // ID of the NFT being auctioned
        uint256 _startingBid // Starting bid amount
    ) {
        nft = IERC721(_nft); // Initialize the NFT contract
        nftId = _nftId; // Initialize the NFT ID
        seller = payable(msg.sender); // Set the seller to the contract deployer
        highestBid = _startingBid; // Set the starting bid
    }

    // Start the auction
    function start() external {
        require(!started, "started"); // Auction has not already started
        require(msg.sender == seller, "not seller"); // Only the seller can start the auction
        nft.transferFrom(msg.sender, address(this), nftId); // Transfer the NFT to the contract
        started = true; // Set the started flag to true
        endAt = block.timestamp + 7 days; // Set the end time to 7 days from now
        emit Start(); // Emit the start event
    }

    // Place a bid
    function bid() external payable {
        require(started, "not started"); // Auction has started
        require(block.timestamp < endAt, "ended"); // Auction has not ended
        require(msg.value > highestBid, "value < highest"); // Bid is higher than the current highest bid

        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid; // Add the previous highest bid to their bid amount
        }

        highestBidder = msg.sender; // Set the highest bidder to the current bidder
        highestBid = msg.value; // Set the highest bid to the current bid amount
        emit Bid(msg.sender, msg.value); // Emit the bid event
    }

    // Withdraw a bid
    function withdraw() external {
        uint256 bal = bids[msg.sender]; // Get the bidder's current bid amount
        bids[msg.sender] = 0; // Set their bid amount to 0
        payable(msg.sender).transfer(bal); // Transfer their bid amount back to them
        emit Withdraw(msg.sender, bal); // Emit the withdraw event
    }

    // End the auction
    function end() external {
        require(started, "not started");
        require(block.timestamp >= endAt, "not ended");
        require(!ended, "ended");

        ended = true;
        if (highestBidder != address(0)) {
            nft.safeTransferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            nft.safeTransferFrom(address(this), seller, nftId);
        }

        emit End(highestBidder, highestBid);
    }
}

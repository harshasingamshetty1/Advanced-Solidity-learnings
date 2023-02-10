// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _nftId
    ) external;
}

/**
    In Dutch Auction, a start price is set for the asset
    The auction starts and lasts for a specified duration.
    The prices keeps decreasing at a particular rate and
    the users can buy the asset whenever they find the price is reasonable.
*/
contract DutchAuction {
    uint256 private constant DURATION = 7 days;

    // the nft contract, whose token is in auction
    IERC721 public immutable nft;
    // the tokenId of the nft in its contract
    uint256 public immutable nftId;
    //address of the seller/owner
    address payable public immutable seller;
    uint256 public immutable startingPrice;
    uint256 public immutable startAt;
    uint256 public immutable expiresAt;
    // discount rate is in wei/second => So, how much wei the price is decreased per second
    uint256 public immutable discountRate;

    constructor(
        uint256 _startingPrice,
        uint256 _discountRate,
        address _nft,
        uint256 _nftId
    ) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;
        discountRate = _discountRate;

        // at the provided rate of discount price should not go below 0
        require(
            _startingPrice >= _discountRate * DURATION,
            "starting price < min"
        );

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    // calculating the price according to discount rate based on the time elapsed
    function getPrice() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - startAt;
        uint256 discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable {
        require(block.timestamp < expiresAt, "auction expired");

        uint256 price = getPrice();
        require(msg.value >= price, "ETH < price");
        //prior, the owner need to approve this contract, for the nftId
        nft.transferFrom(seller, msg.sender, nftId);
        uint256 refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        selfdestruct(seller);
    }
}

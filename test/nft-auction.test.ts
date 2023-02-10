import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import {
  CryptoDevs,
  DutchAuction,
  DutchAuction__factory,
} from "../typechain-types";
const { parseEther } = ethers.utils;

describe("NFT Auction", () => {
  async function increaseTimestampOfBlock(interval: number) {
    let curBlockNumber = await ethers.provider.getBlockNumber();
    let curBlock = await ethers.provider.getBlock(curBlockNumber);
    let curTimestamp = curBlock.timestamp;
    // console.log("Before Timestamp, block number = ", curTimestamp, curBlockNumber);
    let newTimestampInSeconds = curTimestamp + interval;
    await ethers.provider.send("evm_mine", [newTimestampInSeconds]);
    curBlockNumber = await ethers.provider.getBlockNumber();
    curBlock = await ethers.provider.getBlock(curBlockNumber);
    curTimestamp = curBlock.timestamp;
    // console.log("After Timestamp = ", curTimestamp, curBlockNumber);
  }
  let dutchAuctionFactory: DutchAuction__factory,
    whitelistFactory,
    whitelistContract,
    cryptoDevsFactory,
    cryptoDevsContract: CryptoDevs,
    accounts: SignerWithAddress[];

  beforeEach(async () => {
    let basePrice = 1;
    accounts = await ethers.getSigners();
    whitelistFactory = await ethers.getContractFactory("Whitelist");
    whitelistContract = await whitelistFactory.deploy(10);
    await whitelistContract.deployed();

    cryptoDevsFactory = await ethers.getContractFactory("CryptoDevs");
    cryptoDevsContract = await cryptoDevsFactory.deploy(
      "",
      whitelistContract.address,
      basePrice
    );
    await cryptoDevsContract.deployed();

    await cryptoDevsContract.startPresale();
    await increaseTimestampOfBlock(300);
    await cryptoDevsContract.mint({ value: parseEther("1") });

    dutchAuctionFactory = await ethers.getContractFactory("DutchAuction");
  });
  it("works", async () => {
    const dutchAuctionToken1 = (await dutchAuctionFactory.deploy(
      parseEther("1.5"),
      100,
      cryptoDevsContract.address,
      1
    )) as DutchAuction;
    await dutchAuctionToken1.deployed();

    await cryptoDevsContract.approve(dutchAuctionToken1.address, 1);

    await dutchAuctionToken1
      .connect(accounts[1])
      .buy({ value: parseEther("2") });

    expect(await cryptoDevsContract.ownerOf(1)).to.eq(accounts[1].address);
    await dutchAuctionToken1.buy();
  });
});

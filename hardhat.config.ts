import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
dotenv.config();
// import { DotenvConfigOptions } from "dotenv";

const PRIVATE_KEY = process.env.PRIVATE_KEY || "Enter your Private Key";
// console.log(PRIVATE_KEY);
const INFURA_HTTP_URL =
  process.env.INFURA_HTTP_URL || "Provide RPC endpoint for testnet";

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 31337,
    },
    goerli: {
      url: INFURA_HTTP_URL,
      accounts: [PRIVATE_KEY],
    },
  },
};

export default config;

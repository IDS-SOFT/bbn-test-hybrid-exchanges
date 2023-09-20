import { ethers } from "hardhat";

const trade_fee = 10;

async function main() {

  const cryptoExchange = await ethers.deployContract("CryptoExchange", [trade_fee]);

  await cryptoExchange.waitForDeployment();

  console.log("CryptoExchange deployed to : ",await cryptoExchange.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// eslint-disable-next-line @typescript-eslint/no-var-requires
const { ethers, upgrades } = require('hardhat');
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { writeFile } = require('fs/promises');
// eslint-disable-next-line @typescript-eslint/no-var-requires
const path = require('path');
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { readFileSync } = require('fs');

async function main() {
  const Protocol = await ethers.getContractFactory('Protocol');

  const protocol = await Protocol.deploy(
    '0xd761acf92daFA3B7d2a13adf816af291A223c6f4',
    '0xd761acf92daFA3B7d2a13adf816af291A223c6f4',
  );

  await protocol.deployed();

  const NFT = await ethers.getContractFactory('EathasysNFT');
  const nft = await upgrades.deployProxy(NFT, [protocol.address]);
  await nft.deployed();

  console.log('Protocol contract deployed to: ', protocol.address);
  console.log('Earthasys NFT contract deployed to: ', nft.address);

  const erc20s = JSON.parse(readFileSync(path.join(__dirname, 'data.json')));

  for (const erc20 of erc20s) {
    console.log(erc20);
  }

  await writeFile(
    './src/info/data.json',
    JSON.stringify({ protocolAddress: protocol.address, nftAddress: nft.address }),
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// eslint-disable-next-line @typescript-eslint/no-var-requires
const { ethers } = require('hardhat');
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { writeFile } = require('fs/promises');
// eslint-disable-next-line @typescript-eslint/no-var-requires
const path = require('path');
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { readFileSync } = require('fs');

async function main() {
  const Protocol = await ethers.getContractFactory('Protocol');
  const testnetExplorerLink = 'https://testnet.snowtrace.io/address/';

  const protocol = await Protocol.deploy(
    '0xd761acf92daFA3B7d2a13adf816af291A223c6f4',
    '0xd761acf92daFA3B7d2a13adf816af291A223c6f4',
  );

  await protocol.deployed();

  const EarthasysNFT = await ethers.getContractFactory('EarthasysNFT');
  const nft = await EarthasysNFT.deploy(protocol.address);
  await nft.deployed();

  console.log('Protocol contract deployed to: ', protocol.address);
  console.log('Earthasys NFT contract deployed to: ', nft.address);
  console.log('Protocol contract link: ', testnetExplorerLink + protocol.address);
  console.log('Earthasys NFT contract link: ', testnetExplorerLink + nft.address);

  const erc20s = JSON.parse(readFileSync(path.join(__dirname, 'data.json')));
  for (const erc20 of erc20s) {
    // eslint-disable-next-line no-await-in-loop
    const tx = await nft.addNewERC20(
      erc20.PollutantName,
      erc20.tokenName,
      erc20.ticker,
      erc20.unitName,
      erc20.imageURI,
    );
    // eslint-disable-next-line no-await-in-loop
    await tx.wait();
    // eslint-disable-next-line prefer-template, no-await-in-loop
    console.log(erc20.PollutantName + ' ERC20 of address' + (await nft.getERC20Address(erc20.PollutantName)));
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

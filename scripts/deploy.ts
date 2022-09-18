
const { ethers } = require('hardhat');
const { writeFile } = require('fs/promises');
const path = require('path');
const { readFileSync } = require('fs');

async function main() {
  console.log(__dirname);
  
  const Protocol = await ethers.getContractFactory('Protocol');
  const testnetExplorerLink = 'https://testnet.snowtrace.io/address/';

  const protocol = await Protocol.deploy(
    '0xAaC0c3338A52e5D8D98bDdf8C5C5F54e093Ac49f',
    '0xAaC0c3338A52e5D8D98bDdf8C5C5F54e093Ac49f',
  );

  await protocol.deployed();

  const EarthasysNFT = await ethers.getContractFactory('EarthasysNFT');
  const nft = await EarthasysNFT.deploy(protocol.address);
  await nft.deployed();
  console.log('Protocol contract deployed to: ', protocol.address);
  console.log('Earthasys NFT contract deployed to: ', nft.address);
  console.log('Protocol contract link: ', testnetExplorerLink + protocol.address);
  console.log('Earthasys NFT contract link: ', testnetExplorerLink + nft.address);

  // const ERC20Addresses = {
  //   "Carbon": "0x4c9F85aC612507E93E6B94106E90b083A87E2495",
  //   "Lead": "0x3D3736Cb1f5aC304CDb2FAB2db6e70c629E382Aa",
  //   "Dust": "0x9b9cd543DC1586c053e566F16390DCc7A76902Fd"
  // };
  const ERC20Addresses  = {};
  const erc20s = JSON.parse(readFileSync(path.join(__dirname, 'data.json').toString()));
  for (const erc20 of erc20s) {
    // eslint-disable-next-line no-await-in-loop
    const tx = await nft.addNewERC20(
      erc20.PollutantName,
      erc20.tokenName,
      erc20.ticker,
      erc20.unitName,
      erc20.imageURI,
      erc20.price,
    );
    // eslint-disable-next-line no-await-in-loop
    await tx.wait();
    // eslint-disable-next-line prefer-template, no-await-in-loop
    console.log(erc20.PollutantName + ' ERC20 of address ' + (await nft.getERC20Address(erc20.PollutantName)));
    ERC20Addresses[erc20.PollutantName] = erc20.PollutantName;
  }

  await writeFile(
    path.join(__dirname, '../', 'frontend', 'src', 'info', 'data.json'),
    JSON.stringify({ protocolAddress: protocol.address, nftAddress: nft.address, ERC20Addresses: ERC20Addresses }, null, 2),
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// eslint-disable-next-line @typescript-eslint/no-var-requires
const { ethers } = require('hardhat');
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { writeFile } = require('fs/promises');

async function main() {
  // const CubeToken = await ethers.getContractFactory("CubeToken");
  // const cubeToken = await upgrades.deployProxy(CubeToken, "fdf");
  // await cubeToken.deployed();
  const Protocol = await ethers.getContractFactory('Protocol');

  const protocol = await Protocol.deploy(
    '0xd761acf92daFA3B7d2a13adf816af291A223c6f4',
    '0xd761acf92daFA3B7d2a13adf816af291A223c6f4',
  );

  await protocol.deployed();

  console.log('Greeting contract deployed to: ', protocol.address);
  // write
  await writeFile('./src/info/data.json', JSON.stringify({ protocolAddress: protocol.address }));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

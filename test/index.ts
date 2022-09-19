import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers, waffle} from 'hardhat';
import EarthasysNFTArtifacts from '../artifacts/contracts/EathasysNFT.sol/EarthasysNFT.json';
import {EarthasysNFT} from '../types/contracts/EathasysNFT.sol/EarthasysNFT';
import EarthasysERC20Artifacts from '../artifacts/contracts/EarthasysERC20.sol/EarthasysERC20.json';
import {EarthasysERC20} from '../types/contracts/EarthasysERC20';
import EarthasysProtocolArtifacts from '../artifacts/contracts/Protocol.sol/Protocol.json';
import {Protocol} from '../types/contracts/Protocol';
import { NFTStorage, File } from "nft.storage";
import {readFileSync} from 'fs';
import path from "path";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

const {deployContract} = waffle;

// eslint-disable-next-line no-undef
describe("Earthasys tests", () => {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshopt in every test.
  async function deployOnceFixture() {
    let earthasysProtocol: Protocol;
    let earthasysNFT: EarthasysNFT;
    // Contracts are deployed using the first signer/account by default
    const [owner, ...otherAccounts] = await ethers.getSigners();

    // eslint-disable-next-line prefer-const
    earthasysProtocol = (await deployContract(owner, EarthasysProtocolArtifacts, ["0xAaC0c3338A52e5D8D98bDdf8C5C5F54e093Ac49f", "0xAaC0c3338A52e5D8D98bDdf8C5C5F54e093Ac49f"])) as Protocol;
    // eslint-disable-next-line prefer-const
    earthasysNFT = (await deployContract(owner, EarthasysNFTArtifacts, [earthasysProtocol.address])) as EarthasysNFT;

  const erc20s = JSON.parse(readFileSync(path.join(__dirname, 'data.json')).toString());
  for (const erc20 of erc20s) {
    // eslint-disable-next-line no-await-in-loop
    const tx = await earthasysNFT.addNewERC20(
      erc20.PollutantName,
      erc20.tokenName,
      erc20.ticker,
      erc20.unitName,
      erc20.imageURI,
      erc20.price
    );
    // eslint-disable-next-line no-await-in-loop
    await tx.wait();
    // eslint-disable-next-line prefer-template, no-await-in-loop
    console.log(erc20.PollutantName + ' ERC20 of address ' + (await earthasysNFT.getERC20Address(erc20.PollutantName)));
  }

    return { earthasysProtocol, earthasysNFT, owner, otherAccounts };
  }

  // eslint-disable-next-line no-undef
  describe("Test suite", () => {

    async function signMessage(signer: SignerWithAddress) {

      let messageHash = ethers.utils.id("Earthasys");

      let messageHashBytes = ethers.utils.arrayify(messageHash)

      // Sign the binary data
      let flatSig = await signer.signMessage(messageHashBytes);

      // For Solidity, we need the expanded-format of a signature
      let sig = ethers.utils.splitSignature(flatSig);
   
      // split signature
      const v = sig.v;
      const r = sig.r;
      const s = sig.s;

      return {messageHashBytes,  v, r, s }
    }
    // eslint-disable-next-line no-undef
    it("Should deploy all contracts owner", async () => {
      const { earthasysProtocol, earthasysNFT } = await loadFixture(deployOnceFixture);
      console.log(earthasysProtocol.address);
      console.log(earthasysNFT.address);
 
    });

    it.only("Should verify message", async () => {
      const { owner, earthasysProtocol, earthasysNFT } = await loadFixture(deployOnceFixture);
      const {messageHashBytes, v, r, s} =await signMessage(owner);
 
       expect(await earthasysProtocol.VerifySignature(messageHashBytes, v, r, s)).to.be.eq(owner.address);
    });

    // it("Check if not owner cant change greet", async () => {
    //   const { greeter, owner, otherAccounts } = await loadFixture(deployOnceFixture);
    //   await expect(greeter.connect(otherAccounts[0]).setGreeting("Hello, universe!")).to.be.reverted;
    // });
  });
});
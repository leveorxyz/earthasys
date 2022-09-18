// eslint-disable-next-line etc/no-commented-out-code
// import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import '@nomiclabs/hardhat-solhint';
import '@typechain/hardhat';
import '@nomiclabs/hardhat-ethers';
import '@nomiclabs/hardhat-waffle';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const dotenv = require('dotenv');
// eslint-disable-next-line @typescript-eslint/no-var-requires
const path = require('path');

dotenv.config({ path: path.resolve(__dirname, './.env') });

const chainIds = {
  goerli: 5,
  hardhat: 31337,
  kovan: 42,
  mainnet: 1,
  rinkeby: 4,
  ropsten: 3,
  bsctest: 97,
  bscmain: 56,
};

const { PRIVATE_KEY } = process.env;
const API_KEY = process.env.RPC_NODE_API_KEY;
const { MNEMONIC } = process.env;
const { ETHERSCAN_API_KEY } = process.env;

const defaultRPCNodeProvider = 'infura';

// eslint-disable-next-line consistent-return
const getRPCURL = (network: string, RPCNodeProvider: string) => {
  switch (RPCNodeProvider) {
    case 'moralis':
      return `https://speedy-nodes-nyc.moralis.io/${API_KEY}/eth/${network}`;

    case 'alchemy':
      return `https://eth-${network}.alchemyapi.io/v2/${API_KEY}`;

    case 'infura':
      return `https://${network}.infura.io/v3/${API_KEY}`;

    case 'datahub':
      return `https://ethereum-${network}--rpc.datahub.figment.io//apikey/${API_KEY}`;

    default:
      console.error('Unknown provider:', RPCNodeProvider);
  }
};

const config = {
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      accounts: {
        mnemonic: MNEMONIC,
      },
      chainId: chainIds.hardhat,
    },
    ropsten: {
      url: getRPCURL('ropsten', defaultRPCNodeProvider),
      accounts: [`0x${PRIVATE_KEY}`],
      chainId: chainIds.ropsten,
    },
    rinkeby: {
      url: getRPCURL('rinkeby', defaultRPCNodeProvider),
      accounts: [`0x${PRIVATE_KEY}`],
      chainId: chainIds.rinkeby,
    },
    kovan: {
      url: getRPCURL('kovan', defaultRPCNodeProvider),
      accounts: [`0x${PRIVATE_KEY}`],
      chainId: chainIds.kovan,
    },
    goerli: {
      url: getRPCURL('goerli', defaultRPCNodeProvider),
      accounts: [`0x${PRIVATE_KEY}`],
      chainId: chainIds.goerli,
    },
    mainnet: {
      url: getRPCURL('mainnet', defaultRPCNodeProvider),
      accounts: [`0x${PRIVATE_KEY}`],
      chainId: chainIds.mainnet,
    },
    bsctest: {
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545',
      chainId: chainIds.bsctest,
      gasPrice: 20000000000,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    bscmain: {
      url: 'https://bsc-dataseed.binance.org/',
      chainId: chainIds.bscmain,
      gasPrice: 20000000000,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    fuji: {
      url: 'https://api.avax-test.network/ext/bc/C/rpc',
      gasPrice: 225000000000,
      chainId: 43113,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  solidity: {
    compilers: [
      {
        version: '0.8.15',
        settings: { optimizer: { enabled: true, runs: 200 } },
      },
    ],
  },
  gasReporter: {
    currency: 'USD',
    enabled: false,
  },
  typechain: {
    outDir: 'frontend/src/types',
    target: 'ethers-v5',
    // eslint-disable-next-line no-inline-comments
    alwaysGenerateOverloads: false, // should overloads with full signatures like deposit(uint256) be generated always, even if there are no overloads?
    // eslint-disable-next-line no-inline-comments
    externalArtifacts: ['externalArtifacts/*.json'], // optional array of glob patterns with external artifacts to process (for example external libs from node_modules)
    // eslint-disable-next-line no-inline-comments
    dontOverrideCompile: false, // defaults to false
  },
  etherscan: {
    apiKey: {
      rinkeby: ETHERSCAN_API_KEY,
    },
  },
};

module.exports = config;

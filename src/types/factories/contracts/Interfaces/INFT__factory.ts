/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from 'ethers';
import type { Provider } from '@ethersproject/providers';
import type { INFT, INFTInterface } from '../../../contracts/Interfaces/INFT';

const _abi = [
  {
    inputs: [
      {
        internalType: 'address',
        name: 'account',
        type: 'address',
      },
      {
        internalType: 'bytes',
        name: 'data',
        type: 'bytes',
      },
      {
        components: [
          {
            internalType: 'string',
            name: 'name',
            type: 'string',
          },
          {
            internalType: 'uint256[]',
            name: 'intialAmounts',
            type: 'uint256[]',
          },
          {
            internalType: 'uint256[]',
            name: 'targetAmounts',
            type: 'uint256[]',
          },
        ],
        internalType: 'struct INFT.Pollutant[]',
        name: 'pollutantDetails',
        type: 'tuple[]',
      },
    ],
    name: 'mintNewProject',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'nftID',
        type: 'uint256',
      },
      {
        internalType: 'address',
        name: 'account',
        type: 'address',
      },
      {
        internalType: 'uint256',
        name: 'amount',
        type: 'uint256',
      },
      {
        internalType: 'bytes',
        name: 'data',
        type: 'bytes',
      },
      {
        components: [
          {
            internalType: 'string',
            name: 'name',
            type: 'string',
          },
          {
            internalType: 'uint256[]',
            name: 'intialAmounts',
            type: 'uint256[]',
          },
          {
            internalType: 'uint256[]',
            name: 'targetAmounts',
            type: 'uint256[]',
          },
        ],
        internalType: 'struct INFT.Pollutant[]',
        name: 'pollutantDetails',
        type: 'tuple[]',
      },
    ],
    name: 'mintProjects',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
];

export class INFT__factory {
  static readonly abi = _abi;
  static createInterface(): INFTInterface {
    return new utils.Interface(_abi) as INFTInterface;
  }
  static connect(address: string, signerOrProvider: Signer | Provider): INFT {
    return new Contract(address, _abi, signerOrProvider) as INFT;
  }
}

/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type { BaseContract, BigNumber, BytesLike, CallOverrides, PopulatedTransaction, Signer, utils } from 'ethers';
import type { FunctionFragment, Result } from '@ethersproject/abi';
import type { Listener, Provider } from '@ethersproject/providers';
import type { TypedEventFilter, TypedEvent, TypedListener, OnEvent, PromiseOrValue } from '../../common';

export interface IProtocolInterface extends utils.Interface {
  functions: {
    'isOffsetter(address)': FunctionFragment;
    'isRegulator(address)': FunctionFragment;
  };

  getFunction(nameOrSignatureOrTopic: 'isOffsetter' | 'isRegulator'): FunctionFragment;

  encodeFunctionData(functionFragment: 'isOffsetter', values: [PromiseOrValue<string>]): string;
  encodeFunctionData(functionFragment: 'isRegulator', values: [PromiseOrValue<string>]): string;

  decodeFunctionResult(functionFragment: 'isOffsetter', data: BytesLike): Result;
  decodeFunctionResult(functionFragment: 'isRegulator', data: BytesLike): Result;

  events: {};
}

export interface IProtocol extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IProtocolInterface;

  queryFilter<TEvent extends TypedEvent>(
    event: TypedEventFilter<TEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined,
  ): Promise<Array<TEvent>>;

  listeners<TEvent extends TypedEvent>(eventFilter?: TypedEventFilter<TEvent>): Array<TypedListener<TEvent>>;
  listeners(eventName?: string): Array<Listener>;
  removeAllListeners<TEvent extends TypedEvent>(eventFilter: TypedEventFilter<TEvent>): this;
  removeAllListeners(eventName?: string): this;
  off: OnEvent<this>;
  on: OnEvent<this>;
  once: OnEvent<this>;
  removeListener: OnEvent<this>;

  functions: {
    isOffsetter(addressToCheck: PromiseOrValue<string>, overrides?: CallOverrides): Promise<[boolean]>;

    isRegulator(addressToCheck: PromiseOrValue<string>, overrides?: CallOverrides): Promise<[boolean]>;
  };

  isOffsetter(addressToCheck: PromiseOrValue<string>, overrides?: CallOverrides): Promise<boolean>;

  isRegulator(addressToCheck: PromiseOrValue<string>, overrides?: CallOverrides): Promise<boolean>;

  callStatic: {
    isOffsetter(addressToCheck: PromiseOrValue<string>, overrides?: CallOverrides): Promise<boolean>;

    isRegulator(addressToCheck: PromiseOrValue<string>, overrides?: CallOverrides): Promise<boolean>;
  };

  filters: {};

  estimateGas: {
    isOffsetter(addressToCheck: PromiseOrValue<string>, overrides?: CallOverrides): Promise<BigNumber>;

    isRegulator(addressToCheck: PromiseOrValue<string>, overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    isOffsetter(addressToCheck: PromiseOrValue<string>, overrides?: CallOverrides): Promise<PopulatedTransaction>;

    isRegulator(addressToCheck: PromiseOrValue<string>, overrides?: CallOverrides): Promise<PopulatedTransaction>;
  };
}

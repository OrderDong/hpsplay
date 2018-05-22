package com.block.eth.contract;

import org.web3j.abi.datatypes.generated.Uint256;
import org.web3j.protocol.core.RemoteCall;
import org.web3j.protocol.core.methods.response.TransactionReceipt;

/**
 * @author littleredhat
 */
public interface HelloWorldInterface {

    // get
    public RemoteCall<Uint256> get();

    // set
    public RemoteCall<TransactionReceipt> set(int x);


    //创建token
    public RemoteCall<Uint256> createToken();
    //查询token
    public RemoteCall<Uint256> balanceOf(String address);

    public RemoteCall<Uint256> tokensOfOwner(String address);

    // transfer
    public RemoteCall<TransactionReceipt> transfer(int token,String address);

    //创建token
    public RemoteCall<TransactionReceipt> createToken2();
}

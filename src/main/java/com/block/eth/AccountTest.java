package com.block.eth;


import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.methods.response.Web3ClientVersion;
import org.web3j.protocol.http.HttpService;

import java.io.IOException;


/**
 * Created by Administrator on 2018/4/10.
 */
public class AccountTest {
    public static void main(String args[]) {
//       getBalance("0x8ede599b059c5ab7f60ccbc7fe6573ea0793c0d6");
//        queryAccount();
//        getBalance("0x339177a6a2b21a8b7CE76811C86D3a2C99301355");
        String url = "https://ropsten.infura.io/0x339177a6a2b21a8b7CE76811C86D3a2C99301355";
        Web3j web3 = Web3j.build(new HttpService("https://ropsten.infura.io/0x339177a6a2b21a8b7CE76811C86D3a2C99301355"));
        Web3ClientVersion web3ClientVersion = null;
        try {
            web3ClientVersion = web3.web3ClientVersion().send();
//            System.out.println(web3.ethAccounts().send().getAccounts());
            System.out.println(web3.ethBlockNumber().send().getBlockNumber());
        } catch (IOException e) {
            e.printStackTrace();
        }
        System.out.println(web3ClientVersion.getWeb3ClientVersion());
    }
}

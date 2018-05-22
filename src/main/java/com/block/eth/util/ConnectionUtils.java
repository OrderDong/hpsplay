package com.block.eth.util;

import org.web3j.crypto.Credentials;
import org.web3j.crypto.ECKeyPair;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.admin.Admin;
import org.web3j.protocol.http.HttpService;
import org.web3j.utils.Numeric;

/**
 * Created by Administrator on 2018/4/24.
 */
public class ConnectionUtils {

    private final static String privateKey = "4f74868ca57f26ba012c0d2f3f36b0dc45b97628c136b4f8be94b3590423f989";
    private final static String publicKey = "0x339177a6a2b21a8b7CE76811C86D3a2C99301355";
    private static Web3j web3j;
    private static  Admin admin;
    public static Web3j getInstall(){
        if(web3j == null ){
            web3j = Web3j.build(new HttpService("https://ropsten.infura.io/"+publicKey));
        }
        return  web3j;
    }

    public  static Credentials getCredentials(){
        ECKeyPair keyPair = ECKeyPair.create(Numeric.toBigInt(privateKey));
        Credentials credentials = Credentials.create(keyPair);
        return credentials;
    }

    public static Admin getInstallAdmin(){
        if(admin == null ) {
            admin = Admin.build(new HttpService("http://127.0.0.1:8545"));
        }
//        Admin admin = Admin.build(new HttpService("https://ropsten.infura.io/0x339177a6a2b21a8b7CE76811C86D3a2C99301355"));
        return  admin;
    }
}

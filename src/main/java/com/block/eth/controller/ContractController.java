package com.block.eth.controller;

import com.alibaba.fastjson.JSON;
import com.block.eth.contract.HelloWorldContract;
import com.block.eth.util.ConnectionUtils;
import com.block.eth.util.Consts;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.web3j.abi.datatypes.Type;
import org.web3j.abi.datatypes.generated.Uint256;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.Web3jService;
import org.web3j.protocol.admin.Admin;
import org.web3j.protocol.admin.methods.response.PersonalListAccounts;
import org.web3j.protocol.admin.methods.response.PersonalUnlockAccount;
import org.web3j.protocol.core.RemoteCall;
import org.web3j.protocol.core.methods.response.TransactionReceipt;
import org.web3j.protocol.http.HttpService;

import java.io.IOException;
import java.util.List;

/**
 * Created by Administrator on 2018/4/24.
 */
@RestController
@RequestMapping("/cont")
public class ContractController {

    @RequestMapping("/use")
    public  String useCon( ){
        String str = "";
        Web3j web3j =  ConnectionUtils.getInstall();
        // 加载合约
        HelloWorldContract contract = HelloWorldContract.load(Consts.HELLOWORLD_ADDR, web3j, ConnectionUtils.getCredentials(),
                Consts.GAS_PRICE, Consts.GAS_LIMIT);
        /*System.out.println("getContractAddress : " + contract.getContractAddress());
        try {
            System.out.println("isValid : "+ contract.isValid());
        } catch (IOException e) {
            e.printStackTrace();
        }*/

        ////////// 同步请求方式 //////////
        // get
       /* Uint256 result = contract.balanceOf(publicKey).send();
        Uint256 result = null;
        try {
            result = contract.createToken().send();
        } catch (Exception e) {
            e.printStackTrace();
        }*/
        // set
      /*  TransactionReceipt transactionReceipt = null;
        try {
            transactionReceipt = contract.set(10000).send();
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println("waiting..."); // 进入阻塞
        System.out.println("set : " + transactionReceipt.getTransactionHash());
        str = transactionReceipt.getTransactionHash();*/
        // get
        Uint256 result = null;
        try {
            result = contract.get().send();
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println("waiting..."); // 进入阻塞
        System.out.println("get : " + result.getValue().intValue());
        str =   String.valueOf(result.getValue().intValue());
        return str;
    }

    @RequestMapping("/ct")
    public  String createToken( ){
        String str = "";
        Web3j web3j =  ConnectionUtils.getInstall();
        // 加载合约
        HelloWorldContract contract = HelloWorldContract.load(Consts.HELLOWORLD_ADDR, web3j, ConnectionUtils.getCredentials(),
                Consts.GAS_PRICE, Consts.GAS_LIMIT);
        /*System.out.println("getContractAddress : " + contract.getContractAddress());
        try {
            System.out.println("isValid : "+ contract.isValid());
        } catch (IOException e) {
            e.printStackTrace();
        }*/

        ////////// 同步请求方式 //////////
        // get
       /* Uint256 result = contract.balanceOf(publicKey).send();*/
       /* Uint256 result = null;
        Admin admin = Admin.build(new HttpService("http://127.0.0.1:8545"));
//        Admin admin = Admin.build(new HttpService("https://ropsten.infura.io/0x339177a6a2b21a8b7CE76811C86D3a2C99301355"));

        PersonalUnlockAccount personalUnlockAccount = null;

        try {
            PersonalListAccounts accounts = admin.personalListAccounts().send();
            System.out.println("账户列表:"+JSON.toJSONString(accounts));
            personalUnlockAccount = admin.personalUnlockAccount("4f74868ca57f26ba012c0d2f3f36b0dc45b97628c136b4f8be94b3590423f989", "0x339177a6a2b21a8b7CE76811C86D3a2C99301355").send();
        } catch (IOException e) {
            e.printStackTrace();
        }
        if (personalUnlockAccount.accountUnlocked()) {
            // send a transaction
            System.out.println("解锁成功");
            try {
                result = contract.createToken().send();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }else {
            System.out.println("解锁失败");
        }*/
        Uint256 result = null;
        try {
            result = contract.createToken().send();
        } catch (Exception e) {
            e.printStackTrace();
        }
        str =   String.valueOf(result.getValue().intValue());
        System.out.print(str);
        return str;
    }

    @RequestMapping("/gto")
    public  String tokensOfOwner( ){
        String str = "";
        Web3j web3j =  ConnectionUtils.getInstall();
        // 加载合约
        HelloWorldContract contract = HelloWorldContract.load(Consts.HELLOWORLD_ADDR, web3j, ConnectionUtils.getCredentials(),
                Consts.GAS_PRICE, Consts.GAS_LIMIT);
        Uint256 result = null;
        try {
            result = contract.tokensOfOwner("0x339177a6a2b21a8b7CE76811C86D3a2C99301355").send();
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println("1111111111111111");
        str = JSON.toJSONString(result);
        return str;
    }

    @RequestMapping("/count")
    public  String balanceOf(){
        String str = "";
        Web3j web3j =  ConnectionUtils.getInstall();
        // 加载合约
        HelloWorldContract contract = HelloWorldContract.load(Consts.HELLOWORLD_ADDR, web3j, ConnectionUtils.getCredentials(),
                Consts.GAS_PRICE, Consts.GAS_LIMIT);

        Uint256 result = null;
        try {
            result = contract.balanceOf("0x339177a6a2b21a8b7CE76811C86D3a2C99301355").send();
        } catch (Exception e) {
            e.printStackTrace();
        }
        str = JSON.toJSONString(result.getValue().intValue());
        return str;
    }


    @RequestMapping("/unlok")
    public  String unlok(){
        String str = "";
        Admin admin = ConnectionUtils.getInstallAdmin();
        PersonalUnlockAccount personalUnlockAccount = null;

        try {
            PersonalListAccounts accounts = admin.personalListAccounts().send();
            System.out.println("账户列表:"+JSON.toJSONString(accounts));
            System.out.println("账户地址："+accounts.getId());
            //str = JSON.toJSONString(accounts);
            personalUnlockAccount = admin.personalUnlockAccount("Liuw33024892", "0xd3ee6bbe053a2510a2ae8faf58ebabecebb624c3").send();
        } catch (IOException e) {
            e.printStackTrace();
        }
        if (personalUnlockAccount.accountUnlocked()) {
            // send a transaction
            System.out.println("解锁成功"+personalUnlockAccount.accountUnlocked());
        }else {
            System.out.println("解锁失败");
        }
        return str;
    }

    /**
     * 转移token
     * account3 : 0x2a307FBf59490c210eED8c29980FbB80640a9F10
     * @return
     */
    @RequestMapping("/tras")
    public  String transfer(){
        Web3j web3j =  ConnectionUtils.getInstall();
        // 加载合约
        HelloWorldContract contract = HelloWorldContract.load(Consts.HELLOWORLD_ADDR, web3j, ConnectionUtils.getCredentials(),
                Consts.GAS_PRICE, Consts.GAS_LIMIT);
        String str = "";
        TransactionReceipt transactionReceipt = null;
        try {
            transactionReceipt = contract.transfer(2,"0x2a307FBf59490c210eED8c29980FbB80640a9F10").send();
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println("waiting..."); // 进入阻塞
        System.out.println("set : " + transactionReceipt.getTransactionHash());
        str = transactionReceipt.getTransactionHash();
        return str;
    }

    @RequestMapping("/ct2")
    public  String createToken2( ){
        String str = "";
        Web3j web3j =  ConnectionUtils.getInstall();
        // 加载合约
        HelloWorldContract contract = HelloWorldContract.load(Consts.HELLOWORLD_ADDR, web3j, ConnectionUtils.getCredentials(),
                Consts.GAS_PRICE, Consts.GAS_LIMIT);

        TransactionReceipt transactionReceipt = null;
        try {
            transactionReceipt = contract.createToken2().send();
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println("waiting..."); // 进入阻塞
        System.out.println("set : " + transactionReceipt.getTransactionHash());
        str = transactionReceipt.getTransactionHash();
        return str;
    }

}

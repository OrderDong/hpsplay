package com.block.eth.contract;

import com.alibaba.fastjson.JSON;
import com.block.eth.util.Consts;
import org.web3j.abi.datatypes.generated.Uint256;
import org.web3j.crypto.Credentials;
import org.web3j.crypto.ECKeyPair;
import org.web3j.crypto.WalletUtils;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.methods.response.Transaction;
import org.web3j.protocol.http.HttpService;
import org.web3j.utils.Numeric;

/**
 * @author littleredhat
 * <p>
 * 部署合约方式：
 * 一、wallet 部署
 * 二、geth 部署
 * 三、web3j 部署
 */
public class MainTest {

    public static void main(String[] args) throws Exception {

        String privateKey = "4f74868ca57f26ba012c0d2f3f36b0dc45b97628c136b4f8be94b3590423f989";
        String publicKey = "0x339177a6a2b21a8b7CE76811C86D3a2C99301355";

        ECKeyPair keyPair = new ECKeyPair(Numeric.toBigInt(privateKey), Numeric.toBigInt(publicKey));
        Credentials credentials = Credentials.create(keyPair);
        // 获取凭证
        //Credentials credentials = WalletUtils.loadCredentials(Consts.PASSWORD, Consts.PATH);
        System.out.println("getCredentialsAddress : " + credentials.getAddress());

        // defaults to http://localhost:8545/
        String url = "https://ropsten.infura.io/"+publicKey;
        Web3j web3j = Web3j.build(new HttpService(url));

        //Transaction result1 = web3j.ethGetTransactionByHash("0x99982abeaf7d9e8a86133fadc685fb3095090a28b1ccc133480875649a859931").send().getResult();
//        System.out.println(JSON.toJSONString(result1));
        //查看余额


        // 加载合约
        HelloWorldContract contract = HelloWorldContract.load(Consts.HELLOWORLD_ADDR, web3j, credentials,
                Consts.GAS_PRICE, Consts.GAS_LIMIT);
        System.out.println("getContractAddress : " + contract.getContractAddress());
        System.out.println("isValid : "+ contract.isValid());

        ////////// 同步请求方式 //////////
        // get
       /* Uint256 result = contract.balanceOf(publicKey).send();*/
        Uint256 result = contract.createToken().send();
        System.out.println("waiting..."); // 进入阻塞
        System.out.println("get : " + result.getValue().intValue());

        ////////// 异步请求方式 //////////
        // get
        /*
        CompletableFuture<Uint256> resultAsync = contract.get().sendAsync();
        System.out.println("waiting..."); // 马上返回
        System.out.println("get : " + resultAsync.get().getValue().intValue());
        */
    }
}

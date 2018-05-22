const MyNonFungibleToken = artifacts.require('./MyNonFungibleToken.sol')

module.exports = (deployer) => {
  deployer.deploy(MyNonFungibleToken);
}

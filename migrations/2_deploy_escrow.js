var EscrowController = artifacts.require('EscrowController.sol')

module.exports = function(deployer) {
  deployer.deploy(EscrowController)
}
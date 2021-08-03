/* global ethers, network */
const { expect } = require('chai')
const { getFTContractAddress } = require('./utils')
const CONTRACT_ADDRESS = getFTContractAddress(network.name)

// see: https://github.com/mawrkus/js-unit-testing-guide
describe('ERC20Swapper', function () {
  let token
  let owner, account1
  const txOptions = {}

  before(async function () {
    [owner, account1] = await ethers.getSigners()
    txOptions.gasPrice = await ethers.provider.getGasPrice()
    const Token = await ethers.getContractFactory('ERC20Swapper')
    token = Token.attach(CONTRACT_ADDRESS)
  })

  describe('Swap', function () {
    it('should revert invalid token address', async function () {
      // This test is not passing
      // just an example how can be tested
      const tokenAddress = '0xfA3E941D1F6B7b10eD84A0C211bfA8aeE907965e'
      const currentTokens = await token.swapEtherToToken(tokenAddress, 10)
      expect(currentTokens.wait()).to.be.reverted
    })
  })

})

/* global task, ethers */

require('dotenv').config()

require('@nomiclabs/hardhat-waffle')
require('hardhat-gas-reporter')
require('solidity-coverage')
require('hardhat-contract-sizer')
require('@openzeppelin/hardhat-upgrades')

const ROPSTEN_ALCHEMY_API_KEY = process.env.ROPSTEN_ALCHEMY_API_KEY
const HARDHAT_AUTOMINE = process.env.HARDHAT_AUTOMINE
const OWNER_KEY = process.env.OWNER_KEY
const SECONDARY_KEY = process.env.SECONDARY_KEY

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async () => {
  const accounts = await ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

if (HARDHAT_AUTOMINE === 'true' && !process.env.CI) {
  console.warn('WARN: HARDHAT_AUTOMINE is on. This should only be in CI or selectively on local')
}

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

module.exports = {
  solidity: {
    version: '0.8.6',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  gasReporter: {
    enabled: true,
    currency: 'EUR',
    showTimeSpent: true,
    coinmarketcap: '6ffc3d5b-865e-482d-a05c-144ba7fe319e'
  },
  networks: {
    hardhat: {
      mining: {
        auto: false,
        interval: (HARDHAT_AUTOMINE === 'true') ? 100 : [500, 2000]
      },
      throwOnTransactionFailures: true,
      throwOnCallFailures: true
    }
  },
  mocha: {
    timeout: 0
  }
}

module.exports.networks = {
  ...{
    ropsten: {
      url: `https://eth-ropsten.alchemyapi.io/v2/${ROPSTEN_ALCHEMY_API_KEY}`,
      from: `0x${OWNER_KEY}`,
      accounts: [`0x${OWNER_KEY}`, `0x${SECONDARY_KEY}`],
      gas: 8000000,
      timeout: 60 * 1000
    },
    ...module.exports.networks
  }
}

const { ethers, network, upgrades } = require('hardhat') // eslint-disable-line
const { getFTContractAddress, runUpgradeTest, } = require('../test/utils') // eslint-disable-line

async function main () {
  const ERC20Swapper= await ethers.getContractFactory('ERC20Swapper')
  const currentContract = getFTContractAddress(network.name)
  const attachedContract = ERC20Swapper.attach(currentContract) // eslint-disable-line

  // Current contract
  const version = await attachedContract.version()
  console.log('>> Current version:', version)

  // Upgraded contract
  const upgraded = await upgrades.upgradeProxy(currentContract, ERC20Swapper)
  await runUpgradeTest(version, upgraded)

  console.log(' > ERC20Swapper upgraded')
  process.stdout.write(upgraded.address)
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })

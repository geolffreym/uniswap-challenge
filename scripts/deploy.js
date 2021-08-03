const { ethers, network, upgrades } = require('hardhat')
const { writeInEnv } = require('./utils')

async function main () {
  const ERC20Swapper = await ethers.getContractFactory('ERC20Swapper')
  const swapper = await upgrades.deployProxy(ERC20Swapper, { initializer: 'initialize' })
  const currentNetwork = network.name.toUpperCase()

  if (!process.env.CI) {
    // Write in env if not CI workflow env
    writeInEnv({ [`${currentNetwork}_CONTRACT`]: swapper.address })
  }

  console.log(`${network.name}:swapper:${swapper.address}`)
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })

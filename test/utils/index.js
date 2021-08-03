function getFTContractAddress (networkName) {

  if (networkName === 'ropsten') {
    return process.env.ROPSTEN_CONTRACT
  }

  return process.env.LOCALHOST_CONTRACT
}

async function runUpgradeTest (version, upgraded) {
  const upgrade = await upgraded.upgrade()
  await upgrade.wait() // wait for tx
  const newVersion = await upgraded.version()

  if (+version === +newVersion) {
    console.error('expected version to increment')
    process.exit(1)
  } else {
    console.log(' > version state passed')
  }
}

module.exports = {
  runUpgradeTest,
  getFTContractAddress
}

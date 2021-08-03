# Include env file
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

.PHONY: test
test: deps
	npx hardhat test --network localhost

clean:
	rm -rf cache
	rm -rf artifacts
	rm -rf node_modules
	rm -rf package-lock.json
	docker-compose down

node_modules:
	# --legacy-peer-deps is required
	#  for now, hopefully not forever.
	npm install --legacy-peer-deps

deps: node_modules
	docker-compose up -d
	npx hardhat compile
	npx hardhat run --network localhost scripts/deploy.js


deploy-ropsten:
	npx hardhat run ./scripts/deploy.js --network ropsten

deploy-all: rebuild deploy-ropsten


upgrade-ropsten:
	npx hardhat run ./scripts/upgrade.js --network ropsten

upgrade-all: rebuild upgrade-ropsten

rebuild: clean deps

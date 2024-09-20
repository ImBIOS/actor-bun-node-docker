# Environment values
# Bun
BUN_VERSION ?= 1
# Node
NODE_VERSION ?= 20
# Tag must have format: v1.42.0-
PLAYWRIGHT_VERSION ?= v1.42.0-
# Tag must have format: 22.6.2
PUPPETEER_VERSION ?= 22.6.2

ALL_TESTS = test-bun-node-puppeteer-chrome

what-tests:
	@echo "Available tests:"
	@for test in $(ALL_TESTS); do \
		echo "  $$test"; \
	done

all:
	@echo "Running all tests, this will take a while..."

	@for test in $(ALL_TESTS); do \
		echo "Running $$test"; \
		$(MAKE) $$test; \
		echo "Done $$test"; \
	done

	@echo ""
	@echo "All tests done!"

test-bun-node-puppeteer-chrome:
	@echo "Building bun-puppeteer-chrome with version $(PUPPETEER_VERSION) (overwrite using PUPPETEER_VERSION=22.6.2), bun version $(BUN_VERSION), and node version $(NODE_VERSION) (overwrite using NODE_VERSION=XX)"

	@# Correct package.json
	@jq ".dependencies.apify = \"latest\" | .dependencies.crawlee = \"latest\" | .dependencies.puppeteer = \"${PUPPETEER_VERSION}\"" ./bun-node-puppeteer-chrome/package.json > ./bun-node-puppeteer-chrome/package.json.tmp && mv ./bun-node-puppeteer-chrome/package.json.tmp ./bun-node-puppeteer-chrome/package.json

	docker buildx build --build-arg NODE_VERSION=$(NODE_VERSION) --file ./bun-node-puppeteer-chrome/Dockerfile --tag imbios/bun-node-puppeteer-chrome:local --load ./bun-node-puppeteer-chrome
	docker run --rm -it --platform linux/amd64 imbios/bun-node-puppeteer-chrome:local

	@# Restore package.json
	@git checkout ./bun-node-puppeteer-chrome/package.json 1>/dev/null 2>&1

	@# Delete docker image
	docker rmi imbios/bun-node-puppeteer-chrome:local

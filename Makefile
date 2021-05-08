
.PHONY: help check clean fetch-dependencies docker-build build-lambda-package

help:
	@python -c 'import fileinput,re; \
	ms=filter(None, (re.search("([a-zA-Z_-]+):.*?## (.*)$$",l) for l in fileinput.input())); \
	print("\n".join(sorted("\033[36m  {:25}\033[0m {}".format(*m.groups()) for m in ms)))' $(MAKEFILE_LIST)

check:		## print versions of required tools
	@docker --version
	@docker-compose --version
	@python3 --version

clean:		## delete pycache, build files
	@rm -rf build build.zip
	@rm -rf __pycache__

fetch-dependencies:		## download chromedriver, headless-chrome to `./bin/`
	@mkdir -p bin/

	# Get chromedriver
	# TODO: update headless chrome version to work with 91.* version of chrome driver
	curl -SL https://chromedriver.storage.googleapis.com/86.0.4240.22/chromedriver_linux64.zip > chromedriver.zip
	unzip chromedriver.zip -d bin/

	# Get Headless-chrome
	curl -SL https://github.com/adieuadieu/serverless-chrome/releases/download/v1.0.0-57/stable-headless-chromium-amazonlinux-2.zip > headless-chromium.zip

	unzip headless-chromium.zip -d bin/

	# Clean
	@rm headless-chromium.zip chromedriver.zip

compose-build:
	docker-compose build

publish-image:
	docker tag ps5-plz_lambda:latest 291118487001.dkr.ecr.us-east-1.amazonaws.com/ps5-plz:latest
	docker push 291118487001.dkr.ecr.us-east-1.amazonaws.com/ps5-plz:latest

local-run:
	docker-compose run local python3.8 src/purchase/lambda.py

debug:
	docker-compose run debug python3.8 src/purchase/lambda.py
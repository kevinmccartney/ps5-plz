
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
	curl -SL https://chromedriver.storage.googleapis.com/91.0.4472.19/chromedriver_linux64.zip > chromedriver.zip
	unzip chromedriver.zip -d bin/

	# Get Headless-chrome
	curl -SL https://github.com/adieuadieu/serverless-chrome/releases/download/v1.0.0-57/stable-headless-chromium-amazonlinux-2.zip > headless-chromium.zip
	unzip headless-chromium.zip -d bin/

	# Clean
	@rm headless-chromium.zip chromedriver.zip

compose-build:
	docker-compose build

local-run:
	docker-compose run local python3.8 src/purchase/lambda.py

debug:
	docker-compose run debug python3.8 src/purchase/lambda.py

build-lambda-package: clean fetch-dependencies			## prepares zip archive for AWS Lambda deploy (-> build/build.zip)
	mkdir build
	cp -r src/* build/.
	cp -r bin build/.
	pip install -r requirements.txt -t build/lib/.
	chmod -R 777 build
	cd build; zip -9qr latest.zip .
	cp build/latest.zip .
	rm -rf build

.PHONY: help check clean fetch-dependencies docker-build build-lambda-package

help:
	@python -c 'import fileinput,re; \
	ms=filter(None, (re.search("([a-zA-Z_-]+):.*?## (.*)$$",l) for l in fileinput.input())); \
	print("\n".join(sorted("\033[36m  {:25}\033[0m {}".format(*m.groups()) for m in ms)))' $(MAKEFILE_LIST)

check:		## print versions of required tools
	@docker --version
	@docker-compose --version
	@python3 --version

image-build:
	docker-compose build

image-publish:
	docker tag ps5-plz_lambda:latest 291118487001.dkr.ecr.us-east-1.amazonaws.com/ps5-plz:latest
	docker push 291118487001.dkr.ecr.us-east-1.amazonaws.com/ps5-plz:latest

image-run:
	docker-compose run lambda

registry-authenticate:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 291118487001.dkr.ecr.us-east-1.amazonaws.com

lambda-request:
	curl -v -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"payload":"hello world!"}'

# local-run:
# 	docker-compose run local python3.8 src/purchase/lambda.py

# debug:
# 	docker-compose run debug python3.8 src/purchase/lambda.py
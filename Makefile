.PHONY: help install bootstrap build test deploy clean logs

# Default target
help:
	@echo "Available targets:"
	@echo "  install       - Install all dependencies"
	@echo "  bootstrap     - Bootstrap AWS CDK and install dependencies"
	@echo "  build         - Build all packages"
	@echo "  test          - Run all tests"
	@echo "  test-unit     - Run unit tests only"
	@echo "  test-e2e      - Run end-to-end tests"
	@echo "  lint          - Run linting"
	@echo "  format        - Format code"
	@echo "  deploy-dev    - Deploy to development environment"
	@echo "  deploy-staging - Deploy to staging environment"
	@echo "  deploy-prod   - Deploy to production environment"
	@echo "  diff          - Show CDK diff for all stacks"
	@echo "  synth         - Synthesize CDK stacks"
	@echo "  clean         - Clean all build artifacts"
	@echo "  logs          - Tail CloudWatch logs"
	@echo "  webhook-test  - Test webhook locally"

# Installation and setup
install:
	npm install

bootstrap: install
	npm run bootstrap

# Build targets
build:
	npm run build

build-shared:
	npm run build:shared

build-services:
	npm run build:services

build-infra:
	npm run build:infra

# Testing
test:
	npm test

test-unit:
	npm run test:unit

test-integration:
	npm run test:integration

test-e2e:
	cd tests && npm test

# Code quality
lint:
	npm run lint

format:
	npm run format

format-check:
	npm run format:check

# Deployment
deploy-dev:
	npm run deploy:dev

deploy-staging:
	npm run deploy:staging

deploy-prod:
	npm run deploy:prod

diff:
	npm run diff

synth:
	npm run synth

# Utilities
clean:
	npm run clean
	rm -rf cdk.out
	find . -name "*.js" -not -path "./node_modules/*" -not -name "jest.config.js" -delete
	find . -name "*.d.ts" -not -path "./node_modules/*" -delete

logs:
	npm run logs

webhook-test:
	npm run webhook:test

# Docker local development
docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

docker-logs:
	docker-compose logs -f

# AWS specific commands
aws-login:
	aws sso login

aws-whoami:
	aws sts get-caller-identity

# Environment setup
setup-secrets-dev:
	scripts/setup/create-secrets.sh dev

setup-secrets-staging:
	scripts/setup/create-secrets.sh staging

setup-secrets-prod:
	scripts/setup/create-secrets.sh prod
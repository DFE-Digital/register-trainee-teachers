.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z\.\-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Create a new image
	touch .env ## Create an empty .env file if it does not exist
	docker-compose build

.PHONY: dbsetup
dbsetup: build ## Set up a clean database
	docker-compose down -v
	docker-compose run --rm web bundle exec rake db:setup

.PHONY: serve
serve: ## Run the service
	docker-compose up

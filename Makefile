SHELL := /bin/zsh
NS ?= onekenken
VERSION ?= latest
IMAGE_NAME ?= postgres-student-image
CONTAINER_NAME ?= sparkify-db
CONTAINER_INSTANCE ?= default
PORTS ?= 5432:5432

.PHONY: pull run clean start test

pull:
	docker login
	docker pull $(NS)/$(IMAGE_NAME)

run:
	docker run -d --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -p $(PORTS) $(NS)/$(IMAGE_NAME):$(VERSION)

clean:
	docker stop $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)
	docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

# TODO: Figure out how to check for running container before testing
# container-check: export CONTAINER_NAME_ENV = $(CONTAINER_NAME)
# 	@ if [ ! $(docker ps -a | grep $(CONTAINER_NAME_ENV))]; then \
# 		echo "Container not running!"; \
# 		exit 1; \
# 	fi

test: container-check
	@python create_tables.py
	@ipython test.ipynb

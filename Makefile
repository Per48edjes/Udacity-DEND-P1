SHELL := /bin/zsh
NS ?= onekenken
VERSION ?= latest
IMAGE_NAME ?= postgres-student-image
CONTAINER_NAME ?= sparkify-db
CONTAINER_INSTANCE ?= default
PORTS ?= 5432:5432

.PHONY: pull run clean test

pull:
	docker login
	docker pull $(NS)/$(IMAGE_NAME)

run: pull
	docker run -d --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) -p $(PORTS) $(NS)/$(IMAGE_NAME):$(VERSION)

clean:
	docker stop $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)
	docker rm $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)

test:
	@python create_tables.py
	@python etl.py
	@ipython test.ipynb

DOCKER_REPO ?= matteocng/travis-test
IMAGE_VERSION = "1.0.0" # the one in package.json
GIT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)

#$(warning $(shell env))
$(warning "DEBUG: GIT BRANCH" $(GIT_BRANCH))

ifeq ($(GIT_BRANCH), master)
$(warning "DEBUG: IS GIT MASTER TRUE")
	IS_GIT_MASTER ?= true
	_BRANCH_TAG ?= latest # e.g matteocng/travis-test:latest
	_VERSION_TAG ?= $(IMAGE_VERSION) # e.g matteocng/travis-test:1.0.6
$(warning DEBUG: _BRANCH_TAG: $(_BRANCH_TAG))
$(warning DEBUG: _VERSION_TAG_ $(_VERSION_TAG))
else
$(warning DEBUG: IS GIT MASTER FALSE)
	_BRANCH_TAG ?= $(GIT_BRANCH) # e.g matteocng/travis-test:dev
	_VERSION_TAG ?= $(GIT_BRANCH)-$(IMAGE_VERSION) # e.g matteocng/travis-test:dev-1.0.6
$(warning DEBUG: _BRANCH_TAG: $(_BRANCH_TAG))
$(warning DEBUG: _VERSION_TAG_ $(_VERSION_TAG))
endif

DOCKER_BRANCH_TAG ?= $(DOCKER_REPO):$(_BRANCH_TAG)
DOCKER_VERSION_TAG ?= $(DOCKER_REPO):$(_VERSION_TAG)

.PHONY: all clean lint build build_travis test

all: build

build: lint
	docker build -t $(DOCKER_BRANCH_TAG) .
	docker tag $(DOCKER_BRANCH_TAG) $(DOCKER_VERSION_TAG) # e.g matteocng/travis-test:1.0.6
	$(eval IMAGE_SIZE := $(shell docker run --rm --entrypoint=/bin/sh $(DOCKER_BRANCH_TAG) -c 'du -sh / 2>/dev/null | cut -f1'))
	@echo "Image size "$(IMAGE_SIZE)

build_travis: lint
	docker build -t $(DOCKER_BRANCH_TAG) .
	docker tag $(DOCKER_BRANCH_TAG) $(DOCKER_REPO):$(TRAVIS_COMMIT_SHORT) # e.g matteocng/travis-test:93c5b371
	docker tag $(DOCKER_BRANCH_TAG) $(DOCKER_REPO):travis-$(TRAVIS_BUILD_NUMBER)  # e.g matteocng/travis-test:travis-4

clean:
	docker images $(DOCKER_REPO) | grep -q $(_BRANCH_TAG) && docker rmi $(DOCKER_BRANCH_TAG) || true
	docker images $(DOCKER_REPO) | grep -q $(_VERSION_TAG) && docker rmi $(DOCKER_VERSION_TAG) || true

lint:
	docker run --rm -t -v $(CURDIR):/mnt/df koalaman/shellcheck /mnt/df/entrypoint.sh # -i ?
	docker run --rm -t -v $(CURDIR):/mnt/df lukasmartinelli/hadolint bash -c "hadolint --ignore DL3002 --ignore DL4000 /mnt/df/Dockerfile" # -i ?

push:
	ifdef DOCKER_USERNAME
		docker login -u=$(DOCKER_USERNAME) -p=$(DOCKER_PASSWORD)
		docker push $(DOCKER_REPO) # TODO: check
	else
		$(error "Define DOCKER_USERNAME and DOCKER_PASSWORD to push $(DOCKER_REPO) to the Docker registry")
	endif

test:
	bats test # Test the Dockerfile

#!/usr/bin/env bats
DOCKER_IMAGE_NAME="matteocng/travis-test"
YARN_VERSION="0.18.1"

@test "With no cmd/args, the image runs yarn" {
	docker run -t "${DOCKER_IMAGE_NAME}" | grep "yarn install"
}

@test "The correct version of yarn is installed" {
	docker run -t "${DOCKER_IMAGE_NAME}" yarn -V | grep "${YARN_VERSION}"
}

@test "The npm command is symlinked to yarn" {
	docker run -t "${DOCKER_IMAGE_NAME}" npm -V | grep "${YARN_VERSION}"
}

@test "The entrypoint script can match and exec package.json scripts" {
  SCRIPTS=("lorem" "ipsum" "ipsum:dolor" "lorem:ipsum dolor" "vestibulum:varius_porttitor")

  for A_SCRIPT in "${SCRIPTS[@]}"
  do
		GREP="$A_SCRIPT ok"
		docker run -w /app -v "$BATS_TEST_DIRNAME/dummy-package.json":/app/package.json -t "${DOCKER_IMAGE_NAME}" "${A_SCRIPT}" | grep "${GREP}"
  done
}

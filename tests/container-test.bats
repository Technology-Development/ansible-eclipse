#!/usr/bin/env bats

# https://github.com/tutumcloud/tutum-fedora
DOCKER_IMAGE="tutum/fedora:21"
SSH_PUBLIC_KEY_FILE=~/.ssh/id_rsa.pub
DOCKER_CONTAINER_NAME="fedora-ansible-eclipse-role-test"

setup() {
  docker ps -q | grep $DOCKER_CONTAINER_NAME | xargs -r docker stop > /dev/null
  docker ps -aq | grep $DOCKER_CONTAINER_NAME | xargs -r docker rm > /dev/null
  docker run --name $DOCKER_CONTAINER_NAME -d -p 5555:22 -e AUTHORIZED_KEYS="$(< $SSH_PUBLIC_KEY_FILE)" $DOCKER_IMAGE
}

@test "Role can be applied to container" {
  run ansible-playbook -i hosts test.yml
}

@test "Role is idempotent" {
  run time ansible-playbook -i hosts test.yml
  run time ansible-playbook -i hosts test.yml
  [[ $output =~ changed=0.*unreachable=0.*failed=0 ]]
}

teardown() {
  docker stop $DOCKER_CONTAINER_NAME > /dev/null
  docker rm $DOCKER_CONTAINER_NAME > /dev/null
}

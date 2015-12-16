#!/usr/bin/env bats

# testing requirements: docker, ansible, xargs, grep, (python/pip/shyaml)

# https://github.com/tutumcloud/tutum-fedora
DOCKER_IMAGE="alzadude/tutum-fedora-java:21"
SSH_PUBLIC_KEY_FILE=~/.ssh/id_rsa.pub
DOCKER_CONTAINER_NAME="fedora-ansible-eclipse-role-test"

docker_exec() {
  docker exec $DOCKER_CONTAINER_NAME $@
}

setup() {
  docker ps -q -f name=$DOCKER_CONTAINER_NAME | xargs -r docker stop > /dev/null
  docker ps -aq -f name=$DOCKER_CONTAINER_NAME | xargs -r docker rm > /dev/null
  docker run --name $DOCKER_CONTAINER_NAME -d -p 5555:22 -e AUTHORIZED_KEYS="$(< $SSH_PUBLIC_KEY_FILE)" $DOCKER_IMAGE
}

@test "Role can be applied to container" {
  ansible-playbook -i hosts test.yml
  docker_exec test -f /usr/local/eclipse-platform-4.4.2-linux-gtk-x86_64/eclipse
  docker_exec alternatives --display eclipse | grep "link currently points to /usr/local/eclipse-platform-4.4.2-linux-gtk-x86_64"
}

@test "Override default eclipse url" {
  ansible-playbook -i hosts --extra-vars "eclipse_url=http://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-4.5-201506032000/eclipse-platform-4.5-linux-gtk-x86_64.tar.gz&r=1" test.yml
  docker_exec test -f /usr/local/eclipse-platform-4.5-linux-gtk-x86_64/eclipse
  docker_exec alternatives --display eclipse | grep "link currently points to /usr/local/eclipse-platform-4.5-linux-gtk-x86_64"
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

#!/usr/bin/env bats

# testing requirements: docker, ansible, grep, (python/pip/shyaml)

# https://github.com/tutumcloud/tutum-fedora
readonly docker_image="tutum/fedora:21"
readonly docker_container_name="ansible-eclipse"

docker_exec() {
  docker exec $docker_container_name $@
}

docker_exec_q() {
  docker exec $docker_container_name $@ > /dev/null
}

setup() {
  local _ssh_public_key=~/.ssh/id_rsa.pub
  docker run --name $docker_container_name -d -p 5555:22 -e AUTHORIZED_KEYS="$(< $_ssh_public_key)" -v $docker_container_name:/var/cache/yum/x86_64/21/ $docker_image
  docker_exec_q sed -i -e 's/keepcache=\(.*\)/keepcache=1/' /etc/yum.conf
  docker_exec_q yum -y install deltarpm java-headless
}

@test "Role can be applied to container" {
  ansible-playbook -i hosts test.yml
  docker_exec_q test -f /usr/local/eclipse-platform-4.5.1-linux-gtk-x86_64/eclipse
  docker_exec alternatives --display eclipse | grep "/usr/local/eclipse-platform-4.5.1-linux-gtk-x86_64"
}

@test "Override default eclipse url" {
  ansible-playbook -i hosts --extra-vars "eclipse_url=http://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-4.5-201506032000/eclipse-platform-4.5-linux-gtk-x86_64.tar.gz&r=1" test.yml
  docker_exec_q test -f /usr/local/eclipse-platform-4.5-linux-gtk-x86_64/eclipse
  docker_exec alternatives --display eclipse | grep "/usr/local/eclipse-platform-4.5-linux-gtk-x86_64"
}

@test "Role is idempotent" {
  run ansible-playbook -i hosts test.yml
  run ansible-playbook -i hosts test.yml
  [[ $output =~ changed=0.*unreachable=0.*failed=0 ]]
}

teardown() {
  docker stop $docker_container_name > /dev/null
  docker rm $docker_container_name > /dev/null
}

#!/usr/bin/env bats

# dependencies of this test: bats, ansible, docker, grep
# control machine requirements for playbook under test: ???

load 'bats-ansible/load'

setup() {
  container=$(container_startup fedora)
  hosts=$(tmp_file $(container_inventory $container))
  container_dnf_conf $container keepcache 1
  container_dnf_conf $container metadata_timer_sync 0
#  container_exec_sudo $container dnf -q -y install java-headless
}

@test "Role can be applied to container" {
  ansible-playbook -i $hosts ${BATS_TEST_DIRNAME}/test.yml
  container_exec $container test -f /usr/local/eclipse-platform-4.5.2-linux-gtk-x86_64/eclipse
  container_exec_sudo $container alternatives --display eclipse | grep "/usr/local/eclipse-platform-4.5.2-linux-gtk-x86_64"
}

@test "Override default eclipse url" {
  ansible-playbook -i $hosts --extra-vars "eclipse_url=http://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-4.5.2-201602121500/eclipse-platform-4.5.2-linux-gtk.tar.gz&r=1" ${BATS_TEST_DIRNAME}/test.yml
  container_exec $container test -f /usr/local/eclipse-platform-4.5.2-linux-gtk/eclipse
  container_exec_sudo $container alternatives --display eclipse | grep "/usr/local/eclipse-platform-4.5.2-linux-gtk"
}

@test "Role is idempotent" {
  run ansible-playbook -i $hosts ${BATS_TEST_DIRNAME}/test.yml
  run ansible-playbook -i $hosts ${BATS_TEST_DIRNAME}/test.yml
  [[ $output =~ changed=0.*unreachable=0.*failed=0 ]]
}

teardown() {
  container_cleanup
}

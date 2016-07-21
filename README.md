ansible-eclipse
===============

[![Build Status](https://travis-ci.org/alzadude/ansible-eclipse.svg?branch=master)](https://travis-ci.org/alzadude/ansible-eclipse)

A role for installing Eclipse, including sudo configuration, `PATH` environment and desktop launcher.

Notes:

  - The alternatives system is used to allow multiple Eclipse packages to be installed concurrently.
  - The `secure_path` for sudo is modifed to include the Eclipse installation path (this is required by the related [ansible-eclipse-director](https://github.com/alzadude/ansible-eclipse-director) role).

Requirements
------------

Currently the role has only been tested against Fedora (23) hosts, but in theory should work for all Linux variants. 

Role Variables
--------------

- `eclipse_url` - Download link for the Eclipse package. Defaults to the link for the Eclipse Platform Binary package, `http://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-4.5.1-201509040015/eclipse-platform-4.5.1-linux-gtk-x86_64.tar.gz&r=1`

Dependencies
------------

This role has no role dependencies.

Installation
------------

Install from Ansible Galaxy by executing the following command:

```
ansible-galaxy install alzadude.eclipse
```

Example Playbook
----------------

The following playbook gives an example of usage, installing an alternate, non-default Eclipse package (in this case, the 'Eclipse IDE for Java Developers' package).

Save the following configuration into files with the specified names:

**playbook.yml:**
```
---

- hosts: linux-workstation
  sudo: yes

  roles:
    - { alzadude.eclipse, eclipse_url: http://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/mars/2/eclipse-java-mars-2-linux-gtk-x86_64.tar.gz&r=1 }
```

**hosts:**

```
# Dummy inventory for ansible
linux-workstation ansible_host=localhost ansible_connection=local
```
Then run the playbook with the following command:
```
ansible-playbook -i hosts playbook.yml
```

License
-------

MIT


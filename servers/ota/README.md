# Disinfo.quaidorsay.fr-ops

Recipes to setup infrastructure and deploy disinfo.quaidorsay.fr website and API

> Recettes pour mettre en place l'infrastructure et déployer le site web et l'API de disinfo.quaidorsay.fr

## Requirements

- Install [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- Install required Ansible roles `ansible-galaxy install -r requirements.yml`

See [troubleshooting](#troubleshooting) in case of errors

### [For development only] Additionals dependencies

To test the changes without impacting the production server, a Vagrantfile is provided to test the changes locally in a virtual machine. VirtualBox and Vagrant are therefore required.

- Install [VirtualBox](https://www.vagrantup.com/docs/installation/)
- Install [Vagrant](https://www.vagrantup.com/docs/installation/)

## Configuration

### Allow decrypting all sensitive data.

A password is needed to decrypt encrypted files with [`ansible-vault`](https://docs.ansible.com/ansible/latest/user_guide/vault.html).
Get the password from the administrator and copy it in a `vault.key` file at the root of this project, it will avoid entering it every time you run a command.

### [For developement only] Configure your host machine to access the VM.

Edit your hosts file `/etc/hosts`, add the following line so you can connect to the VM to test deployed apps from your host machine's browser:

```
192.168.33.12    ota.local
```

Now on your browser you will be able to access deployed app on the VM with the URL `http://ota.local` to mimic the real architecture of our servers

The guest VM's IPs can be changed in the `VagrantFile`:

## Usage

To avoid making changes on the production server by mistake, by default all commands will only affect the vagrant developement VM. Note that the VM needs to be started before with `vagrant up`.\
To execute commands on the production server you should specify it by adding the option `-i servers/ota/inventories/production.yml` to the following commands.

- **Setup a phoenix server:**

```
ansible-playbook servers/ota/playbooks/site.yml
```

- **Setup infrastructure only:**

```
ansible-playbook servers/ota/playbooks/infra.yml
```

- **Setup apps only:**

```
ansible-playbook servers/ota/playbooks/apps.yml
```

- **Setup one sub part of the infra:**

```
ansible-playbook servers/ota/playbooks/infra/<MODULE>.yml
```

_You can find all available modules in `servers/ota/playbooks/infra` directory._

For example, to setup only nginx on the new server:

```
ansible-playbook servers/ota/playbooks/infra/nginx.yml
```

### Options and tags

#### Options

Ansible provide among many others the following useful options:

- `--diff`: to see what changed.
- `--check`: to simulate execution.
- `--check --diff`: to see what will be changed.

For example, if you modify the nginx config and you want to see what will be changed you can run:

```
ansible-playbook servers/ota/playbooks/infra/nginx.yml --check --diff
```

#### Tags

Some tags are available to refine what will happen, use them with `-t`:

- `setup`: to only setup system dependencies required by the app(s) (cloning repo, installing app dependencies, all config files, and so on…)
- `start`: to start the app(s)
- `stop`: to stop the app(s)
- `restart`: to restart the app(s)
- `update`: to update the app(s) (pull code, install dependencies and restart app)

For example, you can update all apps by running:

```
ansible-playbook servers/ota/playbooks/apps.yml -t update
```

…or update only `media-scale`:

```
ansible-playbook servers/ota/playbooks/apps/media-scale.yml -t update
```

…or restart only `panoptes`:

```
ansible-playbook servers/ota/playbooks/apps/panoptes.yml -t restart
```

### commands

In order to deploy here are the corresponding commands
TODO: make a deploy script

```
deploy:local:ota		    ansible-playbook servers/ota/site.yml   -i servers/ota/inventories/dev-fix.yml
deploy:local:ota:nginx      ansible-playbook servers/ota/playbooks/infra/nginx.yml -i servers/ota/inventories/dev-fix.yml
deploy:local:ota:docker     ansible-playbook servers/ota/playbooks/infra/docker.yml -i servers/ota/inventories/dev-fix.yml
deploy:ota          	    ansible-playbook servers/ota/site.yml -i servers/ota/inventories/production.yml --check --diff
deploy:ota:nginx            ansible-playbook servers/ota/playbooks/infra/nginx.yml -i servers/ota/inventories/production.yml --check --diff
deploy:ota:docker           ansible-playbook servers/ota/playbooks/infra/docker.yml -i servers/ota/inventories/production.yml --check --diff

deploy:local:ota	          ansible-playbook servers/ota/site.yml -i servers/ota/servers/ota/inventories/dev-fix.yml
deploy:ota       	          ansible-playbook servers/ota/site.yml -i servers/ota/servers/ota/inventories/production.yml --check --diff
```

### Troubleshooting

#### Failed to connect to the host via ssh: Received disconnect from 127.0.0.1 port 2222:2: Too many authentication failures

Modify ansible ssh options to the `servers/ota/inventories/dev.yml` file like this:

```
all:
  children:
    dev:
      hosts:
        '127.0.0.1':
          […]
          ansible_ssh_private_key_file: .vagrant/machines/default/virtualbox/private_key
          ansible_ssh_extra_args: -o StrictHostKeyChecking=no -o IdentitiesOnly=yes
          […]
```

Or alternatively you can use the dev-fix config by appending `-i ops/servers/ota/inventories/dev-fix.yml`

#### ansible: command not found

if you're on mac OSX and tried to install with `pip install ansible`
you may need to add python's bin folder to your path with

```
export PATH=$PATH:/Users/<yourusername>/Library/Python/3.7/bin
```

#### ~/.netrc access too permissive: access permissions must restrict access to only the owner

on linux

```
chmod og-rw /home/<yourusername>/.netrc
```

on mac OSX

```
chmod og-rw /Users/<yourusername>/.netrc
```

#### <urlopen error [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer certificate (\_ssl.c:1123)>

on mac OSX, go to folder `/Applications/Python 3.9` and double click on `Install Certificates.command`

### An error occurred during the signature verification. GPG error

```
# https://www.linuxuprising.com/2019/06/fix-missing-gpg-key-apt-repository.html

sudo apt update 2>&1 1>/dev/null | sed -ne 's/.*NO_PUBKEY //p' | while read key; do if ! [[ ${keys[*]} =~ "$key" ]]; then sudo apt-key adv --keyserver hkp://pool.sks-keyservers.net:80 --recv-keys "$key"; keys+=("$key"); fi; done
sudo apt update 2>&1 1>/dev/null | sed -ne 's/.*NO_PUBKEY //p' | while read key; do if ! [[ ${keys[*]} =~ "$key" ]]; then sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys "$key"; keys+=("$key"); fi; done
```

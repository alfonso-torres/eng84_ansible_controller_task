# Ansible Task

### Task

![ANSIBLE_1](./Ansible_scheme.png)

Use ansible playbooks to launch 3 machines on AWS: a controller, a web-app and a database. Implement the 2 tier architecture as IAC with ansible Node app has to work with public IP and db working with /posts.

### Solution

__Steps__:

![STEPS](./steps.png)

__We are going to run our virtual machine, which we are going to use as a controller only to launch the three instances in AWS.__

- Let's run `vagrant up`. We have the Vagrantfile ready.

- Connect into the machine: `vagrant ssh controller`

- Run the followings commands:

````
sudo apt-get upgrade -y

sudo apt-get update -y

sudo apt-get install software-properties-common -y

sudo apt-add-repository ppa:ansible/ansible -y

sudo apt-get update -y

sudo apt-get install ansible -y

sudo apt-get install tree -y
````

- Check if ansible was installed: `ansible --version`

- Let's configure our vagrant vault. Run the following commands:

````
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
sudo apt install python3-pip -y
pip3 install awscli
pip3 install boto boto3
sudo apt-get update -y
sudo apt-get upgrade -y
````

- All the commands are available in the file `provision_controller.sh` if you want to install everything automatically.

- After installing everything, in the folder /etc/ansible, run:

````
sudo mkdir group_vars
cd group_vars
sudo mkdir all
cd all
````

- Then, we are going to create our file of ansible vault:

`sudo ansible-vault create pass.yml` -> write down a password

- Inside the file enter:

````
aws_access_key: THISISMYACCESSKEY
aws_secret_key: THISISMYSECRETKEY
````

Press Esc and then :wq to save the file.

- When we run our playbook, it will automatically check the AWS keys in the file we created earlier. It is going to decrypt it and check if it matches to create the instances.

- Run the next command: `sudo nano /etc/ansible/hosts`. Add the following line to resolve any dependencies:

````
[local]
localhost ansible_python_interpreter=/usr/bin/python3
````

- Let's create the playbook that is going to launch our instances. Go back to `cd /etc/ansible`

- Create the yml file: `sudo nano create_ec2_instances.yml`. You have the code/file available in this repository. Make sure you select the configuration related to your settings.

- If you would like to check the YAML syntax you can use syntax-check: `ansible-playbook create_ec2_instances.yml --syntax-check`.

- After writing down the syntax, we are going to check that we have no code bugs: `sudo ansible-playbook create_ec2_instances.yml --ask-vault-pass`. Enter the password.

- If everything is fine, let's go to run the playbook: `sudo ansible-playbook create_ec2_instance.yml --ask-vault-pass --tags create_ec2
`.

- Done. We have created our three instances on AWS through a playbook. Check that everything is correct in the AWS dashboard.

__Once we have our instances available, we proceed to connect to our controller instance as usual and install everything as we just did in our vagrant@controller, except ansible vault. We are going to use this instance as a controller to install all the corresponding in app and db using playbooks.__

- Once we have installed everything correctly, we proceed to connect to our app and db instances from the controller using ssh. We have to copy our key from our host to the instance using the following command:

`scp -i ~/.ssh/name_key.pem -r name_key.pem ubuntu@public_ip_controller:~/.ssh/`

- We proceed to connect to our app and db machine from the controller using ssh. We go to `~/.ssh /` and proceed to ssh as we have done previously to connect to our controller, using the public ip address of the app and db instances. Check that all the inbound rules are correctly configured in order to connect from the controller to the other machines.

- We go back to our controller and first run `sudo nano /etc/ansible/hosts`. Add the following lines:

````
[local]
localhost ansible_python_interpreter=/usr/bin/python3

[web]
private_ip_web_instance ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/name_key.pem

[db]
private_ip_db_instance ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/name_key.pem
````
This would allow us to have our machines reachable, with which we can run our playbooks on any of the machines. The Ansible inventory file defines the hosts and groups of hosts upon which commands, modules, and tasks in a playbook operate.

You can use your public or private ip address. I suggest using the private one for the reason that the public is modified every time we start the machine. If we have our inbound rules configured correctly, there is nothing to worry about.

- We are going to proceed to execute a ping to see if we have configured everything correctly: `ansible all -m ping`. If the result has been successful, it means that our controller has access to the instances via ssh to carry out any type of operation.

__We proceed to create the playbooks that are responsible for installing everything related to the application and the database, on their corresponding machines.__

1. We need to access in `/etc/ansible` of your controller instance: `cd /etc/ansible`.

2. Check that your hosts file is configured correctly so that we can access via ssh to our app and db instances. To check that run this commands:

`ansible all -m ping`

3. We are going to create the two playbooks that will help us automate the installation of all the necessary software on each of the machines, app and db:

- Web

`sudo nano playbook_web.yml`.

Inside of this file, write down all the code. This code is available on the file `playbook_web.yml` of this repository.

Check the syntax: `ansible-playbook playbook_web.yml --syntax-check`.

- Db

`sudo nano playbook_db.yml`.

Inside of this file, write down all the code. This code is available on the file `playbook_db.yml` of this repository.

Check the syntax: `ansible-playbook playbook_db.yml --syntax-check`.

Make sure that in both playbooks the configuration is related to your instances, that is, check that you insert the IP addresses corresponding to your instances.

Everything is ready, so we proceed to first install everything in the instance db and then install everything in the instance app and be able to make the connection from the app to the web and not have any type of error in the installation.

- `ansible-playbook playbook_db.ym`

- `ansible-playbook playbook_web.ym`

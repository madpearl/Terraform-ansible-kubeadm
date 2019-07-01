# Terraform-ansible-kubeadm
Use terraform to create EC2 instance then use ansible to provision a single node kuberetes cluster on this instance

The objective is to:
--------------------
   - Use terraform to create an instance on aws
   - Use ansible to provision a single-node kubernetes cluster with the instance created above
   - Download kubectl binary locally to access the newly created cluster above
   - Use ansible provisioner or run ansible-playbook with terraform

Assumption:
-----------
1- EC2 instance will be created in the default VPC for selected region.

2- This script uses the default security group for default VPC.


Regarding installing kubectl locally:
-------------------------------------
I used "local-exec" resource provisioner and it works fine, I did not include it in my script because it is working only "Ubuntu" and I did not want the script to have dependencies. here is the part of script that was changed to achieve this

provisioner "local-exec" {
command = <<EOT
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo touch /etc/apt/sources.list.d/kubernetes.list
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
ansible-playbook -u ubuntu --private-key ${var.ssh_key_name} -i ${self.public_ip}, site.yml
EOT
}  

Then configure kubectl to connect to the remote cluster by downloading .kube folder usig scp command from user home directory to my local user home directory


Here are some improvements that can be done if needed.
------------------------------------------------------

1- Create a new VPC in the selected region and create the EC2 instance in this VPC.

2- Create a new security group, attach it to created instance and add rule(s) to this security group.


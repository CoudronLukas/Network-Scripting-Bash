runnen terraform code:
terraform init
terraform validate
terraform plan -out=Examen
terraform apply Examen

runnen ansible code:

ansible-playbook confVM.yml -i inventory.txt

inventory.txt is geëncrypteerd (password = passwd)
(dit stond erin)
[ubuntu_examen]
192.168.50.100 ansible_ssh_pass=P@ssw0rd ansible_ssh_user=student ansible_become_pass=P@ssw0rd

[windows_examen]
192.168.50.110 ansible_ssh_pass=P@ssw0rd ansible_ssh_user=student ansible_become_pass=P@ssw0rd
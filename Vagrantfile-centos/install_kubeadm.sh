sed -i 's/#host_key_checking = False/host_key_checking = False/g' /etc/ansible/ansible.cfg
git clone https://github.com/echochio-tw/kubeadm-ansible.git
cd kubeadm-ansible
rm -rf hosts.ini
cat >>hosts.ini<<EOF
[master]
192.168.22.164

[node]
192.168.22.[165:166]

[kube-cluster:children]
master
node
EOF

rm -rf group_vars/all.yml
cat >>group_vars/all.yml<<EOF
# Ansible
# ansible_user: root

# Kubernetes
kube_version: v1.11.1
token: b0f7b8.8d1767876297d85c

# 1.8.x feature: --feature-gates SelfHosting=true
init_opts: ""

# Any other additional opts you want to add..
kubeadm_opts: ""
# For example:
# kubeadm_opts: '--apiserver-cert-extra-sans "k8s.domain.com,kubernetes.domain.com"'

service_cidr: "10.96.0.0/12"
pod_network_cidr: "10.244.0.0/16"

# Network implementation('flannel', 'calico')
network: flannel

# Change this to an appropriate interface, preferably a private network.
# For example, on DigitalOcean, you would use eth1 as that is the default private network interface.
cni_opts: "interface=eth1" # flannel: --iface=eth1, calico: interface=eth1

enable_dashboard: yes

# A list of insecure registrys you might need to define
insecure_registrys: ""
# insecure_registrys: ['gcr.io']

systemd_dir: /lib/systemd/system
system_env_dir: /etc/sysconfig
network_dir: /etc/kubernetes/network
kubeadmin_config: /etc/kubernetes/admin.conf
kube_addon_dir: /etc/kubernetes/addon
EOF

yum install -y sshpass

rm -rf /root/.ssh
ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -N ""
sshpass -p "vagrant" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@master
sshpass -p "vagrant" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@node1
sshpass -p "vagrant" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@node2

sleep 10

ansible-playbook site.yaml


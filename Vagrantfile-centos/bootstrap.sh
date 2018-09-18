cat << 'EOF' >> /etc/hosts
192.168.22.164 master
192.168.22.165 node1
192.168.22.166 node2
EOF
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
yum -y update
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
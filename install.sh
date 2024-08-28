#!/bin/bash

username="callcabinet"
password=$(openssl rand -base64 12)

echo "###########"
echo "Welcome to call cabinet single 3cx instance installer"
echo "###########"

echo ""

read -p "Enter Customer Name without any spaces: " customer_name
read -p "Enter Site ID from Call Cabinet: " SiteID

echo "Thanks, to confirm you are setting up call cabinet for $customer_name"
echo "with site id of $side_id"

echo ""
echo "The script is now going to create the callcabinet user in the system"
echo ""
echo "### Now Creating user"

useradd -m -s /bin/bash $username
echo "$username:$password" | chpasswd

echo "### Now creating folders"

mkdir /home/$username/$customer_name
mkdir /home/$username/recordings
mkdir /home/$username/movelogs
#mkdir /home/$username/recordings/$customer_name
touch /home/$username/recording_sync.log
touch /home/$username/getccrecdata.log

echo "### Folders created in /home/$username"

echo "Downloading the call cabinet zip file to extract in /home/$username"

cd /home/$username
wget "https://systems01.technical.network/callcab.tar.gz"

echo "Extracting the callcab.tar.gz file"
tar -xzf callcab.tar.gz -C /home/$username/
chown -R $username: /home/$username/

echo "Listing the current directory"

ls -la

echo "Now modifying config files"

echo ""

echo "Configuring the files with the right username"

echo ""

sed -i "s/^username=\".*\"/username=\"$username\"/" 3cxmoverecdata.sh
sed -i "s/^username=\".*\"/username=\"$username\"/" ccdaemon.sh
sed -i "s/^username=\".*\"/username=\"$username\"/" ccinitd.sh
#sed -i "s/^username=\".*\"/username=\"$username\"/" rsync.sh
sed -i "s/^customer_name=\".*\"/customer_name=\"$customer_name\"/" rsync.sh
sed -i "s/SiteID:<.*>/SiteID:<$SiteID>/" CCconfig.txt
sed -i "s|Repository:</home/.*>|Repository:</home/$username/recordings/>|" CCconfig.txt
sed -i "s/username/$username/" cc.service

echo "setting relevant files to be executable"

chmod +x /home/$username/ccdaemon.sh
chmod +x /home/$username/64bit20221115withlibsu16
#chmod +x /home/$username/rsync.sh
chmod +x /home/$username/3cxmoverecdata.sh

echo "Adding $username to the suders file"
echo "callcabinet ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo "creating and Starting the service"

mv /home/$username/cc.service /etc/systemd/system/cc.service

systemctl daemon-reload
systemctl stop cc.service
systemctl start cc.service
systemctl status cc.service


echo "#########################"
echo "Please save the following"
echo "#########################"
echo ""
echo "Username created: $username"
echo "Password created: $password"
echo ""

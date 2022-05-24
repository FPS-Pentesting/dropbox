### INSTALLING AZURE JUMPHOST ###

<h4>Under the “Basics” section, select the following:</h4>  

Resource Group: Pentest VPN  
Virtual Machine Name: OpenVPN  
Region: East US  
Image: Ubuntu Server 18.04 LTS  
Size: B1s (1 VCPUS, 1GB RAM)  
Authentication type: Password  
Username: pentest  
Password: [fill out and store securely]  
Public inbound ports: HTTP, HTTPS, SSH  

<h4>Under the “Disks” section, select “SSD”</h4>  

<h4>Under the Networking section, Public IP:</h4>  

Select “create new”  
Select “static” and save (Take note of this you will need it later)  

<h4>Select “review and create” and create the machine</h4>  

<h4>Once the machine is running, open the virtual machine settings and select “Networking”:</h4>  

Select “Add inbound port rule”  
Change “Destination port ranges” to 1194  
Change “Protocol” to UDP  
Change “Name” to “Port_1194”  
Leave the rest as default and select “Add”  

<h4>SSH into Public Azure IP of server using credentials chosen during setup:</h4>  

ssh pentest@[Public IP]  
sudo apt install git  
git clone https://github.com/FPS-Pentesting/dropbox.git
sudo ./azure_setup.sh  
Create an openvpn cert and copy the file to flash drive.  

### CONFIGURING THE DROPBOX ###

<h4>Then power on the dropbox and run the dropbox setup script:</h4>  

copy the openvpn cert to the home folder  
git clone https://github.com/FPS-Pentesting/dropbox.git
cd dropbox  
chmod +x *.sh  
sudo ./NAB_MASTER_INSTALL.sh

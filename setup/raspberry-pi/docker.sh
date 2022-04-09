echo "Updating packages"
sudo apt-get update && sudo apt-get -y upgrade

# To create a .local domain, install Avahi Daemon on your Pi;

sudo apt-get install avahi-daemon
# Once complete, you don’t need to reboot the device.
# Raspberry Pi will begin to recognize local network queries for its hostname.
# By default, the hostname is raspberrypi.

echo "Installing Docker"
# Installing docker will disconnect ssh
curl -sSL https://get.docker.com | sh

echo "Finishing docker setup by adding user"
sudo usermod -aG docker ${USER}

groups ${USER}

sudo reboot
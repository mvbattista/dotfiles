#!/bin/bash

echo "Running automated raspi-config tasks"

# Via https://gist.github.com/damoclark/ab3d700aafa140efb97e510650d9b1be
# Execute the config options starting with 'do_' below
grep -E -v -e '^\s*#' -e '^\s*$' <<END | \
sed -e 's/$//' -e 's/^\s*/\/usr\/bin\/raspi-config nonint /' | bash -x -
#

# Drop this file in SD card root. After booting run: sudo /boot/setup.sh

# --- Begin raspi-config non-interactive config option specification ---

# Hardware Configuration
do_boot_wait 0            # Turn on waiting for network before booting
#do_boot_splash 1          # Disable the splash screen
#do_overscan 1             # Enable overscan
#do_camera 1               # Enable the camera
do_ssh 0                  # Enable remote ssh login
# GPIO enabled later after installing wiringpi to avoid error

# System Configuration
do_configure_keyboard us
do_hostname ${host}
do_wifi_country US                           # Set wifi country as US
do_wifi_ssid_passphrase ${wifi_name} ${wifi_password}   # Set wlan0 network to join 'wifi_name' network using 'password'
do_change_timezone America/New_York
do_change_locale LANG=en_US.UTF-8

# Don't add any raspi-config configuration options after 'END' line below & don't remove 'END' line
END

# Note: do_camera 1 doesn't seem to work / be enough. Enabled below via /boot/config.txt mod.

############# CUSTOM COMMANDS ###########
# You may add your own custom GNU/Linux commands below this line
# These commands will execute as the root user

# Interactively set password for your login. Going through raspi-config w/do_change_pass is slower
#/usr/bin/raspi-config do_change_pass          # Interactively set password for your login
sudo passwd pi

echo "Updating packages"
sudo apt-get update && sudo apt-get -y upgrade

# rasp-config non-interactive do_camera didn't seem to work
#echo "Enabling camera"
#sed -i "s/start_x=0/start_x=1/g" /boot/config.txt

/usr/bin/raspi-config do_wifi_ssid_passphrase # Interactively configure the wifi network

echo "Moving pull script from boot to home"
mv /boot/pull.sh /home/pi

echo "Installing Docker"
# Installing docker will disconnect ssh
curl -sSL https://get.docker.com | sh

echo "Finishing docker setup"
sudo usermod -aG docker pi

echo "Restarting to apply changes. After run ssh pi@${host}.local"
# Reboot after all changes above complete
/sbin/shutdown -r now
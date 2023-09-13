# Use this to monitor what changes need to be made: 
## xfconf-query -c xfce4-desktop -m 
### Example output
# set: /backdrop/screen0/monitorVirtual1/workspace0/image-style
# set: /backdrop/screen0/monitorVirtual1/workspace0/color-style
# set: /backdrop/screen0/monitorVirtual1/workspace0/rgba1
# Use this to make changes:
## xfconf-query -c xfce4-desktop -p insert_property_here -s path/image

# You can manually toggle these settings via "Desktop"
## Set image to None
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorrdp0/workspace0/image-style -s 0
## Set color-style to Solid
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorrdp0/workspace0/color-style -s 0
## Set color to Black (may not work, the variable isn't created until the user selects a value in the GUI)
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorrdp0/workspace0/rgba1 -n -t int -t int -t int -t int -s 0 -s 0 -s 0 -s 1


# Turn off Windows Compositing (fancy GUI window graphics that seem to really hurt xrdp performance)
## As seen here: https://github.com/neutrinolabs/xrdp/issues/1600
# You can toggle this setting manually via "Windows Manager Tweaks" -> Compositor
xfconf-query -c xfwm4 -p /general/use_compositing -t bool -s false


### Make XRDP Config Changes ###
CONFIG_FILE='/etc/xrdp/xrdp.ini'
# Backup old config
cp -p "$CONFIG_FILE" "$CONFIG_FILE.orig.`date \"+%Y%m%d_%H%M%S\"`"
# Increase xrdp TCP send buffer (https://github.com/neutrinolabs/xrdp/issues/1483)
grep -qxF "tcp_send_buffer_bytes=4194304" $CONFIG_FILE || sed -i -e '/#tcp_send_buffer_bytes=/a\' -e 'tcp_send_buffer_bytes=4194304' $CONFIG_FILE
# Change from 32-bit to 8-bit color (15-bit works okay, except for with complex images, ex browsing webpages)
sed -i 's/^max_bpp=/#&/' $CONFIG_FILE
grep -qxF "max_bpp=8" $CONFIG_FILE || sed -i -e '/#max_bpp=/a\' -e 'max_bpp=8' $CONFIG_FILE
# Change listening port (responder wants port 3389)
sed -i 's/^port=3389/#&/' $CONFIG_FILE
grep -qxF "port=8933" $CONFIG_FILE || sed -i -e '/^#port=3389/a\' -e 'port=8933' $CONFIG_FILE


# Update Network Kernel Send Buffer to be twice that of XRDP's
## These commands can check current value and temporarily change it
## sysctl -n net.core.wmem_max
## sysctl -w net.core.wmem_max=8388608
SYSCTL='/etc/sysctl.conf'
# Backup old config
cp -p "$SYSCTL" "$SYSCTL.orig.`date \"+%Y%m%d_%H%M%S\"`"
# Make permanent changes to the configuration
grep -qxF "# Send Buffer Increased Size" $SYSCTL || echo "# Send Buffer Increased Size" >> $SYSCTL
grep -qxF "net.core.wmem_max=8388608" $SYSCTL || echo "net.core.wmem_max=8388608" >> $SYSCTL


### Change Terminal Theme and Transparency
QTERM_CONFIG=/home/pentest/.config/qterminal.org/qterminal.ini
sed -i 's/TerminalTransparency=.*/TerminalTransparency=0/' $QTERM_CONFIG
sed -i 's/ApplicationTransparency=.*/ApplicationTransparency=0/' $QTERM_CONFIG
sed -i 's/colorScheme=.*/colorScheme=WhiteOnBlack/' $QTERM_CONFIG



### Get rid of the "Authentication Required to Create Managed Color Device" message
# source: https://www.kali.org/docs/general-use/xfce-with-rdp/
mkdir -p /etc/polkit-1/localauthority/50-local.d/
chown root:polkitd /etc/polkit-1/localauthority
chmod 750 /etc/polkit-1/localauthority
cat <<EOF | sudo tee /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

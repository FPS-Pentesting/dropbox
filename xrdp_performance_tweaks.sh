#!/bin/bash

### Setup Desktop Background
XFCE_CONFIG_DIR="/home/pentest/.config/xfce4/xfconf/xfce-perchannel-xml"
# Set image to None
sed -i 's/name="image-style" type="int" value="5"/name="image-style" type="int" value="0"/g' $XFCE_CONFIG_DIR/xfce4-desktop.xml
# Set color-style to Solid
sed -i 's/name="color-style" type="int" value="1"/name="color-style" type="int" value="0"/g' $XFCE_CONFIG_DIR/xfce4-desktop.xml

        
### Turn off Windows Compositing (fancy GUI window graphics that seem to really hurt xrdp performance)
## As seen here: https://github.com/neutrinolabs/xrdp/issues/1600
# You can toggle this setting manually via "Windows Manager Tweaks" -> Compositor
sed -i 's/name="use_compositing" type="bool" value="true"/name="use_compositing" type="bool" value="false"/' $XFCE_CONFIG_DIR/xfwm4.xml


### Make XRDP Config Changes ###
XRDP_CONFIG='/etc/xrdp/xrdp.ini'
# Backup old config
cp -p "$XRDP_CONFIG" "$XRDP_CONFIG.orig.`date \"+%Y%m%d_%H%M%S\"`"
# Increase xrdp TCP send buffer (https://github.com/neutrinolabs/xrdp/issues/1483)
grep -qxF "tcp_send_buffer_bytes=4194304" $XRDP_CONFIG || sed -i -e '/#tcp_send_buffer_bytes=/a\' -e 'tcp_send_buffer_bytes=4194304' $XRDP_CONFIG
# Change from 32-bit to 8-bit color (15-bit works okay, except for with complex images, ex browsing webpages)
sed -i 's/^max_bpp=32/#&/' $XRDP_CONFIG
grep -qxF "max_bpp=8" $XRDP_CONFIG || sed -i -e '/#max_bpp=32/a\' -e 'max_bpp=8' $XRDP_CONFIG
# Change listening port (responder wants port 3389)
sed -i 's/^port=3389/#&/' $XRDP_CONFIG
grep -qxF "port=8933" $XRDP_CONFIG || sed -i -e '/^#port=3389/a\' -e 'port=8933' $XRDP_CONFIG


### Update Network Kernel Send Buffer to be twice that of XRDP's
## These commands can check current value and temporarily change it
## sysctl -n net.core.wmem_max
## sysctl -w net.core.wmem_max=8388608
SYSCTL_CONFIG='/etc/sysctl.conf'
# Backup old config
cp -p "$SYSCTL_CONFIG" "$SYSCTL_CONFIG.orig.`date \"+%Y%m%d_%H%M%S\"`"
# Make permanent changes to the configuration
grep -qxF "# Send Buffer Increased Size" $SYSCTL_CONFIG || echo "# Send Buffer Increased Size" >> $SYSCTL_CONFIG
grep -qxF "net.core.wmem_max=8388608" $SYSCTL_CONFIG || echo "net.core.wmem_max=8388608" >> $SYSCTL_CONFIG


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

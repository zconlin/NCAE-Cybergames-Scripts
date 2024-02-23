#!/bin/bash

echo "Running network configuration script..."

# Prompt user for input
prompt_for_input() {
    read -p "$1: " input
    echo "$input"
}

# Update ifcfg file
update_ifcfg() {
    interface=$1
    zone=$2
    ip=$3
    netmask=$4
    gateway=$5
    dns=$6

    # Check if the interface file exists
    if [ -f "/etc/sysconfig/network-scripts/ifcfg-$interface" ]; then
        # Check if the line exists, replace it, otherwise append it
        grep -q "^BOOTPROTO=" "/etc/sysconfig/network-scripts/ifcfg-$interface" || echo "BOOTPROTO=static" >> "/etc/sysconfig/network-scripts/ifcfg-$interface"
        grep -q "^ONBOOT=" "/etc/sysconfig/network-scripts/ifcfg-$interface" || echo "ONBOOT=yes" >> "/etc/sysconfig/network-scripts/ifcfg-$interface"
        grep -q "^IPADDR=" "/etc/sysconfig/network-scripts/ifcfg-$interface" || echo "IPADDR=$ip" >> "/etc/sysconfig/network-scripts/ifcfg-$interface"
        grep -q "^NETMASK=" "/etc/sysconfig/network-scripts/ifcfg-$interface" || echo "NETMASK=$netmask" >> "/etc/sysconfig/network-scripts/ifcfg-$interface"
        grep -q "^GATEWAY=" "/etc/sysconfig/network-scripts/ifcfg-$interface" || echo "GATEWAY=$gateway" >> "/etc/sysconfig/network-scripts/ifcfg-$interface"
        grep -q "^DNS1=" "/etc/sysconfig/network-scripts/ifcfg-$interface" || echo "DNS1=$dns" >> "/etc/sysconfig/network-scripts/ifcfg-$interface"
        grep -q "^ZONE=" "/etc/sysconfig/network-scripts/ifcfg-$interface" || echo "ZONE=$zone" >> "/etc/sysconfig/network-scripts/ifcfg-$interface"
    else
        cat <<EOF >"/etc/sysconfig/network-scripts/ifcfg-$interface"
BOOTPROTO=static
ONBOOT=yes
IPADDR="$ip"
NETMASK="$netmask"
GATEWAY="$gateway"
DNS1="$dns"
ZONE=$zone
EOF
    fi
}

# Config prompts
echo "Configuring ens18:"
EXTERNAL_IP=$(prompt_for_input "Enter external IP address for ens18")
EXTERNAL_NETMASK=$(prompt_for_input "Enter netmask for ens18")
EXTERNAL_GATEWAY=$(prompt_for_input "Enter gateway for ens18")
EXTERNAL_DNS=$(prompt_for_input "Enter DNS for ens18")

update_ifcfg ens18 external "$EXTERNAL_IP" "$EXTERNAL_NETMASK" "$EXTERNAL_GATEWAY" "$EXTERNAL_DNS"

echo "Configuring ens19:"
INTERNAL_IP=$(prompt_for_input "Enter internal IP address for ens19")
INTERNAL_NETMASK=$(prompt_for_input "Enter netmask for ens19")
INTERNAL_GATEWAY=$(prompt_for_input "Enter gateway for ens19")
INTERNAL_DNS=$(prompt_for_input "Enter DNS for ens19")

update_ifcfg ens19 internal "$INTERNAL_IP" "$INTERNAL_NETMASK" "$INTERNAL_GATEWAY" "$INTERNAL_DNS"

echo "Configuration comlpete. Restarting network service..."

# Restart network
systemctl restart network

echo "Network configuration updated and network service restarted."

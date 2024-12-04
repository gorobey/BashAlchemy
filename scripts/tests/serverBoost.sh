#!/usr/bin/env bash

#import helpers
source "../../helpers/term_messages.sh"
source "../../helpers/spinner.sh"

# if user is not root, exit
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

offswap () {
  echo "Disabling swap..."
  swapoff -a
}

onswap () {
  echo "Enable swap..."
  swapon -a
}

#clear cache memory
clear_cache () {
  echo "Clearing cache memory..."
  sync; echo 3 > /proc/sys/vm/drop_caches
}

disable_thp () {
  echo "Disabling Transparent Huge Pages (THP)..."
  echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled
  echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag
}

adjust_dirty_ratio () {
  echo "Adjusting vm.dirty_ratio and vm.dirty_background_ratio..."
  sysctl vm.dirty_ratio=10
  sysctl vm.dirty_background_ratio=5
}

set_overcommit_memory () {
  echo "Setting vm.overcommit_memory to 1..."
  sysctl vm.overcommit_memory=1
}

enable_tcp_bbr () {
  echo "Enabling TCP BBR..."
  echo 'net.core.default_qdisc=fq' >> /etc/sysctl.conf
  echo 'net.ipv4.tcp_congestion_control=bbr' >> /etc/sysctl.conf
  sysctl -p
}

# Function to update the existing swap file to 8 GB
update_swap_file () {
  echo "Updating the existing swap file to 8 GB..."
  swapoff /swapfile
  fallocate -l 4G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
}

run_with_spinner offswap
run_with_spinner onswap
run_with_spinner disable_thp
run_with_spinner adjust_dirty_ratio
run_with_spinner set_overcommit_memory
run_with_spinner enable_tcp_bbr

# altre ottimizzazioni per il server (4GB di ram)
echo "Applying other optimizations..."

# Set swappiness to 10
echo "Setting swappiness to 10..."
sysctl vm.swappiness=30
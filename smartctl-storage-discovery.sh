#!/bin/bash
#
#    .VERSION
#    0.7
#
#    .DESCRIPTION
#    Author: Nikitin Maksim
#    Github: https://github.com/nikimaxim/zbx-smartmonitor.git
#    Note: Zabbix lld for smartctl
#
#    .TESTING
#    Smartmontools: 7.1 and later
#    OS: CentOS 7 x64, Ubuntu 18.04 x64, MacOS High Sierra
#

# Get OS type
OS=`uname`

CTL=''

if [[ -z "$CTL" ]]; then
    # Default path "smartctl"
    # For Linux: /usr/sbin/smartctl
    # For MacOS: /usr/local/sbin/smartctl
    # For Other: smartctl
    if [[ $OS == 'Linux' ]]; then
        CTL='/usr/sbin/smartctl'
    elif [[ $OS == 'Darwin' ]]; then
        CTL='/usr/local/sbin/smartctl'
    else
        CTL='smartctl'
    fi
fi

if [[ ! -x "$CTL" ]]; then
    echo "Could not find path: $CTL"
    exit
fi

LLDSmart() {
    # For MacOS
    if [[ $OS == 'Darwin' ]]; then
        smart_scan=$(diskutil list | grep -i "physical" | cut -f 1 -d' ')
    else
        smart_scan=$($CTL --scan-open | sed -e 's/\s*$/;/')
    fi
    disk_sn_all=()

    IFS=";"
    for device in ${smart_scan}; do
        storage_sn=""
        storage_model=""
        storage_name=""
        storage_cmd=""
        storage_smart=0
        storage_type=0
        storage_args=""

        device=$(echo $device | grep -iE "^(\w*|\d*).")

        # Remove non-working disks
        # Example: "# /dev/sdb -d scsi"
        if [[ ! ${device} =~ (^\s*#|^#) ]]; then
            # Extract and concatenate args
            storage_args=$(echo $device | cut -f 1 -d'#' | awk '{print $2 $3}')
            # Get device name
            storage_name=$(echo $device | cut -f 1 -d'#' | awk '{print $1}')

            info=$($CTL -i $storage_name $storage_args)

            # Get device SN
            storage_sn=$(echo $info | grep -i "Serial Number:" | cut -f2 -d":" | sed -e 's/^\s*//')

            # Check duplicate storage
            if [[ ! -z $storage_sn ]] && [[ ! $disk_sn_all == *"$storage_sn"* ]]; then
                if [ -z $disk_sn_all ]; then
                    disk_sn_all=$storage_sn
                else
                    disk_sn_all+=" ${storage_sn}"
                fi

                storage_cmd="${storage_name} ${storage_args}"

                # Device SMART
                if [ -n $(echo $info | grep -iE "^SMART support is:.+Enabled\s*$") ]; then
                    storage_smart=1
                fi

                # Get device model(For different types of devices)
                d=$(echo $info | grep -i "Device Model:" | cut -f2 -d":" | sed -e 's/^\s*//')
                if [ -n $d ]; then
                    storage_model=$d
                else
                    m=$(echo $info | grep -i "Model Number:" | cut -f2 -d":" | sed -e 's/^\s*//')
                    if [ -n $m ]; then
                        storage_model=$m
                    else
                        p=$(echo $info | grep -i "Product:" | cut -f2 -d":" | sed -e 's/^\s*//')
                        if [ -n $p ]; then
                            storage_model=$p
                        else
                            v=$(echo $info | grep -i "Vendor:" | cut -f2 -d":" | sed -e 's/^\s*//')
                            if [ -n $v ]; then
                                storage_model=$v
                            else
                                storage_model="Not find"
                            fi
                        fi
                    fi
                fi

                # Get device type:
                # - 0 is for HDD
                # - 1 is for SSD
                # - 2 is for NVMe
                if [ -n "$(echo $info | grep -iE "^Rotation Rate:.*rpm.*$")" ]; then
                    storage_type=0
                elif [ -n "$(echo $info | grep -iE "^Rotation Rate:\s*Solid State Device\s*$")" ]; then
                    storage_type=1
                elif [[ $storage_args == *"nvme"* ]] || [[ $storage_name == *"nvme"* ]]; then
                    # Device NVMe and SMART
                    storage_type=2
                    storage_smart=1
                fi

               storage_json=$storage_json"{\"{#STORAGE.SN}\":\"${storage_sn}\", \"{#STORAGE.MODEL}\":\"${storage_model}\", \"{#STORAGE.NAME}\":\"${storage_name}\", \"{#STORAGE.CMD}\":\"${storage_cmd}\", \"{#STORAGE.SMART}\":\"${storage_smart}\", \"{#STORAGE.TYPE}\":\"${storage_type}\"},"
            fi
        fi
    done

    echo "{\"data\":[$(echo $storage_json | sed -e 's/,$//')]}"
}

LLDSmart

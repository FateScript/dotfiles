
bluetooth_conn()
{
    local device_name=$1
    if [ -z "$device_name" ]; then  # default to the first device
        device_name=$(bluetooth_name | sed -n '1p')
    fi
    # find the bluetooth device address
    local address=$(blueutil --paired | grep "$device_name" | awk '{print substr($2, 1, length($2) -1)}')
    echo "connect" "$device_name" "with address: " "$address"
    blueutil --connect "$address"
}

bluetooth_name() {
    # get the paired device information from blueutil
    paired_devices=$(blueutil --paired)
    # use awk to extract the names from the output
    device_names=$(echo "$paired_devices" | awk -F'name: "' '{print $2}' | awk -F'"' '{print $1}')
    # print the list of device names
    echo "$device_names"
}

_bluetooth_device() {
	choices=`bluetooth_name`
	suf=( -S '' )
	_arguments -O suf "*:value:( $choices )"
}

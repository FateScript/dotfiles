
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

bluetooth_disconn() {
    local device_name=$1
    if [ -z "$device_name" ]; then  # default to the first device
        device_name=$(bluetooth_name | sed -n '1p')
    fi

    # find the bluetooth device address
    local address=$(blueutil --paired | grep "$device_name" | awk '{print substr($2, 1, length($2) -1)}')

    if [ -z "$address" ]; then
        echo "Device '$device_name' not found or not paired."
        exit 1
    fi

    blueutil --disconnect "$address"
    echo "dis-connect" "$device_name" "with address: " "$address"
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
  local -a choices
  choices=("${(@f)$(bluetooth_name)}")
  _describe -t devices 'Bluetooth Devices' choices
}

check_port() {
  if [[ -z "$1" ]]; then
    echo "Usage: check_port <port_number>"
    return 1
  fi

  local port="$1"
  local output

  output=$(lsof -iTCP:"$port" -sTCP:LISTEN -n -P 2>/dev/null)

  if [[ -z "$output" ]]; then
    echo "Port $port is not being used."
  else
    echo "Port $port is in use by the following process:"
    echo "$output"
  fi
}

list_ports() {
  echo -e "Proto\tLocal Address\t\tPID/Program name"
  sudo lsof -i -P -n | awk '
    NR==1 {next} # skip header
    {
      split($9, addr, ":")
      port = addr[length(addr)]
      printf "%s\t%s\t%s/%s\n", $8, $9, $2, $1
    }
  ' | sort -u
}

# Setup
sudo apt install edid-decode read-edid edid-decode > /dev/null 2>&1

# Extract
## System
#!/bin/bash

# Get Manufacturer, Model, and Model Number
sudo dmidecode -s system-manufacturer
sudo dmidecode -s system-product-name
sudo dmidecode -s system-version
sudo dmidecode -s system-serial-number

# Get CPU Information
lscpu | grep "Model name:" |  awk '{for(i=3; i<=NF; i++) printf "%s ", $i; print ""}'
lscpu | grep "^CPU(s):" | awk '{print $2}'

# Get RAM Information
sudo dmidecode -t memory | grep "Maximum Capacity:" | awk '{print "Expandable to: " $3 $4}'
sudo dmidecode -t memory | awk '
/Memory Device/ {
    inside_device=1;
    if (device_name) {
        print device_name "\n" size ", " type ", " speed;
        device_name=""; size=""; type=""; speed="";
    }
}
/^\s*$/ {
    inside_device=0;
}
inside_device {
    if ($1 == "Locator:") { device_name="Memory Device: " $2; }
    if ($1 == "Size:" && $2 != "No") { size=$2" "$3; }
    if ($1 == "Type:" && $2 != "Unknown") { type=$2; }
    if ($1 == "Speed:" && $2 != "Unknown") { speed=$2" "$3; }
}
END {
    if (device_name) {
        print device_name "\n" size ", " type ", " speed;
    }
}'

# Get Graphics Card Information
sudo lshw -C display | awk -F':+' '
$1 ~ /product/ {
    gsub(/^[ \t]+|[ \t]+$/, "", $2);
    printf "product: %s\n", $2
}
$1 ~ /vendor/ {
    gsub(/^[ \t]+|[ \t]+$/, "", $2);
    printf "vendor: %s\n", $2
}'

# Get Secondary Storage Information
lsblk -o NAME,SIZE,TYPE,TRAN | grep 'disk' | awk '{print $1}' | while read -r name; do
    model=$(udevadm info --query=property --name=/dev/"$name" | awk -F'=' '/ID_MODEL=/{print $2}')
    vendor=$(udevadm info --query=property --name=/dev/"$name" | awk -F'=' '/ID_VENDOR=/{print $2}')
    connection_type=$(lsblk -o TRAN /dev/"$name" | tail -n 1)
    size=$(lsblk -o SIZE /dev/"$name" | tail -n 1)
    echo "$vendor $model, $connection_type, $size"
done

## Monitors
sudo get-edid -q | edid-decode | awk '
/Block 0, Base EDID:/ { block++ }
/Manufacturer:/ { manufacturer[block] = $2 }
/Display Product Name:/ { productName[block] = substr($0, index($0, $4)) }
/Display Product Serial Number:/ { serialNumber[block] = substr($0, index($0, $5)) }
END {
    for (i = 1; i <= block; i++) {
        print "Monitor " i ":" manufacturer[i] ", " productName[i] ", " serialNumber[i]
        print ""
    }
}'

## Keyboard


## Mouse


# Organize

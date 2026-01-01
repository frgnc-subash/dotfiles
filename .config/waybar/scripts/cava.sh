#! /bin/bash

bar="▁▂▃▄▅▆▇█"
config_file="/tmp/waybar_cava_config"

echo "
[general]
bars = 12

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
" >"$config_file"

trap 'rm -f $config_file' EXIT

cava -p "$config_file" | while read -r line; do
    formatted="${line//;/}"
    output=""

    len=${#formatted}
    for ((i = 0; i < len; i++)); do
        digit=${formatted:$i:1}
        output="${output}${bar:$digit:1}"
    done

    echo "$output"
done

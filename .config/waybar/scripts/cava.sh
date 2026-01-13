#!/bin/bash

bar="▁▂▃▄▅▆▇█"
config_file="/tmp/waybar_cava_config"

pkill -f "cava -p $config_file"

echo "
[general]
bars = 12

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
" >"$config_file"

trap "pkill -f 'cava -p $config_file'" EXIT

cava -p "$config_file" | awk -F';' '
BEGIN {
    # Map numbers 0-7 to the bar characters
    c[0]="▁"; c[1]="▂"; c[2]="▃"; c[3]="▄";
    c[4]="▅"; c[5]="▆"; c[6]="▇"; c[7]="█";
}
{
    o=""
    # Iterate through the semicolon-separated numbers
    for (i=1; i<NF; i++) {
        o=o c[$i]
    }
    print o
    # Flush output immediately so Waybar doesn not lag
    fflush()
}'

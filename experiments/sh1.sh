#!/bin/bash

#echo "a b\tc\nd"
#echo "a b\tc\nd" | { read -r v1 v2 rest; }

#IFS="\n" read -r v1 v2 rest <<'EOF'
#a b   c
#d
#EOF

IFS="\n" read -r rest <<'EOF'
   a b   c   
d
EOF
echo "v1=$v1"
echo "v2=$v2"
echo "rest=$rest"

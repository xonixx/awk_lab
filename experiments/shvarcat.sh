#!/bin/sh

VAR=$(cat <<'EOF'

echo "Hello"
#echo 'World'
#echo $((2+5))
#echo `whoami`

EOF
)
echo $?
echo "$VAR"

bash -c "$VAR"


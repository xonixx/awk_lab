#!/bin/sh

#IFS="\n"
#echo ${#IFS}
#echo a${IFS}a

#define(){ o=; while IFS="\n" read -r a; do o="$o$a"'\n'; done; eval "$1=\$o"; }
define(){ o=; while IFS='\n' read -r a; do VAR="$VAR$a"'
'; done; }
#define(){ o=; while IFS="|" read -r a; do o="$o$a"'
#'; done; eval "$1=\$o"; }
define <<'EOF'

echo "Hello"
echo 'World'
echo $((2+5))
echo `whoami`

EOF
echo $?
echo "$VAR"

bash -c "$VAR"


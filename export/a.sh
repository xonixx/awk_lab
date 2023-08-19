
RETURN=777
export RETURN
bash b.sh
RETURN=888
sh b.sh
sh -c 'RETURN=999'
sh b.sh
echo "$RETURN"


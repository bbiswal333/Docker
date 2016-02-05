set -x

file=swarm-request.ini

# DEBUG
if [ -f $file ]; then
  rm -f $file; fi
# ENDDEBUG

if [ ! -f $file ]; then
  printf "zookeepers=\"$zookeepers\"\n"   >> $file
  printf "managers\"$managers\"\n"       >> $file
  printf "\n# NODES\n# -----\n"           >> $file
  printf "nodes\"$nodes\"\n"             >> $file
  printf "\n# CLUSTER ID\n# ----------\n" >> $file
  printf "token\"$token\"\n"             >> $file
  printf "\n# SECURITY\n# ----------\n"   >> $file
  printf "\"tls$tls\"\n"                 >> $file
  printf "engineport\"$engineport\"\n"   >> $file
  printf "managerport\"$managerport\"\n" >> $file; fi

echo
cat $file

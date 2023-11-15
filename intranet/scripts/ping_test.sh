function ping_test() {

  ip=$1
  name=$2
  echo "  Target: $name $ip"

  ping $ip -c 1 -w 2 > /dev/null

  if [ $? -eq 0 ]; then
    echo "    [o] Ping succeeded"
    return 0
  fi

    echo "    [x] Ping failed"
  return 1



}

declare -i error_count=0

echo ""
echo "===================================="
echo "Testing connection"
echo "Current device ip: $(ip add | grep eth0 | tail -n 1 | head --bytes 18 | tail --bytes 9)"

echo ""
echo "==> DEVICE CONNECTION"
ping_test 10.5.0.20 "ext"
error_count=$(( error_count + $? ))
ping_test 10.5.1.20 "dmz"
error_count=$(( error_count + $? ))
ping_test 10.5.2.20 "int1"
error_count=$(( error_count + $? ))
ping_test 10.5.2.21 "int2"
error_count=$(( error_count + $? ))
echo "SUMMARY ! Failed pings: $error_count/4"


error_count=0
echo ""
echo "==> ROUTER CONNECTION"
ping_test 10.5.0.1 "EXT"
error_count=$(( error_count + $? ))
ping_test 10.5.1.1 "DMZ"
error_count=$(( error_count + $? ))
ping_test 10.5.2.1 "INT"
error_count=$(( error_count + $? ))
echo "SUMMARY ! Failed pings: $error_count/3"

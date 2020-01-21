
#!/bin/bash
cat /var/log/maillog |grep  "authentication failure" | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' |sort -u > /root/ataques.log
input="ataques.log"
while IFS= read -r line
do
  echo "$line"
  country=$(curl -s https://ipapi.co/$line/country/)
  if [ "$country" = "ES" ]; then
   echo "es España $country"
  else
    echo "NO España $country"
    echo $line >> ips.txt
    country=0
    echo "Bloqueando ips"
  fi

done < "$input"

cat ips.txt | tr '\n' ' ' | sed 's/ /,/g' > drop.txt
ips=$(cat drop.txt)
/usr/local/psa/bin/modules/firewall/settings -s -name 'ataques_mail' -direction input -action deny  -remote-addresses  "$ips"
/usr/local/psa/bin/modules/firewall/settings -a
/usr/local/psa/bin/modules/firewall/settings -c

cat /dev/null > /root/ips.txt
cat /dev/null > /root/drop.txt
cat /dev/null > /root/ataques.log

#!/bin/bash
echo -n "Enter domain you want to recon: "
read DOMAIN
assetfinder $DOMAIN | tee $DOMAIN.txt
cat $DOMAIN.txt | sort -u | while read line; do
    if [ $(curl --write-out %{http_code} --silent --output /dev/null -m 5 $line) = 000 ]
    then
      echo "$line was unreachable"
      touch $DOMAIN-unreachable.html
      echo "<b>$line</b> was unreachable<br>" >> $DOMAIN-unreachable.html
    else
      echo "$line is up"
      echo $line >> $DOMAIN-responsive.txt
    fi
  done

awk '{print "https://"$0}' $DOMAIN-responsive.txt > $DOMAIN-recon
sed -i 's/www.//' $DOMAIN-recon
sort -u $DOMAIN-recon
echo -e "\e[31mRunning directory buster now\e[0m"
for i in `cat $DOMAIN-recon`; do dirb $i -o $DOMAIN-dirb;done

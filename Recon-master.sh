#!/bin/bash
echo -n "Enter domain you want to recon: "
read DOMAIN
mkdir -p recons&&cd recons
mkdir -p $DOMAIN-recon&& cd $DOMAIN-recon
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

awk '{print "https://"$0}' $DOMAIN-responsive.txt | sed -i 's/www.//' $DOMAIN-responsive.txt | sort -u $DOMAIN-responsive.txt > $DOMAIN-recon
echo -e "\e[31mFinding js files in $DOMAIN\e[0m"
cat $DOMAIN-recon | waybackurls | grep "\.js" | sort -u | tee $DOMAIN-temp
cat $DOMAIN-temp | parallel -j50 -q curl -w 'Status:%{http_code}\t Size:%{size_download}\t %{url_effective}\n' -o /dev/null -sk| grep -v 404 | grep -v 429 | grep -v 000 | tee $DOMAIN-js
rm -rf $DOMAIN.txt $DOMAIN-responsive.txt $DOMAIN-temp
#echo -e "\e[31mRunning directory buster now\e[0m"
#for i in `cat $DOMAIN-recon`; do dirb $i -o $DOMAIN-dirb;done

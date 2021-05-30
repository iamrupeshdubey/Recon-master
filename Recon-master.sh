#!/usr/bin/env bash

while getopts ":d:w:o:" ops; do
	case "${ops}" in
		d)
			domain=${OPTARG}
			;;
		w)
			wordlist=${OPTARG}
			;;
		o)
			OUTFOLDER=${OPTARG}
 			;;
		\?)
			echo -e "\033[1;31m[-] Error: -${OPTARG} is an Invalid Option"
			exit
			;;
	esac
done

[[ ! -d $OUTFOLDER ]] && mkdir $OUTFOLDER 2>/dev/null

if [ -z "$domain" ]; then
	echo -e "\n\033[31m[-] Unspecified domain Please use -d flag! ❌\033[m"
	exit
fi
if [ -z "$OUTFOLDER" ]; then
	echo -e "\n\033[31m[-] Please enter the output folder as it is not possible to create the folder with symbols! ❌\033[m"
	exit
fi
if [ -z "$wordlist" ]; then
	echo -e "\n\033[32m<<  \033[mYou didn't choose a wordlist. Here are your options: \033[32m >>\033[m"
	for a in $(ls $SCRIPTPATH/wordlists/); do
		pwdWL="$(cd $SCRIPTPATH/wordlists/; pwd)"
		echo -e "\033[1;32m[+] $pwdWL/$a\033[m"
	done
	exit
fi

mkdir -p $OUTFOLDER
cd $OUTFOLDER
show_help() {
	echo -e "\n\tUsage: \033[1;32m./recon.sh \033[35m[  domain ]"
}

echo -e "\n\033[36m[+] Finding the WAF present on the target 🔍\033[m"
#wafw00f $domain -a -o waf.txt
echo -e "\n\033[36m[+] Finding vulnerabilities with Nuclei on $domain 🔍\033[m"
#nuclei -t /home/rupesh/nuclei-templates/ --target $domain -o nuclei.txt --silent
echo -e "\n\033[36m[+] Finding IP of $domain 🔍\033[m"
echo $domain > temp_domain.txt
dnsx --silent -l temp_domain.txt -resp | awk '{print $2}' | tr -d "[]" > ip_only.txt
echo -e "\n\033[36mFound: `cat ip_only.txt` \033[m"
echo -e "\n\033[36m[+] Running nmap on `cat ip_only.txt` 🔍\033[m"
nmap -iL ip_only.txt --top-ports 10000 --max-rate=50000 -oG nmap.txt


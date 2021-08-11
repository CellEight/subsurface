#!/bin/bash

test_make_dir(){
    if [ ! -d "$1" ]; then
        mkdir $1
    fi
}

# parse/validate arguments here
if [ ! -n "$1" ]; then
    echo "[!] Please enter a domain."
    echo "[*] Usage: subsurface.sh <domain> [-subnet]"
    exit 1
fi

# Create output folder structure if not already extant
domain=$1 
ips=$domain/ips
subdomains=$domain/subdomains
info=$domain/info
captures=$domain/captures
test_make_dir $domain
test_make_dir $ips
test_make_dir $subdomains
test_make_dir $info
test_make_dir $captures
subdomains_temp=$subdomains/temp.txt
subdomains_file=$subdomains/subdomains.txt
live_subdomains_file=$subdomains/live.txt

# Enumerate subdomains using subfinder, amass, assetfinder and sublist3r more to follow
echo "[*] Enumerating subdomains of $domain"
subfinder -d $domain > $subdomains_temp
amass enum -d $domain >> $subdomains_temp
assetfinder $domain >> $subdomains_temp
#sublist3r -d $domain >> $subdomains_temp

# filter out any out of scope domains, duplicates or stdio junk from the scripts
cat $subdomains_temp | grep $domain | sort -u > $subdomains_file
rm $subdomains_temp

# List discovered domains
numdomains=$(cat $subdomains_file | wc | cut -d ' ' -f 6)
echo "[*] Found $numdomains subdomains."
cat $subdomains_file

# perform whois lookup
for subdomain in $(cat $subdomains_file); do
    whois $subdomain > $info/${subdomain}.txt
done

# if the -subnet flag is set get the CIDR subnet ranges from whois pulls and add all live ips to the list of tragets
if [ $2 = "-subnet" ]; then
    echo "[%] Be forewarned, THIS WILL TAKE AGES, I advise going for a walk/having a nap..."
    for subdomain in $(cat $subdomains_file); do
        whois $(dig $subdomain +short) 2>/dev/null | grep -e 'CIDR:' -e 'inetnum:' | rev | cut -d ' ' -f 1 | rev | tee $ips/subnet_ranges_temp.txt
    done
    cat $ips/subnet_ranges_temp.txt | sort -u > $ips/subnet_ranges.txt
    rm $ips/subnet_ranges_temp.txt
    for subnet_range in $(cat $ips/subnet_ranges.txt); do
        subnet_ip=$(echo $subnet_range | cut -d '/' -f 1)
        subnet_cidr=$(echo $subnet_range | cut -d '/' -f 2)
        whois $subnet_ip 2>/dev/null > $info/${subnet_ip}-${subnet_cidr}.txt
        fping -a -g $subnet_range 2>/dev/null >> $ips/live_ips.txt
    done
    cat $ips/live_ips.txt >> $subdomains_file
fi

# Enumerate subdomains hosting live http servers on port 80
echo "[*] Checking to see which hosts are severing websites"
cat $subdomains_file | httprobe-bin -p http:8080,https:8443  > $live_subdomains_file 
numalive=$(cat $live_subdomains_file | wc | cut -d ' ' -f 6)
echo "[*] Found $numdomains live subdomains."

# Grab screen shots from all live hosts
echo "[*] Gathering screen captures from live hosts."
gowitness file -f $live_subdomains_file -t 50 -P $captures 
echo "[*] Done, captures can be found in $captures"

# probably should delete the database but can mess with other instances of the script
# maybe add a check that there are no open handles to it? 
#rm gowitness.sqlite3


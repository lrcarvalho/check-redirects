#!/bin/bash
# Script to check the redirets till any URL address

#initializing URL variable
URL=""
#initializing k variable (enble following redirects with invalis ssl cert)
k=""

usage() {
	cat <<EOT

  usage $0 [-u] [-k]
        -u url-to-test (mandatory)
        -k Default FALSE. Follow redirects with invalid SSL certificate. (not mandatory)

  OPTIONS
    -u url to test
    -k follow invalid SSL redirects
EOT
}

check() {
	counter=0
    temp_url=$URL

    #not folowing redirects that has no valid certificate
    if [ -z "$k" ]; then
        exists=$(curl -Is "$URL" | head -n 1)

    #-k: folowing redirects that has invalid certificate
    else
        exists=$(curl -k -Is "$URL" | head -n 1)
    fi

    #if site exists
    if ! [ -z "$exists" ]; then
        #not folowing redirects that has no valid certificate
        if [ -z "$k" ]; then
            echo "Checking redirects for $URL (NOT following redirects invalid SSL cetiticates):"
            echo ""
            while [ -n "${URL}" ]; do
                if [ "$counter" -gt 0 ]; then
                    echo -e ' \t '"Redirect $counter - $URL"
                fi
                ((counter++))
                URL=$(curl -sw "\n\n%{redirect_url}" "${URL}" | tail -n 1)
            done
        #-k: folowing redirects that has invalid certificate
        else
            echo "Checking redirects for $URL (-k option enabled: following redirects with invalid SSL cetiticates):"
            echo ""
            while [ -n "${URL}" ]; do
                if [ "$counter" -gt 0 ]; then
                    echo -e ' \t '"Redirect $counter - $URL"
                fi
                ((counter++))
                URL=$(curl -k -sw "\n\n%{redirect_url}" "${URL}" | tail -n 1)
            done
        fi

        #No redirects found
        if [ "$counter" -eq 1 ]; then
            echo -e ' \t '"URL $temp_url has no redirects for other url's."
        fi
    else
        echo -e ' \t '"URL $URL not found"
    fi
}

while getopts "u:k" option; do
	case $option in
	u)
		URL="$OPTARG"
		;;
	k)
		k="1"
		;;
	\?)
		echo "wrong option."
		usage
		exit 1
		;;
	esac
done
shift $((OPTIND -1))

if [[ -z $URL ]]; then
	echo "ERROR: At least URL option required."
	usage
	exit 1
fi

check
echo
exit 0

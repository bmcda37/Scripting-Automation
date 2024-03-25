#!/bin/bash
# Count number of characters in a variable:
#     echo $variable | wc -c

# Variable to encode
: << 'COMMENT'
Example 1:

var="nef892na9s1p9asn2aJs71nIsm"

for counter in {1..40}
do
    var=$(echo $var | base64)
    #Print the 35 result of the loop
    if [ $counter -eq 35 ]
    then
        echo "Number of characters in the 35th generated value: $(echo $var | wc -c)"
    fi
done
COMMENT

: << 'COMMENT'
Example 2:
domains=(www.inlanefreight.com ftp.inlanefreight.com vpn.inlanefreight.com www2.inlanefreight.com)

echo ${domains[3]}
COMMENT

var="8dm7KsjU28B7v621Jls"
value="ERmFRMVZ0U2paTlJYTkxDZz09Cg"

for i in {1..40}
do
        var=$(echo $var | base64)
		
		#<---- If condition here:

        if [[ $var == *"$value"* && ${#var} -gt 113450 ]]
        then
            echo "${var: -20}"
        fi

done

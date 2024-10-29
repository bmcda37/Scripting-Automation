import re
import sys

# .match(re,string) - returns a match object if there is a match, else None
# .search(re,string) - returns a match object if there is a match, else None
# .findall(re,string) - returns a list of all matches
#regexp move left to right on a string
#\w any text character but no special characters
#\W opposite of \w
#^ Matches from the start of the string
#$ Matches from the end of the string
#. Matches any character except newline
#\ escapes special characters such as . in an IP address

#Holds the precompiled regular expression patterns to speed up processing.c
regexp = re.compile(
    
)


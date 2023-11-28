#!/bin/bash

HEADER = "| Name | Homepage URL | Description |"  
SEPARATOR = "|---|---|---|"

JSON = gh repo list 23W-GBAC -L 100 --json name --json description --json stargazerCount --json homepageUrl
BODY = $JSON | jq -r '.[] | [.name, .homepageUrl, .description] | @tsv' | sed 's/\t/ | /g'
BODY = $BODY | sed 's/^/| /g'
BODY = $BODY | sed 's/$/ |/g'

# final output of all segments of our code, feeds into a new file called bloglist_auto.md
echo $HEADER && echo $SEPARATOR && echo $BODY > bloglist_auto.md

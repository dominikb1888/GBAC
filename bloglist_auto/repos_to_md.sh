header = "| Name | Homepage URL | Description |"  
separator = "|---|---|---|"

json = gh repo list 23W-GBAC -L 100 --json name --json description --json stargazerCount --json homepageUrl
body = $json | jq -r '.[] | [.name, .homepageUrl, .description] | @tsv' | sed 's/\t/ | /g'
body = $body | sed 's/^/| /g'
body = $body | sed 's/$/ |/g'

# final output of all segments of our code, feeds into a new file called bloglist_auto.md
echo $header && echo $separator && echo $body > bloglist_auto.md

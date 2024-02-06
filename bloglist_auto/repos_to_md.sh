
echo "| Name | Homepage URL | Description |" >  bloglist_auto.md | echo "|---|---|---|" >> bloglist_auto.md | gh repo list 23W-GBAC -L 100 --json name --json description --json stargazerCount --json homepageUrl | jq -r '.[] | [.name, .homepageUrl, .description] | @tsv' | sed 's/\t/ | /g' | sed 's/^/| /g' | sed 's/$/ |/g' >> bloglist_auto.md

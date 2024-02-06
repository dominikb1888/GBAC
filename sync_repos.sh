for NAME in $(gh repo list 23W-GBAC --json name | jq -r '.[] | .name'); do gh repo sync "23W-GBAC/$NAME";done;

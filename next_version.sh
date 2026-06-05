#!/bin/bash

use_gdate() {
  if command -v gdate &> /dev/null; then
    gdate "$@"
  else
    date "$@"
  fi
}

# Get the latest tag on the main branch
latest_tag=$(git describe --tags --abbrev=0 main 2>/dev/null)

# Extract the date components from the latest tag
if [[ $latest_tag =~ ([0-9]{2,4})\.([0-9]{1,2})\.([0-9]{1,2})\+([0-9]{1,2}) ]]; then
  last_year=${BASH_REMATCH[1]}
  last_month=${BASH_REMATCH[2]}
  last_day=${BASH_REMATCH[3]}
  last_release=${BASH_REMATCH[4]}
else
  last_year=$(date +%Y)
  last_month=$(use_gdate -d "$(use_gdate +%Y-%m-1)" +%m)
  last_day="$(date +%d)"
  last_release="00"
fi

# Get today's date components
today=$(date +%Y.%m.%d | sed 's/\.0/./g')
IFS='.' read -ra today_parts <<< "$today"
today_year=${today_parts[0]}
today_month=${today_parts[1]}
today_day=${today_parts[2]}

# Determine the next version based on the logic
if [ "$last_year" = "$today_year" ] && \
   [ "$last_month" = "$today_month" ] && \
   [ "$last_day" = "$today_day" ]; then
  # echo "Incrementing the release number"
  next_release=$(printf "%d" $((10#$last_release + 1)))
else
  next_release="1"
fi

next_version="$today_year.$today_month.$today_day+$next_release"

echo $next_version

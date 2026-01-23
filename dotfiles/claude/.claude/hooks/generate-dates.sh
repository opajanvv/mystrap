#!/bin/bash
# Generate dates for Claude context injection (week: Monday-Sunday)

yesterday=$(date -d "-1 day" +%Y-%m-%d)
today=$(date +%Y-%m-%d)
tomorrow=$(date -d "+1 day" +%Y-%m-%d)

# Day of week: Monday=1, Sunday=7
dow=$(date +%u)

begin_this_week=$(date -d "-$((dow - 1)) days" +%Y-%m-%d)
end_this_week=$(date -d "+$((7 - dow)) days" +%Y-%m-%d)
begin_next_week=$(date -d "+$((8 - dow)) days" +%Y-%m-%d)
end_next_week=$(date -d "+$((14 - dow)) days" +%Y-%m-%d)

cat << EOF
Dates: yesterday ${yesterday}, today ${today}, tomorrow ${tomorrow}. This week ${begin_this_week} to ${end_this_week}, next week ${begin_next_week} to ${end_next_week}.
EOF

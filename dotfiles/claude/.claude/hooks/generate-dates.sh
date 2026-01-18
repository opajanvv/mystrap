#!/bin/bash
# Generate DATES.md with pre-calculated dates (week: Sunday-Saturday)

today=$(date +%Y-%m-%d)
tomorrow=$(date -d "+1 day" +%Y-%m-%d)
dow=$(date +%w)

begin_this_week=$(date -d "-${dow} days" +%Y-%m-%d)
end_this_week=$(date -d "+$((6 - dow)) days" +%Y-%m-%d)
begin_next_week=$(date -d "+$((7 - dow)) days" +%Y-%m-%d)
end_next_week=$(date -d "+$((13 - dow)) days" +%Y-%m-%d)

cat > ~/.claude/DATES.md << EOF
today: ${today}
tomorrow: ${tomorrow}
begin of this week: ${begin_this_week}
end of this week: ${end_this_week}
begin of next week: ${begin_next_week}
end of next week: ${end_next_week}
EOF

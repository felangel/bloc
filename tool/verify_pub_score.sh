#!/bin/bash
# Runs `pana . --no-warning` and verifies that the package score
# is greater or equal to the desired score. By default the desired score is
# a perfect score but it can be overridden by passing the desired score as an argument.
#
# Ensure the package has a score of at least a 100
# `./verify_pub_score.sh 100`
#
# Ensure the package has a perfect score
# `./verify_pub_score.sh`

PANA=$(pana . --no-warning); PANA_SCORE=$(echo $PANA | sed -n "s/.*Points: \([0-9]*\)\/\([0-9]*\)./\1\/\2/p")
echo "score: $PANA_SCORE"
IFS='/'; read -a SCORE_ARR <<< "$PANA_SCORE"; SCORE=SCORE_ARR[0]; TOTAL=SCORE_ARR[1]
if [ -z "$1" ]; then MINIMUM_SCORE=TOTAL; else MINIMUM_SCORE=$1; fi
if (( $SCORE < $MINIMUM_SCORE )); then echo "minimum score $MINIMUM_SCORE was not met!"; exit 1; fi
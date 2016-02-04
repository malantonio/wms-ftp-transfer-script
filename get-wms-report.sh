#!/usr/bin/env bash

SCP="$(which scp)"

# currently can't do anything w/o scp
if [ -z $SCP ]
then
  echo "$0 requires scp to work!"
  exit 1
fi

# definitely need an OCLC symbol to do anything
if [ -z $OCLC_SYMBOL ]
then
  echo "$0 requires the environment variable OCLC_SYMBOL be set"
  exit 1
fi

if [ -z $REPORT_NAME ]
then
  echo "Please specify a report name:"
  echo ""
  echo "    All_Checked_out_items"
  echo "    Circulation_add_delete"
  echo "    Overdue_Report"
  echo "    HoldListReport"
  echo "    HoldsReadyForPickup"
  echo "    Item_Inventories"
  echo "    Open_Holds"
  echo "    Patron_Report_Full"
  echo "    Patron_Report_wk"
  echo ""
  exit 1
fi

REPORT=$(echo $REPORT_NAME | awk '{if ($0 ~ /,/) { printf "{%s}", $0 } else { printf $0 }}')

# store the reports in the current directory if one isn't provided
if [ -z $OUT_PATH ]
then
  OUT_PATH="$PWD"
fi

# passing/setting DATE overrides getting the reports for 'today'
# (useful for debugging or getting older reports)
if [ -z $DATE ]
then
  DATE="$(date +"%Y%m%d")"
fi

# we'll need a lowercase version of the OCLC symbol to use as our user
# in the connection to scp.oclc.org
SYMBOL_LOWER=$(echo "$OCLC_SYMBOL" | awk '{print tolower($0)}')

# and we want an uppercase symbol as our file's prefix
if [[ $SYMBOL_LOWER -eq $OCLC_SYMBOL ]]
then
  OCLC_SYMBOL=$(echo "$SYMBOL_LOWER" | awk '{print toupper($0)}')
fi

OCLC_SERVER="$SYMBOL_LOWER@scp.oclc.org"
OCLC_PATH="wms/reports/$OCLC_SYMBOL*.$REPORT.$DATE.txt"
CMD="$SCP $OCLC_SERVER:$OCLC_PATH $OUT_PATH"

if [[ -z $DEBUG && $DEBUG -lt 1 ]]
then
  $CMD
else
  echo $CMD
fi

#!/bin/bash
set -e -u -o pipefail
set -x
# zpool status now has '-j -p' for json output
# zpool get now has '-j -p' for json output
# This simplifies staggered scrubs
#
# {
#  "output_version": {
#    "command": "zpool get",
#    "vers_major": 0,
#    "vers_minor": 1
#  },
#  "pools": {
#    "mm-015-2024Oct31-9RHG2GML": {
#      "name": "mm-015-2024Oct31-9RHG2GML",
#      "type": "POOL",
#      "state": "ONLINE",
#      "pool_guid": "9348890548095938797",
#      "txg": "32584810",
#      "spa_version": "5000",
#      "zpl_version": "5",
#      "properties": {
#        "size": {
#          "value": "12.7T",
#          "source": {
#            "type": "NONE",
#
# {
#   "output_version": {
#     "command": "zpool status",
#     "vers_major": 0,
#     "vers_minor": 1
#   },
#   "pools": {
#     "mm-015-2024Oct31-9RHG2GML": {
#       "name": "mm-015-2024Oct31-9RHG2GML",
#       "state": "ONLINE",
#       "pool_guid": "9348890548095938797",
#       "txg": "32584810",
#       "spa_version": "5000",
#       "zpl_version": "5",
#       "scan_stats": {
#         "function": "SCRUB",
#         "state": "FINISHED",
#         "start_time": "Sun Jan 11 12:24:02 AM EST 2026",
#         "end_time": "Sun Jan 11 05:31:02 PM EST 2026",
#         "to_examine": "11.2T",
# 
# .pools["$pool"].scan_stats.state
# .pools["$pool"].scan_stats.scrub_pause
# .pools["$pool"].scan_stats.end_time
#
Main() {
    local pool function pause end interval now due
    now=$(date +%s)
    zpool status -j -p | jq -r '.pools[] | [.name, .scan_stats.function, .scan_stats.end_time, .scan_stats.scrub_pause ] | @tsv' | sort -n -k3,4 |
    while read -r pool function end pause; do
        # interval=$(zpool get -H custom:scrub_interval "$pool")
	interval=2419200
	((due=end+interval))
        if [[ "$pause" == 0 ]] && [[ "$end" == 0 ]]; then
	    echo "Exiting because $function in progress on $pool"
	elif [[ "$end" == 0 ]]; then
	   echo "Restarting scrub on $pool because $function paused at $pause"
	   zpool scrub "$pool"
	elif [[ "$now" -gt "$due" ]]; then
	   echo "Starting scrub on $pool because past time for a scrub"
	   zpool scrub "$pool"
        else
           echo "Nothing $pool"
           continue
        fi
        break
    done
}
Main "$@"

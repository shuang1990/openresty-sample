#!/bin/bash

NC='\033[0m'      # Normal Color
RED='\033[0;31m'  # Error Color
CYAN='\033[0;36m' # Info Color

. $devops_prj_path/base/string.sh
. $devops_prj_path/base/init.sh

# defined: $devops_prj_path

# will defined:

base_py_app="$devops_prj_path/src/app.py"
action=${1:-help}

if [ -t 1 ] ; then
    docker_run_fg_mode='-it'
else
    docker_run_fg_mode='-i'
fi

function run_cmd() {
    local t=`date`
    echo "$t: $1"
    eval $1
}

function ensure_dir() {
    if [ ! -d $1 ]; then
        run_cmd "mkdir -p $1"
    fi
}

function docker0_ip() {
    local host_ip=$(ip addr show docker0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | awk '{print $1}' | head  -1)
    echo $host_ip
}


function list_contains() {
    local var="$1"
    local str="$2"
    local val

    eval "val=\" \${$var} \""
    [ "${val%% $str *}" != "$val" ]
}

function py_read_kv() {
    local key=$1
    local ret=$(python $base_py_app --read_kv $key)
    echo $ret
}

action=${1:-help}

. $devops_prj_path/base/init.sh
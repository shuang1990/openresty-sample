#!/bin/bash

set -e
__root_path=$(cd $(dirname $0); pwd -P)
devops_prj_path="$__root_path/devops"
source $devops_prj_path/base.sh

config_file=$__root_path/conf/nginx.conf

function stop() {
    run_cmd "nginx -s stop"
}

function check_config() {
     if [ ! -f $config_file ];then
        echo "nginx config not found, please exec [sh manager.sh init] first"
        exit 1
    fi
}

function start() {
    check_config
    local cmd="nginx -p `pwd`/ -c $config_file"
    run_cmd "$cmd"
}

function restart() {
    stop
    start
}

function reload() {
    init
    local cmd="nginx -p `pwd`/ -c $config_file -s reload"
    run_cmd "$cmd"

}

function py() {
    shift
    local cmd="$@"
    run_cmd "python $devops_prj_path/src/app.py $cmd"
}

function init() {
    local template_file=$__root_path/conf/nginx.conf.example
    run_cmd "python $devops_prj_path/src/app.py --init-config $template_file"
}

help() {
	cat <<-EOF
    Usage: mamanger.sh [options]

    Valid options are:

        init
        reload
        start
        stop
        restart
        -h                      show this help message and exit
EOF
}
if [ -z "$action" ]; then
    action='help'
fi
$action "$@"

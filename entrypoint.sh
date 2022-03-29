#!/bin/bash

set -e

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${addonspath}
: ${database}
: ${update}
: ${init}
: ${stopafterinit}
: ${load}
: ${datadir:='/opt/local/odoo/.local/share/Odoo'}

: ${nohttp}
: ${httpinterface}
: ${httpport}
: ${longpollingport}
: ${proxymode}

: ${db_host:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${db_port:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${db_maxconn:=8}
: ${db_user:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${db_password:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}
: ${dbtemplate}
: ${dbfilter}

: ${workers}
: ${maxcronthreads}
: ${limitmemoryhard}
: ${limitmemorysoft}
: ${limitrequest}
: ${limittimecpu}
: ${limittimereal}
: ${limittimerealcron}

: ${xmlrpcport}

: ${adminpasswd}

DB_ARGS=()
function check_param() {
    param="$1"
    value="$2"
    # Check that there is a value for the parameter before passing it to launch odoo
    if ! [[ -z "$value" ]]; then
        ODOO_ARGS+=("--${param}")

        if ! [[ $value == 'true' ]]; then
            ODOO_ARGS+=("${value}")
        fi;
    fi;
}

# Common options
check_param "addons-path" "$addonspath"
check_param "database" "$database"
check_param "update" "$update"
check_param "init" "$init"
check_param "stop-after-init" "$stopafterinit"
check_param "load" "$load"
check_param "data-dir" "$datadir"

check_param "no-http" "$nohttp"
check_param "http-interface" "$httpinterface"
check_param "http-port" "$httpport"
check_param "longpolling-port" "$longpollingport"
check_param "proxy-mode" "$proxymode"

check_param "db_host" "$db_host"
check_param "db_port" "$db_port"
check_param "db_maxconn" "$db_maxconn"
check_param "db_user" "$db_user"
check_param "db_password" "$db_password"
check_param "db-template" "$dbtemplate"
check_param "db-filter" "$dbfilter"

check_param "workers" "$workers"
check_param "max-cron-threads" "$maxcronthreads"
check_param "limit-memory-hard" "$limitmemoryhard"
check_param "limit-memory-soft" "$limitmemorysoft"
check_param "limit-request" "$limitrequest"
check_param "limit-time-cpu" "$limittimecpu"
check_param "limit-time-real" "$limittimereal"
check_param "limit-time-real-cron" "$limittimerealcron"

check_param "xmlrpc-port" "$xmlrpcport"

check_param "admin-passwd" "$adminpasswd"

echo "odoo $@ ${ODOO_ARGS[@]}"

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            exec odoo "$@" "${ODOO_ARGS[@]}"
        fi
        ;;
    -*)
        exec odoo "$@" "${ODOO_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1

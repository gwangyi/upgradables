typeset -gA UPGDB_ITEMS
typeset -gA UPGDB_ICONS

UPGDB_BASE=$(cd $(dirname ${(%):-%N}) && pwd)
source $UPGDB_BASE/config.zsh

function __upgdb_last_mod_bsd () {
    stat -f %m $1
}

function __upgdb_last_mod_gnu () {
    stat $1 -c %Y
}

if __upgdb_last_mod_bsd > /dev/null 2> /dev/null; then
    function __upgdb_last_mod() { __iupg_last_mod_bsd $@ 2> /dev/null || echo 0; }
else
    function __upgdb_last_mod() { __iupg_last_mod_gnu $@ 2> /dev/null || echo 0; }
fi

function __upgdb_do_update_feed () {
    local cmd
    local full_cmd
    local items_fn
    local cnts_fn
    local feed_body

    id=$1
    full_cmd=${UPGDB_ITEMS[$id]#feed }
    items_fn=${UPGDB_PATH:-$TMPDIR}/upg-$id
    cnts_fn=${UPGDB_PATH:-$TMPDIR}/upg-$id-cnt

    if [ ! -e $cnts_fn ]; then
        echo -n "0" > $cnts_fn 2> /dev/null
    fi

    echo "Updating $id..."
    feed_body=$(eval "curl -sL $full_cmd")
    xmllint --xpath "//*[local-name()='fullcount']/text()" - <<< $feed_body > $cnts_fn
    xsltproc $UPGDB_BASE/feed.xslt - <<< $feed_body | tail -n +2 > $items_fn
}

function __upgdb_do_update () {
    local cmd
    local full_cmd
    local items_fn
    local cnts_fn

    id=$1
    full_cmd=$UPGDB_ITEMS[$id]
    cmd=${full_cmd%% *}
    items_fn=${UPGDB_PATH:-$TMPDIR}/upg-$id
    cnts_fn=${UPGDB_PATH:-$TMPDIR}/upg-$id-cnt

    if [ "$cmd" = "feed" ]; then
        __upgdb_do_update_feed $1
        return
    fi

    if [ ! -e $cnts_fn ]; then
        echo -n "0" > $cnts_fn 2> /dev/null
    fi

    echo "Updating $id..."

    count=$(eval $full_cmd 2> /dev/null | tee $items_fn | wc -l | sed 's/^ +//; s/ +$//')
    echo -n "$count" > $cnts_fn

    true
}

function __upgdb_count () {
    local current
    local last
    local cmd
    local full_cmd
    local target
    local filename
    local cnt
    local icon

    id=$1
    icon=$UPGDB_ICONS[$id]
    full_cmd=$UPGDB_ITEMS[$id]
    cmd=${full_cmd%% *}
    filename=${UPGDB_PATH:-$TMPDIR}/upg-$id-cnt
    current=$(date +%s)
    last=$(__upgdb_last_mod $filename -c %Y)
    target=$(( $last + ${UPGDB_DELTA:-600} ))

    if [ "$cmd" = "feed" ] || command -v $cmd > /dev/null 2> /dev/null; then
        if [[ $target -lt $current ]]; then
            touch $filename
            __upgdb_do_update $id > /dev/null 2> /dev/null &!
        fi
        cnt=$( cat $filename )
        if [ "$cnt" -gt 0 ]; then
            echo -n "$icon "
            echo -n "$cnt "
        fi
    fi

    true
}

function __upgdb_prompt() {
    local id
    for id in ${(k)UPGDB_ITEMS}; do
        __upgdb_count $id
    done
}

function __upgdb_update () {
    local id
    for id in ${(k)UPGDB_ITEMS}; do
        __upgdb_do_update $id
    done
}

function __upgdb_do_list () {
    local id
    local cmd
    local full_cmd
    local filename
    id=$1
    full_cmd=$UPGDB_ITEMS[$1]
    cmd=${full_cmd%% *}

    if [ $cmd = "feed" ] || command -v $cmd > /dev/null 2> /dev/null; then
        filename=${UPGDB_PATH:-$TMPDIR}/upg-$id
        echo "$id: "
        cat $filename
    fi
}

function __upgdb_list () {
    local id
    for id in ${(k)UPGDB_ITEMS}; do
        __upgdb_do_list $id
    done
}

POWERLEVEL9K_CUSTOM_UPGDB="__upgdb_prompt"
POWERLEVEL9K_CUSTOM_UPGDB_BACKGROUND="yellow"
POWERLEVEL9K_CUSTOM_UPGDB_FOREGROUND="black"

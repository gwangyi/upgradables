# UPGDB_PATH=$TMP
# UPGDB_DELTA=600

UPGDB_ICONS=(
    apt-get "\uf306"
    brew "\uf0fc"
    gmail "\uf7aa"
)

UPGDB_GMAIL_ID=""
UPGDB_GMAIL_KEY=""

UPGDB_ITEMS=(
    "apt-get" "apt-get update 2> /dev/null > /dev/null && apt-get --just-print upgrade | grep -E '^Inst'"
    "brew" "brew update 2> /dev/null > /dev/null && brew outdated"
    "gmail" "feed https://\$UPGDB_GMAIL_ID:\$UPGDB_GMAIL_KEY@mail.google.com/mail/feed/atom"
)


# Git related command
git_large_file()
{
    # list topk large file in git repo
    # usage: $0 k
    local topk=$1
    if [ -z "$1" ]; then
        topk=5
    fi
    git rev-list --objects --all | grep "$(git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -$topk | awk '{print$1}')"
}

git_rm_history_file()
{
    # apply filter branch to remove history file
    # usage: git_rm_history_file filename
    if [ ! -z "$1" ]; then
        git filter-branch -f --prune-empty --index-filter 'git rm -rf --cached --ignore-unmatch $1' --tag-name-filter cat -- --all
    fi

}

git_gc_unreachable()
{
    git reflog expire --expire-unreachable="now" --all
    git prune --expire="now" -v
    git gc --aggressive --prune="now"
}

git_clean_branch()
{
    local origin=$1
    if [ -z "$1" ]; then
        origin=origin
    fi
    git remote prune $origin
    git branch --merged | egrep -v "(^\*|main)" | xargs git branch -d
}

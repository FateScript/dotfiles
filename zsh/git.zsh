
# Git related command
# list large file in git repo
# usage: $0 k
git_large_file()
{
    local k
    k=$1
    if [ -z "$1" ]; then
        k=5
    fi

    git rev-list --objects --all | grep "$(git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -$k | awk '{print$1}')"
}

# apply filter branch to remove history file
# usage: $0 filename
git_rm_history_file()
{
    if [ ! -z "$1" ]; then
        git filter-branch -f --prune-empty --index-filter 'git rm -rf --cached --ignore-unmatch $1' --tag-name-filter cat -- --all
    fi

}

git_ls_unreachable()
{
    git fsck --unreachable --no-reflog
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

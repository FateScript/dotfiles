
# Git related command
git_large_file()
{
    # list topk large file in git repo
    # usage: $0 k
    local topk=$1
    if [ -z "$1" ]; then
        topk=5
    fi
    git rev-list --objects --all | grep "$(git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -"$topk" | awk '{print$1}')"
}

git_rm_history_file()
{
    # apply filter branch to remove history file
    # usage: git_rm_history_file filename
    if [[ -z "$1" ]]; then
        echo "Usage: git_rm_history_file filename"
        return 1
    fi

    git filter-branch -f --prune-empty \
        --index-filter "git rm -rf --cached --ignore-unmatch '$1'" \
        --tag-name-filter cat -- --all
}

git_gc_unreachable()
{
    git reflog expire --expire-unreachable="now" --all
    git prune --expire="now" -v
    git gc --aggressive --prune="now"
}

git_clean_branch()
{
    # clean branches that no longer exist in remote and fully merged branch
    local origin=$1
    if [ -z "$1" ]; then
        origin=origin
    fi
    git remote prune "$origin"
    git branch --merged | grep -E -v "(^\*|main)" | xargs git branch -d
}

git_branch_push() {
    # push commit_hash to remote branch, combined with git branchless
    local remote="origin"
    local commit_hash=""
    local remote_branch=""
    local -a push_opts=()

    # Parse flags (anything starting with - or --)
    while [[ "$1" == -* ]]; do
        push_opts+=("$1")
        shift
    done

    if [[ $# -eq 1 ]]; then
        remote_branch="$1"
        commit_hash=$(git rev-parse HEAD)
    elif [[ $# -eq 2 ]]; then
        if git remote get-url "$1" &> /dev/null; then
            remote="$1"
            remote_branch="$2"
            commit_hash=$(git rev-parse HEAD)
        else
            commit_hash="$1"
            remote_branch="$2"
        fi
    elif [[ $# -eq 3 ]]; then
        remote="$1"
        commit_hash="$2"
        remote_branch="$3"
    else
        echo "Usage:"
        echo "    git_branch_push [-f|--force|...] remote-branch"
        echo "    git_branch_push [-f|--force|...] [remote|commit-hash] remote-branch"
        echo "    git_branch_push [-f|--force|...] remote commit-hash remote-branch"
        return 1
    fi

    if [[ -z "$remote_branch" ]]; then
        echo "Error: remote branch name is required."
        return 1
    fi

    # NOTE: using "$commit_hash:refs/heads/$remote_branch" will trigger colon modifiers in zsh
    # check https://stackoverflow.com/questions/55604684/colon-with-r-in-string-not-working-as-desired-under-zsh
    git push "${push_opts[@]}" "$remote" "${commit_hash}:refs/heads/${remote_branch}"
}


git_llm_commit() {
    # Git commit with AI generated message
    # reference: https://gist.github.com/karpathy/1dd0294ef9567971c1e4348a90d69285
    local model_name="$1"
    if [ -z "$1" ]; then
        model_name="qwen2:7b"
    fi

    generate_commit_message() {
        ollama run "$model_name" "
You are an expert of git commit message writer.

The following is the commit message format and example.

Format: <type>(<scope>): <subject>

note that <scope> and () outside <scope> is optional

## Example

\`\`\`
feat: add hat wobble
^--^  ^------------^
|     |
|     +-> Summary in present tense.
|
+-------> Type: chore, docs, feat, fix, refactor, style, or test.
\`\`\`

Type description:

- feat: (new feature for the user, not a new feature for build script)
- fix: (bug fix for the user, not a fix to a build script)
- docs: (changes to the documentation)
- style: (formatting, missing semi colons, etc; no production code change)
- refactor: (refactoring production code, eg. renaming a variable)
- test: (adding missing tests, refactoring tests; no production code change)
- chore: (updating grunt tasks etc; no production code change)

### More examples
- feat: add profile method for call/statement
- chore: add more frame functions
- fix: get_current_varname bug when using constant and sub module call
- style: isort error in tree dir
- docs: add README of ex-debugger
- refactor: all model inherit from lang_model

Below is a diff of all staged changes:
\`\`\`
$(git diff --cached)
\`\`\`

Please generate a concise, one-line commit message for these changes.
"
    }

    read_input() {
        if [ -n "$ZSH_VERSION" ]; then
            echo -n "$1"
            read -r REPLY
        else
            read -p "$1" -r REPLY
        fi
    }

    echo "Generating AI-powered commit message..."
    commit_message=$(generate_commit_message)

    while true; do
        echo -e "\nProposed commit message:"
        echo -e "\033[32m$commit_message\033[0m"

        read_input "Do you want to (a)ccept, (e)dit, (r)egenerate, or (c)ancel? "
        choice=$REPLY
        echo "$choice"

        case "$choice" in
            a|A )
                if git commit -m "$commit_message"; then
                    echo "Changes committed successfully!"
                    return 0
                else
                    echo "Commit failed. Please check your changes and try again."
                    return 1
                fi
                ;;
            e|E )
                read_input "Enter your commit message: "
                commit_message=$REPLY
                if [ -n "$commit_message" ] && git commit -m "$commit_message"; then
                    echo "Changes committed successfully with your message!"
                    return 0
                else
                    echo "Commit failed. Please check your message and try again."
                    return 1
                fi
                ;;
            "r"|"R" )  # r is built-in command in zsh
                echo "Regenerating commit message..."
                commit_message=$(generate_commit_message)
                ;;
            c|C )
                echo "Commit cancelled."
                return 1
                ;;
            * )
                echo "Invalid choice. Please try again."
                ;;
        esac
    done
}

git_rebase_n() {
    local count="$1"
    shift
    git rebase -i "HEAD~$count" "$@"
}

git_rm_worktree() {
    local dry_run=0
    local force=0
    local remove_all=0
    local delete_branch=0

    while (( $# > 0 )); do
        case "$1" in
            -n|--dry-run)
                dry_run=1
                ;;
            -f|--force)
                force=1
                ;;
            -a|--all)
                remove_all=1
                ;;
            --delete-branch)
                delete_branch=1
                ;;
            -h|--help)
                echo "Usage: git_rm_worktree [--dry-run] [--force] [--all] [--delete-branch] <commit|branch>"
                return 0
                ;;
            --)
                shift
                break
                ;;
            -*)
                echo "Error: unknown option: $1" >&2
                return 2
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    if (( $# != 1 )); then
        echo "Usage: git_rm_worktree [--dry-run] [--force] [--all] [--delete-branch] <commit|branch>" >&2
        return 2
    fi

    local target="$1"
    local repo_root
    repo_root=$(git rev-parse --show-toplevel) || return 1

    local match_mode="commit"
    local target_branch=""
    local target_ref=""
    local target_commit=""

    if git show-ref --verify --quiet "refs/heads/$target"; then
        match_mode="branch"
        target_branch="$target"
        target_ref="refs/heads/$target"
        target_commit=$(git rev-parse --verify "$target_ref^{commit}") || return 1
    elif [[ "$target" == refs/heads/* ]] && git show-ref --verify --quiet "$target"; then
        match_mode="branch"
        target_branch="${target#refs/heads/}"
        target_ref="$target"
        target_commit=$(git rev-parse --verify "$target_ref^{commit}") || return 1
    else
        target_commit=$(git rev-parse --verify "$target^{commit}") || {
            echo "Error: not a valid commit or local branch: $target" >&2
            return 1
        }
    fi

    local -a paths
    local -a branches
    local wt_path head branch_ref

    while IFS=$'\t' read -r wt_path head branch_ref; do
        [[ -z "$wt_path" ]] && continue
        paths+=("$wt_path")
        branches+=("${branch_ref#refs/heads/}")
    done < <(
        git worktree list --porcelain | awk \
            -v mode="$match_mode" \
            -v target_commit="$target_commit" \
            -v target_ref="$target_ref" '
            function flush() {
                if (path == "") {
                    return
                }
                if ((mode == "branch" && branch == target_ref) ||
                    (mode == "commit" && head == target_commit)) {
                    print path "\t" head "\t" branch
                }
            }
            /^worktree / {
                flush()
                path = substr($0, 10)
                head = ""
                branch = ""
                next
            }
            /^HEAD / {
                head = substr($0, 6)
                next
            }
            /^branch / {
                branch = substr($0, 8)
                next
            }
            END {
                flush()
            }
        '
    )

    if (( $#paths == 0 )); then
        if [[ "$match_mode" == "branch" ]]; then
            echo "Error: no worktree is checking out branch $target_branch" >&2
        else
            echo "Error: no worktree has HEAD $target_commit" >&2
        fi
        return 1
    fi

    if (( $#paths > 1 && remove_all == 0 )); then
        echo "Found multiple matching worktrees:" >&2
        for wt_path in "${paths[@]}"; do
            echo "  $wt_path" >&2
        done
        echo "Rerun with --all if you want to remove all of them." >&2
        return 1
    fi

    local repo_physical
    repo_physical=$(cd "$repo_root" && pwd -P)

    local i wt_path_physical branch dirty_status branch_commit
    for (( i = 1; i <= $#paths; i++ )); do
        wt_path="${paths[$i]}"
        branch="${branches[$i]}"
        wt_path_physical=$(cd "$wt_path" 2>/dev/null && pwd -P)

        if [[ -n "$wt_path_physical" && "$wt_path_physical" == "$repo_physical" ]]; then
            echo "Error: refusing to remove the main worktree: $wt_path" >&2
            return 1
        fi

        if (( dry_run )); then
            dirty_status=$(git -C "$wt_path" status --porcelain=v1 --untracked-files=normal 2>/dev/null)
            [[ -n "$dirty_status" ]] && echo "warning: worktree has local changes: $wt_path" >&2
            if (( force )); then
                echo "would run: git -C \"$repo_root\" worktree remove --force \"$wt_path\""
            else
                echo "would run: git -C \"$repo_root\" worktree remove \"$wt_path\""
            fi
        else
            if (( force == 0 )); then
                git -C "$wt_path" diff --quiet --ignore-submodules -- \
                    || { echo "Error: worktree has unstaged changes: $wt_path; rerun with --force to remove anyway" >&2; return 1; }
                git -C "$wt_path" diff --cached --quiet --ignore-submodules -- \
                    || { echo "Error: worktree has staged changes: $wt_path; rerun with --force to remove anyway" >&2; return 1; }
                dirty_status=$(git -C "$wt_path" ls-files --others --exclude-standard)
                [[ -z "$dirty_status" ]] \
                    || { echo "Error: worktree has untracked files: $wt_path; rerun with --force to remove anyway" >&2; return 1; }
                git -C "$repo_root" worktree remove "$wt_path"
            else
                git -C "$repo_root" worktree remove --force "$wt_path"
            fi
        fi

        if (( delete_branch )); then
            if [[ -z "$branch" ]]; then
                echo "warning: no local branch checked out in $wt_path" >&2
                continue
            fi
            branch_commit=$(git -C "$repo_root" rev-parse --verify "refs/heads/$branch^{commit}") || return 1
            if [[ "$branch_commit" != "$target_commit" ]]; then
                echo "Error: refusing to delete branch $branch: it moved to $branch_commit" >&2
                return 1
            fi
            if (( dry_run )); then
                echo "would run: git -C \"$repo_root\" branch -D \"$branch\""
            else
                git -C "$repo_root" branch -D "$branch"
            fi
        fi
    done
}

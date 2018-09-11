#!/usr/bin/env bash

#set -x

target=$1
out_file=$2
threads=$3
branchname=$4

function export_home() {
    if command -v cygpath >/dev/null 2>&1; then
        export $1_HOME=$(cygpath -m "$2")
    else
        export $1_HOME="$2"
    fi
}

function hacl_test() {
    fetch_and_make_kremlin &&
        fetch_and_make_mlcrypto &&
        fetch_mitls &&
        export_home OPENSSL "$(pwd)/mlcrypto/openssl" &&
        make -j $threads ci -k
}

function hacl_test_and_hints() {
    hacl_test && refresh_hacl_hints
}

function fetch_and_make_kremlin() {
    fetch_kremlin
    # Default build target is minimal, unless specified otherwise
    local localTarget
    if [[ $1 == "" ]]; then
        localTarget="minimal"
    else
        localTarget="$1"
    fi
    make -C kremlin -j $threads $localTarget ||
        (cd kremlin && git clean -fdx && make -j $threads $localTarget)
    OTHERFLAGS='--admit_smt_queries true' make -C kremlin/kremlib -j $threads
    export PATH="$(pwd)/kremlin:$PATH"
}

# By default, kremlin master works against F* stable. Can also be overridden.
function fetch_kremlin() {
    if [ ! -d kremlin ]; then
        git clone https://github.com/FStarLang/kremlin kremlin
    fi
    cd kremlin
    git fetch origin
    local ref=$(if [ -f ../.kremlin_version ]; then cat ../.kremlin_version | tr -d '\r\n'; else echo origin/master; fi)
    echo Switching to KreMLin $ref
    git reset --hard $ref
    cd ..
    export_home KREMLIN "$(pwd)/kremlin"
}

function fetch_and_make_mlcrypto() {
    fetch_mlcrypto
    make -C mlcrypto -j $threads
}

function fetch_mlcrypto() {
    if [ ! -d mlcrypto ]; then
        git clone https://github.com/project-everest/MLCrypto mlcrypto
    fi
    cd mlcrypto
    git fetch origin
    local ref=$(if [ -f ../.mlcrypto_version ]; then cat ../.mlcrypto_version | tr -d '\r\n'; else echo origin/master; fi)
    echo Switching to MLCrypto $ref
    git reset --hard $ref
    git submodule update
    cd ..
    export_home MLCRYPTO "$(pwd)/mlcrypto"
}

# By default, mitls-fstar master works against F* stable. Can also be overridden.
function fetch_mitls() {
    if [ ! -d mitls-fstar ]; then
        git clone https://github.com/mitls/mitls-fstar mitls-fstar
    fi
    cd mitls-fstar
    git fetch origin
    local ref=$(if [ -f ../.mitls_version ]; then cat ../.mitls_version | tr -d '\r\n'; else echo origin/master; fi)
    echo Switching to mitls-fstar $ref
    git reset --hard $ref
    git clean -fdx
    cd ..
    export_home MITLS "$(pwd)/mitls-fstar"
}

function refresh_hacl_hints() {
    refresh_hints "git@github.com:mitls/hacl-star.git" "true" "regenerate hints" "."
}

# Note: this performs an _approximate_ refresh of the hints, in the sense that
# since the hint refreshing job takes about 80 minutes, it's very likely someone
# merged to $CI_BRANCH in the meanwhile, which would invalidate some hints. So, we
# reset to origin/$CI_BRANCH, take in our hints, and push. This is short enough that
# the chances of someone merging in-between fetch and push are low.
function refresh_hints() {
    local remote=$1
    local extra="$2"
    local msg="$3"
    local hints_dir="$4"

    # Figure out the branch
    CI_BRANCH=$branchname
    echo "Current branch_name=$CI_BRANCH"

    # Add all the hints, even those not under version control
    find $hints_dir -iname '*.hints' -and -not -path '*/.*' -and -not -path '*/dependencies/*' | xargs git add

    # Without the eval, this was doing weird stuff such as,
    # when $2 = "git ls-files src/ocaml-output/ | xargs git add",
    # outputting the list of files to stdout
    eval "$extra"

    git commit --allow-empty -m "[CI] $msg"
    # Memorize that commit
    commit=$(git rev-parse HEAD)
    # Drop any other files that were modified as part of the build (e.g.
    # parse.fsi)
    git reset --hard HEAD
    # Move to whatever is the most recent master (that most likely changed in the
    # meantime)
    git fetch
    git checkout $CI_BRANCH
    git reset --hard origin/$CI_BRANCH
    # Silent, always-successful merge
    export GIT_MERGE_AUTOEDIT=no
    git merge $commit -Xtheirs
    # Push.
    git push $remote $CI_BRANCH
}

function exec_build() {
    cd hacl-star

    export_home FSTAR "$(pwd)/../"
    result_file="../result.txt"
    local status_file="../status.txt"
    echo -n false >$status_file

    if [ ! -d "secure_api" ]; then
        echo "I don't seem to be in the right directory, bailing"
        echo Failure >$result_file
        return
    fi

    export_home HACL "$(pwd)"
    export_home EVERCRYPT "$(pwd)/providers"

    if [[ $target == "hacl-ci" ]]; then
        echo target - >hacl-ci
        hacl_test && echo -n true >$status_file
    elif [[ $target == "hacl-nightly" ]]; then
        echo target - >hacl-nightly
        export OTHERFLAGS="--record_hints $OTHERFLAGS --z3rlimit_factor 2"
        hacl_test_and_hints && echo -n true >$status_file
    else
        echo "Invalid target"
        echo Failure >$result_file
        return
    fi

    if [[ $(cat $status_file) != "true" ]]; then
        echo "Build failed"
        echo Failure >$result_file
    else
        echo "Build succeeded"
        echo Success >$result_file
    fi

    cd ..
}

# Some environment variables we want
export OCAMLRUNPARAM=b
export OTHERFLAGS="--print_z3_statistics --use_hints --query_stats"
export MAKEFLAGS="$MAKEFLAGS -Otarget"

exec_build

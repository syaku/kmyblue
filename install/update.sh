git stash

git fetch
git checkout $(git tag -l | grep -v 'rc[0-9]*$' | sort -V | tail -n 1)

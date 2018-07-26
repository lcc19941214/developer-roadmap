#!/bin/bash

commit() {
  git add -A;
  git commit -m 'update blog';
  echo 'commit done';
}

check() {
  if [ -n "$(git status -s)" ]; then
    echo 'start commit'
    commit
  else
    echo 'nothing to commit'
  fi
}

check();
#!/bin/bash

# This script is for development of this project.

git diff-index --quiet HEAD -- && {
  # Make sure we are working with the latest copy.
  git pull
} || {
  echo "This project has un-commited changes."
  echo "Don't forget to post and commit your changes."
  sleep 10
}

# Put first window on 1 because 0 is at the far end of thee keyboard
tmux new-session -s STFjord_Dev -n shell -d "btop"

tmux new-window -t "STFjord_Dev:1" -n NeoVim 'nvim' # start without file explorer

tmux attach -d -t STFjord_Dev:NeoVim

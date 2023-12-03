#!/bin/bash

#----------------------------------------------------------------------------
# Poetry
# You can only install poetry after setup python 3.x
#----------------------------------------------------------------------------
echo "** Installing Poetry"
curl -sSL https://install.python-poetry.org | python3 -

# Symlink Poetry to /usr/local/bin to make it available system-wide
# To fix the error: Executable `poetry` not found in pre-commit
sudo ln -s ~/.local/bin/poetry /usr/local/bin/poetry

echo
echo "-- Done --"
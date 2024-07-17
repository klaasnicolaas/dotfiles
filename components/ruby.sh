#!/bin/bash

#----------------------------------------------------------------------------
# Ruby
# Ruby is a dynamic, open source programming language with a focus on simplicity and productivity.
#----------------------------------------------------------------------------
echo "** Installing Ruby"
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

# Install ruby-build Ubuntu dependencies
sudo -y apt install libyaml-dev libpq-dev

echo
echo "-- Done --"
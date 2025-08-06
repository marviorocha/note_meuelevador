#!/bin/sh
set -e
# Remove a potentially pre-existing server.pid for Rails.
rm -f /usr/src/app/tmp/pids/server.pid
# Then exec the container's main process (what's set as CMD in the Dockerfile).
if [ "${*}" == "./bin/rails server" ]; then
  ./bin/rails db:create
  ./bin/rails db:prepare
fi

exec "$@"
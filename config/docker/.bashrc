# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

_GEM_PATHS=$(ls -d1 ${HOME}/.gem/ruby/*/bin 2>/dev/null | paste -sd ':')
_APP_PATHS=$(ls -d1 /app/vendor/bundle/ruby/*/bin 2>/dev/null | paste -sd ':')

export PATH="${_GEM_PATHS}:${_APP_PATHS}:${PATH}"
export PATH="/app/node_modules/.bin:${HOME}/.bin:/app/bin:${PATH}"
export MAKE_ENV=baremetal

# Disable the autostart of all supervisord units
sudo sed -i 's/autostart=.*/autostart=false/g' /etc/supervisor/conf.d/*

# Start the supervisord (empty, no units)
sudo supervisord >/dev/null 2>&1 &

# Wait for supervisord
while ! (sudo supervisorctl status | grep avahi) >/dev/null 2>&1; do
  sleep 1
done

# Boot the mDNS stack
echo '# Start the mDNS stack'
sudo supervisorctl start dbus avahi
echo

function watch-make-test()
{
  while [ 1 ]; do
    inotifywait --quiet -r `pwd` -e close_write --format '%e -> %w%f'
    make test
  done
}

function watch-make()
{
  while [ 1 ]; do
    inotifywait --quiet -r `pwd` -e close_write --format '%e -> %w%f'
    make $@
  done
}

function watch-run()
{
  while [ 1 ]; do
    inotifywait --quiet -r `pwd` -e close_write --format '%e -> %w%f'
    bash -c "$@"
  done
}

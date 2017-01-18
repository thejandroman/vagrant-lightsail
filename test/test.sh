#!/bin/bash

destroy() {
    ANSWER=$1
    read -r -d '' EXPECT_CMD <<EOF
spawn bundle exec vagrant destroy
expect {Are you sure you want to destroy}
send "$ANSWER\r"
interact
EOF
    expect -c "$EXPECT_CMD"
}

if ! bundle exec vagrant box list | grep lightsail 1>/dev/null; then
    bundle exec vagrant box add box/lightsail.box
fi

cd test || exit

bundle exec vagrant up --provider=lightsail
bundle exec vagrant up
bundle exec vagrant provision
bundle exec vagrant reload
bundle exec vagrant halt
bundle exec vagrant up
destroy 'N'
bundle exec vagrant destroy --force
exit
destroy 'N'
destroy 'y'
bundle exec vagrant destroy --force
bundle exec vagrant provision
bundle exec vagrant reload

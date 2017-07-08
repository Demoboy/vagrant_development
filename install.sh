#!/bin/bash


echo "Performing final setup"

if ! [ -f $PROJECT_DIR/dev/ansible/lamp/playbook.yml ]; then
    cat >  $PROJECT_DIR/dev/ansible/lamp/playbook.yml <<EOF
- include: "playbook.dist.yml"
EOF

fi

if ! [ -f $PROJECT_DIR/dev/ansible/setup/playbook.yml ]; then
    cat > $PROJECT_DIR/dev/ansible/lamp/playbook.yml <<EOF
- include: "playbook.dist.yml"
EOF
fi

if ! [ -f $PROJECT_DIR/Vagrantfile ]; then
    cat > $PROJECT_DIR/Vagrantfile <<EOF
require_relative 'dev/vagrant/vagrantfile.dist';
EOF
fi


PROJECT_NAME=$(sed 's/[^a-z  A-Z]//g' <<<  $PROJECT_DIR )

echo "Updating project name"

perl -pi -e "s/placeholder.dev/$PROJECT_NAME.dev/g" $PROJECT_DIR/dev/vagrant/vagrant_vars.rb

echo "Done! Run vagrant up inside the project folder: $PROJECT_DIR"
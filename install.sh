#!/bin/bash

if [  -f ./install.sh ]; then
    echo "Cannot run script from repo folder"
    exit 1
fi

PROJECT_DIR="dev"

if [[ $# -eq 1 ]] ; then
    PROJECT_DIR="$1"
fi

if [ -d "$PROJECT_DIR" ]; then
    echo "Cannot create project. Project with name already exists"
    exit 1
fi

echo "Creating project in folder $1"

symfony new $PROJECT_DIR

echo "Cloning the development template"
git clone https://github.com/128keaton/vagrant_development $PROJECT_DIR/dev/ --quiet

echo "Cleaning up the mess we made"
mv $PROJECT_DIR/dev/.git $PROJECT_DIR/dev/.git.old
rm $PROJECT_DIR/dev/install.sh 
rm $PROJECT_DIR/dev/README.md

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
VAGRANT_DOTFILE_PATH = '.vagrant';
require_relative 'dev/vagrant/vagrantfile.dist';
EOF
fi


PROJECT_NAME=$(sed 's/[^a-z  A-Z]//g' <<<  $PROJECT_DIR )

echo "Updating project name"

perl -pi -e "s/placeholder.dev/$PROJECT_NAME.dev/g" $PROJECT_DIR/dev/vagrant/vagrant_vars.rb

echo "Done! Run vagrant up inside the project folder: $PROJECT_DIR"

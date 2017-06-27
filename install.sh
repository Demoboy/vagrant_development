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

echo "Cloning the development template"
git clone https://github.com/Demoboy/vagrant_development $PROJECT_DIR

echo "Cleaning up the mess we made"
mv $PROJECT_DIR/.git $PROJECT_DIR/.git.old

echo "Fixing file permissions"
chmod +x $PROJECT_DIR/bin/setup

echo "Running setup script"
sh $PROJECT_DIR/bin/setup

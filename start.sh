#!/bin/bash
#set up project name
ENV_NAME="usdm"
ENV_OPSTS="--no-site-packages --distribute"

unset PYTHONDONTWRITEBYTECODE
echo "Making Virtual Environment"
os="`uname -a`"
if [[ "$os" == *Linux* ]]; then
    source /etc/bash_completion.d/virtualenvwrapper
else
    source `which virtualenvwrapper.sh`
fi



cd $WORKON_HOME
mkvirtualenv --distribute $ENV_OPTS $ENV_NAME
cd -
workon $ENV_NAME
export DJANGO_SETTINGS_MODULE=$ENV_NAME.settings.local
echo $VIRTUAL_ENV

#install requirements
pip install -r requirements-dev.txt

#check if postgres installed
RESULT=`psql -l | grep light | wc -l | awk '{print $1}'`;
if test $RESULT -eq 0; then
    echo "Creating Database";
    psql -c "create role usdm with createdb encrypted password 'usdm' login;"
    psql -c "create database usdm with owner usdm;"
else
    echo "Database exists"
fi

#run initial migrations and syncdb
python manage.py syncdb --migrate

#link up with git!
if [ -d .git ]; then
  echo "Git exists";
else
    echo "Setting up Git"
    git init .
    git remote add origin "git@github.com:Lightmatter/usdm.git"
fi

chmod +x manage.py

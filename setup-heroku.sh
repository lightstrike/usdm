#!/bin/bash
ENV_NAME="usdm"
ENV_OPSTS="--no-site-packages --distribute"


unset PYTHONDONTWRITEBYTECODE
os="`uname -a`"
if [[ "$os" == *Linux* ]]; then
    source /etc/bash_completion.d/virtualenvwrapper
else
    source `which virtualenvwrapper.sh`
fi


workon $ENV_NAME
heroku create $ENV_NAME-staging --remote staging
heroku create $ENV_NAME-prod --remote prod
heroku addons:add pgbackups --app $ENV_NAME-prod
heroku addons:add pgbackups --app $ENV_NAME-staging
heroku addons:add mandrill:starter --app $ENV_NAME-staging
heroku addons:add mandrill:starter --app $ENV_NAME-prod
heroku addons:add newrelic --app $ENV_NAME-staging
heroku addons:add newrelic --app $ENV_NAME-prod
heroku config:set SECRET_KEY=`python -c 'import random; print "".join([random.choice("abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)") for i in range(50)])'` --app $ENV_NAME-staging
heroku config:set SECRET_KEY=`python -c 'import random; print "".join([random.choice("abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)") for i in range(50)])'` --app $ENV_NAME-prod
heroku config:set DJANGO_SETTINGS_MODULE=$ENV_NAME.settings.heroku-staging --app $ENV_NAME-staging
heroku config:set DJANGO_SETTINGS_MODULE=$ENV_NAME.settings.heroku --app $ENV_NAME-prod

heroku config:set AWS_SECRET_ACCESS_KEY="" --app $ENV_NAME-prod
heroku config:set AWS_ACCESS_KEY_ID="" --app $ENV_NAME-prod
heroku config:set AWS_STORAGE_BUCKET_NAME=$ENV_NAME-prod --app $ENV_NAME-prod
heroku config:set AWS_SECRET_ACCESS_KEY="" --app $ENV_NAME-staging
heroku config:set AWS_ACCESS_KEY_ID="" --app $ENV_NAME-staging
heroku config:set AWS_STORAGE_BUCKET_NAME=$ENV_NAME-staging --app $ENV_NAME-staging

heroku config:set STRIPE_PUBLIC_KEY="" --app $ENV_NAME-staging
heroku config:set STRIPE_PUBLIC_KEY="" --app $ENV_NAME-prod
heroku config:set STRIPE_SECRET_KEY="" --app $ENV_NAME-staging
heroku config:set STRIPE_SECRET_KEY="" --app $ENV_NAME-prod



git push staging master
git push prod master
heroku run python manage.py syncdb --migrate --app $ENV_NAME-staging
heroku run python manage.py syncdb --migrate --app $ENV_NAME-prod

echo "python manage.py syncdb --migrate" >> bin/post_compile

#!/bin/bash
# Get the vars....  need to source a couple things to make sure I get my env
APP_DIR=`dirname $0`
CFG_DIR=$APP_DIR/../config
source ~/.bashrc
source ~/.bash_profile
source $CFG_DIR/script_vars.sh
cd $APP_DIR
ruby ./update_cop.rb -v 
cat scripts/podatawarehouse.sql | mysql -u $DB_USER -p$DB_PASS -P3305 -h $DB_HOST $DB_NAME

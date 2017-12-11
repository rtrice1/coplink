# Fish Supplements Project
The purpose of this project is to document the entire fish_supplements database which will need to live on the same server as the Fishbowl ERP database.   

## Installation
To install this, just do a git pull.

## BE CAREFUL!!!!!
Jump immediately into the config directory and set the default up to the staging environment.   You'll need a user with write access to the fish_supplements db, and read access to the fishbowl db.   Set up Staging first and test.  Remember to set the ENVIRONMENT variable in the script so it pulls the correct credentials.   .  

## Layout
###### DB directory
All files related to creating the DB structure.   And.... I'm lying because some of the db's were created before this project started.  Luckily there are scripts to backup all the things in the 

###### Scripts directory
The scripts directory is where the runnable executables live with the notable exception of the update_cop.rb directory.   That file is never executed by itself though, and is always called from the wrapper update_cop.sh.  

###### Lib directory
Where most of the meat of the program is.   Here's where you find how to map tables to the cop tables, and where you find the copdata file which makes all the nice methods for us.   

###### Reports directory
Empty for now, but I'd imagine we'll dump all the report data here when we do actually start reports.

###### Scratch Files directory
Sample code, and test code.   Be careful in here.   Most aren't pulling the global variables, they're just doing their own thing.

###### Config directory
Obviously config files go here.  You'll need DBHOST/creds/name and Knack AppID and Secret for production and staging.



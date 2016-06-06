#!/bin/sh

# install nvm: https://github.com/creationix/nvm
# note: use your regular user. NOT root user!

# you can launch this script at startup by:
#     sudo nano /etc/rc.local
#         su $USER -c '/home/$USER/startNode.sh'
# note: replace $USER with the real user
# note2: put the command before "exit 0"


export NVM_DIR="/home/$USER/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # this starts nvm

# start your node apps here. i use pm2, but you can use whatever
NODE_ENV=production PORT=3005 pm2 start /var/www/someApp/app.js --name someApp

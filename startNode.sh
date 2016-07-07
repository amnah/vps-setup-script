#!/bin/bash

# install nvm: https://github.com/creationix/nvm
# note: use your regular user. NOT root user!


# you can launch this script at startup using:
#     sudo chmod +x startNode.sh
#     sudo nano /etc/rc.local
#         su ubuntu -c '/home/ubuntu/startNode.sh'
# note: put the command before "exit 0"


# start nvm on the user
export NVM_DIR="/home/$USER/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# start your node apps here. i use pm2, but you can use whatever
NODE_ENV=production PORT=3005 pm2 start /var/www/someApp/app.js --name someApp

#!/bin/sh

# you can install nvm using:
# note: check for the latest version at https://github.com/creationix/nvm)
# note2: use your regular user. NOT root user!
#     wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
#     source ~/.bashrc && nvm install stable && nvm alias default stable


# you can launch this script at startup by:
# note: replace $USER with the real user
# note2: put the command before "exit 0"
#     sudo nano /etc/rc.local
#         su $USER -c '/home/$USER/startNode.sh'



export NVM_DIR="/home/$USER/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # this starts nvm

# start your node apps here. i use pm2, but you can use whatever
NODE_ENV=production PORT=3005 pm2 start /var/www/someApp/app.js --name someApp

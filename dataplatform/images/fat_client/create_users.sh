#!/bin/bash

CONFIG_FILE="/etc/user-config/ssh-keys/users_keys.yml"

# Ensure yq (YAML parser) is installed
if ! command -v yq &> /dev/null; then
    echo "Installing yq..."
    sudo apt-get install -y yq
fi

if [ -f $CONFIG_FILE ]; then
    # Read users from YAML file and create them in the container
    for user in $(yq -r ".users[].name" $CONFIG_FILE); do
        ssh_keys=$(yq -r ".users[] | select(.name == \"$user\") | .ssh_keys[]" $CONFIG_FILE)
        echo "Creating user: $user"
        useradd -rm -d /home/$user -s /usr/bin/bash -G root,sudo $user
        passwd -d $user
        mkdir -p /home/$user/.ssh
        echo $ssh_keys > /home/$user/.ssh/authorized_keys
        chown -R $user:$user /home/$user/.ssh
        chmod 600 /home/$user/.ssh/authorized_keys

        echo "User added successfully!"
    done
    echo "Users setup completed!"
else
    echo "Error: User config file not found!"
fi

echo "Creating a default user dev"
useradd -rm -d /home/dev -s /usr/bin/bash -G root,sudo dev
echo 'dev:dev' | sudo chpasswd
mkdir -p /home/dev/.ssh
chown -R dev:dev /home/dev/.ssh
echo "Created user dev"

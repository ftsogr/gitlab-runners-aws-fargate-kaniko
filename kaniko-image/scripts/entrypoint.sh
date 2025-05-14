#!/bin/bash

# -----------------------------------------------------------------------------
# Update the /etc/hosts file by appending the IP address 10.0.3.5 and
# the domain gitlab.ftso.gr to it.
#
# Remove all comment lines and blank lines from the /etc/hosts file, displaying
# the cleaned-up file content to the user.
# -----------------------------------------------------------------------------

echo "10.0.3.5 gitlab.ftso.gr" | tee -a /etc/hosts
sed -e '/^#/d' -e '/^\s*$/d' /etc/hosts

# -----------------------------------------------------------------------------
# Create a folder to store user's SSH keys if it does not exist.
#
# Copy contents from the `SSH_PUBLIC_KEY` environment variable
# to the `$USER_SSH_KEYS_FOLDER/authorized_keys` file.
#
# Clear the `SSH_PUBLIC_KEY` environment variable.
#
# Start the SSH daemon.
# -----------------------------------------------------------------------------
USER_SSH_KEYS_FOLDER=~/.ssh
[ ! -d ${USER_SSH_KEYS_FOLDER} ] && mkdir -p ${USER_SSH_KEYS_FOLDER}

echo ${SSH_PUBLIC_KEY} > ${USER_SSH_KEYS_FOLDER}/authorized_keys
unset SSH_PUBLIC_KEY

/usr/sbin/sshd -D

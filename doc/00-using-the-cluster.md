# NRRP Cluster

The cluster is composed of 10 nodes which are managed using docker swarm.
A swarm is a group of machines where some of them are managers, the others are slaves.

New stacks (i.e., a `docker-compose.yaml`` file with the required containers) can only be deployed by:

1. accessing one of the managers through ssh
2. using Portainer 

![Adding a stack to portainer](https://github.com/big-unibo/dataplatform/assets/18005592/dc87127c-6561-4be7-a7db-aa9c8e41a891)

![Creating the new stack](https://github.com/big-unibo/dataplatform/assets/18005592/c089547d-b408-4d44-8986-b0cf80935eb2)

## NFS

All stable configurations are stored in an NFS folder accessible at `${NFSPATH}` (e.g., `/nfsshare`) on the `${NFSADDRESS}` machine.

## SSH

To access via ssh, you:

1. must add your public key in NFS to `${NFSPATH}/sshd/authorized_keys`
2. connect to the SSH server at `${MANAGER_IP}:${SSH_PORT}`

```bash
ssh dev@${MANAGER_IP}:${SSH_PORT} -i ~/.ssh/<YOUR-PRIVATE-KEY>
```
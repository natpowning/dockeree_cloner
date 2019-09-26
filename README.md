# dockeree_cloner
A quickly hacked together tool to replicate configs and secrets from one DockerEE swarm to another.

## Setup

### Source Client Bundles
The docker client where you execute do_clone.pl must be attached to the swarm where
configs and secrets will be pulled from.  If it's not a local swarm, or executed on
a node in the source swarm this can be done with a client bundle.

### Destination Client Bundles
In the root of a clone of this repo create a directory called clientbundles and
add to it the client bundle zip for each destination swarm you want to replicate to.

## Execution
Simply execute do_clone.pl and wait.  In the current state the script will run endlessly
until you break out.  It also leaves a stack/service behind that you should remove manually
with docker stack rm cloner


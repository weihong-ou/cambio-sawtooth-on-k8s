#/bin/bash

##### 1. Configure cluster #####
gcloud config set compute/zone us-central1-a
gcloud container clusters create cambio-sawtooth-cluster
     - Need to set static ips for the nodes OR use a service load balancer
     - Need to use size n1-standard-2

#### 2. Create namespace #####
#  Skipping for now, but should be required for a productionalized deployment

#### 3. Create secrets ####
# Haven't figured out how to gracefully update secrets yet

# Validator public and private keys
kubectl create secret generic cambio-validator-keys --from-file=00.priv=/home/theadora_ross/cambio-sawtooth-cluster/validator_keys/00.priv --from-file=00.pub=/home/theadora_ross/cambio-sawtooth-cluster/validator_keys/00.pub --from-file=01.priv=/home/theadora_ross/cambio-sawtooth-cluster/validator_keys/01.priv --from-file=01.pub=/home/theadora_ross/cambio-sawtooth-cluster/validator_keys/01.pub

# Validator configuration
kubectl create secret generic cambio-validator-00-cfg --from-file=validator.toml=/home/theadora_ross/cambio-sawtooth-cluster/validators/00/00.validator.toml
kubectl create secret generic cambio-validator-01-cfg --from-file=validator.toml=/home/theadora_ross/cambio-sawtooth-cluster/validators/01/01.validator.toml


#### 4. Create Validator Deployment ####

# Add tags to cluster node instances
gcloud compute instances add-tags gke-cambio-sawtooth-clus-default-pool-324a232a-5k29 --tags cambio-cluster
gcloud compute instances add-tags gke-cambio-sawtooth-clus-default-pool-324a232a-5rhp --tags cambio-cluster
gcloud compute instances add-tags gke-cambio-sawtooth-clus-default-pool-324a232a-tqsl --tags cambio-cluster

# Create firewall rules 
gcloud compute firewall-rules create cambio-val-00 --allow tcp:30001,tcp:30002 --target-tags cambio-cluster

# Apply yaml deployments

kubectl apply -f /home/theadora_ross/cambio-sawtooth-cluster/validators/00/00.yaml
kubectl apply -f /home/theadora_ross/cambio-sawtooth-cluster/validators/01/01.yaml

#### 5. Create Trasnaction Processor Deployments ####
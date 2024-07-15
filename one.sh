RESOURCE_GROUP_NAME=dev
RESOURCE_GROUP_LOCATION="westus"

VIRTUAL_NETWORK_NAME=vnet 
VIRTUAL_NETWORK_ADDRESS=10.0.0.0/16

VIRTUAL_NETWORK_SUBNET_NAME="web"
VIRTUAL_NETWORK_SUBNET_ADDRESS="10.0.0.0/24"

NSG_NAME="web-nsg"
PUBLIC_IP_NAME="webip"
PUBLIC_IP_SKU="Standard"
PUBLIC_IP_ALLOCATION="Static"

NIC_NAME="webnic"


VM_NAME="web1vm"
VM_USERNAME="vmadmin"
VM_PASSWORD="vmadmin@1234"
VM_IMAGE="Ubuntu2204"
VM_SIZE="Standard_B1s"



#create a resource group
az group create --location ${RESOURCE_GROUP_LOCATION} --name ${RESOURCE_GROUP_NAME}

#create a virtual network
az network vnet create --name ${VIRTUAL_NETWORK_NAME}\
                       --resource-group ${RESOURCE_GROUP_NAME}\
                       --location ${RESOURCE_GROUP_LOCATION}\
                       --address-prefixes ${VIRTUAL_NETWORK_ADDRESS}


# create a subnet
az network vnet subnet create --name ${VIRTUAL_NETWORK_SUBNET_NAME}\
                              --resource-group ${RESOURCE_GROUP_NAME}\
                              --vnet-name ${VIRTUAL_NETWORK_NAME}\
                              --address-prefixes ${VIRTUAL_NETWORK_SUBNET_ADDRESS}

# creata a network security group 
az network nsg create --name ${NSG_NAME}\
                      --resource-group ${RESOURCE_GROUP_NAME}\
                      --location ${RESOURCE_GROUP_LOCATION}

   
# create arule to open port 22 to everyone

az network nsg rule create  --name "openssh"\
                             --nsg-name ${NSG_NAME}\
                             --priority 1100\
                             --resource-group ${RESOURCE_GROUP_NAME}\
                             --protocol "TCP"\
                             --access "allow"\
                             --destination-address-prefixes "*"\
                             --destination-port-ranges "*"\
                             --source-address-prefixes "*"\
                             --source-port-ranges "*"\
                             --direction Inbound

# create  a rule to open port 80 http to everyone

az network nsg rule create  --name "openhttp"\
                             --nsg-name ${NSG_NAME}\
                             --priority 1000\
                             --resource-group ${RESOURCE_GROUP_NAME}\
                             --protocol "TCP"\
                             --access "allow"\
                             --destination-address-prefixes "*"\
                             --destination-port-ranges "*"\
                             --source-address-prefixes "*"\
                             --source-port-ranges "*"\
                             --direction Inbound
                             

# create a public ip 
az network public-ip create  --name ${PUBLIC_IP_NAME}\
                             --resource-group ${RESOURCE_GROUP_NAME}\
                            --location ${RESOURCE_GROUP_LOCATION}\
                            --sku ${PUBLIC_IP_SKU}\
                            --allocation-method ${PUBLIC_IP_ALLOCATION}
                            --version IPv4

# create a network interface
az network nic create  --name ${NIC_NAME}\
                       --resource-group ${RESOURCE_GROUP_NAME}\
                       --subnet ${VIRTUAL_NETWORK_SUBNET_NAME}\
                       --public-ip-address ${PUBLIC_IP_NAME}\
                       --network-security-group ${NSG_NAME}\
                       --vnet-name ${VIRTUAL_NETWORK_NAME}

#creating a virtual machine 

az vm create --name ${VM_NAME}\
             --resource-group ${RESOURCE_GROUP_NAME}\
              --location ${RESOURCE_GROUP_LOCATION}\
              --admin-username ${VM_USERNAME}\
              --admin-password ${VM_PASSWORD}\
              --nics ${NIC_NAME}\
              --size ${VM_SIZE}\
              --image ${VM_IMAGE} 


             
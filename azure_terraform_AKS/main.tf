
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-tokio-AKS"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-AKS"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

#  NUEVO EN AKS: Subnet delegada
resource "azurerm_subnet" "subnet_aks" {
  name                 = "subnet-aks"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "aks-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

#  NUEVO EN AKS: Cluster Kubernetes completo
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aksdemotf"

  #  NUEVO EN AKS: Node pool (no existe en ACI)
  default_node_pool {
    name       = "nodepool1"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.subnet_aks.id
  }

  #  NUEVO EN AKS: Managed Identity (ACI usa credenciales explícitas)
  identity {
    type = "SystemAssigned"
  }

  #  NUEVO EN AKS: Networking avanzado
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    environment = "demo"
  }
}

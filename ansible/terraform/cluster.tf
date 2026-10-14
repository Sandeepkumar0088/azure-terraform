# data "azurerm_user_assigned_identity" "aks" {
#   name                = "aks-identity-iot"
#   resource_group_name = data.azurerm_resource_group.existing.name
# }


# resource "azurerm_kubernetes_cluster" "aks" {
#   name                = "test-aks-iot"
#   location            = data.azurerm_resource_group.existing.location
#   resource_group_name = data.azurerm_resource_group.existing.name
#   dns_prefix          = "test-aks-iot"

#   default_node_pool {
#     name           = "system"
#     node_count     = 1
#     vm_size        = "Standard_B2s"
#     vnet_subnet_id = azurerm_subnet.aks.id
#   }

#     identity {
#     type         = "UserAssigned"
#     identity_ids = [data.azurerm_user_assigned_identity.aks.id]
#   }

#   network_profile {
#     network_plugin      = "azure"
#     network_plugin_mode = "overlay"
#     pod_cidr            = "192.168.0.0/16"
#     service_cidr        = "172.20.0.0/16"
#     dns_service_ip      = "172.20.0.10"
#     outbound_type       = "loadBalancer"
#   }

#   depends_on = [
#     azurerm_role_assignment.aks_network
#   ]
# }

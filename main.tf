terraform {
  required_version = ">= 1.0"
  required_providers {
    azapi = {
      source = "azure/azapi"
    }    
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
provider "azapi" {
}
provider "azurerm" {
  features {}
  subscription_id = "<YOUR_AZURE_SUBSCRIPTION_ID>"
}
variable "resource_group_name" {
  description = "Unyleya App RG"
  type        = string
  default     = "rg-unyleya-app-1"
}
variable "location" {
  description = "Região do Azure"
  type        = string
  default     = "Central US" 
}
variable "app_service_name" {
  description = "Unyleya App Service"
  type        = string
  default     = "unyleya-app"
}
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}
resource "azapi_resource" "service_plan" {
  type      = "Microsoft.Web/serverfarms@2022-09-01"
  name      = "asp-${var.app_service_name}"
  location  = var.location
  parent_id = azurerm_resource_group.main.id
  body = {
    kind = "app,container,windows" 
    sku = {
      name = "P1v3"
      tier = "PremiumV3"
      size = "P1v3"
      family = "Pv3"
      capacity = 1
    }
    properties = {
      hyperV   = true 
      reserved = false 
    }
  }
}

# 3. App Service via AzAPI (IDENTIDADE XENON/CONTAINER)
resource "azapi_resource" "windows_container_app" {
  type      = "Microsoft.Web/sites@2022-09-01"
  name      = var.app_service_name
  location  = var.location
  parent_id = azurerm_resource_group.main.id
  
  body = {
    kind = "app,container,windows"
    properties = {
      serverFarmId = azapi_resource.service_plan.id 
      hyperV       = true
      isXenon      = true
      siteConfig = {
        alwaysOn         = true
        windowsFxVersion = "DOCKER|feliperesendebr/unyleya_projeto_hub_docker:latest"
        appSettings = [
          { name = "WEBSITES_ENABLE_APP_SERVICE_STORAGE", value = "false" },
          { name = "WEBSITES_PORT", value = "80" },
          { name = "DOCKER_REGISTRY_SERVER_URL", value = "https://index.docker.io" },
          { name = "DOCKER_REGISTRY_SERVER_USERNAME", value = "" },
          { name = "DOCKER_REGISTRY_SERVER_PASSWORD", value = "" },
          { name = "WEBSITES_CONTAINER_START_TIME_LIMIT", value = "1800" }
        ]
      }
    }
  }
}
output "app_service_url" {
  value = "https://${var.app_service_name}.azurewebsites.net"
}
output "verify_command" {
  value = "az webapp show --name ${var.app_service_name} --resource-group ${var.resource_group_name} --query \"{kind:kind, webSpace:properties.webSpace}\" -o json"
}
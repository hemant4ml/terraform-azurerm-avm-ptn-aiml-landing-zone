terraform {
  required_version = ">= 1.9.0, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  # Backend configuration is expected to be passed via CLI or environment variables in CI/CD
  # e.g., terraform init -backend-config="resource_group_name=..." ...
  backend "azurerm" {}
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
}

variable "subscription_id" {
  type        = string
  description = "The Azure Subscription ID"
}

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

module "ai_landing_zone" {
  source = "../"

  location            = "swedencentral"
  resource_group_name = "rg-ai-foundry-minimal-${random_string.suffix.result}"

  vnet_definition = {
    address_space = ["10.0.0.0/16", "192.168.0.0/16"]
    subnets = {
      "PrivateEndpointSubnet" = {
        address_prefix = "10.0.0.0/24"
      }
      "AIFoundrySubnet" = {
        address_prefix = "192.168.0.0/24"
      }
    }
  }

  ai_foundry_definition = {
    ai_foundry = {
      name                    = "aifoundry-${random_string.suffix.result}"
      sku                     = "S0"
      create_ai_agent_service = false
    }
    ai_projects = {
      "default-project" = {
        name         = "proj-default-${random_string.suffix.result}"
        display_name = "Default Project"
        description  = "Minimal AI Foundry Project"
        storage_account_connection = {
          new_resource_map_key = "default"
        }
      }
    }
    storage_account_definition = {
      "default" = {
        name                       = "stfoundry${random_string.suffix.result}"
        enable_diagnostic_settings = false
        shared_access_key_enabled  = true
      }
    }
    key_vault_definition = {
      "default" = {
        name                       = "kv-foundry-${random_string.suffix.result}"
        sku                        = "standard"
        enable_diagnostic_settings = false
      }
    }
    law_definition = {
      "default" = {
        name = "law-foundry-${random_string.suffix.result}"
      }
    }
  }

  genai_container_registry_definition = {
    sku                           = "Standard"
    public_network_access_enabled = true
    zone_redundancy_enabled       = false
  }

  # Fix for Storage Account Key Access error
  genai_storage_account_definition = {
    shared_access_key_enabled = true
  }

  ks_ai_search_definition = {
    sku = "basic"
  }

  # Fix for Bing Grounding SKU error
  ks_bing_grounding_definition = {
    deploy = false
  }

  # Fix for Cosmos DB Capacity error (disable secondary region)
  genai_cosmosdb_definition = {
    secondary_regions = null
  }

  # Disable optional components for a minimal setup
  apim_definition = {
    deploy          = false
    publisher_email = "dummy@example.com"
    publisher_name  = "dummy"
  }
  app_gateway_definition = {
    deploy = false
    backend_address_pools = {
      dummy = {
        name = "dummy"
      }
    }
    backend_http_settings = {
      dummy = {
        name     = "dummy"
        port     = 80
        protocol = "Http"
      }
    }
    frontend_ports = {
      dummy = {
        name = "dummy"
        port = 80
      }
    }
    http_listeners = {
      dummy = {
        name               = "dummy"
        frontend_port_name = "dummy"
      }
    }
    request_routing_rules = {
      dummy = {
        name                       = "dummy"
        rule_type                  = "Basic"
        http_listener_name         = "dummy"
        backend_address_pool_name  = "dummy"
        backend_http_settings_name = "dummy"
        priority                   = 1
      }
    }
  }
  bastion_definition                   = { deploy = false }
  buildvm_definition                   = { deploy = false }
  container_app_environment_definition = { deploy = false }
  firewall_definition                  = { deploy = false }
  jumpvm_definition                    = { deploy = false }
  flag_platform_landing_zone           = true # Standalone deployment requires DNS zones to be created
}

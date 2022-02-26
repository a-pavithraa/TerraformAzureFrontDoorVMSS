
# Front Door resource
resource "azurerm_frontdoor" "Az-Demo1" {
  name                                         = "fe2606"
  resource_group_name                          = var.rg_name
  enforce_backend_pools_certificate_name_check = false

  backend_pool {
    name = "Az-Demo1-backend"
    backend {
      host_header = var.lb_publicip.ip_address #LB Public IP
      address     = var.lb_publicip.ip_address #LB Public IP
      http_port   = 80
      https_port  = 443
      priority    = 1
    }
    load_balancing_name = "Az-Demo1-LB"
    health_probe_name   = "Az-Demo1-HealthProbe"
  }

  backend_pool_load_balancing {
    name                            = "Az-Demo1-LB"
    sample_size                     = 4
    successful_samples_required     = 2
    additional_latency_milliseconds = 0
  }

  backend_pool_health_probe {
    name                = "Az-Demo1-HealthProbe"
    path                = "/"
    protocol            = "Http"
    interval_in_seconds = 120
  }

  frontend_endpoint {
    name      = "fe2606"
    host_name = "fe2606.azurefd.net"
    #"azpoc1.azurefd.net"  #We will check later
    session_affinity_enabled     = false #default: false
    session_affinity_ttl_seconds = 0     #default: 0
    #custom_https_provisioning_enabled = false
    #Links the WAF Policy to the Fronend Endpoints 
    #web_application_firewall_policy_link_name = "TerraformPolicy" #Optional Enter the name of the waf policy you'll be creating 
  }

  frontend_endpoint {
    name                         = "virtualcircle"
    host_name                    = "todo.pavithraavasudevan.com"
    session_affinity_enabled     = false #default: false
    session_affinity_ttl_seconds = 0     #default: 0
    #web_application_firewall_policy_link_id = azurerm_frontdoor_firewall_policy.az_demo1.id
  }

  routing_rule {
    name = "RoutingRule1"
    #frontend_endpoints = ["fepoint1"]
    frontend_endpoints = ["fe2606", "virtualcircle"]
    accepted_protocols = ["Http"] #Default: "Http" , "Https"
    patterns_to_match  = ["/*"]   #Default: "/*"
    enabled            = true     #Default: true

    forwarding_configuration {
      backend_pool_name                     = "Az-Demo1-backend"
      cache_enabled                         = false       #Default: false
      cache_use_dynamic_compression         = false       #Default: false
      cache_query_parameter_strip_directive = "StripNone" #Default: "StripNone"
      custom_forwarding_path                = ""
      forwarding_protocol                   = "MatchRequest" #Default: "BestMatch"  
    }
  }
}
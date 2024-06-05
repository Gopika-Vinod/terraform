resource "google_compute_security_policy" "viq_cloud_armor_policy" {
  name        = "${local.project_id}-policy"
  description = "Cloud Armor Policy for VIQ Application"
  project     = local.project_id
  type        = "CLOUD_ARMOR"

  advanced_options_config {
    json_parsing = "STANDARD"
    log_level    = "VERBOSE"
  }

  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable          = true
      rule_visibility = "STANDARD"
    }
  }

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule - Allow rule to accept all incoming traffic"
  }
  rule {
    action   = "allow"
    priority = "6000"
    match {
      expr {
        expression = "request.path.matches('/site-management/bulk-sites-upload')"
      }
    }
    description = "Allow Bulk sites upload"
  }
  rule {
    action   = "allow"
    priority = "6010"
    match {
      expr {
        expression = "request.headers['viq-nt-custom-exception']=='vX59+*sa6T9B'"
      }
    }
    description = "Allows to use/test APIs via postman"
  }

  rule {
    action   = "allow"
    priority = "6020"
    match {
      expr {
        expression = "request.headers['viq-nt-custom-exception']=='vX59+*sa6T9B'"
      }
    }
    description = "custom header exception"
  }

  rule {
    action   = "allow"
    priority = "6030"
    match {
      expr {
        expression = "request.path.matches('/site-management/bulk-sites-upload')"
      }
    }
    description = "allow bulk site upload"
  }

  rule {
    action   = "allow"
    priority = "6040"
    match {
      expr {
        expression = "request.path.matches('/device-images/ovs')"
      }
    }
    description = "allow device/company images upload"
  }

  rule {
    action   = "allow"
    priority = "6050"
    match {
      expr {
        expression = "request.path.matches('exportservice/operations/bq/export-excel')"
      }
    }
    description = "allow excel export from internal API calls"
  }


  rule {
    action   = "allow"
    priority = "6060"
    match {
      expr {
        expression = "request.path.matches('/exportservice/api/v1/pdf')"
      }
    }
    description = "Allow PDF export."
  }


  rule {
    action   = "allow"
    priority = "6070"
    match {
      expr {
        expression = "request.path.matches('/pdfservice')"
      }
    }
    description = "PDF service exception"
  }

  rule {
    action   = "allow"
    priority = "6080"
    match {
      expr {
        expression = "request.path.matches('/systemconfig-service/api/v1/site-management/subsite-upload')"
      }
    }
    description = "allow subsite upload"
  }

  rule {
    action   = "allow"
    priority = "6090"
    match {
      expr {
        expression = "request.path.matches('/systemconfig-service/api/v1/upload')"
      }
    }
    description = "allow subsite upload"
  }
  ##################################################################################
  rule {
    action   = "deny(403)"
    priority = "8000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('xss-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "preconfigured rule to mitigate cross-site scripting (XSS)attacks"
  }

  rule {
    action   = "deny(403)"
    priority = "8010"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('lfi-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "preconfigured rule to mitigate Local file inclusion attacks"
  }

  rule {
    action   = "deny(403)"
    priority = "8020"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('rce-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "preconfigured rule to mitigate Remote file inclusion attacks"
  }

  rule {
    action   = "deny(403)"
    priority = "8030"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('rfi-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "preconfigured rule to mitigate Remote code execution"
  }

  rule {
    action   = "deny(403)"
    priority = "8040"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('scannerdetection-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "preconfigured rule to mitigate Scanner detection"
  }

  rule {
    action   = "deny(403)"
    priority = "8050"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('protocolattack-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "preconfigured rule to mitigate Remote code execution"
  }

  rule {
    action   = "deny(403)"
    priority = "8060"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('sessionfixation-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "preconfigured rule to mitigate Session fixation attack"
  }

  rule {
    action   = "deny(403)"
    priority = "8070"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('java-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "preconfigured rule to mitigate Java attack"
  }

  rule {
    action   = "deny(403)"
    priority = "8080"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('nodejs-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "preconfigured rule to mitigate Nodejs attack"
  }

  rule {
    action   = "deny(403)"
    priority = "8090"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('cve-canary', {'sensitivity': 1})"
      }
    }
    description = "Block CVE Log4j RCE vulnerability"
  }
rule {
    action   = "allow"
    priority = "6100"
    match {
      expr {
        expression = "request.headers['host'].lower().contains('viq.zebra.com') && request.path.matches('/upload')"
      }
    }
    description = "allow strapi upload"
  }


  # rule {
  #   action   = "deny(403)"
  #   priority = "8100"
  #   match {
  #     expr {
  #       expression = "has(request.headers['host']) && !request.headers['host'].matches(\".*\\.zebra.com.*\")"
  #     }
  #   }
  #   description = "deny host"
  # }

  # rule {
  #   action   = "deny(403)"
  #   priority = "8110"
  #   match {
  #     expr {
  #       expression = "has(request.headers[':authority']) && !request.headers[':authority'].matches(\".*\\.zebra.com.*\")"
  #     }
  #   }
  #   description = "deny authority"
  # }

  # rule {
  #   action   = "deny(403)"
  #   priority = "8120"
  #   match {
  #     expr {
  #       expression = "has(request.headers['origin']) && !request.headers['origin'].matches(\".*\\.zebra.com.*\")"
  #     }
  #   }
  #   description = "deny origin"
  # }

  # rule {
  #   action   = "deny(403)"
  #   priority = "8130"
  #   match {
  #     expr {
  #       expression = "has(request.headers['referer']) && !request.headers['referer'].matches(\".*\\.zebra.com.*\")"
  #     }
  #   }
  #   description = "deny referer"
  # }


  # rule {
  #   action   = "deny(403)"
  #   priority = "8140"
  #   match {
  #     expr {
  #       expression = "evaluatePreconfiguredWaf('protocolattack-v33-stable', {'sensitivity': 1})"
  #     }
  #   }
  #   description = "Rule to deny protocol attack"
  # }

  # rule {
  #   action   = "deny(403)"
  #   priority = "8150"
  #   match {
  #     expr {
  #       expression = "evaluatePreconfiguredWaf('rfi-v33-stable', {'sensitivity': 1})"
  #     }
  #   }
  #   description = "remote file inclusion attack"
  # }

  # rule {
  #   action   = "deny(403)"
  #   priority = "8160"
  #   match {
  #     expr {
  #       expression = "evaluatePreconfiguredWaf('rce-v33-stable', {'sensitivity': 1})"
  #     }
  #   }
  #   description = "Remote code execution"
  # }


  # rule {
  #   action   = "deny(403)"
  #   priority = "8170"
  #   match {
  #     expr {
  #       expression = "evaluatePreconfiguredWaf('xss-v33-stable', {'sensitivity': 1})"
  #     }
  #   }
  #   description = "Deny XSS"
  # }

  # rule {
  #   action   = "deny(403)"
  #   priority = "10050"
  #   match {
  #     expr {
  #       expression = "evaluatePreconfiguredWaf('methodenforcement-v33-stable', {'sensitivity': 1})"
  #     }
  #   }
  #   description = "preconfigured rule to mitigate Method enforcement"
  # }

  # rule {
  #   action   = "deny(403)"
  #   priority = "10000"
  #   match {
  #     expr {
  #       expression = "evaluatePreconfiguredWaf('sqli-v33-stable', {'sensitivity': 1})"
  #     }
  #   }
  #   description = "preconfigured rule to mitigate SQL Injection attacks"
  # }

  #Cloud Armor Managed Protection Plus tier is required to use Threat Intelligence expressions
  # rule {
  #   action   = "deny(403)"
  #   priority = "10130"
  #   match {
  #     expr {
  #       expression = "evaluateThreatIntelligence('iplist-known-malicious-ips')"
  #     }
  #   }
  #   description = "Matches IP addresses known to attack web applications"
  # }


}


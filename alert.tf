# ####################################################################
# ##################### BigQuery Alerts ##############################
# ####################################################################


resource "google_monitoring_alert_policy" "bigquery_data_scan_alert" {
  display_name = "BigQuery Data Scan Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "High Data Scan Cost"
    condition_threshold {
      # Retest Window
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "10995116277760" # value specifed is in bytes equivalent to 10 TB
      filter          = "resource.type=\"global\" AND resource.labels.project_id = \"${local.project_id}\" AND metric.type = \"bigquery.googleapis.com/query/scanned_bytes_billed\""
      aggregations {
        # rolling window
        alignment_period = "300s"
        # rolling window function     
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
  alert_strategy {
    auto_close = "604800s"
  }
  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to monitor the amount of data scanned by queries executed on Google BigQuery and to be notified if the amount of data scanned exceeds a specified threshold. This helps prevent unexpected data scanning costs and ensures that BigQuery usage is under control.

### Next Steps:
- **Identify**:
			- Investigate the queries that have been executed recently to see which ones are contributing to the high data scanning cost.
			- Run query against info schema to find out the principal who ran the query and actual query details, (bytes billed, slot used, duration)
- **Optimize queries**: 
			- Identify and address any inefficiencies in the queries that are causing the high data scanning cost.
			- Check if the query can be optimized using partitioning or clustering or reformulate the query to use more efficient techniques.
- **Limit data scanning**:
			- Consider limiting the amount of data that is scanned by queries, by applying filters to reduce the amount of data that is processed.
- **Monitor usage**: 
			- Monitor your BigQuery usage regularly to ensure that the cost of data scanning remains within your budget.
		EOT
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
    google_monitoring_notification_channel.GMSS_DEVOPS.name,
  ]
}

resource "google_monitoring_alert_policy" "bigquery_dataset_data_size_alert" {
  display_name = "BigQuery Dataset Data Size Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Total Data Size Expectancy for BigQuery Dataset Exceeded"
    condition_threshold {
      duration        = "0s" # Retest Window / Duration
      comparison      = "COMPARISON_GT"
      threshold_value = "21990232555520" # value specifed is in bytes equivalent to 20 TB
      filter          = "resource.type = \"bigquery_dataset\" AND resource.labels.project_id = \"${local.project_id}\" AND metric.type = \"bigquery.googleapis.com/storage/stored_bytes\""
      aggregations {
        alignment_period     = "1800s"      #(30 min = sampling period)       # rolling window
        per_series_aligner   = "ALIGN_MAX"  # rolling window per series aligner
        cross_series_reducer = "REDUCE_SUM" # Cross Series Reducer
        group_by_fields = [
          "resource.labels.dataset_id"
        ]
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to monitor the Bytes stored in the dataset and to be notified if the amount of data stored in BigQuery exceeds a specified threshold. exceeds a specified threshold. This helps prevent unexpected data scanning costs and avoid unexpected costs associated with storing large amounts of data

### Next Steps:
-  Please check if this is expected.
- If yes, increase the threshold limit. 
- Perform clean-up activity if any to free up the disk size.
		EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
    google_monitoring_notification_channel.GMSS_DEVOPS.name,
  ]
}


resource "google_monitoring_alert_policy" "bigquery_query_execution_time_alert" {
  display_name = "BigQuery Query Execution Time Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Long Running Queries"
    condition_threshold {
      # Retest Window 
      duration        = "180s" #  3 mins
      comparison      = "COMPARISON_GT"
      threshold_value = "1800" # 30 mins
      filter          = "resource.type = \"bigquery_project\" AND resource.labels.project_id = \"${local.project_id}\" AND metric.type = \"bigquery.googleapis.com/query/execution_times\""
      aggregations {
        # rolling window
        alignment_period = "300s" # 5 mins
        # rolling window function          
        per_series_aligner   = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
  alert_strategy {
    auto_close = "604800s"
  }
  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to monitor the execution time for queries executed on Google BigQuery and to be notified if 90% of the submitted queries exceeds a specified threshold. This helps identify Long running queries.

### Next Steps:
- **Identify**:
			- Investigate the queries that have been executed recently to see which ones are contributing to the high data scanning cost.
			- Run query against info schema to find out the principal who ran the query and actual query details, (bytes billed, slot used, duration)
- **Optimize queries**: 
			- Identify and address any inefficiencies in the queries that are causing the high data scanning cost.
			- Check if the query can be optimized using partitioning or clustering or reformulate the query to use more efficient techniques.
- **Limit data scanning**:
			- Consider limiting the amount of data that is scanned by queries, by applying filters to reduce the amount of data that is processed.
		EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
    google_monitoring_notification_channel.GMSS_DEVOPS.name,
  ]
}


# resource "google_monitoring_alert_policy" "bigquery_slot_usage_alert" {
# 	display_name = "BigQuery Slot Usage Alert"
# 	combiner     = "OR"
# 	project      = var.ops_project_id
# 	conditions {
# 		display_name = "BigQuery Slot usage over 500 for 10 mins"
# 		condition_threshold {
# 			# Retest Window 
# 			duration        = "0s" 
# 			comparison      = "COMPARISON_GT"
# 			threshold_value = "500"
# 			filter          = "resource.type = \"bigquery_project\" AND resource.labels.project_id = \"${local.project_id}\" AND metric.type = \"bigquery.googleapis.com/slots/allocated\""
# 			aggregations {
# 				# rolling window
# 				alignment_period     = "600s" # 10 mins    
# 				# rolling window function    
# 				per_series_aligner   = "ALIGN_MEAN"  
# 				cross_series_reducer = "REDUCE_MEAN" 
# 				group_by_fields      = [
# 					"resource.label.project_id"
# 				]
# 			}
# 		}
# 	}
# 	conditions {
# 		display_name = "BigQuery Project Slot usage over 90% of the Slots allocated for 10 mins"
# 		condition_threshold {
# 			# Retest Window
# 			duration        = "0s" 
# 			comparison      = "COMPARISON_GT"
# 			threshold_value = "1800" # 90 % of slots allocated, slots allocated taken 2000
# 			filter          = "resource.type = \"bigquery_project\" AND resource.labels.project_id = \"${local.project_id}\" AND metric.type = \"bigquery.googleapis.com/slots/allocated\""
# 			aggregations {
# 				# rolling window
# 				alignment_period     = "600s" #10 mins     
# 				# rolling window function               
# 				per_series_aligner   = "ALIGN_MEAN" 
# 				cross_series_reducer = "REDUCE_SUM"          
# 				group_by_fields      = [
# 					"resource.label.project_id"
# 				]
# 			}
# 		}
# 	}
# 	alert_strategy {
# 		auto_close = "604800s"
# 	}
# 	documentation {
# 		mime_type = "text/markdown"
# 		content   = <<-EOT
# #### You are receiving this mail as part of alerting policies your project monitoring team set.

# ## Purpose:
# This alert aims to monitor the Slot utilization and notify if it exceeds the given threshold.

# ### Next Steps:
# - **Identify**:
# 			- Investigate the queries that have been executed recently to see which ones are consuming more Slots
# 			- Run query against info schema to find out the principal who ran the query and actual query details, (bytes billed, slot used, duration)
# - **Optimize queries**: 
# 			- Check if the query can be optimized using partitioning or clustering or reformulate the query to use more efficient techniques.
# - **Purchase or assign more Slots**
# 		EOT
# 	}

# 	notification_channels = [
# 		google_monitoring_notification_channel.datametica_admin.name,
# 	]
# }

# #####################################################################
# ###################### Composer Alerts ##############################
# #####################################################################

resource "google_monitoring_alert_policy" "composer_environment_health_alert" {
  display_name = "Composer Environment Health Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Composer Environment Unhealthy"
    condition_threshold {
      # Retest Window
      duration        = "0s"
      comparison      = "COMPARISON_LT"
      threshold_value = "1"
      filter          = "resource.type = \"cloud_composer_environment\" AND metric.type = \"composer.googleapis.com/environment/healthy\""
      aggregations {
        # rolling window
        alignment_period     = "300s" # 5mins     
        per_series_aligner   = "ALIGN_COUNT_TRUE"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to alert you to a potential issue with the Composerenvironment. 

### Next Steps:
- Check other health alerts
    EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


# #####################################################################
# ####################### Composer Scheduler ##########################
# #####################################################################

resource "google_monitoring_alert_policy" "composer_scheduler_heartbeat_missed_alert" {
  display_name = "Composer Scheduler Heartbeat Missed Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Composer Scheduler Heartbeat Missed"
    condition_threshold {
      # Retest Window
      duration        = "0s"
      comparison      = "COMPARISON_LT"
      threshold_value = "1"
      filter          = "resource.type = \"cloud_composer_environment\" AND metric.type = \"composer.googleapis.com/environment/scheduler_heartbeat_count\""
      aggregations {
        # rolling window
        alignment_period = "60s"
        # rolling window function       
        per_series_aligner   = "ALIGN_COUNT"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to alert you to a potential issue with the scheduler in your environment. 

### Next Steps:
- **Check Resource Usage**: Check for CPU and Memory Usage of the Scheduler.
- **Check the logs**: Review logs to see if they provide any additional information on the cause of the problem.
- **Engage support**: If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.
    EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


resource "google_monitoring_alert_policy" "composer_scheduler_high_cpu_usage_alert" {
  display_name = "Composer Scheduler High CPU Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Composer Scheduler high CPU usage"
    condition_threshold {
      # Retest Window
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.9"
      filter          = "resource.type = \"k8s_container\" AND metric.type = \"kubernetes.io/container/cpu/limit_utilization\" AND (metadata.system_labels.top_level_controller_name = \"airflow-scheduler\" AND metadata.system_labels.top_level_controller_type = \"Deployment\" AND metadata.system_labels.name = \"airflow-scheduler\")"
      aggregations {
        # rolling window
        alignment_period = "300s" #5min 
        # rolling window function
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to alert you to a potential issue with the scheduler in your environment. 

### Next Steps:
- Increase Scheduler CPU or
- Increase file parsing interval, dag dir list interval, pool_metrics_interval.
- Decrease parsing_processes
- Increase number of schedulers 
- If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.
    EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_alert_policy" "composer_scheduler_high_memory_usage_alert" {
  display_name = "Composer Scheduler High Memory usage Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Composer Scheduler high Memory usage"
    condition_threshold {
      # Retest Window
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.9"
      filter          = "resource.type = \"k8s_container\" AND metric.type = \"kubernetes.io/container/memory/limit_utilization\" AND metadata.system_labels.top_level_controller_type = \"Deployment\" AND metadata.system_labels.top_level_controller_name = \"airflow-scheduler\" AND metadata.system_labels.name = \"airflow-scheduler\""
      aggregations {
        # rolling window
        alignment_period = "300s" # 5 mins      
        # rolling window function
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to alert you to a potential issue with the scheduler in your environment. 

### Next Steps:
- Increase Scheduler Memory
- If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.
    EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

# ####################################################################
# ###################### Composer Worker #############################
# ####################################################################

resource "google_monitoring_alert_policy" "composer_worker_high_cpu_usage_alert" {
  display_name = "Composer Worker High CPU Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Composer Worker high CPU usage"
    condition_threshold {
      # Retest Window
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.9"
      filter          = "resource.type = \"k8s_container\" AND resource.labels.container_name = \"airflow-worker\" AND metric.type = \"kubernetes.io/container/cpu/limit_utilization\""
      aggregations {
        # rolling window
        alignment_period = "600s" # 5 mins      
        # rolling window function
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to alert you to a potential issue with the airflow worker in your environment. 

### Next Steps:
- Reduce worker_concurrency, hence recalculate parallelism. 
- Check with dev team if any tasks are doing heavy data processing.
- If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.
    EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_alert_policy" "composer_worker_high_memory_usage_alert" {
  display_name = "Composer Worker High Memory usage Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Composer Worker high Memory usage"
    condition_threshold {
      # Retest Window
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.9"
      filter          = "resource.type = \"k8s_container\" AND resource.labels.container_name = \"airflow-worker\" AND metric.type = \"kubernetes.io/container/memory/limit_utilization\""
      aggregations {
        # rolling window
        alignment_period = "600s" # 5 mins     
        # rolling window function
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to alert you to a potential issue with the airflow worker in your environment. 

### Next Steps:
- If the workers memory usage approaches the limit, this can cause worker pod evictions. To address this problem, increase worker memory.
- Check with dev team if any tasks are doing heavy in-memory data processing"
- If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.
    EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


resource "google_monitoring_alert_policy" "composer_active_workers_alert" {
  display_name = "Composer Active Airflow Workers"
  combiner     = "OR"
  project      = var.ops_project_id

  conditions {
    display_name = "High Number Of Active Airflow Workers for long time"

    condition_threshold {
      # Retest Window 
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "6"
      filter          = "resource.type = \"cloud_composer_environment\" AND metric.type = \"composer.googleapis.com/environment/num_celery_workers\""

      aggregations {
        # rolling window
        alignment_period = "1800s" # 30 min
        # rolling window function       
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to alert you to a potential issue with the airflow worker in your environment. 

### Next Steps:
- Check if queued tasks alerts has been triggered, if yes, then 
			- Increase worker_concurrency and parallelism (if CPU usage is low)
			- Increase CPU and worker_concurrency and parallelism if CPU usage is high.
			- Increase number of workers (revisit CIDR range)"
- If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.
    EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_alert_policy" "composer_worker_pod_eviction_alert" {
  display_name = "Composer Worker Pod Eviction Alert"
  combiner     = "OR"
  project      = var.ops_project_id

  conditions {
    display_name = "Composer Worker Pod Eviction"

    condition_threshold {
      # Retest Window
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "resource.type = \"cloud_composer_environment\" AND metric.type = \"composer.googleapis.com/environment/worker/pod_eviction_count\""

      aggregations {
        # rolling window
        alignment_period     = "300s" # 5 mins     
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }
  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
The purpose of this alert is to monitor the health of the environment and ensure that there are no issues with pod evictions, which can indicate issues with resource constraints or other problems.

### Next Steps:
- Check if memory usage alert has triggered, if yes, take action as per that alert.
- If not, check GKE workloads for evicted pod and examine its logs.
Example filter: 
  resource.type=""k8s_container""
  resource.labels.project_id=""composer_project""
  resource.labels.location=""us-central1-c""
  resource.labels.cluster_name=""us-central1-composer-project-d5b3de0f-gke""
  resource.labels.namespace_name=""composer-1-18-5-airflow-2-2-3-d5b3de0f""
  resource.labels.pod_name=""airflow-worker-5644f849c9-hc2ps"" severity>=DEFAULT"
- If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.
    EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


resource "google_monitoring_alert_policy" "composer_high_dag_parsing_time_alert" {
  display_name = "Composer High DAG Parsing Time Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "High Total Parse Time"
    condition_threshold {
      duration        = "0s" # Retest Window / Duration
      comparison      = "COMPARISON_GT"
      threshold_value = "70" # to be check
      filter          = "resource.type = \"cloud_composer_environment\" AND metric.type = \"composer.googleapis.com/environment/dag_processing/total_parse_time\""
      aggregations {
        # rolling window
        alignment_period     = "1800s" # 30mins   
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
To monitor the total time spent parsing DAGs in the environment and trigger an alert if it exceeds a certain threshold. This can help detect any performance issues with the environment or any issues with the DAGs being processed.

### Next Steps:
- Increase the DAG file parsing interval and increase the DAG directory listing interval.
- Increase the number of schedulers if Scheduler CPU is high.
- Increase the CPU of schedulers if Scheduler CPU is high.
- Simplify your DAGs, including their Python dependencies. Discuss with Dev Team.
- If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.
    EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}



resource "google_monitoring_alert_policy" "composer_running_task_alert" {
  display_name = "Composer Running Task Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "High Unfinished/Running Task Instances"
    condition_threshold {
      # Retest Window
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "70"
      filter          = "resource.type = \"cloud_composer_environment\" AND metric.type = \"composer.googleapis.com/environment/unfinished_task_instances\" AND metric.labels.state = \"running\""
      aggregations {
        # rolling window
        alignment_period     = "900s" # 15 mins    
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
The purpose of this alert is to notify when the number of unfinished task instances for past 15mins exceeds a certain threshold. 
### Next Steps:
Check if queued tasks alerts has been triggered, if yes, then 
- Increase worker_concurrency and parallelism (if CPU usage is low)
- Increase CPU and worker_concurrency and parallelism if CPU usage is high.
- Increase number of workers (revisit CIDR range)
- If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.
    EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}



resource "google_monitoring_alert_policy" "composer_queued_task_alert" {
  display_name = "Composer Queued Task Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "High Queued Task Instances"
    condition_threshold {
      # Retest Window 
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "40" # check
      filter          = "resource.type = \"cloud_composer_environment\" AND metric.type = \"composer.googleapis.com/environment/executor/queued_tasks\""
      aggregations {
        # rolling window
        alignment_period     = "1800s" # 30 mins      
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
The purpose of this alert is to notify when the number of queued task instances for past 30mins exceeds a certain threshold. 
### Next Steps:
Check if queued tasks alerts has been triggered, if yes, then 
- Increase worker_concurrency and parallelism (if CPU usage is low)
- Increase CPU and worker_concurrency and parallelism if CPU usage is high.
- Increase number of workers (revisit CIDR range)
- If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.
    EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}
# #####################################################################
# ####################### Composer Database ###########################
# #####################################################################
resource "google_monitoring_alert_policy" "composer_database_high_cpu_usage_alert" {
  display_name = "Composer Database High CPU Usage "
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "High CPU Usage"
    condition_threshold {
      # Retest Window
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.9"
      filter          = "resource.type = \"cloud_composer_environment\" AND metric.type = \"composer.googleapis.com/environment/database/cpu/utilization\""
      aggregations {
        # rolling window
        alignment_period     = "300s" # 5mins      
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to alert you to a potential issue with the airflow database in your environment. 

### Next Steps:
- Scale up Database size. Change Environment size.
- If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.

    EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


resource "google_monitoring_alert_policy" "composer_database_high_memory_usage_alert" {
  display_name = "Composer Database High Memory Usage "
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "High Memory Usage"
    condition_threshold {
      # Retest Window
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.9"
      filter          = "resource.type = \"cloud_composer_environment\" AND metric.type = \"composer.googleapis.com/environment/database/memory/utilization\""
      aggregations {
        # rolling window
        alignment_period     = "300s" # 5mins      
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to alert you to a potential issue with the airflow database in your environment. 

### Next Steps:
- Scale up Database size. Change Environment size.
- If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.
    EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}



resource "google_monitoring_alert_policy" "composer_database_concurrent_connections_alert" {
  display_name = "Composer Database Concurrent Connections Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "High Number of Concurrent Connections to the Database"
    condition_threshold {
      # Retest Window
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1350" # 90 % max limit(1500)
      filter          = "resource.type = \"cloud_composer_environment\" AND metric.type = \"composer.googleapis.com/environment/database/network/connections\""
      aggregations {
        # rolling window
        alignment_period     = "300s" # 5mins      
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to alert you to a potential issue with the airflow database in your environment. 

### Next Steps:
- Scale up Database size. Change Environment size.
- If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.
    EOT
  }

  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


# #####################################################################
# ####################### GCS #########################################
# #####################################################################

# Log based metric
resource "google_logging_metric" "gcs_bucket_iam_modfied" {
  name        = "gcs-bucket-iam-modfied"
  filter      = "resource.type = \"gcs_bucket\" AND protoPayload.methodName = \"storage.setIamPermissions\""
  project     = local.project_id
  description = "Monitor Cloud Storage Bucket IAM permission changes."

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    labels {
      key         = "PROJECT_ID"
      value_type  = "INT64"
      description = "Project id on which action is performed"
    }

    labels {
      key         = "BUCKET"
      value_type  = "STRING"
      description = "Bucket on which action is performed"
    }

    labels {
      key         = "ACTION_PERFORMED"
      value_type  = "STRING"
      description = "What kind of action is performed"
    }

    labels {
      key         = "PRINCIPAL_EMAIL"
      value_type  = "STRING"
      description = "Who has Performed the action"
    }
  }
  label_extractors = {
    "PROJECT_ID"       = "EXTRACT(protoPayload.resource.project_id)"
    "BUCKET"           = "EXTRACT(protoPayload.ResourceName)"
    "ACTION_PERFORMED" = "EXTRACT(protoPayload.MethodName)"
    "PRINCIPAL_EMAIL"  = "EXTRACT(protoPayload.authenticationInfo.principalEmail)"
  }
}

# Alert
resource "google_monitoring_alert_policy" "gcs_bucket_iam_modfied_alert" {
  display_name = "GCS Bucket IAM Modified Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "GCS Bucket IAM Modified Alert"
    condition_threshold {
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.5"
      filter          = "metric.type=\"logging.googleapis.com/user/gcs-bucket-iam-modfied\" AND resource.type=\"gcs_bucket\""
      aggregations {
        alignment_period     = "300s" # 5 mins
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.
    EOT
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_alert_policy" "gcs_bucket_total_storage_bytes_alert" {
  display_name = "GCS Bucket Total Storage Bytes Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "gcs storage total bytes"
    condition_threshold {
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "21990232555520" # 20 TB
      filter          = "metric.type = \"storage.googleapis.com/storage/total_bytes\" AND resource.type=\"gcs_bucket\""
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to notify you when the storage size execeeds the mentioned treshold.

### Next Steps:
- Perform cleanup activity to delete unwanted files.
    EOT
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

# #####################################################################
# ####################### CloudSQL ####################################
# #####################################################################


resource "google_monitoring_alert_policy" "cloudsql_instance_health_check_alert" {
  display_name = "CloudSQL Instance Health Check Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "CloudSQL Instance Unhealty"
    condition_threshold {
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "metric.type = \"cloudsql.googleapis.com/database/up\" AND resource.type=\"cloudsql_database\""
      aggregations {
        alignment_period     = "300s" #5mins
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to alert you to a potential issue with the CloudSQL instance in your environment. 

### Next Steps:
- **Check Resource Usage**: Check for CPU and Memory Usage of the Scheduler.
- **Check the logs**: Review logs to see if they provide any additional information on the cause of the problem.
- **Engage support**: If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.
    EOT
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


resource "google_monitoring_alert_policy" "cloudsql_instance_cpu_usage_alert" {
  display_name = "Cloud SQL Instance CPU Usage Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "CPU Utlization exceeded"
    condition_threshold {
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.8"
      filter          = "metric.type = \"cloudsql.googleapis.com/database/cpu/utilization\" AND resource.type=\"cloudsql_database\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to alert you to a potential issue with the CloudSQL instance in your environment. 

### Next Steps:
- Increase the number of CPUs for your instance by changing the Tier.
- Note that changing tier requires an instance restart.
- If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.
    EOT
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


resource "google_monitoring_alert_policy" "cloudsql_instance_memory_usage_alert" {
  display_name = "Cloud SQL Instance Memory Usage Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Memory Utlization exceeded"
    condition_threshold {
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.8"
      filter          = "metric.type = \"cloudsql.googleapis.com/database/memory/utilization\" AND resource.type=\"cloudsql_database\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to alert you to a potential issue with the CloudSQL instance in your environment. 

### Next Steps:
- Increase the number of memory for your instance by changing the Tier.
- If the issue persists and cannot be resolved through basic troubleshooting, engage Google support.
    EOT
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


resource "google_monitoring_alert_policy" "cloudsql_instance_disk_usage_alert" {
  display_name = "Cloud SQL Instance Disk Usage Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Disk Utlization exceeded"
    condition_threshold {
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.8"
      filter          = "metric.type = \"cloudsql.googleapis.com/database/disk/utilization\" AND resource.type=\"cloudsql_database\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to alert you to a potential issue with the CloudSQL instance in your environment. 

### Next Steps:
- No action required if autoresize is enabled for disk
    EOT
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


resource "google_monitoring_alert_policy" "cloudsql_instance_max_connection_alert" {
  display_name = "Cloud SQL Instance Max Connection Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Max Connection limit exceeded"
    condition_threshold {
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "200" # TBD
      filter          = "metric.type = \"cloudsql.googleapis.com/database/postgresql/num_backends\" AND resource.type=\"cloudsql_database\""
      aggregations {
        alignment_period     = "600s" # 30 mins
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields = [
          "resource.labels.database_id"
        ]
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Purpose:
This alert aims to alert you to a potential issue with the CloudSQL instance in your environment. 

### Next Steps:
- Investigate the cause of the increased number of active connections.
- If you find that the connections are legitimate, you may need to increase the capacity of your Cloud SQL instance to handle the increased load. You can consider upgrading to a larger instance or increasing the number of CPU cores or memory.
These are the default value for max_connections
The default value depends on the instance memory.
Instance memory (GB)        Default value
tiny (~0.5)                        25
small (~1.7)                       50
3.75 - 6                           100
6 - 7.5                            200
7.5 - 15                           400
15 - 30                            500
30 - 60                            600
64 - 120                           800
>=120                              1,000
- You can also optimize your database queries and reduce the number of connections needed to handle the load. For example, you can consider connection pooling or optimizing your queries to reduce the amount of time each connection needs to be open.
- Check other Cloud SQL alerts
    EOT
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


resource "google_logging_metric" "cloudsql_instance_modified_metric" {
  name        = "cloudsql-instance-modified"
  filter      = "protoPayload.methodName=\"cloudsql.instances.update\" OR protoPayload.methodName=\"cloudsql.instances.create\" OR protoPayload.methodName=\"cloudsql.instances.delete\""
  project     = local.project_id
  description = "Monitor Cloud SQL instance configuration modifications"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    labels {
      key         = "PROJECT_ID"
      value_type  = "INT64"
      description = "Project id on which action is performed"
    }

    labels {
      key         = "SQL_INSTANCE"
      value_type  = "STRING"
      description = "NETWORK on which action is performed"
    }

    labels {
      key         = "ACTION_PERFORMED"
      value_type  = "STRING"
      description = "What kind of action is performed"
    }

    labels {
      key         = "PRINCIPAL_EMAIL"
      value_type  = "STRING"
      description = "Who has Performed the action"
    }
  }

  label_extractors = {
    "PROJECT_ID"       = "EXTRACT(protoPayload.resource.project_id)"
    "SQL_INSTANCE"     = "EXTRACT(protoPayload.ResourceName)"
    "ACTION_PERFORMED" = "EXTRACT(protoPayload.MethodName)"
    "PRINCIPAL_EMAIL"  = "EXTRACT(protoPayload.authenticationInfo.principalEmail)"
  }
}

resource "google_monitoring_alert_policy" "cloudsql_instance_modified_alert" {
  display_name = "Cloud SQL Instance Modified Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Cloud SQL Instance Modified"
    condition_threshold {
      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "metric.type = \"logging.googleapis.com/user/cloudsql-instance-modified\"  AND resource.type=\"global\""
      aggregations {
        alignment_period     = "300s" # 5 mins
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  alert_strategy {
    auto_close = "604800s"
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
    ## You are receiving this mail as part of alerting policies set by your project monitoring team.
    EOT
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


# ###########################################################################
# ############################ Cloud NAT ####################################
# ###########################################################################

# resource "google_monitoring_alert_policy" "cloud_nat_ip_allocation_alert" {
#   display_name = "Cloud Nat IP allocation alert"
#   combiner     = "OR"
#   project      = local.project_id
#   conditions {
#     display_name =  "Cloud NAT Gateway - NAT allocation failed"
#     condition_threshold {
#       duration        = "0s"
#       comparison      = "COMPARISON_GT"
#       threshold_value = "10"
#       filter          = "resource.type = \"nat_gateway\" AND metric.type = \"router.googleapis.com/nat/nat_allocation_failed\""
#       aggregations {
#         alignment_period     = "300s" # 5mins
#         per_series_aligner   = "ALIGN_COUNT_TRUE"
#         cross_series_reducer = "REDUCE_NONE"
#       }
#     }
#   }

#   alert_strategy {
#     auto_close = "604800s"
#   }

#   documentation {
#     mime_type = "text/markdown"
#     content   = <<-EOT
# #### You are receiving this mail as part of alerting policies your project monitoring team set.

# ## Purpose:
# This alert aims to alert you to a potential issue with the CLoud NAT IP allocation. 

# ### Next Steps:   
# - Add New external IP for NAT
#     EOT
#   }
#   notification_channels = [
#     google_monitoring_notification_channel.datametica_admin.name,
#   ]
# }
resource "google_logging_metric" "audit_log_modified" {
  name        = "audit-log-modified"
  filter      = "protoPayload.methodName=\"SetIamPolicy\" AND protoPayload.serviceData.policyDelta.auditConfigDeltas:*"
  project     = local.project_id
  description = "Monitor Audit configuration changes"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    labels {
      key         = "PROJECT_ID"
      value_type  = "INT64"
      description = "Project id on which action is performed"
    }
    labels {
      key         = "PRINCIPAL_EMAIL"
      value_type  = "STRING"
      description = "Who has Performed the action"
    }
  }
  label_extractors = {
    "PROJECT_ID"      = "EXTRACT(protoPayload.resource.project_id)"
    "PRINCIPAL_EMAIL" = "EXTRACT(protoPayload.authenticationInfo.principalEmail)"
  }
}



resource "google_monitoring_alert_policy" "audit_log_modified_alert" {
  display_name = "Audit Log Configuration Modified Alert"
  combiner     = "OR"
  project      = var.ops_project_id

  conditions {
    display_name = "Audit Log Configuration Modified"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.5"
      filter          = "resource.type = \"global\" AND metric.type = \"logging.googleapis.com/user/audit-log-modified\""
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
    ## You are receiving this mail as part of alerting policies set by your project monitoring team.
    EOT
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_logging_metric" "vpc_firewall_modified" {
  name        = "vpc-firewall-modified"
  filter      = "resource.type=\"gce_firewall_rule\" AND (protoPayload.methodName:\"compute.firewalls.insert\" OR protoPayload.methodName:\"compute.firewalls.patch\" OR protoPayload.methodName:\"compute.firewalls.delete\")"
  project     = local.project_id
  description = "Monitor VPC Firewall Rule changes"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    labels {
      key         = "PROJECT_ID"
      value_type  = "INT64"
      description = "Project id on which action is performed"
    }

    labels {
      key         = "NETWORK"
      value_type  = "STRING"
      description = "NETWORK on which action is performed"
    }

    labels {
      key         = "ACTION_PERFORMED"
      value_type  = "STRING"
      description = "What kind of action is performed"
    }

    labels {
      key         = "PRINCIPAL_EMAIL"
      value_type  = "STRING"
      description = "Who has Performed the action"
    }
  }
  label_extractors = {
    "PROJECT_ID"       = "EXTRACT(protoPayload.resource.project_id)"
    "NETWORK"          = "EXTRACT(protoPayload.ResourceName)"
    "ACTION_PERFORMED" = "EXTRACT(protoPayload.MethodName)"
    "PRINCIPAL_EMAIL"  = "EXTRACT(protoPayload.authenticationInfo.principalEmail)"
  }
}


resource "google_monitoring_alert_policy" "vpc_firewall_modified_alert" {
  display_name = "VPC Firewall Rule Modified Alert"
  combiner     = "OR"
  project      = var.ops_project_id

  conditions {
    display_name = "VPC Firewall rule created OR modified OR removed"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.5"
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-firewall-modified\" AND resource.type=\"global\""
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
    ## You are receiving this mail as part of alerting policies set by your project monitoring team.
    EOT
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_alert_policy" "vpc_modified_alert" {
  display_name = "VPC Configuration Modified Alert"
  combiner     = "OR"
  project      = var.ops_project_id

  conditions {
    display_name = "VPC created OR modified OR removed"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.5"
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-modified\" AND resource.type=\"global\""
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
    ## You are receiving this mail as part of alerting policies set by your project monitoring team.
    EOT
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_logging_metric" "vpc_modified_metric" {
  name        = "vpc-modified"
  filter      = "resource.type=\"gce_network\" AND (protoPayload.methodName:\"compute.networks.insert\" OR protoPayload.methodName:\"compute.networks.patch\" OR protoPayload.methodName:\"compute.networks.delete\" OR protoPayload.methodName:\"compute.networks.removePeering\" OR protoPayload.methodName:\"compute.networks.addPeering\")"
  project     = local.project_id
  description = "Monitor VPC configuration changes"

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    labels {
      key         = "PROJECT_ID"
      value_type  = "INT64"
      description = "Project id on which action is performed"
    }

    labels {
      key         = "NETWORK"
      value_type  = "STRING"
      description = "NETWORK on which action is performed"
    }

    labels {
      key         = "ACTION_PERFORMED"
      value_type  = "STRING"
      description = "What kind of action is performed"
    }

    labels {
      key         = "PRINCIPAL_EMAIL"
      value_type  = "STRING"
      description = "Who has Performed the action"
    }
  }

  label_extractors = {
    "PROJECT_ID"       = "EXTRACT(protoPayload.resource.project_id)"
    "NETWORK"          = "EXTRACT(protoPayload.ResourceName)"
    "ACTION_PERFORMED" = "EXTRACT(protoPayload.MethodName)"
    "PRINCIPAL_EMAIL"  = "EXTRACT(protoPayload.authenticationInfo.principalEmail)"
  }
}


resource "google_monitoring_alert_policy" "vpc_route_modified_alert" {
  display_name = "VPC Route Modified Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "VPC Route created or modified"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.5"
      filter          = "metric.type=\"logging.googleapis.com/user/vpc-route-modified\" AND resource.type=\"global\""
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  documentation {
    mime_type = "text/markdown"
    content   = <<-EOT
    ## You are receiving this mail as part of alerting policies set by your project monitoring team.
    EOT
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


resource "google_logging_metric" "vpc_route_modified_metric" {
  name        = "vpc-route-modified"
  filter      = "resource.type=\"gce_route\" AND (protoPayload.methodName:\"compute.routes.delete\" OR protoPayload.methodName:\"compute.routes.insert\")"
  project     = local.project_id
  description = "Monitor VPC network route changes"

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    labels {
      key         = "PROJECT_ID"
      value_type  = "INT64"
      description = "Project id on which action is performed"
    }

    labels {
      key         = "ROUTE"
      value_type  = "STRING"
      description = "NETWORK on which action is performed"
    }

    labels {
      key         = "ACTION_PERFORMED"
      value_type  = "STRING"
      description = "What kind of action is performed"
    }

    labels {
      key         = "PRINCIPAL_EMAIL"
      value_type  = "STRING"
      description = "Who has Performed the action"
    }
  }
  label_extractors = {
    "PROJECT_ID"       = "EXTRACT(protoPayload.resource.project_id)"
    "ROUTE"            = "EXTRACT(protoPayload.ResourceName)"
    "ACTION_PERFORMED" = "EXTRACT(protoPayload.MethodName)"
    "PRINCIPAL_EMAIL"  = "EXTRACT(protoPayload.authenticationInfo.principalEmail)"
  }
}


#######################################################################
####################### Cloud Run Service #############################
#######################################################################
resource "google_monitoring_alert_policy" "cloud_run_request_error_alert" {
  display_name = "Cloud Run Request Error Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Cloud Run Response Code Class 4xx or 5xx"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "10"
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"run.googleapis.com/request_count\" AND metric.labels.response_code_class = one_of(\"4xx\", \"5xx\")"
      aggregations {
        alignment_period     = "300s" # 5mins
        per_series_aligner   = "ALIGN_COUNT"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run revision experiences a high number of client errors or server errors.

## Next Steps
1. Investigate the root cause of the errors.
2. Resolve the issue to ensure the stability and availability of the service.
3. Check if there are any related alerts or incidents, and update them as needed.
4. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_alert_policy" "cloud_run_container_startup_latency_alert" {
  display_name = "Cloud Run Startup Latency Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Cloud Run revision's container startup time is too high"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "120000" # values specified is in ms, equal to 2 mins
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"run.googleapis.com/container/startup_latencies\""
      aggregations {
        alignment_period     = "300s" # 5mins
        per_series_aligner   = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields = [
          "resource.labels.service_name"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run revision's container startup time is too high.

## Next Steps
1. Investigate the root cause of the slow container startup time.
2. Optimize the container startup time to improve the service performance and user experience.
3. Check if there are any related alerts or incidents, and update them as needed.
4. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


resource "google_monitoring_alert_policy" "cloud_run_container_cpu_utilization_alert" {
  display_name = "Cloud Run Container CPU Utilization Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Cloud Run revision's CPU utilization is too high"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.8" # 80 percentage
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"run.googleapis.com/container/cpu/utilizations\""
      aggregations {
        alignment_period     = "300s" # 5mins
        per_series_aligner   = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields = [
          "resource.labels.service_name"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run revision's CPU utilization is too high.

## Next Steps
1. Investigate the root cause of the high CPU utilization.
2. If Possible optimize the service configuration to reduce CPU usage.
        - Increase the Container Instance CPU limits
        - Decrease the containerConcurrency value 
3. Check if there are any related alerts or incidents, and update them as needed.
4. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_alert_policy" "cloud_run_container_memory_utilization_alert" {
  display_name = "Cloud Run Container Memory Utilization Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Cloud Run revision's Memory utilization is too high"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "0.8" # 80 percentage
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"run.googleapis.com/container/memory/utilizations\""
      aggregations {
        alignment_period     = "300s" # 5mins
        per_series_aligner   = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields = [
          "resource.labels.service_name"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run revision's Memory utilization is too high.

## Next Steps
1. Investigate the root cause of the high memory utilization.
2. Optimize the service configuration to reduce memory usage.
        - Increase the Container Instance memory limits
        - Decrease the containerConcurrency value 
3. Check if there are any related alerts or incidents, and update them as needed.
4. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


resource "google_monitoring_alert_policy" "cloud_run_request_latencies_alert" {
  display_name = "Cloud Run Request Latencies Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Cloud Run revision's request latencies is too high"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "120000" # value specifed is in unit ms, equivalent to 2 min
      filter          = "resource.type = \"cloud_run_revision\" AND metric.type = \"run.googleapis.com/request_latencies\" AND metric.labels.response_code_class = \"2xx\""
      aggregations {
        alignment_period     = "300s" # 5mins
        per_series_aligner   = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields = [
          "resource.labels.service_name"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run revision's Memory utilization is too high.

## Next Steps
1. Investigate the root cause of the high request latencies.
2. Optimize the service configuration to reduce latency and improve performance.
3. Check if there are any related alerts or incidents, and update them as needed.
4. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

#######################################################################################
######################## Cloud Run Uptime Check And Alerts ############################
#######################################################################################

resource "google_monitoring_uptime_check_config" "viq_auth_service_uptime_check" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  project      = var.ops_project_id
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Auth Service Uptime"
  checker_type = "STATIC_IP_CHECKERS"
  http_check {
    headers        = {}
    mask_headers   = false
    use_ssl        = true
    path           = "/auth-service/health"
    port           = 443
    request_method = "GET"
    validate_ssl   = true
    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }
  content_matchers {
    content = "OK"
    matcher = "CONTAINS_STRING"
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = each.key
      project_id = var.ops_project_id
    }
  }
  timeout          = "20s"
  period           = "300s"
  selected_regions = ["USA", "EUROPE"]
}


resource "google_monitoring_alert_policy" "viq_auth_service_uptime_check_alert" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Auth Service Uptime Check Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Failure of Uptime check"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id =\"${google_monitoring_uptime_check_config.viq_auth_service_uptime_check[each.key].uptime_check_id}\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields = [
          "resource.label.project_id",
          "resource.label.host"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run service s down/unavailable.

## Next Steps
1. Check if there are any related alerts or incidents, and update them as needed.
2. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_uptime_check_config" "viq_data_service_uptime_check" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  project      = var.ops_project_id
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Data Service Uptime"
  checker_type = "STATIC_IP_CHECKERS"
  http_check {
    headers        = {}
    mask_headers   = false
    use_ssl        = true
    path           = "/data-service/health"
    port           = 443
    request_method = "GET"
    validate_ssl   = true
    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }
  content_matchers {
    content = "{\"status\":\"UP\"}"
    matcher = "CONTAINS_STRING"
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = each.key
      project_id = var.ops_project_id
    }
  }
  timeout          = "20s"
  period           = "300s"
  selected_regions = ["USA", "EUROPE"]
}



resource "google_monitoring_alert_policy" "viq_data_service_uptime_check_alert" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Data Service Uptime Check Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Failure of Uptime check"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id =\"${google_monitoring_uptime_check_config.viq_data_service_uptime_check[each.key].uptime_check_id}\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields = [
          "resource.label.project_id",
          "resource.label.host"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run service s down/unavailable.

## Next Steps
1. Check if there are any related alerts or incidents, and update them as needed.
2. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_uptime_check_config" "viq_systemconfig_service_uptime_check" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  project      = var.ops_project_id
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Systemconfig Service Uptime"
  checker_type = "STATIC_IP_CHECKERS"
  http_check {
    headers        = {}
    mask_headers   = false
    use_ssl        = true
    path           = "/systemconfig-service/health"
    port           = 443
    request_method = "GET"
    validate_ssl   = true
    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }
  content_matchers {
    content = "{\"status\":\"UP\"}"
    matcher = "CONTAINS_STRING"
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = each.key
      project_id = var.ops_project_id
    }
  }
  timeout          = "20s"
  period           = "300s"
  selected_regions = ["USA", "EUROPE"]
}



resource "google_monitoring_alert_policy" "viq_systemconfig_service_uptime_check_alert" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Systemconfig Service Uptime Check Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Failure of Uptime check"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id =\"${google_monitoring_uptime_check_config.viq_systemconfig_service_uptime_check[each.key].uptime_check_id}\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields = [
          "resource.label.project_id",
          "resource.label.host"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run service s down/unavailable.

## Next Steps
1. Check if there are any related alerts or incidents, and update them as needed.
2. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_uptime_check_config" "viq_alert_subscription_uptime_check" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  project      = var.ops_project_id
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Alert Subscription Uptime"
  checker_type = "STATIC_IP_CHECKERS"
  http_check {
    headers        = {}
    mask_headers   = false
    use_ssl        = true
    path           = "/alert-subscription/health"
    port           = 443
    request_method = "GET"
    validate_ssl   = true
    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }
  content_matchers {
    content = "{\"status\":\"UP\"}"
    matcher = "CONTAINS_STRING"
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = each.key
      project_id = var.ops_project_id
    }
  }
  timeout          = "20s"
  period           = "300s"
  selected_regions = ["USA", "EUROPE"]
}

resource "google_monitoring_alert_policy" "viq_alert_subscription_uptime_check_alert" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Alert Subscription Uptime Check Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Failure of Uptime check"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id =\"${google_monitoring_uptime_check_config.viq_alert_subscription_uptime_check[each.key].uptime_check_id}\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields = [
          "resource.label.project_id",
          "resource.label.host"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run service s down/unavailable.

## Next Steps
1. Check if there are any related alerts or incidents, and update them as needed.
2. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


resource "google_monitoring_uptime_check_config" "viq_demo_service_uptime_check" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  project      = var.ops_project_id
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Demo Service Uptime"
  checker_type = "STATIC_IP_CHECKERS"
  http_check {
    headers        = {}
    mask_headers   = false
    use_ssl        = true
    path           = "/demo-service/health"
    port           = 443
    request_method = "GET"
    validate_ssl   = true
    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }
  content_matchers {
    content = "{\"status\":\"UP\"}"
    matcher = "CONTAINS_STRING"
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = each.key
      project_id = var.ops_project_id
    }
  }
  timeout          = "20s"
  period           = "300s"
  selected_regions = ["USA", "EUROPE"]
}


resource "google_monitoring_alert_policy" "viq_demo_service_uptime_check_alert" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Demo Service Uptime Check Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Failure of Uptime check"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id =\"${google_monitoring_uptime_check_config.viq_demo_service_uptime_check[each.key].uptime_check_id}\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields = [
          "resource.label.project_id",
          "resource.label.host"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run service s down/unavailable.

## Next Steps
1. Check if there are any related alerts or incidents, and update them as needed.
2. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}


resource "google_monitoring_uptime_check_config" "viq_export_service_uptime_check" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  project      = var.ops_project_id
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Export Service Uptime"
  checker_type = "STATIC_IP_CHECKERS"
  http_check {
    headers        = {}
    mask_headers   = false
    use_ssl        = true
    path           = "/exportservice/health"
    port           = 443
    request_method = "GET"
    validate_ssl   = true
    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }
  content_matchers {
    content = "{\"status\":\"UP\"}"
    matcher = "CONTAINS_STRING"
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = each.key
      project_id = var.ops_project_id
    }
  }
  timeout          = "20s"
  period           = "300s"
  selected_regions = ["USA", "EUROPE"]
}


resource "google_monitoring_alert_policy" "viq_export_service_uptime_check_alert" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Export Service Uptime Check Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Failure of Uptime check"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id =\"${google_monitoring_uptime_check_config.viq_export_service_uptime_check[each.key].uptime_check_id}\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields = [
          "resource.label.project_id",
          "resource.label.host"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run service s down/unavailable.

## Next Steps
1. Check if there are any related alerts or incidents, and update them as needed.
2. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_uptime_check_config" "viq_fota_service_uptime_check" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  project      = var.ops_project_id
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Fota Service Uptime"
  checker_type = "STATIC_IP_CHECKERS"
  http_check {
    headers        = {}
    mask_headers   = false
    use_ssl        = true
    path           = "/fota-service/health"
    port           = 443
    request_method = "GET"
    validate_ssl   = true
    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }
  content_matchers {
    content = "{\"status\":\"UP\"}"
    matcher = "CONTAINS_STRING"
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = each.key
      project_id = var.ops_project_id
    }
  }
  timeout          = "20s"
  period           = "300s"
  selected_regions = ["USA", "EUROPE"]
}


resource "google_monitoring_alert_policy" "viq_fota_service_uptime_check_alert" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Fota Service Uptime Check Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Failure of Uptime check"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id =\"${google_monitoring_uptime_check_config.viq_fota_service_uptime_check[each.key].uptime_check_id}\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields = [
          "resource.label.project_id",
          "resource.label.host"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run service s down/unavailable.

## Next Steps
1. Check if there are any related alerts or incidents, and update them as needed.
2. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_uptime_check_config" "viq_image_service_uptime_check" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  project      = var.ops_project_id
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Image Service Uptime"
  checker_type = "STATIC_IP_CHECKERS"
  http_check {
    headers        = {}
    mask_headers   = false
    use_ssl        = true
    path           = "/device-images/image-service/health"
    port           = 443
    request_method = "GET"
    validate_ssl   = true
    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }
  content_matchers {
    content = "OK"
    matcher = "CONTAINS_STRING"
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = each.key
      project_id = var.ops_project_id
    }
  }
  timeout          = "20s"
  period           = "300s"
  selected_regions = ["USA", "EUROPE"]
}


resource "google_monitoring_alert_policy" "viq_image_service_uptime_check_alert" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Image Service Uptime Check Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Failure of Uptime check"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id =\"${google_monitoring_uptime_check_config.viq_image_service_uptime_check[each.key].uptime_check_id}\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields = [
          "resource.label.project_id",
          "resource.label.host"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run service s down/unavailable.

## Next Steps
1. Check if there are any related alerts or incidents, and update them as needed.
2. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_uptime_check_config" "viq_notification_service_uptime_check" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  project      = var.ops_project_id
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Notification Service Uptime"
  checker_type = "STATIC_IP_CHECKERS"
  http_check {
    headers        = {}
    mask_headers   = false
    use_ssl        = true
    path           = "/notification-services/health"
    port           = 443
    request_method = "GET"
    validate_ssl   = true
    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }
  content_matchers {
    content = "{\"status\":\"UP\"}"
    matcher = "CONTAINS_STRING"
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = each.key
      project_id = var.ops_project_id
    }
  }
  timeout          = "20s"
  period           = "300s"
  selected_regions = ["USA", "EUROPE"]
}


resource "google_monitoring_alert_policy" "viq_notification_service_uptime_check_alert" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Notification Service Uptime Check Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Failure of Uptime check"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id =\"${google_monitoring_uptime_check_config.viq_notification_service_uptime_check[each.key].uptime_check_id}\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields = [
          "resource.label.project_id",
          "resource.label.host"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run service s down/unavailable.

## Next Steps
1. Check if there are any related alerts or incidents, and update them as needed.
2. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_uptime_check_config" "viq_onboarding_service_uptime_check" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  project      = var.ops_project_id
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Onboarding Service Uptime"
  checker_type = "STATIC_IP_CHECKERS"
  http_check {
    headers        = {}
    mask_headers   = false
    use_ssl        = true
    path           = "/onboarding-service/health"
    port           = 443
    request_method = "GET"
    validate_ssl   = true
    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }
  content_matchers {
    content = "{\"status\":\"UP\"}"
    matcher = "CONTAINS_STRING"
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = each.key
      project_id = var.ops_project_id
    }
  }
  timeout          = "20s"
  period           = "300s"
  selected_regions = ["USA", "EUROPE"]
}


resource "google_monitoring_alert_policy" "viq_onboarding_service_uptime_check_alert" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Onboarding Service Uptime Check Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Failure of Uptime check"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id =\"${google_monitoring_uptime_check_config.viq_onboarding_service_uptime_check[each.key].uptime_check_id}\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields = [
          "resource.label.project_id",
          "resource.label.host"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run service s down/unavailable.

## Next Steps
1. Check if there are any related alerts or incidents, and update them as needed.
2. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_uptime_check_config" "viq_public_service_uptime_check" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  project      = var.ops_project_id
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Public Service Uptime"
  checker_type = "STATIC_IP_CHECKERS"
  http_check {
    headers        = {}
    mask_headers   = false
    use_ssl        = true
    path           = "/public-api/health"
    port           = 443
    request_method = "GET"
    validate_ssl   = true
    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }
  content_matchers {
    content = "{\"status\":\"UP\"}"
    matcher = "CONTAINS_STRING"
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = each.key
      project_id = var.ops_project_id
    }
  }
  timeout          = "20s"
  period           = "300s"
  selected_regions = ["USA", "EUROPE"]
}


resource "google_monitoring_alert_policy" "viq_public_service_uptime_check_alert" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Public Service Uptime Check Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Failure of Uptime check"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id =\"${google_monitoring_uptime_check_config.viq_public_service_uptime_check[each.key].uptime_check_id}\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields = [
          "resource.label.project_id",
          "resource.label.host"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run service s down/unavailable.

## Next Steps
1. Check if there are any related alerts or incidents, and update them as needed.
2. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_uptime_check_config" "viq_push_notification_service_uptime_check" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  project      = var.ops_project_id
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Push Notification Service Uptime"
  checker_type = "STATIC_IP_CHECKERS"
  http_check {
    headers        = {}
    mask_headers   = false
    use_ssl        = true
    path           = "/push-notification/health"
    port           = 443
    request_method = "GET"
    validate_ssl   = true
    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }
  content_matchers {
    content = "{\"status\":\"UP\"}"
    matcher = "CONTAINS_STRING"
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = each.key
      project_id = var.ops_project_id
    }
  }
  timeout          = "20s"
  period           = "300s"
  selected_regions = ["USA", "EUROPE"]
}


resource "google_monitoring_alert_policy" "viq_push_notification_service_uptime_check_alert" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Push Notification Service Uptime Check Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Failure of Uptime check"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id =\"${google_monitoring_uptime_check_config.viq_push_notification_service_uptime_check[each.key].uptime_check_id}\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields = [
          "resource.label.project_id",
          "resource.label.host"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run service s down/unavailable.

## Next Steps
1. Check if there are any related alerts or incidents, and update them as needed.
2. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

resource "google_monitoring_uptime_check_config" "viq_scheduler_service_uptime_check" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  project      = var.ops_project_id
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Scheduler Service Uptime"
  checker_type = "STATIC_IP_CHECKERS"
  http_check {
    headers        = {}
    mask_headers   = false
    use_ssl        = true
    path           = "/scheduler-service/health"
    port           = 443
    request_method = "GET"
    validate_ssl   = true
    accepted_response_status_codes {
      status_class = "STATUS_CLASS_2XX"
    }
  }
  content_matchers {
    content = "{\"status\":\"UP\"}"
    matcher = "CONTAINS_STRING"
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      host       = each.key
      project_id = var.ops_project_id
    }
  }
  timeout          = "20s"
  period           = "300s"
  selected_regions = ["USA", "EUROPE"]
}


resource "google_monitoring_alert_policy" "viq_scheduler_service_uptime_check_alert" {
  for_each     = toset(var.cloud_run_load_balancer_hosts)
  display_name = "VIQ - ${upper(element(split(".", each.key), 0))} Scheduler Service Uptime Check Alert"
  combiner     = "OR"
  project      = var.ops_project_id
  conditions {
    display_name = "Failure of Uptime check"
    condition_threshold {

      duration        = "0s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      filter          = "resource.type = \"uptime_url\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id =\"${google_monitoring_uptime_check_config.viq_scheduler_service_uptime_check[each.key].uptime_check_id}\""
      aggregations {
        alignment_period     = "600s" # 10mins
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields = [
          "resource.label.project_id",
          "resource.label.host"
        ]
      }
    }
  }

  documentation {
    content = <<EOF
#### You are receiving this mail as part of alerting policies your project monitoring team set.

## Alert Purpose
This alert is triggered when a Cloud Run service s down/unavailable.

## Next Steps
1. Check if there are any related alerts or incidents, and update them as needed.
2. If necessary, escalate to the appropriate team for further investigation.
    EOF
  }
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
  ]
}

##############################################################################################
####################### Cloud Function alert for instance status #############################
##############################################################################################

resource "google_monitoring_alert_policy" "cloud_function_status_alert" {
  display_name        = "Cloud function failure status"
  project     = var.ops_project_id
  conditions {
    display_name = "Cloud Function Failure Alert"
    condition_threshold {
      duration        = "0s"
      comparison      = "COMPARISON_LT"
      filter          = "resource.type = \"cloud_function\" AND resource.labels.function_name = one_of(\"cf-${local.project_id}-demo_company_2_contract_loader\", \"cf-${local.project_id}-demo_company_onecare_contract_loader\", \"dlr-device-enrollment\", \"dlr-ml-readiness\", \"dtrk-customer-dim\") AND metric.type = \"cloudfunctions.googleapis.com/function/instance_count\" AND metric.labels.state = \"idle\""
      #filter          = "resource.type=\"cloud_function\"severity>=ERROR"
      aggregations {
        alignment_period     = "300s" # 5mins
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
      trigger {
        count = 1
      }
    }
  }
  alert_strategy {
    auto_close = "604800s"
  }
  combiner = "OR"
  enabled  = true
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
    google_monitoring_notification_channel.GMSS_ST_DEVOPS.name,
    google_monitoring_notification_channel.GMSS_DEVOPS.name,
  ]
}

### Cloud function alert for execution status
resource "google_monitoring_alert_policy" "cloud_function_execution_status" {
  display_name        = "Cloud function execution status 80%"
  project     = var.ops_project_id
  conditions {
    display_name = "Cloud Function execution Alert"
    condition_threshold {
      threshold_value = 1244
      duration        = "0s"
      comparison      = "COMPARISON_LT"
      filter          = "resource.type = \"cloud_function\" AND resource.labels.function_name = one_of(\"cf-${local.project_id}-demo_company_2_contract_loader\", \"cf-${local.project_id}-demo_company_onecare_contract_loader\", \"dlr-device-enrollment\", \"dlr-ml-readiness\", \"dtrk-customer-dim\") AND metric.type = \"cloudfunctions.googleapis.com/function/execution_count\""
      aggregations {
        alignment_period     = "300s" # 5mins
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
  alert_strategy {
    auto_close = "604800s"
  }
  combiner = "OR"
  enabled  = true
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
    google_monitoring_notification_channel.GMSS_ST_DEVOPS.name,
    google_monitoring_notification_channel.GMSS_DEVOPS.name,
  ]
}

resource "google_monitoring_alert_policy" "cloud_function_critical_execution_status" {
  display_name        = "Critical execution status upto 90%"
  project     = var.ops_project_id
  conditions {
    display_name = "Cloud Function critical execution Alert"
    condition_threshold {
      threshold_value = 1400
      duration        = "0s"
      comparison      = "COMPARISON_LT"
      filter          = "resource.type = \"cloud_function\" AND resource.labels.function_name = one_of(\"cf-${local.project_id}-demo_company_2_contract_loader\", \"cf-${local.project_id}-demo_company_onecare_contract_loader\", \"dlr-device-enrollment\", \"dlr-ml-readiness\", \"dtrk-customer-dim\") AND metric.type = \"cloudfunctions.googleapis.com/function/execution_count\""
      aggregations {
        alignment_period     = "300s" # 5mins
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
  alert_strategy {
    auto_close = "604800s"
  }
  combiner = "OR"
  enabled  = true
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
    google_monitoring_notification_channel.GMSS_ST_DEVOPS.name,
    google_monitoring_notification_channel.GMSS_DEVOPS.name,
  ]
}

####################################
##### Cloud Pub/Sub Alerts #########
####################################


resource "google_monitoring_alert_policy" "cloud_pubsub_oldest_unacked_message_age_by_region" {
  display_name        = "cloud pub sub topic oldest unacked message age by region"
  project     = var.ops_project_id
  conditions {
    display_name = "Cloud Pub Sub Topic Oldest unacked message age by region"
    condition_threshold {
      threshold_value = 3600000   #1 hr 
      duration        = "0s"
      comparison      = "COMPARISON_LT"
      trigger {
        count = 1
      }      
      filter          = "resource.type = \"pubsub_topic\" AND resource.labels.project_id = \"${local.project_id}\" AND metric.type = \"pubsub.googleapis.com/topic/oldest_unacked_message_age_by_region\""
      aggregations {
        alignment_period     = "300s" # 5mins
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
  alert_strategy {
    auto_close = "604800s"
  }
  combiner = "OR"
  enabled  = true
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
    google_monitoring_notification_channel.GMSS_ST_DEVOPS.name,
    google_monitoring_notification_channel.GMSS_DEVOPS.name,
  ]
}

resource "google_monitoring_alert_policy" "cloud_pubsub_unacked_messages_by_region" {
  display_name        = "cloud pub sub topic unacked messages by region"
  project     = var.ops_project_id
  conditions {
    display_name = "cloud pub sub topic unacked messages by region"
    condition_threshold {
      threshold_value = 3600000   #1 hr 
      duration        = "0s"
      comparison      = "COMPARISON_LT"
      trigger {
        count = 1
      }      
      filter          = "resource.type = \"pubsub_topic\" AND resource.labels.project_id = \"${local.project_id}\" AND metric.type = \"pubsub.googleapis.com/topic/num_unacked_messages_by_region\""
      aggregations {
        alignment_period     = "300s" # 5mins
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
  alert_strategy {
    auto_close = "604800s"
  }
  combiner = "OR"
  enabled  = true
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
    google_monitoring_notification_channel.GMSS_ST_DEVOPS.name,
    google_monitoring_notification_channel.GMSS_DEVOPS.name,
  ]
}



resource "google_monitoring_alert_policy" "cloud_pubsub_oldest_retained_acked_message_age_by_region" {
  display_name        = "cloud pub sub Topic oldest retained acked message age by region"
  project     = var.ops_project_id
  conditions {
    display_name = "cloud pub sub topic oldest retained acked message age by region"
    condition_threshold {
      threshold_value = 3600000   #1 hr 
      duration        = "0s"
      comparison      = "COMPARISON_LT"
      trigger {
        count = 1
      }      
      filter          = "resource.type = \"pubsub_topic\" AND resource.labels.project_id = \"${local.project_id}\" AND metric.type = \"pubsub.googleapis.com/topic/oldest_retained_acked_message_age_by_region\""
      aggregations {
        alignment_period     = "300s" # 5mins
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
  alert_strategy {
    auto_close = "604800s"
  }
  combiner = "OR"
  enabled  = true
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
    google_monitoring_notification_channel.GMSS_ST_DEVOPS.name,
    google_monitoring_notification_channel.GMSS_DEVOPS.name,
  ]
}


resource "google_monitoring_alert_policy" "cloud_pubsub_subscription_oldest_unacked_message_age_by_region" {
  display_name        = "cloud pubsub subscription oldest unacked message age by region"
  project     = var.ops_project_id
  conditions {
    display_name = "cloud pubsub subscription oldest unacked message age by region"
    condition_threshold {
      threshold_value = 3600000   #1 hr 
      duration        = "0s"
      comparison      = "COMPARISON_LT"
      trigger {
        count = 1
      }      
      filter          = "resource.type = \"pubsub_subscription\" AND resource.labels.project_id = \"${local.project_id}\" AND metric.type = \"pubsub.googleapis.com/subscription/oldest_unacked_message_age_by_region\""
      aggregations {
        alignment_period     = "300s" # 5mins
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
  alert_strategy {
    auto_close = "604800s"
  }
  combiner = "OR"
  enabled  = true
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
    google_monitoring_notification_channel.GMSS_ST_DEVOPS.name,
    google_monitoring_notification_channel.GMSS_DEVOPS.name,
  ]
}


# resource "google_monitoring_alert_policy" "cloud_pubsub_topic_publish_message_size" {
#   display_name        = "cloud pubsub topic publish message size"
#   project     = var.ops_project_id
#   conditions {
#     display_name = "cloud pubsub topic publish message size"
#     condition_threshold {
#     # threshold_value = 
#       duration        = "0s"
#       comparison      = "COMPARISON_LT"
#       trigger {
#         count = 1
#       }      
#       filter          = "resource.type = \"pubsub_topic\" AND resource.labels.project_id = \"${local.project_id}\" AND metric.type = \"pubsub.googleapis.com/topic/message_sizes\""
#       aggregations {
#         alignment_period     = "300s" # 5mins
#         per_series_aligner   = "ALIGN_MEAN"
#         cross_series_reducer = "REDUCE_NONE"
#       }
#     }
#   }
#   alert_strategy {
#     auto_close = "604800s"
#   }
#   combiner = "OR"
#   enabled  = true
#   notification_channels = [
#     google_monitoring_notification_channel.datametica_admin.name,
#     google_monitoring_notification_channel.GMSS_ST_DEVOPS.name,
#     google_monitoring_notification_channel.GMSS_DEVOPS.name,
#   ]
# }

#########################################################
#################### Dataflow Alerts ###################
#########################################################

resource "google_monitoring_alert_policy" "dataflow_job_memory_capacity" {
  display_name        = "dataflow job memory capacity alert"
  project     = var.ops_project_id
  conditions {
    display_name = "dataflow job memory capacity"
    condition_threshold {
      threshold_value = 12884901888   #12 GB in byte
      duration        = "0s"
      comparison      = "COMPARISON_LT"
      trigger {
        count = 1
      }      
      filter          = "resource.type = \"dataflow_job\" AND (resource.labels.job_name = \"shrink-dlr-status-df1\" OR resource.labels.job_name = \"vsda-shrink-region-router\") AND metric.type = \"dataflow.googleapis.com/job/memory_capacity\""
      aggregations {
        alignment_period     = "300s" # 5mins
        per_series_aligner   = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
  alert_strategy {
    auto_close = "604800s"
  }
  combiner = "OR"
  enabled  = true
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
    google_monitoring_notification_channel.GMSS_ST_DEVOPS.name,
    google_monitoring_notification_channel.GMSS_DEVOPS.name,
  ]
}



# resource "google_monitoring_alert_policy" "dataflow_job_disk_space_capacity" {
#   display_name        = "dataflow job disk space capacity"
#   project     = var.ops_project_id
#   conditions {
#     display_name = "dataflow job disk space capacity"
#     condition_threshold {
#       threshold_value =  536870912000  # 500GB in byte
#       duration        = "0s"
#       comparison      = "COMPARISON_GT"
#       trigger {
#         count = 1
#       }      
#       filter          = "resource.type = \"dataflow_job\" AND resource.labels.project_id = \"${local.project_id}\" AND metric.type = \"dataflow.googleapis.com/job/disk_space_capacity\""
#       aggregations {
#         alignment_period     = "300s" # 5mins
#         per_series_aligner   = "ALIGN_MEAN"
#         cross_series_reducer = "REDUCE_NONE"
#       }
#     }
#   }
#   alert_strategy {
#     auto_close = "604800s"
#   }
#   combiner = "OR"
#   enabled  = true
#   notification_channels = [
#     google_monitoring_notification_channel.datametica_admin.name,
#     google_monitoring_notification_channel.GMSS_ST_DEVOPS.name,
#     google_monitoring_notification_channel.GMSS_DEVOPS.name,
#   ]
# }


# resource "google_monitoring_alert_policy" "dataflow_error_message_log" {
#   display_name        = "dataflow error or warning message alert"
#   project     = var.ops_project_id
#   conditions {
#     display_name = "dataflow error message"
#     condition_threshold {
#       duration        = "0s"
#       comparison      = "COMPARISON_LT"
#       trigger {
#         count = 1
#       }      
#       filter          = "resource.type=\"dataflow_step\"\nseverity=(WARNING OR ERROR)"

#       aggregations {
#         alignment_period     = "300s" # 5mins
#         per_series_aligner   = "ALIGN_MEAN"
#         cross_series_reducer = "REDUCE_NONE"
#       }
#     }
#   }
#   alert_strategy {
#     auto_close = "604800s"
#   }
#   combiner = "OR"
#   enabled  = true
#   notification_channels = [
#     google_monitoring_notification_channel.datametica_admin.name,
#     google_monitoring_notification_channel.GMSS_ST_DEVOPS.name,
#     google_monitoring_notification_channel.GMSS_DEVOPS.name,
#   ]
# }


######################################
####### Redis Instance Alert #########
######################################


resource "google_monitoring_alert_policy" "Cloud_Memorystore_Redis_Instance" {
  display_name = "Cloud Memorystore Redis Instance"
  project     = var.ops_project_id
  combiner     = "OR"
  conditions {
    display_name = "Cloud Memorystore Redis Instance - System Memory Usage RatioCloud Memorystore Redis Instance - System Memory Usage Ratio"
    condition_threshold {
      filter     = "resource.type = \"redis_instance\" AND resource.labels.instance_id = \"projects/${local.project_id}/locations/${var.primary_region}/instances/${local.project_id}-redis\" AND metric.type = \"redis.googleapis.com/stats/memory/system_memory_usage_ratio\""
      duration   = "300s"
      comparison = "COMPARISON_GT"
      threshold_value = "0.9"
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MAX"
        cross_series_reducer = "REDUCE_NONE"
      }
      evaluation_missing_data = "EVALUATION_MISSING_DATA_INACTIVE"
    }
  }
  alert_strategy {
    auto_close = "3600s"
  }
  enabled              = true
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
    google_monitoring_notification_channel.GMSS_ST_DEVOPS.name,
    google_monitoring_notification_channel.GMSS_DEVOPS.name,
  ]
}

######################################################
####### Redis Instance Alert for Used Memory #########
######################################################


resource "google_monitoring_alert_policy" "Cloud_Memorystore_Redis_Instance_Used_Memory" {
  display_name = "Cloud Memorystore Redis Instance Used Memory"
  project     = var.ops_project_id
  combiner     = "OR"
  conditions {
    display_name = "Cloud Memorystore Redis Instance - Used Memory"
    condition_threshold {
      filter     = "resource.type = \"redis_instance\" AND (resource.labels.instance_id = \"projects/${local.project_id}/locations/${var.primary_region}/instances/${local.project_id}-redis\" AND resource.labels.region = \"${var.primary_region}\" AND resource.labels.project_id = \"${local.project_id}\") AND metric.type = \"redis.googleapis.com/stats/memory/usage\""
      duration   = "0s"
      comparison = "COMPARISON_GT"
      threshold_value = "5155863551" # 4.8 GB in bytes
      
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
        cross_series_reducer = "REDUCE_NONE"
      }
    }
  }
  alert_strategy {
    auto_close = "3600s"
  }
  enabled              = true
  notification_channels = [
    google_monitoring_notification_channel.datametica_admin.name,
    google_monitoring_notification_channel.GMSS_ST_DEVOPS.name,
    google_monitoring_notification_channel.GMSS_DEVOPS.name,
  ]
}



#filter     = "resource.type = \"redis_instance\" AND resource.labels.project_id = \"${local.project_id}\" AND resource.labels.region = \"${var.primary_region}\" AND resource.labels.instance_id = \"${local.project_id}-redis\" AND metric.type = \"redis.googleapis.com/stats/memory/usage\""
#             "resource.type = redis_instance\" AND (resource.labels.project_id = \"projects/${local.project_id} AND resource.labels.region = \"${var.primary_region}\" AND resource.labels.instance_id = \"projects/${local.project_id}/locations/${var.primary_region}/instances/${local.project_id}-redis\") AND metric.type = \"redis.googleapis.com/stats/memory/usage\""

#"resource.type = \"redis_instance\" AND (resource.labels.instance_id = \"projects/viq-st-na-t/locations/us-central1/instances/viq-st-na-t-redis\" AND resource.labels.region = \"us-central1\" AND resource.labels.project_id = \"viq-st-na-t\") AND metric.type = \"redis.googleapis.com/stats/memory/usage\""
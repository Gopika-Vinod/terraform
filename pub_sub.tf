module "fs_shrink_notification_pri" {
  source       = "terraform-google-modules/pubsub/google"
  version      = "5.0.0"
  topic        = "fs-shrink-notification-pri"
  project_id   = local.project_id
  create_topic = true
  grant_token_creator = false
  # A list of IDs of GCP regions where messages that are published to the topic may be persisted in storage. 
  message_storage_policy = {
    allowed_persistence_regions = [
      var.primary_region,
    ]
  }
  # If this field is not set, message retention is controlled by settings on individual subscriptions.
  topic_message_retention_duration = null
  pull_subscriptions = [
    {
      create_subscriptions = true
      name                 = "fs-shrink-notification-pri-sub01"
      # This value is the maximum time after a subscriber receives a message before the subscriber should acknowledge the message. After message delivery but before the ack deadline expires and before the message is acknowledged, it is an outstanding message and will not be delivered again during that time (on a best-effort basis).                        
      ack_deadline_seconds = 60 # 60 secs                                                      
      filter               = null
      # How long to retain unacknowledged messages in the subscription's backlog, from the moment a message is published.                                   
      message_retention_duration = "604800s" # 7 days
      # indicates whether to retain acknowledged messages. If true, then messages are not expunged from the subscription's backlog, even if they are acknowledged, until they fall out of the messageRetentionDuration window.
      retain_acked_messages = true
      # service account provide will be granted roles/pubsub.subscriber                                                 
      service_account              = module.sa_viq_cloud_run.email
      enable_message_ordering      = false                                                             
      enable_exactly_once_delivery = true    
      # retry policy   
      minimum_backoff = "10s"
      maximum_backoff = "600s"
    },
  ]
  depends_on = [
    module.viq_services,
    module.sa_viq_cloud_run,
  ]
}

module "fs_shrink_notification_fail" {
  source       = "terraform-google-modules/pubsub/google"
  version      = "5.0.0"
  topic        = "fs-shrink-notification-fail"
  project_id   = local.project_id
  create_topic = true
  grant_token_creator = false
  # A list of IDs of GCP regions where messages that are published to the topic may be persisted in storage. 
  message_storage_policy = {
    allowed_persistence_regions = [
      var.primary_region,
    ]
  }
  # If this field is not set, message retention is controlled by settings on individual subscriptions.
  topic_message_retention_duration = null
  pull_subscriptions = [
    {
      create_subscriptions = true
      name                 = "fs-shrink-notification-fail-sub01"
      # This value is the maximum time after a subscriber receives a message before the subscriber should acknowledge the message. After message delivery but before the ack deadline expires and before the message is acknowledged, it is an outstanding message and will not be delivered again during that time (on a best-effort basis).                        
      ack_deadline_seconds = 60 # 60 secs                                                      
      filter               = null
      # How long to retain unacknowledged messages in the subscription's backlog, from the moment a message is published.                                   
      message_retention_duration = "604800s" # 7 days
      # indicates whether to retain acknowledged messages. If true, then messages are not expunged from the subscription's backlog, even if they are acknowledged, until they fall out of the messageRetentionDuration window.
      retain_acked_messages = true
      # service account provide will be granted roles/pubsub.subscriber                                                 
      service_account              = module.sa_viq_cloud_run.email
      enable_message_ordering      = false                                                             
      enable_exactly_once_delivery = true    
      # retry policy   
      minimum_backoff = "10s"
      maximum_backoff = "600s"
    },
  ]
  depends_on = [
    module.viq_services,
    module.sa_viq_cloud_run,
  ]
}

module "fs_shrink_notification_topics_iam_bindings" {
  source        = "terraform-google-modules/iam/google//modules/pubsub_topics_iam"
  version = "7.6.0"
  project       = local.project_id
  pubsub_topics = ["fs-shrink-notification-fail", "fs-shrink-notification-pri"]
  mode          = "additive"

  bindings = {
    "roles/pubsub.publisher" = [
      "serviceAccount:${module.sa_viq_cloud_run.email}"
    ]
    "roles/pubsub.viewer" = [
      "serviceAccount:${module.sa_viq_cloud_run.email}"
    ]
  }
  depends_on = [
    module.fs_shrink_notification_fail,
    module.fs_shrink_notification_pri,
  ]
}



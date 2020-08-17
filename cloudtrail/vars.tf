variable "name" {
  type        = string
  description = "Name  (e.g. `app` or `cluster`)"
  default     = "test-cloudtrail"
}

variable "enable_log_file_validation" {
  type        = bool
  description = "Specifies whether log file integrity validation is enabled. Creates signed digest for validated contents of logs"
  default     = true
}

variable "is_multi_region_trail" {
  type        = bool
  description = "Specifies whether the trail is created in the current region or in all regions"
  default     = true
}

variable "include_global_service_events" {
  type        = bool
  description = "Specifies whether the trail is publishing events from global services such as IAM to the log files"
  default     = true
}

variable "enable_logging" {
  type        = bool
  description = "Enable logging for the trail"
  default     = true
}

variable "is_organization_trail" {
  type        = bool
  description = "The trail is an AWS Organizations trail"
  default     = false
}

variable "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group that receives CloudTrail events."
  default     = "cloudtrail-events"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to keep AWS logs around in specific log group."
  default     = 90
  type        = string
}

variable "event_selector" {
  type = list(object({
    include_management_events = bool
    read_write_type           = string

    data_resource = list(object({
      type   = string
      values = list(string)
    }))
  }))

  description = "Specifies an event selector for enabling data event logging. See: https://www.terraform.io/docs/providers/aws/r/cloudtrail.html for details on this variable"
  // If you intend to write to default then write for
  // "include_management_events", "read_write_type" and "data_resource" or else keep it empty
  default = [
//    {
//      include_management_events = true
//      read_write_type = "All"
//      data_resource = []
//    }
  ]
}

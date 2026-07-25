variable "function_name" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "source_file" {
  type = string
}

variable "agent_id" {
  type = string
}

variable "agent_alias_id" {
  type = string
}

variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "handler" {
  type    = string
  default = "chat.handler"
}

variable "timeout" {
  type    = number
  default = 30
}

variable "memory_size" {
  type    = number
  default = 256
}
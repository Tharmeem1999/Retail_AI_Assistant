variable "api_name" {
  type = string
}

variable "lambda_invoke_arn" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "website_origin" {
  type        = string
  description = "Exact frontend origin, for example https://shopai.example.com"
}

variable "stage_name" {
  type    = string
  default = "prod"
}
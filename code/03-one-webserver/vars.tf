# Input variable: server port
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = "8080"
}

variable "subscription_id"{
  description="Id of the subscription in the acount that this application would be using"
  //value="subscription_id"
  default ="6e1001f2-25e2-42f9-b453-8075e4c87028"
}

variable "tenant_id"{
  description="tenant ID of the Azure AD in use"
  //value="tenant_id"
  default="40ac6e26-3eb6-4888-9080-1bac2ab44055"
}

/*
variable "client_id"{
  description=""
  default=""
}

variable "client_secret"{
  description=""
  default=""
}
*/

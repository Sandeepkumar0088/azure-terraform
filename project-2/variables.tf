variable "vms" {
  default = {
    frontend    = "10.0.1.8"
    mongodb     = "10.0.1.9"
    catalogue   = "10.0.1.13"
    user        = "10.0.1.7"
    redis       = "10.0.1.4"
    cart        = "10.0.1.11"
    mysql       = "10.0.1.12"
    shipping    = "10.0.1.5"
    rabbitmq    = "10.0.1.10"
    payment     = "10.0.1.6"
  }
}
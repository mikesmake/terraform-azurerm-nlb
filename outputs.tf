output "ip_address" {
  value       = azurerm_lb.nlb.private_ip_address
  description = "The first IP asssigned to the front end"
}
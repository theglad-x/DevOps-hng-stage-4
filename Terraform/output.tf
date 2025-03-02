output "server_ip" {
  value = aws_instance.todo_server.public_ip
}

output "domain" {
  value = var.domain_name
}

output "application_url" {
  value = "https://${var.domain_name}"
}
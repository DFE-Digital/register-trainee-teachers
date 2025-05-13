output "url" {
  value = { for k,v in module.web_application : k => "https://${v["hostname"]}/" }
}

# output "source_id" {
#   value = module.airbyte[0].source_id
# }

# output "destination_id" {
#   value = module.airbyte[0].destination_id
# }

# output "connection_id" {
#   value = module.airbyte[0].connection_id
# }

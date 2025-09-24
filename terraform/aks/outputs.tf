output "url" {
  value = { for k,v in module.web_application : k => "https://${v["hostname"]}/" }
}

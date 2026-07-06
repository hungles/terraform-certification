output "private_subnet_ids" {
  description = "List of private subnet IDs with Tier=Private tag"
  value       = data.aws_subnets.private_with_tag.ids
}
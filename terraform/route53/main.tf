resource "aws_route53_zone" "n1mtp_com" {
  name = "n1mtp.com"
}

resource "aws_route53_record" "dns" {
  for_each = local.recordsets

  zone_id = aws_route53_zone.n1mtp_com.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = lookup(each.value, "ttl", null)
  records = try(each.value.record, null)


  dynamic "alias" {
    for_each = length(keys(lookup(each.value, "alias", {}))) == 0 ? [] : [true]

    content {
      name                   = each.value.alias.name
      zone_id                = var.cloudfront_zone_id
      evaluate_target_health = lookup(each.value.alias, "evaluate_target_health", false)
    }
  }
}

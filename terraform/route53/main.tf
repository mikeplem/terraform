resource "aws_route53_zone" "n1mtp_com" {
  name = "n1mtp.com"
}

resource "aws_route53_record" "dns" {
    for_each = local.recordsets

    zone_id = aws_route53_zone.n1mtp_com.zone_id
    name    = each.value.name
    type    = each.value.type
    ttl     = 300
    records = [each.value.record]
}

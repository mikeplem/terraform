locals {
  # convert from list to map with unique keys
  recordsets = { for rs in var.records : join(" ", compact(["${rs.name}_${rs.type}"])) => rs }
}

variable "cloudfront_zone_id" {
  default = "Z2FDTNDATAQYW2"
}

variable "records" {
  default = [
    {
      name = ""
      type = "A"
      alias = {
        name = "d1486w975c4gqn.cloudfront.net"
      }
    },
    {
      name   = ""
      record = ["10 mx.hover.com.cust.hostedemail.com"]
      type   = "MX"
      ttl    = 86400
    },
    {
      name   = ""
      record = ["v=spf1 include:_spf.hostedemail.com include:hover.com ~all"]
      type   = "TXT"
      ttl    = 86400
    },
    {
      name   = "_dmarc"
      record = ["v=DMARC1; p=quarantine; rua=mailto:mike@n1mtp.com; ruf=mailto:mike@n1mtp.com; fo=1;"]
      type   = "TXT"
      ttl    = 86400
    },
    {
      name   = "cups"
      record = ["192.168.1.237"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "down-sense"
      record = ["192.168.1.183"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "files.social"
      record = ["34.233.156.231"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "frigate"
      record = ["192.168.1.209"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "git"
      record = ["100.64.1.1"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "hass"
      record = ["13ittluc6noru76u7dkg0rkdpgsm817l.ui.nabu.casa"]
      type   = "CNAME"
      ttl    = 86400
    },
    {
      name   = "_acme-challenge.hass.n1mtp.com"
      record = ["_acme-challenge.13ittluc6noru76u7dkg0rkdpgsm817l.ui.nabu.casa"]
      type   = "CNAME"
      ttl    = 86400
    },
    {
      name   = "hasswg"
      record = ["100.64.1.5"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "homeassistant"
      record = ["192.168.1.141"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "local"
      record = ["127.0.0.1"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "mail"
      record = ["mail.hover.com.cust.hostedemail.com"]
      type   = "CNAME"
      ttl    = 86400
    },
    {
      name   = "nas"
      record = ["192.168.1.40"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "ntfy"
      record = ["100.64.1.1"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "owncloud"
      record = ["159.203.121.241"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "setup"
      record = ["192.168.1.1"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "social"
      record = ["34.233.156.231"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "tail"
      record = ["165.227.88.197"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "twc"
      record = ["192.168.1.141"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "ubnt"
      record = ["192.168.1.1"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "unifi"
      record = ["192.168.1.230"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "up-sense"
      record = ["192.168.1.175"]
      type   = "A"
      ttl    = 86400
    },
    {
      name   = "www"
      record = ["n1mtp.com."]
      type   = "CNAME"
      ttl    = 86400
    }
  ]
}

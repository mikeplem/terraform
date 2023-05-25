locals {
  # convert from list to map with unique keys
  recordsets        = { for rs in var.records : join(" ", compact(["${rs.name}_${rs.type}"])) => rs }
}

variable "records" {
    type = set(object({
        name = string
        record = string
        type = string
    }))

    default = [
        {
            name = ""
            record = "165.227.88.197"
            type = "A"
        },
        {
            name = ""
            record = "10 mx.hover.com.cust.hostedemail.com"
            type = "MX"
        },
        {
            name = ""
            record = "v=spf1 include:_spf.hostedemail.com include:hover.com ~all"
            type = "TXT"
        },
        {
            name = "_dmarc"
            record = "v=DMARC1; p=quarantine; rua=mailto:mike@n1mtp.com; ruf=mailto:mike@n1mtp.com; fo=1;"
            type = "TXT"
        },
        {
            name = "cups"
            record = "192.168.1.237"
            type = "A"
        },
        {
            name = "files.social"
            record = "34.233.156.231"
            type = "A"
        },
        {
            name = "git"
            record = "100.64.1.1"
            type = "A"
        },
        {
            name = "hasswg"
            record = "100.64.1.5"
            type = "A"
        },
        {
            name = "homeassistant"
            record = "192.168.1.141"
            type = "A"
        },
        {
            name = "local"
            record = "127.0.0.1"
            type = "A"
        },
        {
            name = "mail"
            record = "mail.hover.com.cust.hostedemail.com"
            type = "CNAME"
        },
        {
            name = "nas"
            record = "192.168.1.40"
            type = "A"
        },
        {
            name = "owncloud"
            record = "159.203.121.241"
            type = "A"
        },
        {
            name = "setup"
            record = "192.168.1.1"
            type = "A"
        },
        {
            name = "social"
            record = "34.233.156.231"
            type = "A"
        },
        {
            name = "tail"
            record = "165.227.88.197"
            type = "A"
        },
        {
            name = "ubnt"
            record = "192.168.1.1"
            type = "A"
        },
        {
            name = "unifi"
            record = "192.168.1.230"
            type = "A"
        },
        {
            name = "www"
            record = "n1mtp.com"
            type = "CNAME"
        }
    ]
}

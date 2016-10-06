variable env {}
variable region {}

variable vpc {}
variable domain {}

provider aws {
    region = "${var.region}"
}

resource aws_route53_zone vpc_zone {
    name = "${var.domain}"
    vpc_id = "${var.vpc}"

    tags {
        Name = "${var.env}-vpc-dns"
        Environment = "${var.env}"
        KubernetesCluster = "${var.env}"
    }
}

output domain { value = "${var.domain}" }
output zone_id { value = "${aws_route53_zone.vpc_zone.id}" }

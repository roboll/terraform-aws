variable env {}
variable region {}

variable vpc_id {}
variable vpc_cidr {}
variable vpc_dns_zone {}
variable vpc_route_tables { type = "list" }
variable vpc_route_count { default = 5 }

variable peer_env {}
variable peer_vpc {}
variable peer_cidr {}
variable peer_dns_zone {}
variable peer_route_tables { type = "list" }
variable peer_route_count { default = 5 }
variable peer_account_id {}

provider aws {
    region = "${var.region}"
}

resource aws_vpc_peering_connection connect {
    peer_owner_id = "${var.peer_account_id}"
    peer_vpc_id = "${var.peer_vpc}"

    vpc_id = "${var.vpc_id}"
    auto_accept = true

    tags {
        Name = "${var.env} - ${var.peer_env}"
        Environment = "${var.env}"
    }

    provisioner local-exec { command = "sleep 30" }
}

resource aws_route peer_routes {
    route_table_id = "${element(var.peer_route_tables, count.index)}"
    destination_cidr_block = "${var.vpc_cidr}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.connect.id}"

    count = "${var.peer_route_count}"
}

resource aws_route local_routes {
    route_table_id = "${element(var.vpc_route_tables, count.index)}"
    destination_cidr_block = "${var.peer_cidr}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.connect.id}"

    count = "${var.vpc_route_count}"
}

resource aws_route53_zone_association peered {
    zone_id = "${var.peer_dns_zone}"
    vpc_id = "${var.vpc_id}"
}

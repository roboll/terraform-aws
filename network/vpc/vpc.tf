variable env {}
variable cidr {}
variable region {}
variable zone_count { default = 3 }
variable allowed_ssh_sources { default = [ "0.0.0.0/32" ] }

provider aws {
    region = "${var.region}"
}

data aws_availability_zones available {}

resource aws_vpc vpc {
    cidr_block = "${var.cidr}"

    enable_dns_support = true
    enable_dns_hostnames = true

    tags {
        Name = "${var.env}-vpc"
        Environment = "${var.env}"
        KubernetesCluster = "${var.env}"
    }
}

resource aws_security_group_rule ssh_ingress {
    security_group_id = "${aws_vpc.vpc.default_security_group_id}"

    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = "${var.allowed_ssh_sources}"
}

resource aws_internet_gateway internet {
    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "${var.env}-igw"
        Environment = "${var.env}"
    }

    provisioner local-exec { command = "sleep 30" }
}

resource aws_vpc_endpoint s3 {
    vpc_id = "${aws_vpc.vpc.id}"
    service_name = "com.amazonaws.${var.region}.s3"

    route_table_ids = [
        "${aws_route_table.private_route_table.id}",
        "${aws_route_table.public_route_table.id}",
        "${aws_route_table.nat_route_table.*.id}"
    ]
}

resource null_resource ready {
    triggers {
        vpc = "${aws_vpc.vpc.id}"
        cidr = "${aws_vpc.vpc.cidr_block}"
        security_group = "${aws_vpc.vpc.default_security_group_id}"
        availability_zones = "${join(",", aws_subnet.public_subnet.*.availability_zone)}"
        route_tables = "${join(",", aws_route_table.nat_route_table.*.id)},${aws_route_table.public_route_table.id},${aws_route_table.private_route_table.id}"
    }

    depends_on = [
        "aws_vpc_endpoint.s3",
        "aws_internet_gateway.internet",

        "aws_route.nat_internet_routes",
        "aws_route.public_internet_route",

        "aws_route_table_association.nat_subnet_route",
        "aws_route_table_association.public_subnet_route",
        "aws_route_table_association.private_subnet_route"
    ]
}

output id { value = "${null_resource.ready.triggers.vpc}" }
output cidr { value = "${null_resource.ready.triggers.cidr}" }
output security_group { value = "${null_resource.ready.triggers.security_group}" }
output availability_zones { value = [ "${aws_subnet.public_subnet.*.availability_zone}" ] }
output route_tables {
    value = [
        "${aws_route_table.nat_route_table.*.id}",
        "${aws_route_table.public_route_table.id}",
        "${aws_route_table.private_route_table.id}"
    ]
}

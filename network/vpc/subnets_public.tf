resource aws_subnet public_subnet {
    vpc_id = "${aws_vpc.vpc.id}"

    cidr_block = "${cidrsubnet(var.cidr, 5, count.index)}"
    availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
    map_public_ip_on_launch = true

    tags {
        Name = "${var.env}-public-subnet-${count.index}"
        Environment = "${var.env}"
        KubernetesCluster = "${var.env}"
    }

    count = "${var.zone_count}"
}

resource aws_route_table public_route_table {
    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "${var.env}-public-rtb"
        Environment = "${var.env}"
        KubernetesCluster = "${var.env}"
    }
}

resource aws_route public_internet_route {
    route_table_id = "${aws_route_table.public_route_table.id}"
    gateway_id = "${aws_internet_gateway.internet.id}"
    destination_cidr_block = "0.0.0.0/0"
}

resource aws_route_table_association public_subnet_route {
    subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.public_route_table.id}"

    count = "${var.zone_count}"
}

output public_cidrs { value = [ "${aws_subnet.public_subnet.*.cidr_block}" ] }
output public_subnets { value = [ "${aws_subnet.public_subnet.*.id}" ] }
output public_route_table { value = "${aws_route_table.public_route_table.id}" }

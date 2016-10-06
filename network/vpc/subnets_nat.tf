resource aws_subnet nat_subnet {
    vpc_id = "${aws_vpc.vpc.id}"

    cidr_block = "${cidrsubnet(var.cidr, 3, count.index+4)}"
    availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

    tags {
        Name = "${var.env}-nat-subnet-${count.index}"
        Environment = "${var.env}"
        KubernetesCluster = "${var.env}"
    }

    count = "${var.zone_count}"
}

resource aws_eip nat {
    vpc = true
    count = "${var.zone_count}"
}

resource aws_nat_gateway nat_gateway {
    allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
    subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"

    depends_on = [ "aws_internet_gateway.internet" ]
    count = "${var.zone_count}"
}

resource aws_route_table nat_route_table {
    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "${var.env}-nat-rtb"
        Environment = "${var.env}"
        KubernetesCluster = "${var.env}"
    }

    depends_on = [ "aws_nat_gateway.nat_gateway" ]
    count = "${var.zone_count}"
}

resource aws_route nat_internet_routes {
    route_table_id = "${element(aws_route_table.nat_route_table.*.id, count.index)}"
    nat_gateway_id = "${element(aws_nat_gateway.nat_gateway.*.id, count.index)}"
    destination_cidr_block = "0.0.0.0/0"

    count = "${var.zone_count}"
}

resource aws_route_table_association nat_subnet_route {
    subnet_id = "${element(aws_subnet.nat_subnet.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.nat_route_table.*.id, count.index)}"

    count = "${var.zone_count}"
}

output nat_cidrs { value = [ "${aws_subnet.nat_subnet.*.cidr_block}" ] }
output nat_subnets { value = [ "${aws_subnet.nat_subnet.*.id}" ] }
output nat_route_tables { value = [ "${join(",", aws_route_table.nat_route_table.*.id)}" ] }

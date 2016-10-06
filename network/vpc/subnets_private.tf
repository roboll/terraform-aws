resource aws_subnet private_subnet {
    vpc_id = "${aws_vpc.vpc.id}"

    cidr_block = "${cidrsubnet(var.cidr, 3, count.index+1)}"
    availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

    tags {
        Name = "${var.env}-private-subnet-${count.index}"
        Environment = "${var.env}"
        KubernetesCluster = "${var.env}"
    }

    count = "${var.zone_count}"
}

resource aws_route_table private_route_table {
    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "${var.env}-private-rtb"
        Environment = "${var.env}"
        KubernetesCluster = "${var.env}"
    }
}

resource aws_route_table_association private_subnet_route {
    subnet_id = "${element(aws_subnet.private_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.private_route_table.id}"

    count = "${var.zone_count}"
}

output private_cidrs { value = [ "${aws_subnet.private_subnet.*.cidr_block}" ] }
output private_subnets { value = [ "${aws_subnet.private_subnet.*.id}" ] }
output private_route_table { value = "${aws_route_table.private_route_table.id}"}

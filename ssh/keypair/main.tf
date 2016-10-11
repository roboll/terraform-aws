variable env {}
variable region {}

variable name { default = "default" }

variable public_key {}

provider aws {
    region = "${var.region}"
}

resource aws_key_pair ssh {
    key_name = "${var.env}-${var.name}"
    public_key = "${var.public_key}"
}

output name { value = "${aws_key_pair.ssh.key_name}" }

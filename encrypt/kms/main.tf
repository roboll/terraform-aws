variable env {}
variable region {}

variable name { default = "default" }

variable account_id {}
variable admin_role {}

provider aws {
    region = "${var.region}"
}

data template_file key_policy {
    template = "${file("${path.module}/policy.json")}"

    vars {
        account_id = "${var.account_id}"
        owner = "${var.admin_role}"
    }
}

resource aws_kms_key key {
    description = "${var.env}-${var.name} key"
    policy = "${data.template_file.key_policy.rendered}"
}

output key { value = "${aws_kms_key.key.arn}" }

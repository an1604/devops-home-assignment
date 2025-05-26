resource "aws_key_pair" "terraform-lab" {
  key_name   = "${var.environment}_new_key_pair"
  public_key = file(var.ssh_pubkey_file)
}

resource "aws_key_pair" "nat-instance-key-pair" {
  key_name   = "${var.environment}_nat_instance_key_pair"
  public_key = file(var.ssh_pubkey_file_nat_instance)
}
  
resource "aws_key_pair" "terraform-lab" {
  key_name   = "${var.environment}_key_pair"
  public_key = file(var.ssh_pubkey_file)
}
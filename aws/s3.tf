resource "aws_s3_bucket" "backup" {
  bucket = "iota-solution-s3-backup"
  acl    = "private"

  tags {
    Name = "iota-solution-s3-backup"
  }
}

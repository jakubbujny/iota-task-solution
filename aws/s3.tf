resource "aws_s3_bucket" "backup" {
  bucket = "iota-solution-s3-backup"
  acl    = "private"

  tags {
    Name = "iota-solution-s3-backup"
  }
}


resource "aws_s3_bucket" "layers" {
  bucket = "iota-solution-s3-layers"
  acl    = "private"

  tags {
    Name = "iota-solution-s3-layers"
  }
}

resource "aws_s3_bucket" "b" {
  bucket = "lesson7-couga-bucket"
  acl    = "private"
}
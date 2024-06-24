
data "aws_iam_policy_document" "glue_policy_document"{
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["glue.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "glue_role" {
    name = var.glue_role_name
    assume_role_policy = data.aws_iam_policy_document.glue_policy_document.json
}

resource "aws_iam_role_policy_attachment" "glue_service_role_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
  
}

resource "aws_iam_role_policy_attachment" "glue_s3_access_policy_attachment" {
   role = aws_iam_role.glue_role.name
   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


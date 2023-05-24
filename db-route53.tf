resource "aws_route53_zone" "database-darwinbox" {
  name = "database-darwinbox.com"
  vpc {
    vpc_id     = aws_vpc.dbvpc.id
    vpc_region = "us-east-2"
 }
}
resource "aws_route53_record" "mongo-1" {
  zone_id = aws_route53_zone.database-darwinbox.id
  name    = "www.database-darwinbox-1.com"
  type    = "A"
  ttl     = "60"
  records = ["${aws_instance.mongo-1.private_ip}"]
}

resource "aws_route53_record" "mongo-2" {
  zone_id = aws_route53_zone.database-darwinbox.id
  name    = "www.database-darwinbox-2.com"
  type    = "A"
  ttl     = "60"
  records = ["${aws_instance.mongo-2.private_ip}"]
}

resource "aws_route53_record" "mongo-3" {
  zone_id = aws_route53_zone.database-darwinbox.id
  name    = "www.database-darwinbox-3.com"
  type    = "A"
  ttl     = "60"
  records = ["${aws_instance.mongo-3.private_ip}"]
}




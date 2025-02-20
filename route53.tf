data "aws_route53_zone" "primary" {
  name = "alisriosti.com.br"
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.primary.zone_id # Substitua pelo ID correto da sua zona
  name    = "n8n2.alisriosti.com.br"
  type    = "A"
  ttl     = 300
  records = [aws_instance.this.public_ip]
}
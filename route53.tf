data "aws_route53_zone" "primary" {
  name = "jovando.com.br"
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.primary.zone_id # Substitua pelo ID correto da sua zona
  name    = "n8n.jovando.com.br"
  type    = "A"
  ttl     = 300
  records = [aws_instance.this.public_ip]
}
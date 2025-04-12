resource "aws_security_group" "nlb_sg" {
  name        = "${local.name}-nlb-sg"
  description = "Allow port 80 from the internet"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "nlb" {
  name               = "${local.name}-with-tgb"
  internal           = false
  load_balancer_type = "network"
  security_groups = [aws_security_group.nlb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "nlb_target_group" {
  name        = "${local.name}-target-group"
  port        = 80
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
  }
}


resource "kubernetes_service_v1" "nlb" {
  metadata {
    name = "nlb-with-tgb"
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_manifest" "target_group_binding" {
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind"       = "TargetGroupBinding"
    "metadata" = {
      "name"      = "${local.name}-target-group-binding"
      "namespace" = kubernetes_service_v1.nlb.metadata[0].namespace
    }
    "spec" = {
      "targetGroupARN" = aws_lb_target_group.nlb_target_group.arn
      "serviceRef" = {
        "name" = kubernetes_service_v1.nlb.metadata[0].name
        "port" = 80
      }
      "networking" = {
        "ingress" = [
          {
            "from" = [
              {
                "securityGroup" = {
                  "groupID": aws_security_group.nlb_sg.id
                }
              }
            ]
            "ports" = [
              {
                "protocol" = "TCP"
                "port" = 80
              }
            ]
          }
        ]
      }
    }
  }
}
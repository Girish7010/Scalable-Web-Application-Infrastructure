resource "aws_sns_topic" "alerts" { name = "${var.project_name}-alerts" }

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  dimensions          = { LoadBalancer = aws_lb.alb.arn_suffix }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${var.project_name}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  dimensions          = { ClusterName = aws_ecs_cluster.this.name, ServiceName = aws_ecs_service.prod.name }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.project_name}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  dimensions          = { DBInstanceIdentifier = aws_db_instance.postgres.id }
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      { "type" : "metric", "x" : 0, "y" : 0, "width" : 12, "height" : 6, "properties" : { "title" : "ALB 5XX & Target Response Time", "metrics" : [["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", aws_lb.alb.arn_suffix], [".", "TargetResponseTime", "LoadBalancer", aws_lb.alb.arn_suffix]], "view" : "timeSeries", "stacked" : false, "region" : var.aws_region } },
      { "type" : "metric", "x" : 12, "y" : 0, "width" : 12, "height" : 6, "properties" : { "title" : "ECS CPU/Mem (prod)", "metrics" : [["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.this.name, "ServiceName", aws_ecs_service.prod.name], [".", "MemoryUtilization", "ClusterName", aws_ecs_cluster.this.name, "ServiceName", aws_ecs_service.prod.name]], "view" : "timeSeries", "stacked" : false, "region" : var.aws_region } },
      { "type" : "metric", "x" : 0, "y" : 6, "width" : 12, "height" : 6, "properties" : { "title" : "RDS CPU & FreeStorage", "metrics" : [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.postgres.id], [".", "FreeStorageSpace", "DBInstanceIdentifier", aws_db_instance.postgres.id]], "view" : "timeSeries", "stacked" : false, "region" : var.aws_region } }
    ]
  })
}

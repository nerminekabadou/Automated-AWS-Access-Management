resource "aws_cloudwatch_event_rule" "daily_cleanup" {
  name                = "daily-iam-cleanup"
  description         = "Triggers daily scan for expired IAM users"
  schedule_expression = var.schedule_expression
  is_enabled          = true
  
  tags = {
    internship = "true"  # REQUIRED mentor tag
  }
}

resource "aws_cloudwatch_event_target" "trigger_cleanup_scheduler" {
  rule      = aws_cloudwatch_event_rule.daily_cleanup.name
  target_id = "cleanup-scheduler-lambda"
  arn       = var.cleanup_scheduler_lambda_arn
}

resource "aws_lambda_permission" "allow_eventbridge_to_invoke_scheduler" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.cleanup_scheduler_lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_cleanup.arn
  
  # Ensures permission is only created after both resources exist
  depends_on = [
    aws_cloudwatch_event_rule.daily_cleanup,
    aws_cloudwatch_event_target.trigger_cleanup_scheduler
  ]
}
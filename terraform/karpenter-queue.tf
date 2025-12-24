resource "aws_sqs_queue" "karpenter_interruption" {
  name = var.cluster_name
  tags = local.common_tags
}

data "aws_iam_policy_document" "sqs_allow_eventbridge" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.karpenter_interruption.arn]
  }
}

resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.karpenter_interruption.id
  policy    = data.aws_iam_policy_document.sqs_allow_eventbridge.json
}

# Common interruption signals
resource "aws_cloudwatch_event_rule" "spot_interruption" {
  name        = "${var.cluster_name}-spot-interruption"
  description = "EC2 Spot interruption warning"
  event_pattern = jsonencode({
    source        = ["aws.ec2"]
    "detail-type" = ["EC2 Spot Instance Interruption Warning"]
  })
}

resource "aws_cloudwatch_event_target" "spot_to_sqs" {
  rule      = aws_cloudwatch_event_rule.spot_interruption.name
  target_id = "sqs"
  arn       = aws_sqs_queue.karpenter_interruption.arn
}

resource "aws_cloudwatch_event_rule" "rebalance" {
  name        = "${var.cluster_name}-rebalance"
  description = "EC2 rebalance recommendation"
  event_pattern = jsonencode({
    source        = ["aws.ec2"]
    "detail-type" = ["EC2 Instance Rebalance Recommendation"]
  })
}

resource "aws_cloudwatch_event_target" "rebalance_to_sqs" {
  rule      = aws_cloudwatch_event_rule.rebalance.name
  target_id = "sqs"
  arn       = aws_sqs_queue.karpenter_interruption.arn
}

resource "aws_cloudwatch_event_rule" "state_change" {
  name        = "${var.cluster_name}-state-change"
  description = "EC2 instance state change"
  event_pattern = jsonencode({
    source        = ["aws.ec2"]
    "detail-type" = ["EC2 Instance State-change Notification"]
  })
}

resource "aws_cloudwatch_event_target" "state_to_sqs" {
  rule      = aws_cloudwatch_event_rule.state_change.name
  target_id = "sqs"
  arn       = aws_sqs_queue.karpenter_interruption.arn
}

resource "aws_ses_email_identity" "sender" {
  email = var.from_email
}

resource "aws_ses_template" "admin_notification" {
  name    = "AdminCleanupNotification"
  subject = "Action Required: IAM User Cleanup for {{username}}"
  html    = <<EOF
<html>
<body>
<p>The IAM user <strong>{{username}}</strong> has expired.</p>
<p>Please choose an action:</p>
<ul>
  <li><a href="{{disable_url}}">Disable User</a></li>
  <li><a href="{{delete_url}}">Delete User</a></li>
</ul>
<p>This link expires in 24 hours.</p>
</body>
</html>
EOF

  text    = <<EOF
Action Required: IAM User Cleanup for {{username}}

The IAM user {{username}} has expired.

Choose an action:
1. Disable User: {{disable_url}}
2. Delete User: {{delete_url}}

This link expires in 24 hours.
EOF

  tags = {
    internship = "true"
  }
}
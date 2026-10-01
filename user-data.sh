#!/bin/bash

dnf update -y
dnf install -y httpd

systemctl start httpd
systemctl enable httpd

cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>ALB Auto Scaling Demo</title>
</head>
<body>

<h1>🚀 Scalable Web Application</h1>
<h2>Amazon EC2 + ALB + Auto Scaling</h2>

<p>Web Server is running successfully!</p>

<p><b>Hostname:</b> $(hostname)</p>
<p><b>Instance ID:</b> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>

</body>
</html>
EOF
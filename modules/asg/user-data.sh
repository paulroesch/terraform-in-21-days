#!/bin/bash

yum update -y
yum install -y httpd git mysql
echo "hello world $(hostname)" > /var/www/html/index.html
systemctl start httpd && systemctl enable httpd

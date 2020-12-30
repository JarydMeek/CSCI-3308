#!/bin/bash
# Authors : Jaryd Meek
# Date: 09/18/2020

cp /var/log/syslog/ /home/administrator/
grep -i "error" /home/administrator/syslog | tee error_log_check.txt
mpack -s “ERRORLOG” /home/administrator/error_log_check.txt jaryd.meek@colorado.edu


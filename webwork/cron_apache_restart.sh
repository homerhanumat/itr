# Script to gracefully restart apache if system mory falls below 0.5G.
# Store in /usr/local/sbin/ and then run sudo crontab -e
# to edit crontab file, perhaps:
# 0,15,30,45 * * * *  /bin/bash /usr/local/sbin/cron_apache_restart.sh

totalk=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)
if [ $totalk < 500000 ]; then
  apachectl graceful
fi
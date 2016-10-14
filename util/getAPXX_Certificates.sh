OLDHOST=$(hostname)

for i in `seq -w 1 12`; do
   A=ap${i}
   echo "==========================="
   echo "changing DynDNS for \"$A\""
   hostname $A
   /root/dyndns.sh
done

sleep 65

for i in `seq -w 1 12`; do
   A=ap${i}
   echo "==========================="
   echo "getting cert for \"$A\""
   hostname $A
   ./letsencrypt-auto certonly --webroot -w /var/www/html -d ${A}.my.to --register-unsafely-without-email
done

hostname $OLDHOST


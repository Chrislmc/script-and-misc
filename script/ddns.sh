#!/bin/bash
CF_TOKEN={{cloudflare_token}}
ZONE_ID={{cloudflare_zone_id}}
RECORD_ID={{a_record_id}}
WWW_RECORD_ID={{www_a_record_id}}
RECORD_NAME={{domain-name}}
WWW_RECORD_NAME={{www_a_record_name}}

INTERNET_IP=`curl -s http://ipv4.icanhazip.com`
#INTERFACE_IP=`ip address show ppp0 | grep ppp0 | grep global | awk '{print$2}'`

# Get the DNS Record from cloudflare
DNS_RECORD_IP=`curl -s \
  --request GET \
  --url https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?name=${RECORD_NAME} \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer ${CF_TOKEN}" | \
  jq -r ".result[0].content"`

if [ "$INTERNET_IP" != "$DNS_RECORD_IP" ]
then
  echo "Renew IP: ${DNS_RECORD_IP} to ${INTERNET_IP}"
  curl -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
    -H "Authorization: Bearer ${CF_TOKEN}" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'${RECORD_NAME}'","content":"'${INTERNET_IP}'","ttl":120,"proxied":false}'

  echo "Renew IP WWW: ${DNS_RECORD_IP} to ${INTERNET_IP}"
  curl -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${WWW_RECORD_ID}" \
    -H "Authorization: Bearer ${CF_TOKEN}" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'${WWW_RECORD_NAME}'","content":"'${INTERNET_IP}'","ttl":120,"proxied":false}'
else
  echo "No change: ${INTERNET_IP}"
fi
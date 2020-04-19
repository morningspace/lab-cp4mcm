# Task 1 - Step 2: Launch and configure Secure Gateway Client from localhost

Instructions
============

Please refer to below link to learn details on how to configure Secure Gateway using your IBM Cloud account:
https://cloud.ibm.com/docs/services/SecureGateway?topic=securegateway-getting-started-with-sg&locale=en#getting-started-with-sg

In general, you may need to:

1) Launch Secure Gateway Client if not exists
2) Config Secure Gateway ACL for hub cluster

---

## Launch Secure Gateway Client

On the "Secure Gateway Dashboard" page, click the gateway that we created, click the Clients tab, then click
the Connect Client button. On the dialog, copy the Gateway ID and Security Token that will be used to launch
the Secure Gateway Client

Let's save the Gateway ID and Security Token...

<!--
var::set "Gateway ID" "GATEWAY_ID"
var::set "Security Token" "GATEWAY_SECURITY_TOKEN"
var::save "GATEWAY_ID"
var::save "GATEWAY_SECURITY_TOKEN"
-->

Then, launch the client using the above Gateway ID and Security Token:

```shell
docker run -d -p 9003:9003 ibmcom/secure-gateway-client $gateway_id -t $GATEWAY_SECURITY_TOKEN
```

## Config Secure Gateway ACL for hub cluster

Secure Gateway Client has a dashboard which can be used to manage connections. We will use this dashboard to
config ACL for our hub cluster. Go to: http://127.0.0.1:9003 in web browser, click the "Access Control List"
button, in the "Allow access" section, input:

1) Resource Hostname: `hostname`
2) Port: 8443

Then click the plus icon. It allows the hub cluster deployed in your local network to be accessible from the
internet.

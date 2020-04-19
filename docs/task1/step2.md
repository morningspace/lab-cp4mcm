# Task 1 - Step 2: Launch and configure Secure Gateway Client from localhost

Instructions
============

Please refer to below link to learn details on how to configure Secure Gateway using your IBM Cloud account:
https://cloud.ibm.com/docs/services/SecureGateway?topic=securegateway-getting-started-with-sg&locale=en#getting-started-with-sg

In general, you may need to:

1) [Launch Secure Gateway Client if not exists](step2.1.md)
2) [Config Secure Gateway ACL for hub cluster](step2.2.md)

---

## To launch Secure Gateway Client...

On the "Secure Gateway Dashboard" page, click the gateway that we created, click the Clients tab, then click
the Connect Client button. On the dialog, copy the Gateway ID and Security Token that will be used to launch
the Secure Gateway Client

## To config Secure Gateway ACL for hub cluster...

Secure Gateway Client has a dashboard which can be used to manage connections. We will use this dashboard to
config ACL for our hub cluster. Go to: http://127.0.0.1:9003 in web browser, click the "Access Control List"
button, in the "Allow access" section, input:

1) Resource Hostname: `hostname`
2) Port: 8443

Then click the plus icon. It allows the hub cluster deployed in your local network to be accessible from the
internet.

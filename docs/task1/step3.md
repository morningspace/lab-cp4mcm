# Task 1 - Step 3: Configure and test API server host and port on hub cluster

Instructions
============

After you expose your hub cluster to the internet, the default API server host and port on hub cluster need
to be updated accordingly to reflect the change.

You may need to:

1) Find the public hostname and port for your hub cluster from IBM Cloud Secure Gateway
2) Test API server connectivity using public hostname and port
3) Update the hostname and port for your hub cluster

---

## Find the public hostname and port for your hub cluster from IBM Cloud Secure Gateway

On the "Secure Gateway Dashboard" page, click the gateway that you have created, then click the gear icon of
the destination. On the popup dialog, copy the value of "Cloud Host : Port" field for later use.

## Test API server connectivity using public hostname and port

Save the public hostname and port into $HOSTNAME_AND_PORT...

<!--
var::set-required "The public hostname and port" "HOSTNAME_AND_PORT"
var::save "HOSTNAME_AND_PORT"
-->

Before update the hostname and port for your hub cluster, let's check the current API server host and port...

<!--
get-apiserver
-->

You can test the API server connectivity using the current hostname and port:

```shell
curl -kL https://${HOSTNAME}:8443
echo
```

You can also test the API server connectivity using the public hostname and port:

```shell
curl -kL https://${HOSTNAME_AND_PORT}
echo
```

## Update the hostname and port for your hub cluster

Now, let's update the API server host and port...

<!--
set-apiserver ${HOSTNAME_AND_PORT}
-->

The current API server host and port will been changed...

<!--
get-apiserver
-->

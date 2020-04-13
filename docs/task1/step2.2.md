# To config Secure Gateway ACL for hub cluster...

  Secure Gateway Client has a dashboard which can be used to manage connections. We will use this dashboard to
  config ACL for our hub cluster. Go to: http://127.0.0.1:9003 in web browser, click the "Access Control List"
  button, in the "Allow access" section, input:

  1) Resource Hostname: `hostname`
  2) Port: 8443

  Then click the plus icon. It allows the hub cluster deployed in your local network to be accessible from the
  internet.

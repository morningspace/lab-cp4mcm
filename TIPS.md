# Lab Specific Tips

Here are some tips that are specific to this lab and can help you run this lab more efficiently.

## UI shortcuts

To explore CP4MCM UI, you can open the web browser by double clicking the Firefox icon on desktop, then find
a bookmark called "IBM Cloud Pak for Multicloud Management" on Bookmarks Bar. Click the bookmark to open the
login page, use credential `admin/Passw0rd!` to login CP4MCM. Note: you may need to click the bookmark again
after login in order to bring you to the CP4MCM welcome page.

There is also another bookmark for you to access the dashboard of IBM Cloud Secure Gateway Client, which can
be used to manage connections between local network and internet. The bookmark is called "Secure Gateway Client".

## Time consuming task

When you run [Task 2: Manage a cluster provisioned by AWS EKS](docs/task2/), usually it will take a bit long time to finish
the cluster provision process on AWS. After you finish kicking off the provision, you can go to run the next
task [Task 3: Manage a cluster provisioned by kind](docs/task3/), then go back and check the provision progress on AWS from
time to time until it is finished.

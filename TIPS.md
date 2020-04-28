# Lab Specific Tips

Here are some tips that are specific to this lab and can help you run this lab more efficiently.

## UI shortcuts

To explore CP4MCM UI, you can open the web browser by double clicking the Firefox icon on desktop, then find
a bookmark called "IBM Cloud Pak for Multicloud Management" on Bookmarks Bar. Click the bookmark to open the
login page, use credential `admin/Passw0rd!` to login CP4MCM. Note: you may need to click the bookmark again
after login in order to bring you to the CP4MCM welcome page.

## Time consuming task

When you run [Task 2: Manage a cluster provisioned by AWS EKS](docs/task2/), usually it will take a bit long time to finish
the cluster provision process on AWS. After you finish kicking off the provision, you can go to run the next
task [Task 3: Manage a cluster provisioned by kind](docs/task3/), then go back and check the provision progress on AWS from
time to time until it is finished.

## Define your lab profile

This lab may be used by multiple people simultaneously. Each person has his or her own lab config which can be
found at $HOME/.labs-magic directory by running below command:

```
ls -1 ~/.labs-magic/*.config
/home/morningspace/.labs-magic/alice.config
/home/morningspace/.labs-magic/bob.config
/home/morningspace/.labs-magic/default.config
```

To avoid conflict with other people's lab config, please define your own by specifying an environment variable 
called $LAB_PROFILE. e.g. morningspace, then you will see a new config file called morningspace.config created
under $HOME/.labs-magic directory when you launch the lab for the next time.

```
export LAB_PROFILE=morningspace
```

Note: When you define $LAB_PROFILE, please check $HOME/.labs-magic directory first, to make sure the value you
choose is not used by others.

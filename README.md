# IBM Cloud Pak for Multicloud Management: All-in-One Playground to Manage Your Hybrid Cloud

## Introduction

This lab will walk you through the steps to use IBM Cloud Pak for Multicloud Management (CP4MCM) to manage a
local cluster which is provisioned using kind and a remote cluster which is provisioned using AWS EKS, then
deploy a sample application from hub cluster to the two managed clusters. This gives you a better view of how
CP4MCM can manage clusters and applications in a hybrid environment easily.

The lab also demonstrates the way to use IBM Cloud Secure Gateway to establish connections between hub cluster
deployed in private network and managed cluster deployed on internet. See [lab instructions](docs/) for more details.

![Figure: The Lab Architecture](images/lab-architecture.png)

## How to Run This Lab

Use credential `ibmuser/passw0rd` to login the lab envirnoment, then double click the Terminal icon on desktop
to open a terminal. You can maximize the terminal window to get better visualization experience.

In the terminal, go into the lab root directory and update the lab content to the latest version:
```
cd $HOME/lab-cp4mcm
git pull
```

Then, you can run different commands to launch the lab as needed. For example, To view the lab main page:
```
./lab.sh
```

To list all available tasks and steps with their states, titles and ids:
```
./lab.sh -l
```

To start a particular task by specifying a task id:
```
./lab.sh task0
```

It will run all the steps included in this task one after another. You can also start a particular step in a
task by specifying both a task id and a step id:
```
./lab.sh task0 step1
```

By default, tasks or steps will run interactively, which means it will stop at each step so that you can read
instructions line by line, run specific commands, then check results carefully. Also, most tasks or steps can
be run repeatedly. So, if you want to revisit some tasks or steps to better understand them, you can run them
many times.

On the other hand, you can also run tasks or steps automatically when needed. This is useful if you have gone
through the task or step content already and just want to rerun it to apply whatever changes made by the task
or step. This can be done by adding option `-g` when run the task or step:
```
./lab.sh task0 -g
```

## Lab Specific Tips

Here are some tips that are specific to this lab:

To explore CP4MCM UI, you can open the web browser by double clicking the Firefox icon on desktop, then find
a bookmark called "IBM Cloud Pak for Multicloud Management" on Bookmarks Bar. Click the bookmark to open the
login page, use credential `admin/Passw0rd!` to login CP4MCM. Note: you may need to click the bookmark again
after login in order to bring you to the CP4MCM welcome page.

When you run [Task 2: Manage a cluster provisioned by AWS EKS](task2/), usually it will take a bit long time to finish
the cluster provision process on AWS. After you finish kicking off the provision, you can go to run the next
task [Task 3: Manage a cluster provisioned by kind](task3/), then go back and check the provision progress on AWS from
time to time until it is finished.

# How to Run This Lab

## Lab environment

Use credential `ibmuser/passw0rd` to login the lab envirnoment, then double click the Terminal icon on desktop
to open a terminal. You can maximize the terminal window to get better visualization experience.

In the terminal, go into the lab root directory and update the lab content to the latest version:

```
cd $HOME/lab-cp4mcm
git pull
```

## Run the lab

You can run different commands to launch the lab as needed. For example, To view the lab main page:

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

## Run interactively or automatically

By default, tasks or steps will run interactively, which means it will stop at each step so that you can read
instructions line by line, run specific commands, then check results carefully. To move to the next step, you
can press ENTER key.

Most tasks or steps can be run repeatedly. As a result, if you want to revisit those tasks or steps to better
understand them, you can run them many times.

On the other hand, you can also run tasks or steps automatically when needed. This is useful if you have gone
through the task or step content already and just want to rerun it to apply whatever changes made by the task
or step. This can be done by adding option `-n` without waiting for user key press when run the task or step:

```
./lab.sh task0 -n
```

# How to Run This Lab

## Lab environment

Use credential `ibmuser/passw0rd` to login the lab envirnoment, then double click the Terminal icon on desktop
to open a terminal. You can maximize the terminal window to get better visualization experience.

In the terminal, go into the lab root directory and update the lab content to the latest version:

```
cd $HOME/lab-cp4mcm
git pull
```

## Run lab task and step

You can run different commands to launch the lab as needed. For example, To view the lab main page:

```
./lab.sh
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

## User input during lab run

During the lab runs, sometimes it may need user inputs to control how the lab goes. For example, to ask what
the cluster name is before launch a cluster as below:

```
Input cluster name(my-cluster-eks-18): 
```

Along with the prompt text, there could be a default value appeared in the brackets after the prompt text if
it has default value. You can input whatever value as you wish or press Enter key to use the default one.

## Track lab progress

To list all available tasks and steps with their states, titles and ids:

```
./lab.sh -l
```

Here is a sample output:

```
[✓] Task 1 - Step 1: Install required software [task1 step1]
[?] Task 1 - Step 2: Wait for system up and running [task1 step2]

[✓] Task 2 - Step 1: Configure application [task2 step1]
 ➞  Task 2 - Step 2: Launch application [task2 step2]
[ ] Task 2 - Step 3: Clean up [task2 step3]
```

By checking the list, you will be able to know:

* The current step that you are working on (marked with '[➞]')
* The tasks and steps that are completed (marked with '[✓]')
* The tasks and steps that are stopped unexpectedly for some reason (marked with '[?]')
* The tasks and steps that are not started yet. (marked with '[ ]')

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
./lab.sh -n task0
./lab.sh -n task0 step1
```

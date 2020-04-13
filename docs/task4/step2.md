# Task 4 - Step 2: Define and apply a channel

  Instructions
  ============

  Channel is a custom resource that can help you streamline deployments and separate cluster access. It defines
  namespace on hub cluster and point to physical place where resources are stored for deployment.
  
  There're a few types of channels. In this lab, we will use Namespace channel to monitor a specified namespace
  which is used to maintain custom resources called Deployables. Deployables added or updated in this namespace
  will be promoted to managed clusters through the channel.

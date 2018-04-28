# automation-201

Welcome to the Automation 201 Challenge Lab

## Getting Started

The purpose of this Challenge Lab is to test your knowledge and programmatic skillset utilizing a language of your choice.  The provided Docker container runs a REST Server for use during this lab.    The implementation of this lab is at your discretion but must meet the requirements stated below.

The instructions below will get you started on understanding what is required to complete this Challenge Lab but also define how you will need to setup your environment.

### Measured Outcomes

-   Docker containerization
-   REST API interaction
    -   Auth (NOT IMPLEMENTED YET)
    -   GET, POST, PUT, etc
-   JSON
-   Control structures
-   Boolean / Conditional logic
-   Variables / Data Types
-   Data Structures
-   Basic Error Handling (try / catch)
-   Functions
-   Classes / Modules
-   Logging
-   Read / write from file (CSV, txt, etc)
-   Comments
-   Git

### Prerequisites

-   Docker, <https://www.docker.com/community-edition>, Further details below
-   IDE of your choice (or not if you live dangerously)
-   WWT GitHub Account (Service Now Request)
-   Python / PowerShell / etc

Docker is a key component for this lab.  It is used to run the REST Server locally on your machine. Additionally, since the container runs a web server, it must have IP connectivity.  The Docker engine is built upon the Linux kernel, those running Linux distributions will have a slightly different experience than Windows users.  

### Windows Users

As explained earlier, the Docker engine is based on the Linux Kernel.  Therefore, Windows users must have both hardware virtualization enabled and virtualization software.  Windows 10 includes Hyper-V feature which will be enabled during the Docker installation process.  This process WILL cause other clients to not function properly.  If your machine has another virtualization clients installed, it is suggested to utilize Docker inside a Linux VM running locally and run through above steps to setup server.

Please refer to Docker documentation if proceeding to install Docker locally: <https://docs.docker.com/docker-for-windows/install/#download-docker-for-windows>

Running Docker natively on Windows is possible but not explained in detail here.  In order to continue with the steps below, you will need to ensure you have properly setup the docker-machine, it has received an IP, and no firewall is between where you develop and the container (or you explicitly open the port)

### Docker setup

-   Download [Dockerfile](Dockerfile), [db.json](db.json) and [run.sh](run.sh) to a directory on your machine.
-   Build container: Execute the following command while in the directory you placed the files from the previous step (You can change image name if you like)
```
docker build -t wwt-auto/rest-svr:latest .
```
-   Run container: You can change the forwarded port but must keep port 80 as it is exposed in container
```
docker run -it -p 3000:80 wwt-auto/rest-svr:latest
```
-   Verify connectivity by navigating to <http://localhost:3000> (Or whatever port you choose when running container).

_Note, the above command will open the docker container within the shell.  Use CTRL-C to exit the docker container when done.  If the shell is closed before closing the docker process, run_

```
docker ps
```
or
```
docker container ls
```
_To obtain the Docker ID or Name.  Copy the docker ID or Name if it is still running, and issue:_
```
docker stop [ID/CONTAINER]
```

Alternatively, you can launch the container as follows:
```
docker run -d -p 3000:80 wwt-auto/rest-svr:latest
```
Which will "detach" the container from your shell.  Essentially, the docker container will run in the background.  If you do this, then to stop the container you will need to run docker ps (or docker container ls) to get the ID, then stop the process with docker stop (ID or NAME) as stated above.

You can also specify the -it option (for interactive and psuedo tty) if you need to get into the container itself.

**_FOR MORE INFORMATION, PLEASE READ ASSIGNMENT 8 FOR COMMON DOCKER COMMANDS ASSOCIATED WITH DOCKER RUN, OR RUN DOCKER'S CLI HELP FOR A COMPLETE LISTING_**

## Lab Guide

Your mission, should you choose to accept it, is to read in the contents of a CSV file (data.csv) and meet the requirements below.  There are no formatting requirements for the log file, but it should be self explanatory and contain useful information about what is being printed.  All data contained in the CSV file is dummy data and has no representation on any network.

### Requirements
-   Main script module shall accept two (2) parameters: CSV File location and REST Server URL
-   A help message should be printed on demand or if the required parameters are not present
-   Your solution shall include minimum of 3 distinct modules
    1.  Main processing module
    2.  CSV Module (which reads in and processes CSV file into data structures)
    3.  Logging Module
-   CSV file must be pulled directly down from the Repo programmatically
-   A Logging Module shall be created which creates a log file called ‘output.txt’ and appends messages to it for use in the Main module.
-   CSV Processing
    1.  Determine how many devices from CSV file are missing from REST Server.
    2.  Print the missing device IP addresses in log file for future reference.
    3.  Store list of missing devices (all data) in memory for future use.
-   JSON Processing
    1.  Create a JSON file that only contains IPv4 address and hostname from the data.csv file.
    2.  Generate a random alphanumeric sequence after the hostname that makes the total length of the hostname field (16) sixteen characters long.
    3.  Include a dash (-) between the existing hostname and the random sequence.  
-   Log count of devices broken out by Vendor.  Format output as appropriate.
-   Print count of devices that have MAC addresses that contain 'E1' and are of Vendor type of Juniper, Cisco, or F5.
-   Log count of devices whose hostname contains 3 or 5 characters.
-   Add (POST) devices that were found missing from REST Server.  This can be achieved through accessing the values that should have previously been stored in memory.
-   Log Script start time and end time
-   Script does not encounter runtime (unhandled errors)

**Upon completion, store your code in your personal WWT GitHub account

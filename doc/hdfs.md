---
Data Platform Documentation"
---
Services
1.  Hadoop HDFS, version: 3.3.6

2.  Hadoop YARN, version: 3.3.6

3.  Spark, version: 3

# **Hadoop**

## **HDFS**

![Architecture image](architecture.png)

### **Mode**

**High-Availability**: two or more NameNodes are grouped into a **nameservice** (*myhacluster*).

-   One active namenode per time.

-   Only active namenode manages requests.

-   Stand-by namenodes stay updated thanks to JournalNodes

-   Every action performed by *active* namenode is logged throughjournals.

-   Periodically, [JournalNodes]{.underline} synch with themselves and with namenodes to grant consistency and integrity.

-   Each component data is persisted through a NFS. Each component has its own directory inside NFS.

-   [**High-availability is resolved client-side. Configuration must be shared between NameNodes, JournalNodes and HDFS clients**. Two default ways (we're using RequestHedgingProvider) of communicating with a nameservice. For this and a basic HDFS-HA setup, take a look at the [[official doc]](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithQJM.html)

### **Configuration**

Configuration properties define the cluster setup, how services find and interact with each other and [how clients can communicate with the hadoop cluster]{.underline}.
Configuration can be passed to HDFS services (using apache/hadoop docker image) in two ways.

#### **Configuration file**

It's a simple *.conf* file which will be parsed into environmental variables in the container and then parsed into hdfs properties. Such file should have the following syntax:

> *CORE-SITE.XML_hadoop.http.staticuser.user=root*

where the "\_" and "=" are split characters ([an thus only one occurrence of each should appear in the property string]{.underline}) and the first part refers to the Hadoop property file this property belongs to (core-site.xml), the middle parte refers to the property name (hadoop.http.staticuser.user) and the third part of the split refers to the value of such property (root). Such .conf file needs to be passed as *env_file* inside the docker stack file.

#### **Property files**

HDFS configuration depends on multiple files, most importantly:

-   **core-site.xml**
Contains properties that help communication with/between hadoop services, e.g.
> *CORE-SITE.XML_fs.defaultFS=hdfs://myhacluster.*

An example of core-site.xml with a description of each possible variable can be found in the [[official template]](https://hadoop.apache.org/docs/r2.8.0/hadoop-project-dist/hadoop-common/core-default.xml)



-   **hdfs-site.xml**
Contains the configuration of the HDFS High-Availability cluster, common properties that help communication with/between hadoop services and settings for the HDFS website.
An example of hdfs-site.xml with a description of each possible variable can be found in the [[official
template]](https://hadoop.apache.org/docs/r2.4.1/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml)

-   **capacity-scheduler.xml**
Contains properties related to YARN and resource allocation. An example of hdfs-site.xml with a description of each possible variable can be found in the [[official doc]](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/CapacityScheduler.html)

-   **yarn-site.xml**
 Contains properties related to YARN and resource allocation and the configuration for YARN websites (ResourceManager, NodeManager  HistoryServer). An example of hdfs-site.xml with a description of each possible variable can be found in the [[official template]](https://hadoop.apache.org/docs/r2.7.3/hadoop-yarn/hadoop-yarn-common/yarn-default.xml)**.**
Other "minor" property files:

-   **hadoop-policy.xml**
-   **hadoop-env.sh**
	Can define variable that will be translated into environmental variables when the hadoop service is started ([you won't see these variables on container setup!)]{.underline}

-   **hdfs-rbf-site.xml**

-   **httpfs-site.xml**

-   **kms-acls.xml**

-   **kms-site.xml**

-   **log4j.properties**
     Defines properties about service logs

-   **mapred-env.sh**

-   **mapred-site.xml**

**Property files must be passed to the container and placed inside the \$HADOOP_CONF_DIR folder**

### **Components**

#### **JournalNode**

They are a passive component. Must be in an odd number \> 3. They are responsible for logging every action the *active* namenode does and for keeping the state of the high-availability cluster always consistent. They NEED the same configuration passed to NameNodes and DataNodes since they will need to communicate between each-other. After
setup, they will be contacted by the two NameNodes (once their setup is completed) which will register to the JournalNodes, which will create the NameNode folder to store its logs and start the synching process. On cluster setup, they need to be formatted just as namenodes.

Three main params needed:

-   NameNodes address

-   Other journals address

-   Log directory path

Periodically, JournalNodes will synch with each-other to grant consistency between their logs. Every time the active namenode performs an action, it contacts (the primary or every one (?)) JournalNodes and log such action. Whenever a NameNode switches from *stand-by* state to *active* state, it contacts the journal nodes to assure its state is
consistent.
They don't expose interfaces to users.

#### **NameNode**

Active component. On first cluster setup, it needs to be formatted

>*hdfs \--config \${HADOOP_HOME}/etc/hadoop namenode -format ${CLUSTERNAME}*

If the NameNode you're starting is a stand-by node, it should be formatted and put to stand-by, e.g.

>*hdfs namenode -bootstrapStandby*

After formatting (if needed), namenodes must be started.
>*hdfs \--config \$HADOOPCONFDIR namenode*

it registers itself to the JournalNodes. Namenodes should be started after journal nodes are up and running. Namnodes expose two interfaces:

-   **rpc-address**
	 Contains the address to which clients should send RPCs. It can be defined in hdfs-site.xml. e.g.
	> *fs.namenode.rpc-address.myhacluster.nn2=namenode2:8020*
	
-   **service-rpc-address**
	 Contains the address to which services should send RPCs. It can be defined in hdfs-site.xml. e.g.
	> *fs.namenode.rpc-address.myhacluster.nn2=namenode2:8020*

-   **http-address**
	Contains the address in which the namenode will expose its web UI. It can be defined in hdfs-site.xml. e.g.
	> *fs.namenode.http-address.myhacluster.nn2=namenode2:9870*

Once both NameNodes have started, one of them can be elected **active** (if there isn't already an active namenode defined)**.** This can be done through:
>*hdfs haadmin -transitionToActive namenode1*

##### **Failovers policy**

There are two ways to handle a namenode failoves:

-   Manually: default mode, manually switch the active namenode, e.g.

      > *hdfs haadmin -transitionToActive namenode2*

-   Automatically: Apache ZooKeeper is required, see the related section in this doc.

#### **DataNode**

Doesn't need much setup if not for the same configuration passed to NameNodes and Journal Nodes. On setup, DataNodes **actively** contact the active NameNode and register themselves to it. It's not the other way around, namenodes don't need to know apriori who and where the data nodes are, they will know where they are once they register to them.

### **Communication**

Each service endpoints are defined and exposed through property files. *In Hadoop, each entity is also an HDFS client* which leverages property files to know where to find other services. [The resolution of which namenode is the active happens **client-side**. This means that if you want to add a container to the cluster and want to be able to interact with HDFS, not only should it have HDFS installed in it but it should contain the configuration of the HA cluster.

There are two ways of determining who is the active NameNode, and the preferred way can be specified inside hdfs-site.xml by specifying one of the two default methods:

-   **ConfiguredFailoverProxyProvider**: There is knowledge somewhere (usually implemented through ZooKeper) about which is the currently active namenode. See the related section.

-   **RequestHedgingProxyProvider**: for the first call, concurrently invokes all namenodes to determine the active one, and on subsequent requests, invokes the active namenode until a fail-over happens.

### **Setup Requirements**

-   On first-cluster-startup, there's a strict order to follow: JournalNodes -> Active NN -> Passive NN

## YARN

# SPARK

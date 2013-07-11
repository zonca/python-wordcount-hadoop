#!/bin/bash
#PBS -q normal
#PBS -N hadoop_job
#PBS -l nodes=2:ppn=1
#PBS -l walltime=0:10:00
#PBS -o hadoop_run.out
#PBS -e hadoop_run.err
#PBS -m abe
#PBS -V
#PBS -v Catalina_maxhops=2

# Set this to location of myHadoop on Gordon or Trestles 
export MY_HADOOP_HOME="/opt/hadoop/contrib/myHadoop"

# Set this to the location of Hadoop on Gordon or Trestles
export HADOOP_HOME="/opt/hadoop"

#### Set this to the directory where Hadoop configs should be generated
# Don't change the name of this variable (HADOOP_CONF_DIR) as it is
# required by Hadoop - all config files will be picked up from here
#
# Make sure that this is accessible to all nodes
export HADOOP_CONF_DIR="/home/$USER/p/hadoop/config"

#### Set up the configuration
# Make sure number of nodes is the same as what you have requested from PBS
# usage: $MY_HADOOP_HOME/bin/configure.sh -h
echo "Set up the configurations for myHadoop"

### Create a hadoop hosts file, change to ibnet0 interfaces - DO NOT REMOVE -
sed 's/$/.ibnet0/' $PBS_NODEFILE > $PBS_O_WORKDIR/hadoophosts.txt
export PBS_NODEFILEZ=$PBS_O_WORKDIR/hadoophosts.txt

### Copy over configuration files
$MY_HADOOP_HOME/bin/configure.sh -n 2 -c $HADOOP_CONF_DIR

### Point hadoop temporary files to local scratch - DO NOT REMOVE -

sed -i 's@HADDTEMP@'$PBS_JOBID'@g' $HADOOP_CONF_DIR/hadoop-env.sh
echo

#### Format HDFS, if this is the first time or not a persistent instance
echo "Format HDFS"
$HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR namenode -format
echo
sleep 1m
#### Start the Hadoop cluster
echo "Start all Hadoop daemons"
$HADOOP_HOME/bin/start-all.sh
#$HADOOP_HOME/bin/hadoop dfsadmin -safemode leave
echo

#### Run your jobs here
echo "Run some test Hadoop jobs"
$HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR dfs -mkdir Test
sleep 30s
$HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR dfs -copyFromLocal /home/$USER/p/hadoop/python_streaming/gutemberg/* Test
$HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR dfs -ls Test
$HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR jar $HADOOP_HOME/contrib/streaming/hadoop*streaming*.jar -file /home/$USER/p/hadoop/python_streaming/mapper.py -mapper /home/$USER/p/hadoop/python_streaming/mapper.py -file /home/$USER/p/hadoop/python_streaming/reducer.py -reducer /home/$USER/p/hadoop/python_streaming/reducer.py -input /user/$USER/Test/* -output /user/$USER/Test-Output
echo "Copying output locally"
$HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR dfs -ls Test-Output
$HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR dfs -copyToLocal Test-Output/* /home/$USER/p/hadoop/python_streaming/gutemberg-output/
sleep 30s
echo

#### Stop the Hadoop cluster
echo "Stop all Hadoop daemons"
$HADOOP_HOME/bin/stop-all.sh
echo

#### Clean up the working directories after job completion
echo "Clean up"
$MY_HADOOP_HOME/bin/cleanup.sh -n 2
echo

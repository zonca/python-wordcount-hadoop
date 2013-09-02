hadoop python test
==================

Python simple wordcount test based on:

http://www.michael-noll.com/tutorials/writing-an-hadoop-mapreduce-program-in-python/

and configured to run on Gordon (HPC Cluster at the San Diego Supercomputing Center):

http://www.sdsc.edu/us/resources/gordon/gordon_hadoop.html

It uses the Hadoop streaming interface to send input and get outputs from the Python mapper and reducer.
HDFS is setup on the local SSD flash drives on the computing nodes, output is then copied back to local space.

How to run:

* clone the repository in your home folder
* grab the input files by running `download-inputs.sh` in the `gutemberg` folder
* run: `qsub run.sh`

Run on Amazon Elastic Map Reduce with MrJob
-------------------------------------------

See the mrjob/ folder, more details on:

http://www.andreazonca.com/2013/09/run-hadoop-python-jobs-on-amazon-with-mrjob.html

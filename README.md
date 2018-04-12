# Realest Data

In order to facilitate the modernization of Realest Estate Crop., we present this project: Realest Data, a modern data platform built ontop of Spark and Jupyter.

## Platform

The platform is composed of two main components, a set of ETL jobs and a set of analytics notebooks.

### Extract
* Spark is used for the heavy lifting, performing extracting and transformations on data.


### Explore
* Juypter is used to enable the more technically-savvy to get their hands dirty with the data, either from the raw logs or from a database, in a reproducible and shareabe manner utilizing PySpark as an interface to Spark and Seaborn for visualization.


## Setup

### Setup

To work on or setup Realest Data, install the following tools according to their respective websites:
* [Scala & SBT](https://www.scala-lang.org/)
* [Spark](https://spark.apache.org/)
* [Python 3.6](https://www.python.org/)


There may be some other things that require installaton to get everything working on your own machine, some googling will resolve the majority of these issues, however if that doesn't work. Feel free to create an issue so that this installation guide can be made more universal.


You can check if you have all the tools with:

```bash
$ make check
```

### Explore Setup

First we need to install the python dependencies, preferably within a [virtualenv](https://virtualenv.pypa.io/en/stable/).

```bash
$ make setup_pyspark
```

For more information about [Seaborn](https://seaborn.pydata.org/) and [Jupyter](http://jupyter.org/)

NOTE: In order to export Notebooks to PDFs, you'll need to install pandoc and TeX as detailed [here](http://nbconvert.readthedocs.io/en/latest/install.html)


## Use

### Extract

`jobs` is a SBT project that contains Spark applications written in Scala which operate on some data somewhere and saves the results of those tranformations on that data in another place.

Submitting a job is as easy as exporting the Master node to send to job to and using `submit_job` specifying the job (package.class format) you want to submit.

For example to submit the TestJob to a local cluster (after setting one up of course with `make start_local`):

```bash
$ export SPARK_MASTER=spark://$(hostname):7077
$ make submit_job job=com.realest_estate.TestJob
```

Remember to teardown the cluser if you're done using it with `make kill_local`


### Explore

`notebooks` is the place to hold Juypter notebooks, providing an easy, yet powerful environment for manipulating data at any level in an ad-hoc, yet documentable, fashion. Investigations, prototypes, and research can all be performed in Python on top of PySpark and Seaborn. More languages and frameworks can be supported in the future.

Run `which python` and ensure that it's pointing to the python with the dependencies you need. If it *isn't*:

```bash
$ export PYSPARK_PYTHON=<path_to_python_exe>
```

To run a notebook server in a Spark cluser:
```bash
$ # export the url of the master node to `SPARK_MASTER`
$ export SPARK_MASTER=spark://<master_hostname>:<master_port>
$ make pyspark
```


## Testing

### Jobs

Once everything is installed, to start a local cluster, run a test job, and verify your local setup:


```bash
$ make test_local
```

NOTE: If this is your first time with sbt or spark, this might take a little while as sbt has to download the right versions of itself, Scala, and the project's dependencies. Also, for building the local cluster and tearing it down you may be asked for your password to connect locally to ssh.


### Notebooks

If a Spark cluster *isn't* running, you can do so locally with `make start_local`. EExport the location of the Master node to `SPARK_MASTER` and run the Jupyter notebook

```bash
$ export SPARK_MASTER=spark://<master_hostname>:<master_port>
$ make pyspark
```

A Jupyter notebook will open in your browser, opened to the `notebooks` folder. Select the `Test` notebook and run it. If everything is cool, no error will be thrown, and you can go about your day.


## Example

In `fixtures/` you'll find a CSV file called `daily_properties`. This is the training data of the [Housing Prices Kaggle Challenge](https://www.kaggle.com/c/house-prices-advanced-regression-techniques). In this example, we'll run a job to transform this Data into something that we'll use in a notebook.

First setup according to the steps listed above, including the section about "Explore". Once everything is configured, start a local cluser:

```bash
$ make start_local
```

Once, the cluster is up, check out its status at `http://localhost:8080/`.
You should have one worker and a Master node at port 7077 on your local machine.

Run the `TranformDailyProperties` job:

```bash
$ make submit_job job=com.realest_estate.TransformDailyProperties
```

Once that completes, if everything when well, the following command shouldn't error:

```bash
$ cat fixtures/transformed_daily_properties.csv/_SUCCESS
```

Start the Jupyter notebook server with:

```bash
$ make pyspark
```

Check out the `Questions Investigation` notebook, this has a bunch of different answers to a variety of questions about the data; run it and you should see how you're able to read from the data returned by the job and perform queries on it.

Once your done, do you computer a favor a teardown the cluster.

```bash
$ make kill_local
```


## TODO

Right now, while this system is uncoupled and organized, the lack of structure makes it rather haphazard to uses the pieces in conjunction, due to implicit timing dependencies and inferred schemas. Moreover, the platform is currently without a concrete database layer which will make informal analysis by non-technical users difficult.

Some various things that can be done to productionize this platform:
* Provision and orchestrate a Spark cluster using Terraform and Kubernetes
* Provision and configure a Jenkins service to be able to structure pipelines from jobs with Terraform, Ansible, and Docker
* Establish a schema registry so that jobs and databases can work in sync with different data shapes.
* Design codepaths to provision and/or configure Databases to be populated by Lambda functions that run when jobs deposit their results in S3.
* Adjust SBT so that only the job being submitted (and it's dep) get packaged

This is only some of the possible directions this project can go, it really depends on the business needs.

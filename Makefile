SPARK_HOME ?=/opt/spark-2.3.0-bin-hadoop2.7
LOCAL_SPARK_MASTER = spark://$(shell hostname):7077
SPARK_MASTER ?= $(LOCAL_SPARK_MASTER)
PYSPARK_PYTHON ?= $(shell which python)
PYSPARK_JUPYTER ?= $(shell which jupyter)
JOBS_DIR ?= ./jobs
NOTEBOOKS_DIR ?= ./notebooks
.DEFAULT_GOAL := help

.PHONY: help package_jobs start_local kill_local shell shell_local submit_test test_local submit_job setup_pyspark pyspark


check:  # Check installation of Realest Data dependencies
	scala -version
	sbt sbtVersion
	$(SPARK_HOME)/bin/spark-submit --version


package_jobs:  ## Package jobs
	cd $(JOBS_DIR) && sbt package


start_local:  ## Starts local cluster
	$(SPARK_HOME)/sbin/start-master.sh
	sleep 2  ## Let's wait a sec for the master to start up.
	$(SPARK_HOME)/sbin/start-slave.sh $(LOCAL_SPARK_MASTER)


kill_local:  ## Kills local cluster
	$(SPARK_HOME)/sbin/stop-all.sh


shell:  ## Start a shell connected to $SPARK_MASTER
	$(SPARK_HOME)/bin/spark-shell $(SPARK_MASTER)


shell_local: kill_local package_jobs start_local  ## Connect to a local shell
	make shell
	make kill_local


submit_test:  ## Submits a test job
	make submit_job job=com.realest_estate.TestJob


test_local: kill_local package_jobs start_local submit_test kill_local ## Starts a local cluster and submits a test spark job to it


submit_job:  package_jobs ## Submits the job specified by the job args like `make sumbit_job job=<the_job>`
	$(SPARK_HOME)/bin/spark-submit --class $(job) --master $(SPARK_MASTER) jobs/target/scala-2.11/jobs_2.11-0.1.0.jar


setup_pyspark: # Setup Jupyter
	pip install -r notebooks/requirements.txt
	python -m ipykernel install --user

pyspark:  # Start a Jupyter notebook connected to Spark
	cd $(NOTEBOOKS_DIR) && \
	PYSPARK_PYTHON=$(PYSPARK_PYTHON) \
	MASTER=$(SPARK_MASTER) \
	PYSPARK_DRIVER_PYTHON=$(PYSPARK_JUPYTER) \
	PYSPARK_DRIVER_PYTHON_OPTS='notebook' \
	$(SPARK_HOME)/bin/pyspark

help:/
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

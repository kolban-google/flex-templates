#!/bin/bash

export PROJECT_ID="kolban-dataflow5"
#export PROJECT_ID="test1-305123"

export BUCKET="gs://kolban-dataflow5-tmp/temp"
#export BUCKET="gs://kolban-tmp/temp"

#export RUNNER="DirectRunner"
export RUNNER="DataflowRunner"
mvn compile exec:java -Dexec.args="--project=${PROJECT_ID} \
 --inputText=Greetings \
 --runner=${RUNNER} \
 --region=us-central1 \
 --serviceAccount=worker@${PROJECT_ID}.iam.gserviceaccount.com \
 --network=myvpc \
 --gcpTempLocation=${BUCKET}"
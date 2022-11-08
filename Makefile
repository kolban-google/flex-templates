PROJECT_ID=kolban-dataflow7
BUCKET_NAME=kolban-dataflow7-tmp
REGION=us-central1
REPOSITORY=myrepo
VPC_NAME=myvpc
WORKER_SERVICE_ACCOUNT=worker@$(PROJECT_ID).iam.gserviceaccount.com
JAR=target/myapp-1.0.jar
all:
	@echo "services - Setup the services for the project"
	@echo "build-code"
	@echo "build-flex"
	@echo "run-flex"
	@echo "build-docker"
	@echo "build-flex-manual"
	@echo "run-flex-manual"
	@echo "show-job"

services:
	gcloud services enable artifactregistry.googleapis.com \
		cloudbuild.googleapis.com \
		compute.googleapis.com \
		dataflow.googleapis.com \
		--project=$(PROJECT_ID)

build-code:
	mvn clean package

build-flex:
	gcloud dataflow flex-template build gs://$(BUCKET_NAME)/dataflow/flextemplate1.json \
		--image-gcr-path=$(REGION)-docker.pkg.dev/$(PROJECT_ID)/$(REPOSITORY)/dataflow/myapp:latest \
    	--sdk-language=JAVA \
    	--flex-template-base-image=JAVA11 \
    	--jar=$(JAR) \
    	--metadata-file=metadata.json \
    	--env FLEX_TEMPLATE_JAVA_MAIN_CLASS=com.example.App \
    	--service-account-email=$(WORKER_SERVICE_ACCOUNT) \
    	--network=$(VPC_NAME) \
    	--project $(PROJECT_ID)

run-flex:
	gcloud dataflow flex-template run "example-app-$(shell date +%Y%m%d-%H%M%S)" \
		--project=$(PROJECT_ID) \
    	--template-file-gcs-location=gs://$(BUCKET_NAME)/dataflow/flextemplate1.json \
		--region=$(REGION)

build-docker:
	tar -cvzf all.tgz Dockerfile target/myapp-1.0.jar
	gcloud builds submit all.tgz \
		--project=$(PROJECT_ID) \
		--region=$(REGION) \
		--tag=$(REGION)-docker.pkg.dev/$(PROJECT_ID)/$(REPOSITORY)/dataflow/manual-myapp

build-flex-manual:
	gcloud dataflow flex-template build gs://$(BUCKET_NAME)/dataflow/flextemplate-manual.json \
		--image=$(REGION)-docker.pkg.dev/$(PROJECT_ID)/$(REPOSITORY)/dataflow/manual-myapp:latest \
    	--sdk-language=JAVA \
    	--metadata-file=metadata.json \
    	--service-account-email=$(WORKER_SERVICE_ACCOUNT) \
    	--network=$(VPC_NAME) \
    	--project $(PROJECT_ID)

run-flex-manual:
	gcloud dataflow flex-template run "example-app-$(shell date +%Y%m%d-%H%M%S)" \
		--project=$(PROJECT_ID) \
    	--template-file-gcs-location=gs://$(BUCKET_NAME)/dataflow/flextemplate-manual.json \
		--region=$(REGION)

list-jobs:
	gcloud dataflow jobs list --project=$(PROJECT_ID) --region=$(REGION)

describe-job:
	gcloud dataflow jobs describe 2022-11-08_08_01_10-5446430905305015812 --project=$(PROJECT_ID) --region=$(REGION) --format=json --full

show-job:
	gcloud dataflow jobs show 2022-11-08_08_01_10-5446430905305015812 --project=$(PROJECT_ID) --region=$(REGION) --format=json
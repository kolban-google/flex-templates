PROJECT_ID=kolban-dataflow6
BUCKET_NAME=kolban-dataflow6-tmp
REGION=us-central1
REPOSITORY=myrepo
VPC_NAME=myvpc
WORKER_SERVICE_ACCOUNT=worker@$(PROJECT_ID).iam.gserviceaccount.com
JAR=target/myapp-1.0.jar
all:
	echo "Hi!"

services:
	gcloud services enable artifactregistry.googleapis.com \
		cloudbuild.googleapis.com \
		compute.googleapis.com \
		dataflow.googleapis.com

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

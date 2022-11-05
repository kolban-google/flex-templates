PROJECT_ID=kolban-dataflow5
BUCKET_NAME=kolban-dataflow5-tmp
REGION=us-central1
REPOSITORY=myrepo
VPC_NAME=myvpc
WORKER_SERVICE_ACCOUNT=worker@$(PROJECT_ID).iam.gserviceaccount.com
JAR=target/myapp-1.0.jar
all:
	echo "Hi!"

build-code:
	mvn clean package

build-flex:
	gcloud dataflow flex-template build gs://$(BUCKET_NAME)/dataflow/flextemplate1.json \
    --image-gcr-path=$(REGION)-docker.pkg.dev/$(PROJECT_ID)/$(REPOSITORY)/dataflow/mytest:latest \
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
	  --region=$(REGION) \

run_direct:
	java -cp target/xyz-1.0.jar com.example.App \
		--runner=DataflowRunner \
		--project=$(PROJECT_ID) \
		--region=$(REGION) \
		--tempLocation=gs://$(BUCKET_NAME)/temp/ \
		--jobName="mytest-$(shell date +%Y%m%d-%H%M%S)"	 \
		--serviceAccount="worker@$(PROJECT_ID).iam.gserviceaccount.com" \
		--disable-public-ips \
		--subnetwork=https://www.googleapis.com/compute/v1/projects/$(VPC_HOST_PROJECT_ID)/regions/us-central1/subnetworks/mysubnet
	
df-run:
	mvn compile exec:java -Dexec.args="--project=${PROJECT_ID} \
 		--inputText=Greetings \
 		--runner=${RUNNER} \
 		--region=us-central1 \
 		--serviceAccount=worker@${PROJECT_ID}.iam.gserviceaccount.com \
 		--gcpTempLocation=${BUCKET_NAME}"
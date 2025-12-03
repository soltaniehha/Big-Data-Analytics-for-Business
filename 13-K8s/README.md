Primary k8s app contributor: Barrett Ratzlaff (MSBA 2026)
 
The following document states all adjustments needed to run the files in this repo on your own:

01-Chat-Completion-API.ipynb
-------------------------------
This notebook works on Google Colab. You'll need an OpenAI API key. Store the API key in your Google Colab Environment as a secret/key.

02-Run-an-LLM-Locally.ipynb
-------------------------------
This notebook works on Google Colab. You'll need a HuggingFace token that can read the Llama model in the file, or whatever model you wish if you hope to customize.  Store the token in your Google Colab Environment as a secret/key.

app.py
-------------------------------
This file requires the source of the flight summary .csv which is already attached in the docker image.

job.yaml
-------------------------------
It requires the source of the docker repo on line 16. Use the naming convention listed in the file to create the app repo on Cloud Shell to avoid trouble.

Deployment
-------------------------------
We will deploy this on Cloud Shell. Once these files all exist in your Cloud Shell (excluding the .ipynb files), use the following commands in Cloud Shell to build it yourself:

(The below assumes all necessary APIs are enabled and the user is on the desired project)

### 1. Create a new Docker Artifact Registry repository for storing LLM container images:
```
gcloud artifacts repositories create llm-app-repo --repository-format=docker --location=us-central1 --description="LLM container images"
```

### 2. Configure Docker authentication so you can push/pull images from that Artifact Registry endpoint:
```
gcloud auth configure-docker us-central1-docker.pkg.dev
```

### 3. Create a K8S cluster called `flight-llm-cluster`:
```
gcloud container clusters create flight-llm-cluster --machine-type=n1-standard-4 --zone=us-central1-a --num-nodes=1 --workload-pool=PROJECT_ID_HERE.svc.id.goog
```

### 4. (Authenticate) Retrieve GKE cluster credentials and update kubeconfig to use it with kubectl:
```
gcloud container clusters get-credentials flight-llm-cluster --zone us-central1-a
```

### 5. Create a new Kubernetes secret to store your Hugging Face access token:
```
kubectl create secret generic huggingface-token --from-literal=token='YOUR_TOKEN_HERE'
```

### 6. Ensure you are in the project folder on cloud shell first, where your Dockerfile and app.py are accessible. The build your docker image:
```
docker build -t us-central1-docker.pkg.dev/PROJECT_ID_HERE/llm-app-repo/flight-analysis-local:v1 .
```

### 7. Push your local Docker image to the Artifact Registry repository:
```
docker push us-central1-docker.pkg.dev/PROJECT_ID_HERE/llm-app-repo/flight-analysis-local:v1
```

### 8. Create a new service account for the flight analysis application:
```
gcloud iam service-accounts create flight-analysis-sa --display-name="Flight Analysis Service Account"
```

### 9. Grant the service account permission to view objects in Cloud Storage:
```
gcloud projects add-iam-policy-binding PROJECT_ID_HERE --member="serviceAccount:flight-analysis-sa@PROJECT_ID_HERE.iam.gserviceaccount.com" --role="roles/storage.objectViewer"
```

### 10.Create a Kubernetes service account for the workload: 
```
kubectl create serviceaccount flight-analysis-sa
```

### 11. Allow the Kubernetes service account to impersonate the GCP service account via Workload Identity: 
```
gcloud iam service-accounts add-iam-policy-binding flight-analysis-sa@PROJECT_ID_HERE.iam.gserviceaccount.com --role roles/iam.workloadIdentityUser --member "serviceAccount:PROJECT_ID_HERE.svc.id.goog[default/flight-analysis-sa]"
```

### 12. Annotate the Kubernetes service account to link it to the GCP service account:
```
kubectl annotate serviceaccount flight-analysis-sa iam.gke.io/gcp-service-account=flight-analysis-sa@PROJECT_ID_HERE.iam.gserviceaccount.com
```

### 13. Deploy the Kubernetes job to your GKE cluster: 
```
kubectl apply -f job.yaml
```

### 14. Get the name of the pod running the flight-analysis-local-llm app:
```
POD_NAME=$(kubectl get pods -l app=flight-analysis-local-llm -o jsonpath='{.items[0].metadata.name}')
```

### 15. Stream the live logs from that pod:
```
kubectl logs -f $POD_NAME
```

The last two steps should help display the output of your Docker image in the terminal.

 ## Cleanup (Prevent Ongoing Costs)

When you are finished with this project, run the following commands in **Cloud Shell** to delete all resources that can incur charges:

### 1. Delete the GKE Cluster (largest cost)
```
gcloud container clusters delete flight-llm-cluster \
    --zone=us-central1-a
```

### 2. Delete the Artifact Registry Repository (stored container images)
```
gcloud artifacts repositories delete llm-app-repo \
    --location=us-central1
```

### 3. Delete the GCP Service Account
```
gcloud iam service-accounts delete \
    flight-analysis-sa@PROJECT_ID_HERE.iam.gserviceaccount.com
```
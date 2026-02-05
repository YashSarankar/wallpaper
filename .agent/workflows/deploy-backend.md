---
description: How to deploy the Node.js backend to Google Cloud Run
---

// turbo-all
1. Navigate to the backend directory:
   `cd backend`

2. Run the deployment command (using the stable europe-west1 region):
   `gcloud run deploy wallpaper-backend --source . --region europe-west1 --allow-unauthenticated --set-env-vars MONGO_URI="mongodb+srv://render_app:SuperSecret123!@cluster0.y16ylbl.mongodb.net/Application?retryWrites=true&w=majority",GCS_BUCKET_NAME="my-wallpaper-app-bucket",NODE_ENV="production"`

3. Verify the deployment:
   `curl.exe https://wallpaper-backend-917312759089.europe-west1.run.app/`

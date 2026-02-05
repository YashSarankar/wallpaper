# ☁️ Deploying Express Backend to Google Cloud Run

Your backend is now ready for Google Cloud Run. I have added a `Dockerfile` and `.dockerignore` to the `backend/` folder.

## 🚀 Deployment Steps (Using Google Cloud CLI)

If you have the `gcloud` CLI installed, run these commands from the `backend/` directory:

1.  **Configure gcloud:**
    ```bash
    gcloud config set project [YOUR_PROJECT_ID]
    ```

2.  **Deploy to Cloud Run:**
    ```bash
    gcloud run deploy wallpaper-backend --source . --region us-central1 --allow-unauthenticated
    ```
    *Cloud Run will automatically build the image using the Dockerfile and deploy it.*

---

## 🔑 Environment Variables (Important!)

Cloud Run does **not** read your `.env` file. You must set these variables in the **Google Cloud Console**:

1.  Go to **Cloud Run** in the Google Cloud Console.
2.  Select your service (`wallpaper-backend`).
3.  Go to **Edit & Deploy New Revision**.
4.  Under **Variables & Secrets**, add:
    *   `MONGO_URI`: `your_mongodb_connection_string`
    *   `GCS_BUCKET_NAME`: `your_backet_name`
    *   `ADMIN_PANEL_URL`: `your_live_admin_url` (if applicable)

---

## 🛡️ Google Cloud Storage (GCS) Configuration

Currently, your `.env` points to a local JSON key file for GCS. **For Cloud Run, you should not use a key file.**

**Do this instead:**
1.  In the Google Cloud Console, find the **Service Account** used by your Cloud Run service (usually `[project-number]-compute@developer.gserviceaccount.com`).
2.  Go to **IAM & Admin > IAM**.
3.  Add the role **Storage Object Admin** (or `Storage Admin`) to that service account.
4.  Cloud Run will then automatically authenticate with GCS without needing `GOOGLE_APPLICATION_CREDENTIALS`.

---

## 🛠️ Code Adjustments Checklist
*   [x] **Port:** The app already listens on `process.env.PORT`, which is required for Cloud Run.
*   [x] **Dockerfile:** Created and optimized for production.
*   [x] **Security:** `.dockerignore` prevents uploading your local `.env` or node_modules.

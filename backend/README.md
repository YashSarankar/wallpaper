# Backend Setup Instructions

## Prerequisites
1.  **Node.js** installed.
2.  **MongoDB** installed and running locally on port 27017.
3.  **Google Cloud Storage** bucket created.

## Installation
1.  Navigate to the `backend` directory:
    ```bash
    cd backend
    ```
2.  Install dependencies:
    ```bash
    npm install
    ```

## Configuration
1.  Open `.env` and update the following:
    -   `MONGO_URI`: Your MongoDB connection string.
    -   `GCS_BUCKET_NAME`: Your Google Cloud Storage bucket name.
    -   `GOOGLE_APPLICATION_CREDENTIALS`: Path to your GCS service account key JSON file.

    *Note: If you don't provide GCS credentials, the system will use a mock upload service.*

## Running the Server
-   Development:
    ```bash
    npm run dev
    ```
-   Production:
    ```bash
    npm start
    ```

## API Endpoints

### Get All Wallpapers
-   `GET /api/wallpapers`
-   Returns a list of all wallpapers.

### Get Wallpapers by Category
-   `GET /api/wallpapers/category/:category`
-   Returns wallpapers for the specified category.

### Add Wallpaper (Upload Image)
-   `POST /api/wallpapers`
-   Body (multipart/form-data):
    -   `title`: (String) Wallpaper title
    -   `category`: (String) Category (e.g., Nature, Space)
    -   `image`: (File) The image file to upload.
-   **Functionality**:
    -   Resizes the image into 3 versions:
        -   **Original**: High quality.
        -   **Mid**: Optimized for mobile screens (width 1080).
        -   **Low**: Thumbnail/low bandwidth (width 300).
    -   Uploads all 3 versions to GCS.
    -   Saves the URLs in MongoDB.

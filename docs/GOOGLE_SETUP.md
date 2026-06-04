# Google Cloud Setup Guide for AutoVSF

To use OCR, you need a Google Cloud project and a `credentials.json` file.

## Step 1: Create a Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/).
2. Sign in with your Google account.
3. Create a new project or select an existing one.

## Step 2: Enable Google Drive API
1. Search for **"Google Drive API"** in the top search bar.
2. Select the result and click **"Enable"**.

## Step 3: Create credentials.json
1. Go to **"APIs & Services"** > **"Credentials"**.
2. Click **"Create Credentials"** > **"OAuth client ID"**.
3. If prompted, **"Configure Consent Screen"**:
    - Choose **External**.
    - Fill in required fields (App name, Support email).
4. Back on the OAuth client ID page:
    - **Application type**: **Desktop app**.
    - **Name**: e.g. `AutoVSF-OCR`.
    - Click **Create**.
5. Click **"Download JSON"** in the dialog.
6. Rename the file to `credentials.json` and place it in the project root (next to `main.py`).

## Step 4: Publish the App (Important)
To allow the browser login flow without "App not verified" errors:
1. In [Google Cloud Console](https://console.cloud.google.com/), go to **"APIs & Services"** > **"Audience"**.
2. Under **"Publishing status"**, click **"PUBLISH APP"** and confirm.
3. This changes status from "Testing" to "In production", ensuring a smooth first-time login (`token.json` creation).

---
*Back to [main guide](../README.md)*

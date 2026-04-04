# ZUG: Evaluation Instructions 🛡️

Follow these steps to launch the ZUG Insurance Engine and verify the integration between the **Mobile SDK**, **AI Backend**, and the **Live Supabase Database**.

---

## 1. Start the AI Backend (Python/FastAPI)
The backend calculates risk scores and dynamic premiums based on live weather and traffic data.

1.  **Open Terminal** and navigate to the project root.
2.  **Activate Virtual Environment**:
    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```
3.  **Install Dependencies**:
    ```bash
    pip install -r backend/requirements.txt
    ```
4.  **Run the Server**:
    ```bash
    python3 backend/main.py
    ```
    *Wait for: `Uvicorn running on http://0.0.0.0:8000`*

---

## 2. Connect the Mobile App (Flutter)

### Step A: Configure Environment
The app is designed to connect to the **ZUG Production Database**. Ensure your `.env` file exists in the root directory with the provided credentials:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-public-key
```

### Step B: Device Connection (CRITICAL for Physical Devices)
If you are evaluating on a physical phone (like the Pixel 7a):
1.  Find your Mac's IP address: `ipconfig getifaddr en0`.
2.  Open `lib/services/api_service.dart`.
3.  Update the `_macIp` constant with your Mac's IP (e.g., `10.210.29.152`).

### Step C: Run the App
```bash
flutter pub get
flutter run
```

---

## 3. Database Architecture (Supabase)
The system uses a highly optimized PostgreSQL schema already configured on our live instance. Key highlights for evaluation:

*   **Partitioning**: The `claims` table is partitioned by month (e.g., `claims_2024_10`) to handle high-volume event data.
*   **PostGIS**: The `zones` table uses spatial geometry for geofencing disruptions.
*   **Security**: Row-Level Security (RLS) is active across all tables to isolate worker data.
*   **Telemetry Storage**: The `claim_evidence` table stores 10-minute JSON snapshots of raw sensor data for AI audit.

---

## 4. Evaluation Scenarios to Test

### Scenario 1: Secure Modular Login
1.  Enter any **e-Shram ID** and **Phone Number**.
2.  Use Mock OTP: `123456`.
3.  **Biometric Confirmation**: Provide fingerprint access to bind your hardware ID to the account.

### Scenario 2: Dynamic Pricing (Python AI Integration)
*   Observe the **"Live Status"** card on the dashboard. It fetches real-time risk scores from the Python FastAPI server.
*   The **"Next week premium"** is calculated dynamically by the backend (Capped at ₹50).

### Scenario 3: 10-Minute Telemetry Sync (Anti-Fraud)
1.  Tap **Valid Claim** or **Fraud Claim**.
2.  The app immediately creates a Claim record in the database.
3.  **Background Sync**: The SDK captures data for 5 minutes *after* the tap.
4.  After 5 minutes, it bundles the full **10-minute snapshot** and syncs it to the `claim_evidence` table.

---
**Technical Stack**: Flutter (Mobile SDK), FastAPI (AI/ML Backend), Supabase (PostgreSQL/PostGIS/Partitioning).

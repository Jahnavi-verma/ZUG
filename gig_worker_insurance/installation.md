Installation & Local Setup
1. Prerequisites
Python 3.10 or higher (Recommended: 3.11)

pip (Python package manager)

Git

Internet connection (for external APIs)

2. Clone the Repository
git clone https://github.com/Jahnavi-verma/ZUG
cd gig_worker_insurance
3. Create Virtual Environment
Windows (PowerShell)
python -m venv .venv
.venv\Scripts\activate
Mac/Linux
python3 -m venv .venv
source .venv/bin/activate
4. Install Dependencies
pip install -r requirements.txt
5. Environment Variables Setup
Create a .env file in the root directory:

OPENWEATHER_API_KEY=your_api_key_here
CITY=Bangalore
Ensure the API key is valid and activated.

6. Run the Backend Server
uvicorn backend.main:app --reload
7. Access the Application
API Base URL:
http://127.0.0.1:8000

Swagger Documentation:
http://127.0.0.1:8000/docs

8. Testing the API
Open Swagger UI

Use endpoint: POST /predict-risk

Click "Try it out" → Execute

Expected output includes:

Risk score

Premium

Trigger alerts

Fraud detection

Detailed breakdown

9. Common Issues
Invalid API Key
Error: 401 Unauthorized

Fix: Verify .env file and API key activation

Module Not Found Errors
Ensure virtual environment is activated

Reinstall dependencies:

pip install -r requirements.txt
Port Already in Use
uvicorn backend.main:app --reload --port 8001
Slow or Failed API Calls
Check internet connection

Ensure external APIs are accessible

10. Notes
RTO data is loaded from:
backend/data/rto_data.csv

ML model file:
backend/ml/model.pkl

Backend depends on live API responses for weather data
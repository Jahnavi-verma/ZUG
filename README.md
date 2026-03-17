# ZUG
## Zero-risk Universal Gig-cover

---

### **1. Core Requirement: "The Income Safety Net"**

The application must provide a digital insurance/protection layer that automatically compensates delivery partners for "lost earning opportunities" caused by external operational failures (app crashes, warehouse delays, or customer rejections), while using high-integrity biometric and sensor data to prevent fraudulent claims.

---

### **2. Persona-Based Scenarios**

##### Our MVP

#### **Persona A: Kirto (The "Customer not available")**

* **Role:** A delivery partner for a e-commerce brand (e.g., Amazon)
* **The Problem:** Kirto reaches the destination, the customer does not accept the parcel or the customer is not availabe. This results in Kirto carrying the parcel back to warehouse. For this return journey Kirto may only be paid once (many associated companies do not pay even once). But if multiple trips are made back and fourth, Kirto does not get any compensation, her status is reduced and she losses her wages and incentives.
* **The Application Scenario:** The app detects multiple failed deliveries to the same destination, it then calcultes total compensations and losses and files for insurance. Hence bridging the gap bettween her wages.

#### **Persona B: Arjun (The "Hardworking Hustler")**

* **Role:** Last-mile delivery partner for a high-volume e-commerce brand (e.g., DHL or Amazon).
* **The Problem:** Arjun reaches the warehouse at 8:00 AM, but the sorting system is down. He sits idle for 3 hours. Because he is paid "per successful delivery," he has earned ₹0 for the morning and will now miss his "Daily 20-Delivery Bonus."
* **The Application Scenario:** The app detects his GPS location at the warehouse and cross-references the logistics partner's "System Down" status. It automatically logs a "Warehouse Delay" event and calculates his average hourly earning rate to provide a bridge payment, saving his daily income.

#### **Persona C: Sarah (The "SLA Victim")**

* **Role:** Premium delivery partner with "Gold Tier" status.
* **The Problem:** Sarah has 5 packages left. A sudden app outage prevents her from closing her deliveries before the 8:00 PM SLA deadline. The system marks her as "Late," dropping her to "Silver Tier" for the next week, which reduces her per-package pay by 15%.
* **The Application Scenario:** The app records the "App Outage" period. When the connection restores, it "Shields" Sarah’s Tier status by compensating the amount that she has lost in her wages. This enables Sarah to have stable life.

#### **Persona D: "The Ghost" (The Fraudster)**

* **Role:** A user trying to exploit the income protection.
* **The Problem:** This user leaves their phone at a known "high traffic" zone to claim "Traffic Congestion Delay" payments while they are actually at home.
* **The Application Scenario:** The **Anti-Spoof Shield** triggers. It detects that the phone's **Accelerometer and Gyroscope** are perfectly still (no engine vibration or walking motion), while the **Liveness Check** fails because no face is present. The claim is automatically denied and flagged for the "Manager Web App."

---

### **3. Operational Workflow**

The workflow operates in a loop of **Monitor → Detect → Shield → Resolve.**

#### **Step 1: Active Monitoring (The Bridge)**

* The application runs in the background while the delivery partner is on shift.
* It tracks three data streams: **Telemetry** (GPS/Speed), **Environment** (App Connectivity/Logistics API), and **Motion** (Sensors).

#### **Step 2: Trigger Event (The Income Gap)**

* An event occurs: A "Customer Rejected Delivery" or "Warehouse Delay."
* The system immediately creates a "Pending Incident" log.

#### **Step 3: Fraud Shield Verification (The Security Layer)**

Before any payout is authorized, the system runs the following checks:

1. **Liveness Verification:** Prompts for a quick biometric scan to ensure the correct partner is present.
2. **Sensor Fusion:** Analyzes if the GPS movement matches the physical vibrations of a moving vehicle (prevents GPS spoofing).
3. **Deduplication:** Checks if the partner is currently active on a competing app to prevent "Double Dipping" on income loss claims.

#### **Step 4: Payout & Documentation (The Resolution)**

* **Validation:** If the shields pass, the system calculates the "Income Protection Gap" (Difference between expected and actual earnings).
* **Reporting:** A summary is sent to the **Manager Web App** dashboard.
* **Disbursement:** The micro-compensation is credited to the partner's digital wallet.

#### **Step 5: Audit (The Command Center)**

* The Manager reviews the "Evidence Management" folder, which contains the photos, location logs, and sensor data from the incident to ensure the system is making accurate decisions.

---

### **1. Weekly Premium & Parametric Model**

#### **The Weekly Premium Model**

* **The "Micro-Premium" Approach:** Instead of large upfront costs, the model uses a weekly "Subscription for Protection" deducted automatically from the partner’s earnings.
* **Dynamic Risk Rating:** The premium is not fixed; it adjusts weekly based on the partner’s "Safe Driver" score and "Fraud Integrity" rating. High integrity (never triggering "Anti-Spoof" shields) results in lower weekly premiums.
* **Collaborative Funding:** The cost is split three ways: a small percentage from the **Partner** (security), a contribution from the **Logistics Company** (SLA insurance), and a platform fee from the **E-commerce Brand** (retention).

#### **Parametric Triggers (Automatic Payouts)**

Unlike traditional insurance that requires a manual claim, this system uses **Parametric Triggers**—if a specific data threshold is met, the payout is automatic:

* **Trigger A: "Systemic Latency":** If the Logistics Partner’s API reports a "Server Down" status for >30 minutes while the partner's GPS is within 500m of a warehouse.
* **Trigger B: "Verified Rejection":** If a customer rejects a "Pay on Delivery" package, and the app records the partner remained at the delivery coordinate for >5 minutes (proving the attempt was made).
* **Trigger C: "Unplanned Congestion":** If real-time traffic data (Google Maps/Mapbox API) shows "Deep Red" congestion on the assigned route, increasing travel time by >50% beyond the SLA window.

---

### **2. Platform Choice: Why Mobile-First?**

While a **Web App** is used for the **Manager's "Command Center"** (to review high-level data and manage investigators), the core application for the partners **must be Mobile-based** for the following justifications:

* **Sensor Access:** To run the **Anti-Spoof Shield**, the app requires direct hardware access to the Accelerometer, Gyroscope, and Magnetometer—sensors rarely available or accurate via a web browser.
* **Biometric Integrity:** Mobile OS (iOS/Android) provides secure enclaves for the **"Anti-Ghost" Shield** (FaceID/Fingerprint) which are more secure than web-based camera prompts.
* **Persistent Telemetry:** The "Bridge" needs to maintain a persistent background socket to track movement even when the phone screen is off—a task browsers often kill to save memory.

---

### **3. AI/ML Workflow Integration**

#### **Premium Calculation (Predictive Risk)**

* **ML Model:** Uses **XGBoost** or similar regression models to analyze historical "Income Loss" events.
* **Goal:** It predicts which delivery zones or times of day are "High Risk" (e.g., Friday evenings in monsoon season) and adjusts premiums in real-time to ensure the insurance pool remains solvent.

#### **Fraud Detection (The "Shields")**

* **Anomaly Detection:** ML identifies "Non-Human" movement patterns. If GPS coordinates jump in a way that defies physics or if sensor vibrations don't match a vehicle's engine RPM, the **Anti-Spoof Shield** flags it.
* **Computer Vision:** For the **Anti-Ghost Shield**, on-device ML (TensorFlow Lite) performs "Liveness Detection" to ensure a static photo or video isn't being held up to the camera during a verification check.

---

### **4. Tech Stack & Development Plan**

#### **The Architecture**
![Architecture](https://github.com/Jahnavi-verma/ZUG/blob/main/505a516b-efe3-47f6-946c-16fc6bf7b012.png)
#### **The "Anti-Fraud" Tech Stack**

* **Frontend (Mobile):** **Flutter or React Native** (for cross-platform deployment) with native modules for high-speed sensor data polling.
* **Backend:** **Node.js/Go** for the high-concurrency "Bridge" that handles millions of telemetry pings.
* **Database:** **PostgreSQL** (with PostGIS for location data) and **Redis** for real-time trigger monitoring.
* **AI Layer:** **Python (FastAPI)** serving models trained on historical delivery and fraud data.
---
### **5. Development Plan**

1. **Phase 1 (The Bridge):** Build the core GPS and sensor logging infrastructure to establish a "Truth Baseline" for delivery partners.
2. **Phase 2 (The Shields):** Deploy the **Anti-Ghost** and **Anti-Spoof** ML models to the mobile app to secure the data stream.
3. **Phase 3 (The Payout Engine):** Integrate with Logistics APIs to automate the **Parametric Triggers** and start the Weekly Premium pilot.
4. **Phase 4 (Manager Hub):** Launch the **Web Command Center** for audit trails and investigation management.

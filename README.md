# ZUG
<img src="https://github.com/Jahnavi-verma/ZUG/blob/main/WhatsApp%20Image%202026-03-18%20at%2012.42.59%20PM.jpeg" width="100" height="100">

## Zero-risk Universal Gig-cover

---

### **1. Core Requirement: "The Income Safety Net"**

The application must provide a digital insurance/protection layer that automatically compensates delivery partners for "lost earning opportunities" caused by external operational failures (app crashes, warehouse delays, or customer rejections), while using high-integrity biometric and sensor data to prevent fraudulent claims.

---

### **2. Persona-Based Scenarios**

##### RTO is our MVP use case for a broader income protection system. Future triggers:
- rain disruption
- low demand zones
- traffic delays

We provide parametric insurance for gig workers against excess Return-To-Origin (RTO) trips by modeling zone-level RTO risk using platform data. Workers experiencing abnormal RTO frequency are automatically compensated.

#### **Persona A: Kirto (The "Customer not available")**

* **Role:** A delivery partner for a e-commerce brand (e.g., Amazon)
* **The Problem:** Kirto reaches the destination, the customer does not accept the parcel or the customer is not available. This results in Kirto carrying the parcel back to warehouse. For this return journey, Kirto may only be paid once (many associated companies do not pay even once). But if multiple trips are made back and fourth, Kirto does not get any compensation, her tier status is reduced and she losses her wages and incentives.

* **The Application Scenario:** The app detects multiple failed deliveries to the same destination, it then calculates total compensations and losses and files for insurance. Hence bridging the gap between her wages.

#### **Persona B: Arjun (The "Hardworking Hustler")**

* **Role:** Last-mile delivery partner for a high-volume e-commerce brand (e.g., Flipkart or Amazon).
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
Step 1: Calculate zone RTO risk
Step 2: Estimate expected excess RTO
Step 3: Convert to expected loss
Step 4: Apply margin → weekly premium

* **The "Micro-Premium" Approach:** Instead of large upfront costs, the model uses a weekly "Subscription for Protection" deducted automatically from the partner’s earnings.
Dynamic Premium Logic
Total Risk = RTO Risk + Weather Risk
* **Dynamic Risk Rating:** The premium is not fixed; it adjusts weekly based on the partner’s "Safe Driver" score and "Fraud Integrity" rating. High integrity (never triggering "Anti-Spoof" shields) results in lower weekly premiums.
RTO Risk Score = f(
  zone_rto_rate,
  COD_percentage,
  time_of_day,
  historical failures
)
RTO Risk + Weather Risk + Traffic Risk -> Risk SCore->Premium Band

* **Collaborative Funding:** The cost is split three ways: a small percentage from the **Partner** (security), a contribution from the **Logistics Company** (SLA insurance), and a platform fee from the **E-commerce Brand** (retention).
 Collaborative Funding Model
Stakeholder
Contribution
 Worker
50%
 Platform
30%
 E-commerce Brand
20%
• Worker pays a small, affordable amount
• Platform benefits from worker retention & reliability
• Customer contributes micro-amount (~₹0.10/order) without friction
Flow
1. Compute Zone RTO Rate based on:
  * historical RTO rate per zone
  * time of day
  * payment mode (COD vs prepaid)
  * customer reliability
2. Predict excess RTO probability
3. Fetch weather forecast (rain probability)
4. Estimate Expected Loss:

   RTO Loss = excess RTO × ₹10
   Weather Loss = ₹250/day × rain probability
(₹10 is MVP placeholder; model scales payout based on distance/time)
5. Premium = Expected Loss × margin (capped ₹40–₹50 as
Avg RTO risk per week = 5 trips
Payout per RTO = ₹10
Expected loss = ₹50
Premium = ₹40–₹50 (with margin))
#### **Parametric Triggers (Automatic Payouts)**

Unlike traditional insurance that requires a manual claim, this system uses **Parametric Triggers**—if a specific data threshold is met, the payout is automatic:

* **Trigger A: "Systemic Latency":** If the Logistics Partner’s API reports a "Server Down" status for >30 minutes while the partner's GPS is within 500m of a warehouse.
* **Trigger B: "Verified Rejection":** If a customer rejects a "Pay on Delivery" package, and the app records the partner remained at the delivery coordinate for >5 minutes (proving the attempt was made).
Trigger = Worker RTO count > zone average + threshold
This can be predicted using simulated platform API.
* **Trigger C: "Unplanned Congestion":** If real-time traffic data (Google Maps/Mapbox API)or weather data(heatwave/rainfall>60 mm) shows "Deep Red" congestion on the assigned route, increasing travel time by >50% beyond the SLA window.
We model a gig worker earning ₹750/day with an average net income of ₹625. Based on real-world disruptions like rain and traffic, we estimate a weekly income loss of ₹1000+. Using this, we compute a dynamic weekly premium (₹20–₹50) and trigger instant payouts (₹100–₹200) using parametric conditions such as rainfall intensity and traffic congestion.

---

### **2. Platform Choice: Why Mobile-First?**

While a **Web App** is used for the **Manager's "Command Center"** (to review high-level data and manage investigators), the core application for the partners **must be Mobile-based** for the following justifications:
* **User accessibility:** Drivers need low-interaction based platform for easy onboarding and ease of use without taking much of their attention and time. 
* **Sensor Access:** To run the **Anti-Spoof Shield**, the app requires direct hardware access to the Accelerometer, Gyroscope, and Magnetometer—sensors rarely available or accurate via a web browser.
* **Biometric Integrity:** Mobile OS (iOS/Android) provides secure enclaves for the **"Anti-Ghost" Shield** (FaceID/Fingerprint) which are more secure than web-based camera prompts.
* **Persistent Telemetry:** The "Bridge" needs to maintain a persistent background socket to track movement even when the phone screen is off—a task browsers often kill to save memory.

---

### **3.Complete workflow and AI/ML Integration**

#### **End-to-end workflow**
Login → Fetch zone data → Calculate risk → Show premium → Track RTO → Trigger payout
#### **Premium Calculation (Predictive Risk)**

* **ML Model:** Uses **XGBoost** or similar regression models to analyze historical "Income Loss" events.
* **Goal:** It predicts which delivery zones or times of day are "High Risk" (e.g., Friday evenings in monsoon season) and adjusts premiums in real-time to ensure the insurance pool remains solvent.

#### **Fraud Detection (The "Shields")**

* **Anomaly Detection:** ML identifies "Non-Human" movement patterns. If GPS coordinates jump in a way that defies physics or if sensor vibrations don't match a vehicle's engine RPM, the **Anti-Spoof Shield** flags it.
* **RTO mocking:** Uses platform API data (not self-reported) and compares with zone average to detect anomalies. If a sudden spike or repeated same area failures are observed, user is flagged.

---

### **4. Tech Stack & Development Plan**

#### **The Architecture**
![Architecture](https://github.com/Jahnavi-verma/ZUG/blob/main/505a516b-efe3-47f6-946c-16fc6bf7b012.png)
#### **The "Anti-Fraud" Tech Stack**

* **Frontend (Mobile):** **Flutter ** (for cross-platform deployment) with native modules for high-speed sensor data polling.
* **Backend:** **Node.js/Go** for the high-concurrency "Bridge" that handles millions of telemetry pings.
* **Database:** **PostgreSQL** (with PostGIS for location data) and **Redis** for real-time trigger monitoring.
* **AI Layer:** **Python (FastAPI)** serving models trained on historical delivery and fraud data.
---
### **5. Development Plan**

1. **Phase 1 (The Bridge):** Build the core GPS and sensor logging infrastructure to establish a "Truth Baseline" for delivery partners.
2. **Phase 2 (The Shields):** Deploy the **Anti-Ghost** and **Anti-Spoof** ML models to the mobile app to secure the data stream.
3. **Phase 3 (The Payout Engine):** Integrate with Logistics APIs to automate the **Parametric Triggers** and start the Weekly Premium pilot.
4. **Phase 4 (Manager Hub):** Launch the **Web Command Center** for audit trails and investigation management.
   
Summary

We model Return-To-Origin (RTO) as a measurable financial risk for gig workers, where each RTO results in an estimated ₹30 loss due to fuel and opportunity cost. Using simulated platform API data, we compute zone-level average RTO rates and dynamically assess worker risk. Insurance coverage is triggered only when a worker’s RTO count exceeds the expected baseline, ensuring fairness and preventing misuse. Workers receive ₹10–₹15 per excess RTO, while paying a capped weekly premium of ₹40–₹50, collaboratively funded by the worker, platform, and customers. This enables affordable, real-time, and automated protection against operational inefficiencies.

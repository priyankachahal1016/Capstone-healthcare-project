CREATE DATABASE Hospital_db;
USE Hospital_db;

-- SQL tables: patients, visits, and billing with appropriate data types
-- Patientd table:
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    age INT,
    gender VARCHAR(10),
    city VARCHAR(50),
    insurance_provider VARCHAR(50),
    chronic_flag INT,
    registration_date DATE
);
-- Visits table:
CREATE TABLE visits (
    visit_id INT PRIMARY KEY,
    patient_id INT,
    visit_date DATE,
    department VARCHAR(50),
    visit_type VARCHAR(20),
    length_of_stay_hours DECIMAL(10,2),
    risk_score VARCHAR(20),
    doctor_id INT,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);
-- Billing table:
CREATE TABLE billing (
    bill_id INT PRIMARY KEY,
    visit_id INT,
    billed_amount DECIMAL(10,2),
    approved_amount DECIMAL(10,2),
    claim_status VARCHAR(20),
    payment_days INT,
    billing_date DATE,
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
);

-- LOAD CSV DATA by feeding the data directly into tables 

/* The database is designed using a relational structure:

The patients table uses patient_id as the primary key to uniquely identify each patient.
The visits table uses visit_id as the primary key and references patient_id as a foreign key, linking each visit to a patient.
The billing table uses bill_id as the primary key and references visit_id as a foreign key, linking billing records to visits.*/

-- Create indexes

CREATE INDEX idx_visit_date ON visits(visit_date);
CREATE INDEX idx_department ON visits(department);
CREATE INDEX idx_insurance ON patients(insurance_provider);
CREATE INDEX idx_claim_status ON billing(claim_status);

/* Indexes were created on frequently queried columns to improve query performance:

visit_date index helps in time-based filtering and trend analysis queries.
department index improves performance of grouping and aggregation queries such as identifying top departments.
insurance_provider index speeds up financial analysis queries involving grouping by provider.
claim_status index optimizes queries related to claim approval and rejection analysis.*/

-- OPERATIONAL ANALYSIS QUERIES
-- Top 10 departments by visits

SELECT department, COUNT(*) AS total_visits
FROM visits
GROUP BY department
ORDER BY total_visits DESC
LIMIT 10;

-- top 5 departments with the highest average length of stay.

SELECT department, AVG(length_of_stay_hours) AS avg_stay
FROM visits
GROUP BY department
ORDER BY avg_stay DESC
LIMIT 5;

--  percentage of High Risk visits per department

SELECT 
    department,
    SUM(CASE WHEN risk_score = 'High' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS high_risk_percentage
FROM visits
GROUP BY department;

-- average number of visits per patient by city. 

SELECT city, AVG(visit_count) AS avg_visits
FROM (
    SELECT p.patient_id, p.city, COUNT(v.visit_id) AS visit_count
    FROM patients p
    JOIN visits v ON p.patient_id = v.patient_id
    GROUP BY p.patient_id, p.city
) sub
GROUP BY city;

-- doctors handling the highest number of High Risk visits. 

SELECT doctor_id, COUNT(*) AS high_risk_cases
FROM visits
WHERE risk_score = 'High'
GROUP BY doctor_id
ORDER BY high_risk_cases DESC;

-- there were 101 doctors who handle high risk patients.

-- Financial Analysis 
-- top 10 insurance providers by total billed amount. 

SELECT p.insurance_provider, SUM(b.billed_amount) AS total_billed
FROM billing b
JOIN visits v ON b.visit_id = v.visit_id
JOIN patients p ON v.patient_id = p.patient_id
GROUP BY p.insurance_provider
ORDER BY total_billed DESC
LIMIT 10;


-- top 5 insurance providers with the highest claim rejection rate. 

SELECT 
    p.insurance_provider,
    SUM(CASE WHEN b.claim_status = 'Rejected' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS rejection_rate
FROM billing b
JOIN visits v ON b.visit_id = v.visit_id
JOIN patients p ON v.patient_id = p.patient_id
GROUP BY p.insurance_provider
ORDER BY rejection_rate DESC
LIMIT 5;

-- Avg Payment Delay by insurance provider

SELECT p.insurance_provider, AVG(payment_days) AS avg_delay
FROM billing b
JOIN visits v ON b.visit_id = v.visit_id
JOIN patients p ON v.patient_id = p.patient_id
GROUP BY p.insurance_provider; 

-- revenue realization ratio (approved_amount / billed_amount) by department

SELECT 
    v.department,
    SUM(b.approved_amount) / SUM(b.billed_amount) AS realization_ratio
FROM billing b
JOIN visits v ON b.visit_id = v.visit_id
GROUP BY v.department;

-- visits where billed_amount is high but approved_amount is zero or missing

SELECT *
FROM billing
WHERE billed_amount > 10000
AND (approved_amount = 0 OR approved_amount IS NULL);

-- There were 1000 rows whose billed amount is high 

-- Data Quality and Integrity Checks 
-- visits that do not have a corresponding billing record

SELECT v.*
FROM visits v
LEFT JOIN billing b ON v.visit_id = b.visit_id
WHERE b.visit_id IS NULL;

-- There were 1000 rows

--  billing records that do not have a corresponding visit. 

SELECT b.*
FROM billing b
LEFT JOIN visits v ON b.visit_id = v.visit_id
WHERE v.visit_id IS NULL;

-- There are zero rows who don't have corresponding visits.

--  patients with duplicate patient_id values. 

SELECT patient_id, COUNT(*)
FROM patients
GROUP BY patient_id
HAVING COUNT(*) > 1;

-- There are zero patients with duplicate id's 

--   missing or invalid length_of_stay_hours or payment_days. 

SELECT *
FROM visits
WHERE length_of_stay_hours IS NULL;

-- There are zero records where length of stay hour is null

SELECT *
FROM billing
WHERE payment_days IS NULL;

--  There are zero records where payment day is null

-- visits linked to patients with missing insurance provider information.

SELECT v.*, p.insurance_provider
FROM visits v
JOIN patients p ON v.patient_id = p.patient_id
WHERE p.insurance_provider IS NULL 
   OR p.insurance_provider = '';
   
--  There are zero records visits linked to patients with missing insurance provider information.











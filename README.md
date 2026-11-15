# Healthcare Risk, Claim & Operational Analytics System

A comprehensive end-to-end data science and SQL analytics project focused on hospital operational efficiency, financial revenue realization, data integrity auditing, and predictive machine learning for claim status classification.

---

##  Project Overview

This repository contains a full-stack data workflow built around a simulated hospital database (`Hospital_db`). The project bridges relational database management, exploratory data analysis (EDA), automated data quality validation, and supervised machine learning to help healthcare providers optimize patient flow, minimize claim rejection rates, and manage financial risk.

---

##  Repository Structure & File Overview

```text
├── sql/
│   ├── phase 1.sql           # Relational schema definition, constraints, and indexes
│   └── cap.sql               # Operational analytics, financial metrics, and data integrity audit scripts
├── notebooks/
│   ├── EDA phase 2.ipynb     # Exploratory data analysis, merging, missing value audits, and visualizations
│   └── Claim_model.ipynb     # Feature engineering, time-based splitting, SMOTE, and LightGBM training
├── models/
│   └── claim_model.pkl       # Serialized top-performing LightGBM classifier
└── data/
    └── model_table1.csv      # Unified dataset (25,000 merged records)


1. SQL Scripts (sql/)
Relational Database Schema (phase 1.sql): Defines core tables (patients, visits, and billing) equipped with primary/foreign key constraints and indexes for optimized query performance.

Operational Analytics (cap.sql): SQL queries tracking department visit volumes, length-of-stay averages, high-risk visit percentages, and physician caseloads.

Financial Analytics (cap.sql): Queries computing insurance provider claim volumes, rejection rates, payment delays, and departmental revenue realization ratios.

Data Integrity Checks (cap.sql): Automated SQL auditing scripts verifying foreign key consistency, duplicate patient records, null values, and missing insurance entries.

2. Data Pipelines & Machine Learning (notebooks/)
Exploratory Data Analysis & Merging (EDA phase 2.ipynb): Performs relational inner and left joins to combine multi-table hospital datasets into a unified pandas dataframe (25,000 records).

Missing Value & Distribution Analysis (EDA phase 2.ipynb): Audits missing payment days and approved amounts, visualizing department distributions and patient demographics.

Feature Engineering (Claim_model.ipynb): Derives approval ratios, cost-per-day metrics, high-cost flags, and stay-duration indicators.

Time-Based Splitting & Modeling (Claim_model.ipynb): Implements robust time-based train/test splits per patient, handles class imbalance via SMOTE and class weights, and trains baseline/ensemble models (Logistic Regression, Random Forest, and LightGBM) to predict claim statuses (Paid, Pending, Rejected).

Model Serialization (Claim_model.ipynb): Exports the top-performing LightGBM classifier (claim_model.pkl) for downstream deployment.


Tech Stack & Libraries
Database: MySQL / Relational SQL (DDL, Indexes, Joins, Aggregations)

Data Manipulation & Analysis: Python, Pandas, NumPy

Visualization: Matplotlib, Seaborn

Machine Learning & Imbalance Handling: Scikit-Learn, LightGBM, Imbalanced-Learn (SMOTE), Joblib

Key Highlights & Findings
Relational Integrity: Validated 25,000 visit records against billing and patient tables with zero duplicate patient IDs and robust foreign key relationships.

Financial Risk Management: Identified key bottlenecks in insurance claim approvals, highlighting providers with high rejection rates and revenue gaps between billed and approved amounts.

Predictive Performance: The LightGBM classifier achieved high accuracy and robust recall on minority classes (particularly rejected claims), providing hospital finance teams with an early-warning system to mitigate revenue leakage.

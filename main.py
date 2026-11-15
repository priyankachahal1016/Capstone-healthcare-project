from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import numpy as np
import hashlib
from datetime import datetime
import os
import json

app = FastAPI()


# LOAD MODELS

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

risk_model = joblib.load(os.path.join(BASE_DIR, "risk_model.pkl"))
claim_model = joblib.load(os.path.join(BASE_DIR, "claim_model.pkl"))

print(" Models loaded successfully")


# INPUT SCHEMA

class PatientData(BaseModel):
    age: float
    gender: int
    city: int
    chronic_flag: int
    department: int
    visit_type: int
    length_of_stay_hours: float
    visit_frequency: float
    avg_stay_patient: float
    stay_days: float
    cost_per_day: float
    high_cost_flag: int
    is_long_stay: int
    dept_avg_bill: float
    bill_vs_dept_avg: float
    cost_intensity: float
    stay_severity: float
    cost_per_visit: float


class ClaimData(BaseModel):
    age: float
    gender: int
    city: int
    insurance_provider: int
    billed_amount: float
    approved_amount: float
    length_of_stay_hours: float
    approval_ratio: float
    cost_per_day: float
    visit_frequency: float
    provider_rejection_rate: float
    high_cost_flag: int
    is_long_stay: int


# HEALTH CHECK

@app.get("/")
def health():
    return {"status": "API is running 🚀"}


# HASH FUNCTION

def generate_hash(data):
    return hashlib.md5(str(data).encode()).hexdigest()


# VALIDATION FUNCTION

def validate_input(data_dict):
    errors = []

    for key, value in data_dict.items():
        if value is None:
            errors.append(f"{key} is missing")

    if data_dict.get("age", 0) < 0 or data_dict.get("age", 0) > 120:
        errors.append("Invalid age")

    if data_dict.get("cost_per_day", 0) < 0:
        errors.append("Cost cannot be negative")

    if data_dict.get("gender") not in [0, 1]:
        errors.append("Invalid gender")

    if data_dict.get("city") not in [0, 1, 2, 3]:
        errors.append("Invalid city")

    if "insurance_provider" in data_dict:
        if data_dict.get("insurance_provider") not in [0, 1, 2]:
            errors.append("Invalid insurance provider")

    return errors


# LOGGING FUNCTION

def log_prediction(log_data):
    with open("prediction_logs.json", "a") as f:
        f.write(json.dumps(log_data) + "\n")


# RISK PREDICTION

@app.post("/predict_risk")
def predict_risk(data: PatientData):

    input_data = data.dict()
    errors = validate_input(input_data)

    if errors:
        return {"error": errors}

    features = np.array([[ 
        data.age,
        data.gender,
        data.city,
        data.chronic_flag,
        data.department,
        data.visit_type,
        data.length_of_stay_hours,
        data.visit_frequency,
        data.avg_stay_patient,
        data.stay_days,
        data.cost_per_day,
        data.high_cost_flag,
        data.is_long_stay,
        data.dept_avg_bill,
        data.bill_vs_dept_avg,
        data.cost_intensity,
        data.stay_severity,
        data.cost_per_visit
    ]])

    probs = risk_model.predict_proba(features)[0]

    if probs[2] > 0.32:
        prediction = 2
    elif probs[0] > 0.28:
        prediction = 0
    else:
        prediction = 1

    log = {
        "timestamp": str(datetime.now()),
        "model": "risk_model_v1",
        "input_hash": generate_hash(features.tolist())
    }

    # FOR DRIFT TRACKING
    log["prediction"] = int(prediction) if str(prediction).isdigit() else str(prediction)

    log_prediction(log)

    return {
        "prediction": int(prediction),
        "probabilities": probs.tolist(),
        "log": log
    }


# CLAIM PREDICTION

@app.post("/predict_claim")
def predict_claim(data: ClaimData):

    input_data = data.dict()
    errors = validate_input(input_data)

    if errors:
        return {"error": errors}

    features = np.array([[ 
        data.age,
        data.gender,
        data.city,
        data.insurance_provider,
        data.billed_amount,
        data.approved_amount,
        data.length_of_stay_hours,
        data.approval_ratio,
        data.cost_per_day,
        data.visit_frequency,
        data.provider_rejection_rate,
        data.high_cost_flag,
        data.is_long_stay
    ]])

    prediction = claim_model.predict(features)[0]

    log = {
        "timestamp": str(datetime.now()),
        "model": "claim_model_v1",
        "input_hash": generate_hash(features.tolist())
    }

    log["prediction"] = int(prediction) if str(prediction).isdigit() else str(prediction)

    log_prediction(log)

    return {
        "prediction": str(prediction),
        "log": log
    }
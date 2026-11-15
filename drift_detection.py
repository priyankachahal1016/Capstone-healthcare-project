import pandas as pd

# Feature Drift
def check_feature_drift(train_df, new_df, threshold=0.2):
    drift_report = {}

    for col in train_df.columns:
        train_mean = train_df[col].mean()
        new_mean = new_df[col].mean()

        diff = abs(train_mean - new_mean)

        drift_report[col] = "Drift" if diff > threshold else "No Drift"

    return drift_report


# Prediction Drift
def check_prediction_drift(old_preds, new_preds, threshold=0.1):
    old_mean = sum(old_preds) / len(old_preds)
    new_mean = sum(new_preds) / len(new_preds)

    diff = abs(old_mean - new_mean)

    if diff > threshold:
        return "Prediction Drift Detected"
    else:
        return "No Prediction Drift"
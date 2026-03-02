import os
import joblib
import pandas as pd
from sqlalchemy import create_engine
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score

DB_URL = os.getenv("DB_URL")

def main():
    if not DB_URL:
        raise SystemExit("DB_URL is not set")

    engine = create_engine(DB_URL)

    df = pd.read_sql("SELECT * FROM churn_features", engine)
    df = df.dropna(subset=["totalcharges"])

    X = df.drop(columns=["customerid", "target"])
    y = df["target"]

    if len(df) == 0:
        raise SystemExit("No rows after dropna(totalcharges). Check totalcharges in DB.")

    Xtr, Xte, ytr, yte = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    model = RandomForestClassifier(
        n_estimators=400, max_depth=10, random_state=42, n_jobs=-1, class_weight="balanced"
    )
    model.fit(Xtr, ytr)

    proba = model.predict_proba(Xte)[:, 1]
    auc = roc_auc_score(yte, proba)
    print(f"AUC={auc:.4f}")

    os.makedirs("outputs/model", exist_ok=True)
    joblib.dump(model, "outputs/model/random_forest.joblib")

if __name__ == "__main__":
    main()
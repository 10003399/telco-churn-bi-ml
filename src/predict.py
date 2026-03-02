import os
import joblib
import pandas as pd
from sqlalchemy import create_engine, text

DB_URL = os.getenv("DB_URL")

def main():
    if not DB_URL:
        raise SystemExit("DB_URL is not set")

    engine = create_engine(DB_URL)

    df = pd.read_sql("SELECT * FROM churn_features", engine)
    df = df.dropna(subset=["totalcharges"])

    model = joblib.load("outputs/model/random_forest.joblib")

    X = df.drop(columns=["customerid", "target"])

    out = df[["customerid"]].copy()
    out["churn_probability"] = model.predict_proba(X)[:, 1]

    # töm tabellen utan att droppa den (view fungerar kvar)
    with engine.begin() as conn:
        conn.execute(text("TRUNCATE TABLE public.predictions"))

    out.to_sql(
        "predictions",
        engine,
        schema="public",
        if_exists="append",
        index=False
    )

    os.makedirs("outputs/predictions", exist_ok=True)
    out.to_csv("outputs/predictions/predictions.csv", index=False)

if __name__ == "__main__":
    main()
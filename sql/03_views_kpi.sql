CREATE OR REPLACE VIEW churn_kpi AS
SELECT
    COUNT(*) AS customers,
    AVG(MonthlyCharges) AS avg_monthly_charges,
    AVG(tenure) AS avg_tenure,
    AVG(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churn_rate
FROM telco_raw;
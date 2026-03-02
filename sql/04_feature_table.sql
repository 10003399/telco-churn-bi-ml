DROP TABLE IF EXISTS churn_features;

CREATE TABLE churn_features AS
SELECT
    customerID,
    tenure,
    MonthlyCharges,
    NULLIF(TRIM(TotalCharges), '')::DOUBLE PRECISION AS TotalCharges,

    CASE WHEN gender='Male' THEN 1 ELSE 0 END AS gender_male,
    CASE WHEN Partner='Yes' THEN 1 ELSE 0 END AS partner_yes,
    CASE WHEN Dependents='Yes' THEN 1 ELSE 0 END AS dependents_yes,
    CASE WHEN PaperlessBilling='Yes' THEN 1 ELSE 0 END AS paperless_yes,

    CASE WHEN Contract='Month-to-month' THEN 1 ELSE 0 END AS contract_m2m,
    CASE WHEN Contract='One year' THEN 1 ELSE 0 END AS contract_1y,
    CASE WHEN Contract='Two year' THEN 1 ELSE 0 END AS contract_2y,

    CASE WHEN InternetService='DSL' THEN 1 ELSE 0 END AS internet_dsl,
    CASE WHEN InternetService='Fiber optic' THEN 1 ELSE 0 END AS internet_fiber,
    CASE WHEN InternetService='No' THEN 1 ELSE 0 END AS internet_no,

    CASE WHEN OnlineSecurity='Yes' THEN 1 ELSE 0 END AS online_security_yes,
    CASE WHEN TechSupport='Yes' THEN 1 ELSE 0 END AS tech_support_yes,

    CASE WHEN PaymentMethod='Electronic check' THEN 1 ELSE 0 END AS pay_echeck,
    CASE WHEN PaymentMethod='Mailed check' THEN 1 ELSE 0 END AS pay_mailed,
    CASE WHEN PaymentMethod='Bank transfer (automatic)' THEN 1 ELSE 0 END AS pay_bank_auto,
    CASE WHEN PaymentMethod='Credit card (automatic)' THEN 1 ELSE 0 END AS pay_cc_auto,

    CASE WHEN Churn='Yes' THEN 1 ELSE 0 END AS target
FROM telco_raw;
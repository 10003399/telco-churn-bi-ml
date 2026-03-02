SELECT *
FROM public.churn_top_risk
LIMIT 50;

SELECT
    SUM(CASE WHEN churn_probability >= 0.90 THEN 1 ELSE 0 END) AS p90_plus,
    SUM(CASE WHEN churn_probability >= 0.80 AND churn_probability < 0.90 THEN 1 ELSE 0 END) AS p80_90,
    SUM(CASE WHEN churn_probability >= 0.70 AND churn_probability < 0.80 THEN 1 ELSE 0 END) AS p70_80,
    SUM(CASE WHEN churn_probability < 0.70 THEN 1 ELSE 0 END) AS below_70
FROM public.predictions;

SELECT
    CASE
        WHEN f.contract_2y = 1 THEN 'Two year'
        WHEN f.contract_1y = 1 THEN 'One year'
        WHEN f.contract_m2m = 1 THEN 'Month-to-month'
        ELSE 'Unknown'
        END AS contract,
    COUNT(*) AS customers,
    AVG(p.churn_probability) AS avg_risk,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY p.churn_probability) AS median_risk
FROM public.predictions p
         JOIN public.churn_features f USING (customerid)
GROUP BY 1
ORDER BY avg_risk DESC;

WITH b AS (
    SELECT
        customerid,
        churn_probability,
        CASE
            WHEN tenure < 6 THEN '0-5'
            WHEN tenure < 12 THEN '6-11'
            WHEN tenure < 24 THEN '12-23'
            WHEN tenure < 48 THEN '24-47'
            ELSE '48+'
            END AS tenure_bucket
    FROM public.predictions p
             JOIN public.churn_features f USING (customerid)
)
SELECT
    tenure_bucket,
    COUNT(*) customers,
    AVG(churn_probability) avg_risk
FROM b
GROUP BY tenure_bucket
ORDER BY
    CASE tenure_bucket
        WHEN '0-5' THEN 1
        WHEN '6-11' THEN 2
        WHEN '12-23' THEN 3
        WHEN '24-47' THEN 4
        ELSE 5
        END;


SELECT
    CASE
        WHEN f.contract_2y = 1 THEN 'Two year'
        WHEN f.contract_1y = 1 THEN 'One year'
        WHEN f.contract_m2m = 1 THEN 'Month-to-month'
        ELSE 'Unknown'
        END AS contract,
    SUM(f.monthlycharges * p.churn_probability) AS expected_monthly_revenue_at_risk,
    SUM(f.monthlycharges) AS total_monthly_revenue,
    AVG(p.churn_probability) AS avg_risk
FROM public.predictions p
         JOIN public.churn_features f USING (customerid)
GROUP BY 1
ORDER BY expected_monthly_revenue_at_risk DESC;

SELECT
    CASE
        WHEN internet_fiber = 1 THEN 'Fiber'
        WHEN internet_dsl = 1 THEN 'DSL'
        WHEN internet_no = 1 THEN 'No internet'
        ELSE 'Unknown'
        END AS internet_type,
    COUNT(*) customers,
    AVG(p.churn_probability) avg_risk
FROM public.predictions p
         JOIN public.churn_features f USING (customerid)
GROUP BY 1
ORDER BY avg_risk DESC;

WITH ranked AS (
    SELECT
        p.*,
        NTILE(10) OVER (ORDER BY churn_probability DESC) AS decile
    FROM public.predictions p
)
SELECT
    decile,
    COUNT(*) customers,
    AVG(churn_probability) avg_risk
FROM ranked
GROUP BY decile
ORDER BY decile;

CREATE OR REPLACE VIEW public.churn_actions AS
SELECT
    p.customerid,
    p.churn_probability,
    CASE
        WHEN p.churn_probability >= 0.80 THEN 'High'
        WHEN p.churn_probability >= 0.60 THEN 'Medium'
        ELSE 'Low'
        END AS risk_band,
    CASE
        WHEN f.contract_m2m = 1 AND p.churn_probability >= 0.80 THEN 'Offer yearly discount'
        WHEN f.tenure < 6 AND p.churn_probability >= 0.70 THEN 'Onboarding / support outreach'
        WHEN f.tech_support_yes = 0 AND p.churn_probability >= 0.70 THEN 'Promote Tech Support'
        ELSE 'Monitor'
        END AS suggested_action
FROM public.predictions p
         JOIN public.churn_features f USING (customerid);
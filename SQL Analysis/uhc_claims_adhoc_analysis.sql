-- =====================================
-- U.S. healthcare claims Analysis
-- ======================================

/* 1. Preview Claims Data
		Business Use: Understand data structure before analysis */
SELECT *
FROM claims
LIMIT 10;	

/* 2. Total Number of Claims
Business Use: Overall claim volume tracking */
SELECT COUNT(*) AS total_claims
FROM claims;

/* 3. Claims Volume by Payer
Business Use: Compare workload across payers (UHC, Medicare, etc.) */
SELECT i.payer,
COUNT(*) AS total_claims
FROM claims c
JOIN insurance_plans i ON c.plan_id = i.plan_id
GROUP BY i.payer
ORDER BY total_claims DESC;

/* 4. Average Claim Cost by Plan Type
Business Use: Identify cost differences by insurance plan */
SELECT i.plan_name,
ROUND(AVG(c.total_cost), 2) AS avg_claim_cost,
ROUND(AVG(c.amount_covered), 2) AS avg_amount_covered
FROM claims c
JOIN insurance_plans i ON c.plan_id = i.plan_id
GROUP BY i.plan_name
ORDER BY avg_claim_cost DESC;

/* 5. Claim Approval Rate by Payer
Business Use: Measure payer efficiency */
SELECT i.payer,
COUNT(*) AS total_claims,
SUM(CASE WHEN c.claim_status = 'Approved' THEN 1 ELSE 0 END) AS approved_claims,
ROUND(SUM(CASE WHEN c.claim_status = 'Approved' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS approval_rate_pct
FROM claims c
JOIN insurance_plans i ON c.plan_id = i.plan_id
GROUP BY i.payer
ORDER BY approval_rate_pct DESC;

/* 6. Top 5 Costliest Diagnoses
Business Use: Identify high-cost conditions*/
SELECT d.diagnosis_code,
d.diagnosis_desc,
ROUND(SUM(c.total_cost), 2) AS total_claim_cost
FROM claims c
JOIN diagnosis d ON c.diagnosis_code = d.diagnosis_code
GROUP BY d.diagnosis_code, d.diagnosis_desc
ORDER BY total_claim_cost DESC
LIMIT 5;

/* 7. State-wise Claim Cost Analysis
Business Use: Regional healthcare cost comparison*/
SELECT p.state,
ROUND(SUM(c.total_cost), 2) AS total_claim_cost,
ROUND(SUM(c.amount_covered), 2) AS total_covered_cost
FROM claims c
JOIN patients p ON c.patient_id = p.patient_id
GROUP BY p.state
ORDER BY total_claim_cost DESC;

/* 8. Monthly Claim Trend
Business Use: Identify seasonality in claims*/
SELECT DATE_FORMAT(c.claim_date, '%Y-%m') AS claim_month,
COUNT(*) AS claim_count,
ROUND(SUM(c.total_cost), 2) AS total_cost
FROM claims c
GROUP BY claim_month
ORDER BY claim_month;

/*  9.Provider Performance Metrics
Business Use: Compare hospitals and clinics*/
SELECT pr.provider_name,
COUNT(*) AS total_claims,
ROUND(SUM(c.total_cost), 2) AS total_claim_cost,
ROUND(SUM(CASE WHEN c.claim_status = 'Approved' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS approval_rate_pct
FROM claims c
JOIN providers pr ON c.provider_id = pr.provider_id
GROUP BY pr.provider_name
ORDER BY total_claim_cost DESC
LIMIT 10;

/* 10. Coverage Efficiency by Payer
Business Use: Financial efficiency analysis */
SELECT i.payer,
ROUND(SUM(c.amount_covered) / SUM(c.total_cost) * 100, 2) AS coverage_efficiency_pct
FROM claims c
JOIN insurance_plans i ON c.plan_id = i.plan_id
GROUP BY i.payer
ORDER BY coverage_efficiency_pct DESC;

-- Which payer and diagnosis combinations have the highest denial rates?
SELECT i.payer,
d.diagnosis_desc,
COUNT(*) AS total_claims,
ROUND(SUM(CASE WHEN c.claim_status = 'Denied' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS denial_rate_pct
FROM claims c
JOIN insurance_plans i ON c.plan_id = i.plan_id
JOIN diagnosis d ON c.diagnosis_code = d.diagnosis_code
GROUP BY i.payer, d.diagnosis_desc
HAVING COUNT(*) > 20
ORDER BY denial_rate_pct DESC;
-- Campaign funnel per group: customers -> visitors -> purchasers
-- One row per experiment group, with rates and the difference from the control group.

WITH funnel AS (
    -- Step 1: count customers at each funnel stage
    SELECT
        segment,
        COUNT(*)        AS customers,
        SUM(visit)      AS visitors,
        SUM(conversion) AS purchasers
    FROM customers
    GROUP BY segment
),

rates AS (
    -- Step 2: turn counts into rates (in percent)
    SELECT
        segment,
        customers,
        visitors,
        purchasers,
        100.0 * visitors   / customers AS visit_rate_pct,
        100.0 * purchasers / customers AS conversion_rate_pct,
        100.0 * purchasers / NULLIF(visitors, 0) AS visit_to_purchase_pct
    FROM funnel
)

-- Step 3: compare every group with the control group using window functions
SELECT
    segment,
    customers,
    visitors,
    purchasers,
    ROUND(visit_rate_pct, 2)        AS visit_rate_pct,
    ROUND(conversion_rate_pct, 3)   AS conversion_rate_pct,
    ROUND(visit_to_purchase_pct, 2) AS visit_to_purchase_pct,
    ROUND(
        visit_rate_pct
        - MAX(CASE WHEN segment = 'No E-Mail' THEN visit_rate_pct END) OVER (),
        2
    ) AS visit_lift_pp,
    ROUND(
        conversion_rate_pct
        - MAX(CASE WHEN segment = 'No E-Mail' THEN conversion_rate_pct END) OVER (),
        3
    ) AS conversion_lift_pp
FROM rates
ORDER BY CASE WHEN segment = 'No E-Mail' THEN 0 ELSE 1 END, segment;

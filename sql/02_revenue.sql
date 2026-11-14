-- Revenue metrics per group, with each group's share of total revenue
-- and the incremental revenue compared with the control group.

WITH revenue AS (
    -- Step 1: revenue totals per group
    SELECT
        segment,
        COUNT(*)        AS customers,
        SUM(conversion) AS purchasers,
        SUM(spend)      AS total_spend
    FROM customers
    GROUP BY segment
),

per_customer AS (
    -- Step 2: per-customer and per-order averages
    SELECT
        segment,
        customers,
        purchasers,
        total_spend,
        1.0 * total_spend / customers             AS spend_per_customer,
        1.0 * total_spend / NULLIF(purchasers, 0) AS avg_order_value
    FROM revenue
)

-- Step 3: window functions for revenue share and difference from control
SELECT
    segment,
    customers,
    purchasers,
    ROUND(total_spend, 2)        AS total_spend,
    ROUND(spend_per_customer, 4) AS spend_per_customer,
    ROUND(avg_order_value, 2)    AS avg_order_value,
    ROUND(100.0 * total_spend / SUM(total_spend) OVER (), 1) AS revenue_share_pct,
    ROUND(
        spend_per_customer
        - MAX(CASE WHEN segment = 'No E-Mail' THEN spend_per_customer END) OVER (),
        4
    ) AS spend_lift_per_customer,
    ROUND(
        10000 * (
            spend_per_customer
            - MAX(CASE WHEN segment = 'No E-Mail' THEN spend_per_customer END) OVER ()
        ),
        0
    ) AS incremental_revenue_per_10k
FROM per_customer
ORDER BY CASE WHEN segment = 'No E-Mail' THEN 0 ELSE 1 END, segment;

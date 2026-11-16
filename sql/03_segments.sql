-- Baseline behaviour of customer segments, using the control group only.
-- Answers: without any e-mail, which kinds of customers visit and buy the most?
-- One row per (dimension, category), ranked within each dimension.

WITH control AS (
    -- Step 1: keep the control group and derive three readable segment columns
    SELECT
        history_segment,
        zip_code,
        channel,
        visit,
        conversion,
        CASE
            WHEN mens = 1 AND womens = 1 THEN 'Both'
            WHEN mens = 1 THEN 'Mens only'
            ELSE 'Womens only'
        END AS purchase_category,
        CASE
            WHEN recency <= 3 THEN '01-03 months'
            WHEN recency <= 6 THEN '04-06 months'
            WHEN recency <= 9 THEN '07-09 months'
            ELSE '10-12 months'
        END AS recency_bucket,
        CASE WHEN newbie = 1 THEN 'New customer' ELSE 'Existing customer' END AS customer_type
    FROM customers
    WHERE segment = 'No E-Mail'
),

stacked AS (
    -- Step 2: stack every dimension into one long table (dimension, category)
    SELECT 'history_segment' AS dimension, history_segment AS category, visit, conversion FROM control
    UNION ALL
    SELECT 'recency', recency_bucket, visit, conversion FROM control
    UNION ALL
    SELECT 'purchase_category', purchase_category, visit, conversion FROM control
    UNION ALL
    SELECT 'customer_type', customer_type, visit, conversion FROM control
    UNION ALL
    SELECT 'channel', channel, visit, conversion FROM control
    UNION ALL
    SELECT 'zip_code', zip_code, visit, conversion FROM control
),

summary AS (
    -- Step 3: aggregate per category
    SELECT
        dimension,
        category,
        COUNT(*)        AS customers,
        SUM(visit)      AS visitors,
        SUM(conversion) AS purchasers,
        100.0 * SUM(visit)      / COUNT(*) AS visit_rate_pct,
        100.0 * SUM(conversion) / COUNT(*) AS conversion_rate_pct
    FROM stacked
    GROUP BY dimension, category
)

-- Step 4: rank categories inside each dimension and compare with the control average
SELECT
    dimension,
    category,
    customers,
    visitors,
    purchasers,
    ROUND(visit_rate_pct, 2)      AS visit_rate_pct,
    ROUND(conversion_rate_pct, 3) AS conversion_rate_pct,
    DENSE_RANK() OVER (PARTITION BY dimension ORDER BY visit_rate_pct DESC) AS visit_rank,
    ROUND(
        visit_rate_pct
        - 100.0 * SUM(visitors) OVER (PARTITION BY dimension)
                / SUM(customers) OVER (PARTITION BY dimension),
        2
    ) AS vs_control_avg_pp
FROM summary
ORDER BY dimension, visit_rank, category;

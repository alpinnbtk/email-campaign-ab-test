-- Visit and conversion rates per customer segment and experiment group.
-- Only the three segments pre-specified in analysis_plan.md are included.
-- One row per (dimension, category, segment); pivoted into a heatmap in the notebook.

WITH labelled AS (
    -- Step 1: derive readable segment columns for all customers
    SELECT
        segment,
        channel,
        visit,
        conversion,
        CASE
            WHEN mens = 1 AND womens = 1 THEN 'Both'
            WHEN mens = 1 THEN 'Mens only'
            ELSE 'Womens only'
        END AS purchase_category,
        CASE WHEN newbie = 1 THEN 'New customer' ELSE 'Existing customer' END AS customer_type
    FROM customers
),

stacked AS (
    -- Step 2: stack the three pre-specified dimensions
    SELECT 'purchase_category' AS dimension, purchase_category AS category, segment, visit, conversion FROM labelled
    UNION ALL
    SELECT 'customer_type', customer_type, segment, visit, conversion FROM labelled
    UNION ALL
    SELECT 'channel', channel, segment, visit, conversion FROM labelled
)

-- Step 3: aggregate per category and experiment group
SELECT
    dimension,
    category,
    segment,
    COUNT(*)        AS customers,
    SUM(visit)      AS visitors,
    SUM(conversion) AS purchasers,
    ROUND(100.0 * SUM(visit)      / COUNT(*), 2) AS visit_rate_pct,
    ROUND(100.0 * SUM(conversion) / COUNT(*), 3) AS conversion_rate_pct
FROM stacked
GROUP BY dimension, category, segment
ORDER BY dimension, category, segment;

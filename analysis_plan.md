# Analysis Plan

## 1. Business context

An online retailer ran an e-mail test on 64,000 customers who had purchased within
the last twelve months. Customers were randomly assigned to one of three groups:
an e-mail featuring men's merchandise, an e-mail featuring women's merchandise, or
no e-mail. Results were tracked for two weeks.

The marketing team needs to decide:

1. Does sending an e-mail cause more customers to visit and buy, compared with
   sending nothing?
2. If so, which of the two e-mails performs better?
3. Should the e-mail go to every customer, or only to certain customer segments?

## 2. Groups

| Group | Role | Customers |
| --- | --- | --- |
| No E-Mail | Control | 21,306 |
| Mens E-Mail | Treatment 1 | 21,307 |
| Womens E-Mail | Treatment 2 | 21,387 |

## 3. Metrics

| Metric | Column | Role | Definition |
| --- | --- | --- | --- |
| Conversion rate | `conversion` | Primary | Share of customers who purchased within two weeks |
| Visit rate | `visit` | Secondary | Share of customers who visited the website within two weeks |
| Spend per customer | `spend` | Revenue | Average dollars spent within two weeks, including customers who spent 0 |

All metrics are calculated per customer assigned to a group, not per visitor.
Conversion is the primary metric because a purchase is the outcome the business
cares about. Visit rate is an earlier, more frequent signal and is easier to detect.

## 4. Hypotheses (primary metric)

For each comparison between group A and group B:

- H0: the conversion rate of A equals the conversion rate of B.
- H1: the conversion rate of A differs from the conversion rate of B.

Tests are two-sided with a significance level (alpha) of 0.05. A two-sided test is
used because an e-mail could also reduce purchases, for example by annoying
customers.

## 5. Comparisons

1. Mens E-Mail vs No E-Mail
2. Womens E-Mail vs No E-Mail
3. Mens E-Mail vs Womens E-Mail

The same three comparisons are run for the secondary and revenue metrics.

Because several tests are run, p-values are adjusted with the Holm method within
each metric. A result is called statistically significant only if its adjusted
p-value is below 0.05.

## 6. Statistical methods

| Metric | Method |
| --- | --- |
| Conversion rate, visit rate | Two-proportion z-test, 95% confidence interval for the difference |
| Spend per customer | Bootstrap 95% confidence interval for the difference in means (10,000 resamples), with Welch's t-test as a cross-check |

## 7. Practical significance threshold

An e-mail is considered worth sending only if it raises the conversion rate by at
least **0.2 percentage points** over the control group. That equals 20 additional
purchases per 10,000 e-mails sent.

This threshold is an assumption. The dataset contains no information on the cost of
sending an e-mail or on product margins, so the threshold is set as a modest but
meaningful lift relative to the low overall conversion rate reported for this
dataset (about 0.9%). The decision memo will show how the recommendation changes
if this threshold is different.

## 8. Experiment validity checks (before any outcome analysis)

- **Sample ratio mismatch:** chi-square goodness-of-fit test against an equal
  three-way split. A p-value below 0.001 is treated as a warning sign.
- **Covariate balance:** compare the pre-campaign columns (`recency`, `history`,
  `mens`, `womens`, `zip_code`, `newbie`, `channel`) across groups. An absolute
  standardized mean difference above 0.1 is treated as an imbalance.
- **Logical consistency:** every customer with `conversion = 1` should have
  `visit = 1`, and `spend > 0` should occur only when `conversion = 1`.

If a check fails, the issue is documented and its effect on the conclusions is
discussed before continuing.

## 9. Segments (pre-specified, maximum three)

Segment analysis uses only columns measured before the campaign:

1. **Past purchase category:** bought men's merchandise only, women's merchandise
   only, or both (`mens`, `womens`). Expectation: each e-mail works better for
   customers who previously bought that category.
2. **New vs existing customer** (`newbie`).
3. **Purchase channel** (`channel`): Phone, Web, or Multichannel.

Whether the e-mail effect truly differs between segments is tested with a logistic
regression that includes a treatment-by-segment interaction term. Any segment
finding outside these three is labelled exploratory.

## 10. Decision rules

- **Send an e-mail** if its conversion lift over the control group is
  statistically significant after Holm adjustment and the estimated lift is at
  least 0.2 percentage points.
- **Choose between the two e-mails** using comparison 3. If neither is
  significantly better overall, use the segment results to decide who receives
  which e-mail.
- **Do not send** if the upper bound of the 95% confidence interval for the lift
  is below 0.2 percentage points.
- **Run a follow-up test** if the result is inconclusive, meaning the confidence
  interval includes both zero and values above 0.2 percentage points. The power
  analysis determines the sample size for that test.

## 11. Data handling

- No rows are removed unless a validity check reveals clearly invalid records.
- `spend` is analysed as recorded. As a sensitivity check, the analysis is repeated
  with `spend` capped at the 99th percentile of purchasers (winsorizing).
- A `customer_id` column is added when loading, because the original file has no
  identifier.

## 12. Known limitations (before analysis)

- The data is from 2008 and the retailer is not named.
- Outcomes are tracked for two weeks only; long-term effects are unknown.
- There is no data on unsubscribes, e-mail costs, or product margins.

## Plan changes

None so far.
# E-mail Campaign A/B Test

An A/B testing case study on a retailer's e-mail campaign: does sending a
promotional e-mail cause more customers to visit, buy, and spend, and which
customers should receive it?

## Business question

A retailer randomly split 64,000 customers into three groups: one received an
e-mail featuring men's merchandise, one received an e-mail featuring women's
merchandise, and one received no e-mail. This project analyses the two weeks of
results to recommend which e-mail to send and to whom.

## Data

Hillstrom MineThatData E-Mail Analytics and Data Mining Challenge (64,000
customers, three randomly assigned groups).

The dataset is not included in this repository and is not covered by this
repository's license. Download it from the original source:
https://blog.minethatdata.com/2008/03/minethatdata-e-mail-analytics-and-data.html

## Approach

1. Write the analysis plan before looking at results (`analysis_plan.md`)
2. Check experiment validity: sample ratio and covariate balance
3. Build the campaign funnel and customer segments in SQL (MySQL)
4. Test the effect on visits and conversion (two-proportion z-test)
5. Estimate the effect on revenue (bootstrap)
6. Run a power analysis and correct for multiple comparisons
7. Analyse the effect by customer segment
8. Write a decision memo for the marketing team

## Tech stack

Python (pandas, SciPy, statsmodels, matplotlib, seaborn), MySQL, SQLAlchemy,
Jupyter.

## Status

In progress (day 1 of 10). Results will be added here when the analysis is
complete.

## How to run

1. Create a virtual environment and install dependencies:
   `pip install -r requirements.txt`
2. Download the dataset to `data/raw/hillstrom.csv`
3. Create a `.env` file with your MySQL connection string:
   `MYSQL_URL=mysql+pymysql://USER:PASSWORD@HOST:PORT/DATABASE`
4. Load the data: `python src/load_to_mysql.py`
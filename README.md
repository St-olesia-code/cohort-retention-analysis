# Cohort Retention Analysis

## End-to-End Data Analytics Project | SQL + Google Sheets

A cohort analysis project focused on evaluating user retention over time and comparing promotional and organic acquisition cohorts.

The project demonstrates an analytical workflow from raw user and event data preparation in SQL to cohort analysis, retention rate calculation, and business insights in Google Sheets.

---

## 📌 Project Overview

The objective of the project was to analyze user behavior after registration and understand how retention changes over time across different acquisition cohorts.

Users were grouped by their registration month and then tracked across subsequent months based on their activity.

The analysis also compares users acquired through promotional campaigns with organically acquired users.

---

## 🎯 Business Questions

The analysis was designed to answer:

- How does user retention change over time?
- How do promotional and organic cohorts differ in retention?
- Which acquisition group demonstrates stronger long-term retention?
- How does retention vary across registration cohorts?
- At which stage after registration is the largest user drop-off observed?

---

## 🗂️ Data Sources

The analysis uses two raw datasets:

- `cohort_users_raw` — user registration data and promotional acquisition flag;
- `cohort_events_raw` — user activity events.

The data was processed using PostgreSQL and DBeaver.

---

## 🧹 Data Preparation

The source data contained dates stored as text with inconsistent formats.

The SQL transformation pipeline standardizes these fields before performing the cohort analysis.

### User registration data

The registration date was prepared through several transformation steps:

1. Extracted the date portion from `signup_datetime`.
2. Removed the time component.
3. Replaced `/` and `.` separators with `-`.
4. Determined whether the year was stored in `YYYY` or `YY` format.
5. Converted the resulting text into a proper SQL `date` using `CASE` and `TO_DATE()`.

### Event data

The same preparation logic was applied to `event_datetime`:

1. Extracted the date without time.
2. Standardized date separators.
3. Identified the year format.
4. Converted the value to the `date` data type.

---

## 🔗 Data Transformation & Joining

After cleaning the dates, user and event data were joined using `user_id`.

The resulting dataset combines:

- user registration date;
- event date;
- acquisition type;
- event type.

This created the analytical base for cohort analysis.

---

## 🧮 Cohort Definition

Each user was assigned to a cohort based on the month of registration.

The registration date was truncated to the beginning of the month using:

`DATE_TRUNC('month', signup_date_clear)`

This created the `cohort_month` field.

The event date was also truncated to month level to create `activity_month`.

---

## ⏱️ Month Offset Calculation

The analysis calculates the number of months between the user's registration cohort and their activity month.

The resulting `month_offset` represents the user's lifecycle stage:

- `0` — registration month;
- `1` — first month after registration;
- `2` — second month after registration;
- `3` — third month after registration;
- `4` — fourth month after registration;
- `5` — fifth month after registration.

This allows user activity to be analyzed consistently across cohorts.

---

## 🔎 Data Filtering

The final dataset was filtered to include only valid analytical records.

The filtering logic:

- excludes records with missing registration dates;
- excludes records with missing event dates;
- excludes records with missing event types;
- removes `test_event` records;
- keeps activity between January and June 2025;
- excludes activity occurring before the user's registration cohort.

---

## 📊 Cohort Aggregation

The final SQL query calculates the number of distinct active users for each combination of:

- acquisition type;
- cohort month;
- month offset.

The resulting metric:

`COUNT(DISTINCT user_id) AS users_total`

produces the number of active users remaining in each cohort at each month of observation.

---

## 📈 Google Sheets Analysis

The SQL output was exported from DBeaver to CSV and used for further cohort analysis in Google Sheets.

The spreadsheet contains:

- cohort tables;
- Retention Rate calculations;
- comparison of promotional and organic cohorts;
- cohort retention patterns over time.

👉 **[View the Google Sheets analysis](https://docs.google.com/spreadsheets/d/1khXNSDgdEahhdlEeSaQXxadpg3k9SHYOrlj908EhQLc/edit?gid=0#gid=0)**

---

## 🔍 Key Insights

The analysis shows a clear difference between organic and promotional cohorts.

### Organic cohorts

Organic users demonstrate relatively strong retention throughout the observed period.

For example, the January 2025 organic cohort retained:

- **82.9%** of users in Month 1;
- **77.1%** in Month 2;
- **74.3%** in Month 3;
- **61.4%** in Month 4;
- **55.7%** in Month 5.

### Promotional cohorts

Promotional cohorts show a stronger decline in retention.

For example, the January 2025 promotional cohort retained:

- **61.8%** of users in Month 1;
- **50.0%** in Month 2;
- **41.2%** in Month 3;
- **17.6%** in Month 4;
- **8.8%** in Month 5.

### Acquisition comparison

Across the observed cohorts, organic users generally demonstrate stronger retention than promotional users, especially in later months.

This may indicate that organically acquired users have stronger long-term engagement, while promotional acquisition can generate users with lower subsequent retention.

---

## 🛠️ Tools & Technologies

- **PostgreSQL**
- **SQL**
- **DBeaver**
- **Google Sheets**
- **CTEs**
- **JOINs**
- **CASE expressions**
- **DATE_TRUNC**
- **EXTRACT**
- **TO_DATE**
- **String manipulation**
- **COUNT DISTINCT**
- **Cohort analysis**
- **Retention analysis**

---

## 📁 Project Files

The repository contains:

- `cohort-retention-analysis.sql` — SQL data preparation, transformation, cohort definition, and aggregation;
- `cohort_analysis.csv` — final analytical dataset exported from DBeaver;
- Google Sheets analysis — cohort tables, retention calculations, and comparison of promotional vs. organic cohorts.

---

## 🎯 Project Outcome

The project demonstrates the ability to transform raw user and event data into a structured analytical dataset and use it to evaluate customer retention.

The complete workflow:

> **Raw Data → Data Cleaning → Data Transformation → Data Joining → Cohort Definition → Month Offset Calculation → Cohort Aggregation → Retention Analysis → Business Insights**

The project demonstrates practical experience with SQL data preparation, CTE-based transformations, cohort analysis, retention metrics, and translating analytical results into business conclusions.

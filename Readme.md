# 🚚 FedEx Logistics Optimization for Delivery Routes using SQL

## 📌 Project Overview

This project analyzes FedEx's global logistics operations using SQL to identify delivery delays, optimize transportation routes, evaluate warehouse performance, and measure delivery agent efficiency.

The project was developed as a SQL analytics case study using relational datasets representing FedEx's logistics network. Through data cleaning, analytical SQL queries, window functions, CTEs, and KPI reporting, the project provides actionable insights for improving operational efficiency and on-time delivery performance.

---

## 🎯 Project Objectives

The objective of this project is to build a SQL-driven logistics analytics system capable of:

- Identifying shipment delay patterns
- Detecting operational inefficiencies
- Optimizing transportation routes
- Evaluating warehouse performance
- Measuring delivery agent efficiency
- Tracking shipment status
- Generating logistics KPIs
- Providing business recommendations for improving delivery efficiency

---

## 🛠 Tech Stack

- MySQL
- SQL
- MySQL Workbench
- CSV Datasets

---

## 📂 Dataset

The project consists of five relational datasets.

| Dataset | Description |
|----------|-------------|
| Orders | Customer order information |
| Routes | Route source, destination, distance, transit time |
| Warehouses | Warehouse information and daily capacity |
| Delivery Agents | Delivery agent information and ratings |
| Shipments | Shipment tracking and delivery details |

---

## 📋 Project Tasks

### Task 1 — Data Cleaning & Preparation

- Identified duplicate Order_ID and Shipment_ID records
- Replaced missing Delay_Hours values using average delay for each Route_ID
- Standardized date formats
- Flagged invalid delivery records
- Validated referential integrity between related tables

---

### Task 2 — Delivery Delay Analysis

- Calculated delivery duration
- Identified Top 10 delayed routes
- Ranked delayed shipments using SQL Window Functions
- Compared average delay across delivery types

---

### Task 3 — Route Optimization Insights

- Calculated average transit time
- Calculated average delay per route
- Computed Distance-to-Time Efficiency Ratio
- Identified least efficient routes
- Detected routes with more than 20% delayed shipments
- Suggested route optimization opportunities

---

### Task 4 — Warehouse Performance

- Top 3 warehouses with highest delays
- Total vs delayed shipments
- Warehouses exceeding global average delay
- Warehouse ranking based on on-time delivery percentage

---

### Task 5 — Delivery Agent Performance

- Ranked delivery agents by route
- Identified agents below 85% on-time delivery
- Compared Top 5 vs Bottom 5 agents
- Suggested operational improvements

---

### Task 6 — Shipment Tracking Analytics

- Latest shipment status
- Routes with majority of shipments In Transit or Returned
- Most common delay reasons
- Shipments delayed by more than 120 hours

---

### Task 7 — Advanced KPI Reporting

Generated business KPIs including:

- Average Delivery Delay per Source Country
- Overall On-Time Delivery Percentage
- Average Delay per Route
- Warehouse Utilization Percentage

---

## 📚 SQL Concepts Used

- SELECT
- WHERE
- GROUP BY
- HAVING
- ORDER BY
- Aggregate Functions
- INNER JOIN
- LEFT JOIN
- CASE Statements
- Subqueries
- Common Table Expressions (CTEs)
- Window Functions
- RANK()
- ROW_NUMBER()
- DATE_FORMAT()
- TIMESTAMPDIFF()

---

## 📊 Key Business Insights

- Certain transportation routes experience significantly higher average delays.
- Warehouse performance varies considerably across dispatch centers.
- Delivery agent performance can be monitored using on-time delivery percentages.
- Distance-to-time efficiency helps identify underperforming routes.
- High-delay shipments highlight potential operational bottlenecks.
- KPI reporting enables data-driven decision making for logistics optimization.
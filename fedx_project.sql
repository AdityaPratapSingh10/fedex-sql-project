create database fedx;
use fedx;

#Task 1: Data Cleaning & Preparation

#Find Duplicate Orders
SELECT Order_ID, COUNT(*) AS duplicate_count
FROM orders
GROUP BY Order_ID
HAVING COUNT(*) > 1;

#Find Duplicate Shipments
SELECT Shipment_ID, COUNT(*)
FROM shipments
GROUP BY Shipment_ID
HAVING COUNT(*) > 1;

#Replace NULL Delay_Hours with Route Average
UPDATE shipments s
JOIN
(
    SELECT Route_ID,
           AVG(Delay_Hours) avg_delay
    FROM shipments
    GROUP BY Route_ID
) r
ON s.Route_ID = r.Route_ID
SET s.Delay_Hours = r.avg_delay
WHERE s.Delay_Hours IS NULL;

# Convert all date columns (Order_Date, Pickup_Date, Delivery_Date) into YYYY-MM-DD 
# HH:MM:SS format using SQL date functions.
SELECT
DATE_FORMAT(Order_Date,'%Y-%m-%d %H:%i:%s')
FROM orders;

SELECT
DATE_FORMAT(Pickup_Date,'%Y-%m-%d %H:%i:%s'),
DATE_FORMAT(Delivery_Date,'%Y-%m-%d %H:%i:%s')
FROM shipments;

# Find Invalid Dates
SELECT *
FROM shipments
WHERE Delivery_Date < Pickup_Date;

# Referential Integrity Check
# Orders → Routes
SELECT o.*
FROM orders o
LEFT JOIN routes r
ON o.Route_ID = r.Route_ID
WHERE r.Route_ID IS NULL;

#Orders → Warehouses
SELECT o.*
FROM orders o
LEFT JOIN warehouses w
ON o.Warehouse_ID = w.Warehouse_ID
WHERE w.Warehouse_ID IS NULL;

# Shipments → Orders
SELECT s.*
FROM shipments s
LEFT JOIN orders o
ON s.Order_ID = o.Order_ID
WHERE o.Order_ID IS NULL;

# Task-2: Delivery Delay Analysis
# Actual Delivery Time in Hours
SELECT
Shipment_ID,
TIMESTAMPDIFF(HOUR,
Pickup_Date,
Delivery_Date) AS Delivery_Hours
FROM shipments;

# Top 10 Delayed Routes
SELECT
Route_ID,
ROUND(AVG(Delay_Hours),2) Avg_Delay
FROM shipments
GROUP BY Route_ID
ORDER BY Avg_Delay DESC
LIMIT 10;

#Rank Shipments by Delay Within Warehouse
SELECT
Shipment_ID,
Warehouse_ID,
Delay_Hours,
RANK() OVER
(
PARTITION BY Warehouse_ID
ORDER BY Delay_Hours DESC
) AS delay_rank
FROM shipments;

# Average Delay by Delivery Type
SELECT
o.Delivery_Type,
ROUND(AVG(s.Delay_Hours),2) Avg_Delay
FROM shipments s
JOIN orders o
ON s.Order_ID=o.Order_ID
GROUP BY o.Delivery_Type;

# Task-3: Route Optimization
# Average Transit Time Per Route
SELECT
Route_ID,
AVG(
TIMESTAMPDIFF(HOUR,
Pickup_Date,
Delivery_Date)
) Avg_Transit_Time
FROM shipments
GROUP BY Route_ID;

#Average Delay Per Route
SELECT
Route_ID,
ROUND(AVG(Delay_Hours),2) as Delay_hours
FROM shipments
GROUP BY Route_ID;

# Distance-to-Time Efficiency Ratio
SELECT
Route_ID,
Distance_KM,
Avg_Transit_Time_Hours,
ROUND(
Distance_KM / Avg_Transit_Time_Hours,
2
) Efficiency_Ratio
FROM routes;

#Worst 3 Routes
SELECT
Route_ID,
ROUND(
Distance_KM / Avg_Transit_Time_Hours,
2
) as Efficiency_Ratio
FROM routes
ORDER BY Efficiency_Ratio
LIMIT 3;

# Routes with >20% Delayed Shipments
SELECT
Route_ID,
ROUND(
100 *
SUM(
CASE
WHEN Delay_Hours > 0 THEN 1
ELSE 0
END
)
/COUNT(*)
,2
) Delay_Percentage
FROM shipments
GROUP BY Route_ID
HAVING Delay_Percentage > 20;

# Task-4: Delivery Agent Performance
# Top 3 Warehouses with Highest Delay
SELECT
Warehouse_ID,
ROUND(AVG(Delay_Hours),2) Avg_Delay
FROM shipments
GROUP BY Warehouse_ID
ORDER BY Avg_Delay DESC
LIMIT 3;

# Total vs Delayed Shipments
SELECT
Warehouse_ID,
COUNT(*) Total_Shipments,
SUM(
CASE
WHEN Delay_Hours > 0
THEN 1
ELSE 0
END
) Delayed_Shipments
FROM shipments
GROUP BY Warehouse_ID;

# Warehouses Above Global Average Delay
WITH global_avg AS
(
SELECT AVG(Delay_Hours) avg_delay
FROM shipments
)

SELECT
Warehouse_ID,
AVG(Delay_Hours) warehouse_avg
FROM shipments
GROUP BY Warehouse_ID
HAVING warehouse_avg >
(
SELECT avg_delay
FROM global_avg
);

# Rank Warehouses by On-Time %
SELECT
Warehouse_ID,

ROUND(
100 *
SUM(
CASE
WHEN Delay_Hours=0
THEN 1
ELSE 0
END
)
/COUNT(*)
,2
) OnTime_Percentage,

RANK() OVER
(
ORDER BY
100 *
SUM(
CASE
WHEN Delay_Hours=0
THEN 1
ELSE 0
END
)
/COUNT(*) DESC
) warehouse_rank

FROM shipments
GROUP BY Warehouse_ID;

# Task-5: Shipment Tracking Analytics
# Rank Agents Per Route
SELECT
Agent_ID,
Route_ID,

ROUND(
100 *
SUM(
CASE
WHEN Delay_Hours=0
THEN 1
ELSE 0
END
)
/COUNT(*)
,2
) OnTime_Percentage,

RANK() OVER
(
PARTITION BY Route_ID
ORDER BY
SUM(
CASE
WHEN Delay_Hours=0
THEN 1
ELSE 0
END
)/COUNT(*) DESC
) Rank_No

FROM shipments
GROUP BY Agent_ID, Route_ID;

# Agents Below 85%
SELECT
Agent_ID,

ROUND(
100 *
SUM(
CASE
WHEN Delay_Hours=0
THEN 1
ELSE 0
END
)
/COUNT(*)
,2
) OnTime_Percentage

FROM shipments
GROUP BY Agent_ID
HAVING OnTime_Percentage < 85;

# Top 5 vs Bottom 5 Agent Comparison
WITH agent_perf AS
(
    SELECT
        d.Agent_ID,
        d.Agent_Name,
        d.Experience_Years,
        d.Avg_Rating,

        ROUND(
            100 *
            SUM(
                CASE
                    WHEN s.Delay_Hours = 0 THEN 1
                    ELSE 0
                END
            ) / COUNT(*),2
        ) AS OnTime_Percentage

    FROM delivery_agents d
    JOIN shipments s
    ON d.Agent_ID = s.Agent_ID

    GROUP BY
        d.Agent_ID,
        d.Agent_Name,
        d.Experience_Years,
        d.Avg_Rating
),
ranked AS
(
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY OnTime_Percentage DESC) AS rn1,
           ROW_NUMBER() OVER (ORDER BY OnTime_Percentage ASC) AS rn2
    FROM agent_perf
)

SELECT
    'Top 5 Agents' AS Category,
    AVG(Avg_Rating) AS Avg_Rating,
    AVG(Experience_Years) AS Avg_Experience
FROM ranked
WHERE rn1 <= 5

UNION

SELECT
    'Bottom 5 Agents',
    AVG(Avg_Rating),
    AVG(Experience_Years)
FROM ranked
WHERE rn2 <= 5;

# Task 6: Shipment Tracking Analytics
# Latest Shipment Status
SELECT
Shipment_ID,
Delivery_Status,
MAX(Delivery_Date) Latest_Date
FROM shipments
GROUP BY Shipment_ID, Delivery_Status;

# Routes with Majority In Transit / Returned
SELECT
Route_ID,
COUNT(*) Total_Shipments,

SUM(
CASE
WHEN Delivery_Status IN
('In Transit','Returned')
THEN 1
ELSE 0
END
) Problem_Shipments

FROM shipments
GROUP BY Route_ID
HAVING Problem_Shipments > Total_Shipments/2;

# Most Frequent Delay Reasons
SELECT
Delay_Reason,
COUNT(*) Frequency
FROM shipments
GROUP BY Delay_Reason
ORDER BY Frequency DESC;

# Delays Greater than 120 Hours
SELECT *
FROM shipments
WHERE Delay_Hours > 120;

# Task 7: KPI Reporting
# Average Delay per Source Country
SELECT
r.Source_Country,
ROUND(AVG(s.Delay_Hours),2) Avg_Delay
FROM shipments s
JOIN routes r
ON s.Route_ID=r.Route_ID
GROUP BY r.Source_Country;

# On-Time Delivery %
SELECT

ROUND(
100 *
SUM(
CASE
WHEN Delay_Hours=0
THEN 1
ELSE 0
END
)
/COUNT(*)
,2
) AS OnTime_Delivery_Percentage

FROM shipments;

# Average Delay Per Route
SELECT
Route_ID,
ROUND(AVG(Delay_Hours),2) Avg_Delay
FROM shipments
GROUP BY Route_ID;

# Warehouse Utilization %
SELECT
w.Warehouse_ID,
w.Capacity_per_day,

COUNT(s.Shipment_ID) Shipments_Handled,

ROUND(
100 *
COUNT(s.Shipment_ID)
/ w.Capacity_per_day
,2
) Utilization_Percentage

FROM warehouses w
LEFT JOIN shipments s
ON w.Warehouse_ID=s.Warehouse_ID

GROUP BY
w.Warehouse_ID,
w.Capacity_per_day;
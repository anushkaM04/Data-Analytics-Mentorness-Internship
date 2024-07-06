-- Step 1: Checking Data set was well imported
SELECT * FROM `hotel reservation dataset` LIMIT 10;

-- Step 2: Check if there are any NULL Values
SELECT
    SUM(CASE WHEN no_of_adults IS NULL THEN 1 ELSE 0 END) AS null_no_of_adults,
    SUM(CASE WHEN no_of_children IS NULL THEN 1 ELSE 0 END) AS null_no_of_children,
    SUM(CASE WHEN no_of_weekend_nights IS NULL THEN 1 ELSE 0 END) AS null_no_of_weekend_nights,
    SUM(CASE WHEN no_of_week_nights IS NULL THEN 1 ELSE 0 END) AS null_no_of_week_nights,
    SUM(CASE WHEN type_of_meal_plan IS NULL THEN 1 ELSE 0 END) AS null_type_of_meal_plan,
    SUM(CASE WHEN room_type_reserved IS NULL THEN 1 ELSE 0 END) AS null_room_type_reserved,
    SUM(CASE WHEN lead_time IS NULL THEN 1 ELSE 0 END) AS null_lead_time,
    SUM(CASE WHEN arrival_date IS NULL THEN 1 ELSE 0 END) AS null_arrival_date,
    SUM(CASE WHEN market_segment_type IS NULL THEN 1 ELSE 0 END) AS null_market_segment_type,
    SUM(CASE WHEN avg_price_per_room IS NULL THEN 1 ELSE 0 END) AS null_avg_price_per_room,
    SUM(CASE WHEN booking_status IS NULL THEN 1 ELSE 0 END) AS null_booking_status
FROM `hotel reservation dataset`;

-- Step 3: Create the view
SELECT Booking_ID, COUNT(*) AS duplicate_count
FROM `hotel reservation dataset`
GROUP BY Booking_ID
HAVING COUNT(*) > 1;

-- Step 4: Create the view
CREATE VIEW duplicate_booking_ids AS
SELECT Booking_ID, COUNT(*) AS duplicate_count
FROM `hotel reservation dataset`
GROUP BY Booking_ID
HAVING COUNT(*) > 1;

-- Step 5: Verify the view creation
SELECT * FROM duplicate_booking_ids;

-- Step 6: Query the view
SELECT Booking_ID, duplicate_count
FROM duplicate_booking_ids
UNION ALL
SELECT 'No duplicates found' AS Booking_ID, 0 AS duplicate_count
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM duplicate_booking_ids);

-- Step 7: Drop the view
DROP VIEW IF EXISTS duplicate_booking_ids;

-- Basic descriptive statistics 
-- Taking average of all the schemas
SELECT
    AVG(no_of_adults) AS avg_no_of_adults,
    AVG(no_of_children) AS avg_no_of_children,
    AVG(no_of_weekend_nights) AS avg_no_of_weekend_nights,
    AVG(no_of_week_nights) AS avg_no_of_week_nights,
    AVG(lead_time) AS avg_lead_time,
    AVG(avg_price_per_room) AS avg_avg_price_per_room,
    MAX(lead_time) AS max_lead_time,
    MIN(lead_time) AS min_lead_time,
    MAX(avg_price_per_room) AS max_avg_price_per_room,
    MIN(avg_price_per_room) AS min_avg_price_per_room
FROM `hotel reservation dataset`;

-- Distribution of categorical schemeas
SELECT type_of_meal_plan, COUNT(*) AS count
FROM `hotel reservation dataset`
GROUP BY type_of_meal_plan;

SELECT room_type_reserved, COUNT(*) AS count
FROM `hotel reservation dataset`
GROUP BY room_type_reserved;

SELECT market_segment_type, COUNT(*) AS count
FROM `hotel reservation dataset`
GROUP BY market_segment_type;

SELECT booking_status, COUNT(*) AS count
FROM `hotel reservation dataset`
GROUP BY booking_status;

-- Question 1: What is the total number of reservations in the dataset?
SELECT COUNT(*) AS total_reservations
FROM `hotel reservation dataset`;

-- Question 2: Which meal plan is the most popular among guests?
SELECT type_of_meal_plan, COUNT(*) AS count
FROM `hotel reservation dataset`
GROUP BY type_of_meal_plan
ORDER BY count DESC
limit 1

-- Question 3: What is the average price per room for reservations involving children?
SELECT AVG(avg_price_per_room) AS avg_price_per_room_children
FROM `hotel reservation dataset`
WHERE no_of_children > 0;

-- Question 3: What is the average price per room for reservations involving children?
-- Step 1: Check if the table exists
SHOW TABLES LIKE 'hotel reservation dataset';

-- Step 2: Verify the columns
SHOW COLUMNS FROM `hotel reservation dataset`;

-- Step 3: Run a basic query to check data retrieval
SELECT * FROM `hotel reservation dataset` LIMIT 1;

-- Step 4: Execute the main query
SELECT AVG(avg_price_per_room) AS avg_price_per_room_children
FROM `hotel reservation dataset`
WHERE no_of_children > 0;

-- Question 4: How many reservations were made for the year 2018?
-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Inspect the current format
SELECT arrival_date
FROM `hotel reservation dataset`
LIMIT 700;

-- Convert the dates to 'YYYY-MM-DD' format
-- Assuming the current format is 'DD-MM-YYYY'
SELECT
    arrival_date,
    STR_TO_DATE(arrival_date, '%d-%m-%Y') AS converted_date
FROM `hotel reservation dataset`
LIMIT 700;

-- Add a new column for converted dates
ALTER TABLE `hotel reservation dataset`
ADD COLUMN date_converted DATE;

-- Update the new column with converted dates
UPDATE `hotel reservation dataset`
SET date_converted = STR_TO_DATE(arrival_date, '%d-%m-%Y');

-- Verify the conversion
SELECT arrival_date, date_converted
FROM `hotel reservation dataset`
LIMIT 700;

-- Update the original column with the new format
UPDATE `hotel reservation dataset`
SET arrival_date = DATE_FORMAT(date_converted, '%Y-%m-%d');

-- Drop the temporary column
ALTER TABLE `hotel reservation dataset`
DROP COLUMN date_converted;

-- Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;

-- Step 1: Check a sample of the arrival_date column to verify the format
SELECT arrival_date
FROM `hotel reservation dataset`
LIMIT 700;

-- Step 2: Check for dates in 2018 directly
SELECT arrival_date
FROM `hotel reservation dataset`
WHERE arrival_date LIKE '%2018%'
LIMIT 700;

-- Step 3: Check the length of arrival_date to identify any leading/trailing spaces or inconsistencies
SELECT arrival_date, LENGTH(arrival_date) AS date_length
FROM `hotel reservation dataset`
LIMIT 700;

-- Step 4: Extract the year from arrival_date and count occurrences for each year
SELECT YEAR(STR_TO_DATE(TRIM(arrival_date), '%Y-%m-%d')) AS year, COUNT(*) AS count
FROM `hotel reservation dataset`
GROUP BY year
ORDER BY year;

-- Step 5: Final count for reservations in 2018
SELECT COUNT(Booking_ID) AS reservations_2018
FROM `hotel reservation dataset`
WHERE YEAR(STR_TO_DATE(TRIM(arrival_date), '%Y-%m-%d')) = 2018;

-- Question 5: What is the most commonly booked room type?
SELECT room_type_reserved, COUNT(*) AS count
FROM `hotel reservation dataset`
GROUP BY room_type_reserved
ORDER BY count DESC
LIMIT 1;

-- Question 6: How many reservations fall on a weekend (no_of_weekend_nights > 0)?
SELECT COUNT(*) AS weekend_reservations
FROM `hotel reservation dataset`
WHERE no_of_week_nights > 0;

-- Question 7: What is the highest and lowest lead time for reservations?
SELECT MAX(lead_time) AS highest_lead_time, MIN(lead_time) AS lowest_lead_time
FROM `hotel reservation dataset`;

-- Question 8: What is the most common market segment type for reservations?
SELECT market_segment_type, COUNT(*) AS count
FROM `hotel reservation dataset`
GROUP BY market_segment_type
ORDER BY count DESC
LIMIT 1;

-- Question 9: How many reservations have a booking status of "Confirmed"?
SELECT COUNT(*) AS confirmed_reservations
FROM `hotel reservation dataset`
WHERE booking_status = 'Not_Canceled';

-- Question 10: What is the total number of adults and children across all reservations?
SELECT SUM(no_of_adults) AS total_adults, SUM(no_of_children) AS total_children
FROM `hotel reservation dataset`;

-- Question 11: What is the average number of weekend nights for reservations involving children?
SELECT AVG(no_of_weekend_nights) AS avg_weekend_nights_children
FROM`hotel reservation dataset`
WHERE no_of_children > 0;

-- Question 12: How many reservations were made in each month of the year?
SELECT MONTH(arrival_date) AS month, COUNT(*) AS reservations_count
FROM `hotel reservation dataset`
GROUP BY MONTH(arrival_date)
ORDER BY MONTH;

-- Question 13: What is the average number of nights (both weekend and weekday) spent by guests for each room type?
SELECT room_type_reserved, AVG(no_of_weekend_nights + no_of_week_nights) AS avg_total_nights
FROM `hotel reservation dataset`
GROUP BY room_type_reserved;

-- Question 14: For reservations involving children, what is the most common room type, and what is the average price for that room type?
WITH common_room_type_children AS (
    SELECT room_type_reserved, COUNT(*) AS count
    FROM `hotel reservation dataset`
    WHERE no_of_children > 0
    GROUP BY room_type_reserved
    ORDER BY count DESC
    LIMIT 1
)
SELECT cr.room_type_reserved, AVG(h.avg_price_per_room) AS avg_price
FROM `hotel reservation dataset` h
JOIN common_room_type_children cr
ON h.room_type_reserved = cr.room_type_reserved
WHERE h.no_of_children > 0
GROUP BY cr.room_type_reserved;


-- Question 15: Find the market segment type that generates the highest average price per room.
SELECT market_segment_type, AVG(avg_price_per_room) AS avg_price
FROM `hotel reservation dataset`
GROUP BY market_segment_type
ORDER BY avg_price DESC
LIMIT 1;











    
    
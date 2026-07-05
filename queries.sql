-- =====================================================================
-- University Security System Database — Sample Queries
-- Group 5C: Mantavya Bhojani (202403028), Chovatiya Yash (202403006)
--
-- 40 queries demonstrating filtering, joins, aggregation, subqueries,
-- CTEs, window functions, a stored function, and a trigger.
-- Run schema.sql first.
-- =====================================================================

-- ---------------------------------------------------------------------
-- SECTION 1: Basic filtering & sorting
-- ---------------------------------------------------------------------

-- Q1: All 'High' severity incidents
SELECT Incident_No, Type, Description, TimeReported FROM Incident WHERE Severity = 'High';

-- Q2: Golf carts with a capacity of 8
SELECT Cart_No, Pickup, DropPoint FROM GolfCart WHERE Capacity = 8;

-- Q3: Entry logs from 2025-10-17 with purpose 'Classes'
SELECT Name, Entry_Time, Exit_Time FROM EntryExit
WHERE Purpose = 'Classes' AND DATE(Entry_Time) = '2025-10-17';

-- Q4: All registered cars
SELECT RegistrationNo, Owner_ID FROM Vehicle WHERE VehicleType = 'Car';

-- Q5: Cart rides taken by Student ID 25
SELECT Cart_No FROM Rides_Student WHERE Student_ID = 25;

-- Q6: Cart rides taken by Visitor ID 110
SELECT Cart_No FROM Rides_Visitor WHERE Visitor_ID = 110;

-- Q7: People whose email is not a university address
SELECT Person_Name, Email FROM Person WHERE Email NOT LIKE '%@uni.edu';

-- Q8: Incidents reported before 9:00 AM
SELECT Type, Description, TimeReported FROM Incident WHERE EXTRACT(HOUR FROM TimeReported) < 9;

-- Q9: Lost items not in 'Apparel', stored at 'Gate 1'
SELECT Item_No, ItemCategory, Description FROM LostItem
WHERE ItemCategory != 'Apparel' AND Storage_Location = 'Gate 1';

-- Q10: Delivered parcels, most recent first
SELECT ParcelID, Place, Delivery_Time, Student_ID FROM Parcel
WHERE Status = 'Delivered' ORDER BY Delivery_Time DESC;

-- Q11: Visitors who have not yet exited campus
SELECT Name, Entry_Time, Purpose FROM EntryExit
WHERE Visitor_ID IS NOT NULL AND Exit_Time IS NULL;

-- Q12: Guard duties that were night shifts
SELECT Guard_ID, Place, StartTime, EndTime, Person_ID FROM Guard WHERE StartTime >= '22:00:00';

-- Q13: Lost items with 'laptop' in the description
SELECT * FROM LostItem WHERE Description ILIKE '%laptop%';

-- ---------------------------------------------------------------------
-- SECTION 2: Joins across entities
-- ---------------------------------------------------------------------

-- Q14: Full names and phone numbers of all students
SELECT p.Person_Name, p.Phone, s.Student_ID
FROM Person p
JOIN Student s ON p.Person_ID = s.Person_ID;

-- Q15: Names and genders of all registered guards
SELECT DISTINCT p.Person_Name, p.Gender, p.Email
FROM Person p
JOIN Guard g ON p.Person_ID = g.Person_ID;

-- Q16: Visitors and the students they are visiting
SELECT v_person.Person_Name AS VisitorName, s_person.Person_Name AS StudentName
FROM Visitor v
JOIN Person v_person ON v.Person_ID = v_person.Person_ID
JOIN Student s ON v.Student_ID = s.Student_ID
JOIN Person s_person ON s.Person_ID = s_person.Person_ID;

-- Q17: Lost item description for Claim ID 20
SELECT li.Description, li.ItemCategory, c.Claimer_Details, c.Claim_Date
FROM LostItem li
JOIN Claim c ON li.Item_No = c.Item_No
WHERE c.Claim_ID = 20;

-- Q18: Parcels handled per guard
SELECT p.Person_Name, COUNT(par.ParcelID) AS ParcelCount
FROM Person p
JOIN Guard g ON p.Person_ID = g.Person_ID
JOIN Parcel par ON g.Guard_ID = par.Guard_ID
GROUP BY p.Person_Name
ORDER BY ParcelCount DESC;

-- ---------------------------------------------------------------------
-- SECTION 3: Subqueries
-- ---------------------------------------------------------------------

-- Q19: Students who own a 'Car'
SELECT p.Person_Name
FROM Person p
JOIN Student s ON p.Person_ID = s.Person_ID
WHERE p.Person_ID IN (SELECT Owner_ID FROM Vehicle WHERE VehicleType = 'Car');

-- Q20: Students who reported a 'High' severity incident
SELECT DISTINCT p.Person_Name, p.Phone
FROM Person p
JOIN Student s ON p.Person_ID = s.Person_ID
JOIN Incident i ON s.Student_ID = i.Student_ID
WHERE i.Severity = 'High';

-- Q21: Visitors who rode in a golf cart with capacity 8
SELECT DISTINCT p.Person_Name
FROM Person p
JOIN Visitor v ON p.Person_ID = v.Person_ID
JOIN Rides_Visitor rv ON v.Visitor_ID = rv.Visitor_ID
JOIN GolfCart gc ON rv.Cart_No = gc.Cart_No
WHERE gc.Capacity = 8;

-- Q22: Count of claimed lost items by category
SELECT ItemCategory, COUNT(Item_No) AS TotalClaimed
FROM LostItem
WHERE Status = 'Claimed'
GROUP BY ItemCategory;

-- Q23: Guards on duty when a 'Theft' incident was reported
SELECT DISTINCT p.Person_Name
FROM Person p
JOIN Guard g ON p.Person_ID = g.Person_ID
WHERE g.Duty_Date IN (SELECT DATE(TimeReported) FROM Incident WHERE Type = 'Theft');

-- Q24: Students who have never reported a lost item
SELECT p.Person_Name, s.Student_ID
FROM Student s
JOIN Person p ON s.Person_ID = p.Person_ID
WHERE NOT EXISTS (SELECT 1 FROM LostItem li WHERE li.Student_ID = s.Student_ID);

-- Q25: Guard who handled a specific student's parcel on a specific date
SELECT p.Person_Name AS GuardName
FROM Person p
JOIN Guard g ON p.Person_ID = g.Person_ID
JOIN Parcel par ON g.Guard_ID = par.Guard_ID
WHERE par.Student_ID = 50 AND DATE(par.Delivery_Time) = '2025-10-19';

-- Q26: Pending parcels whose pickup deadline has passed
SELECT par.ParcelID, p.Person_Name AS GuardName, par.Student_ID, par.Pickup_Deadline
FROM Parcel par
JOIN Guard g ON par.Guard_ID = g.Guard_ID
JOIN Person p ON g.Person_ID = p.Person_ID
WHERE par.Status = 'Pending' AND par.Pickup_Deadline < CURRENT_DATE;

-- Q27: Students who filed a 'Noise Complaint' AND lost an 'Electronics' item
SELECT p.Person_Name
FROM Person p
JOIN Student s ON p.Person_ID = s.Person_ID
WHERE s.Student_ID IN (SELECT Student_ID FROM Incident WHERE Type = 'Noise Complaint')
  AND s.Student_ID IN (SELECT Student_ID FROM LostItem WHERE ItemCategory = 'Electronics');

-- Q28: Average duty hours worked by guards, per gate
SELECT Place, AVG(DutyHours) AS AverageHours
FROM Guard
GROUP BY Place
ORDER BY AverageHours DESC;

-- Q29: Visitors who entered on 2025-10-17 and minutes spent on campus
SELECT p.Person_Name, EXTRACT(EPOCH FROM (ee.Exit_Time - ee.Entry_Time)) / 60 AS MinutesOnCampus
FROM EntryExit ee
JOIN Visitor v ON ee.Visitor_ID = v.Visitor_ID
JOIN Person p ON v.Person_ID = p.Person_ID
WHERE DATE(ee.Entry_Time) = '2025-10-17' AND ee.Exit_Time IS NOT NULL;

-- Q30: Students who both reported an incident and claimed a lost item
SELECT DISTINCT p.Person_Name
FROM Person p
JOIN Student s ON p.Person_ID = s.Person_ID
WHERE s.Student_ID IN (SELECT Student_ID FROM Incident WHERE Student_ID IS NOT NULL)
  AND s.Student_ID IN (SELECT li.Student_ID FROM LostItem li JOIN Claim c ON li.Item_No = c.Item_No);

-- Q31: Total parcels per gate, grouped by status
SELECT Place, Status, COUNT(ParcelID) AS TotalParcels
FROM Parcel
GROUP BY Place, Status
ORDER BY Place, Status;

-- Q32: Students who rode a cart also used by a specific visitor
SELECT DISTINCT p.Person_Name
FROM Person p
JOIN Student s ON p.Person_ID = s.Person_ID
JOIN Rides_Student rs ON s.Student_ID = rs.Student_ID
WHERE rs.Cart_No IN (SELECT Cart_No FROM Rides_Visitor WHERE Visitor_ID = 125);

-- Q33: Incidents at the same location where a 'Wallet' was lost
SELECT i.*
FROM Incident i
JOIN Student s ON i.Student_ID = s.Student_ID
JOIN Person p ON s.Person_ID = p.Person_ID
WHERE p.Person_Name IN (
    SELECT p.Person_Name
    FROM Person p
    JOIN Student s ON p.Person_ID = s.Person_ID
    JOIN LostItem li ON s.Student_ID = li.Student_ID
    WHERE li.Description ILIKE '%Wallet%'
);

-- ---------------------------------------------------------------------
-- SECTION 4: CTEs, window functions, CASE, and correlated subqueries
-- ---------------------------------------------------------------------

-- Q34: Car owners and how many 'High' severity incidents each reported
WITH CarOwners AS (
    SELECT s.Student_ID, p.Person_Name
    FROM Student s
    JOIN Person p ON s.Person_ID = p.Person_ID
    JOIN Vehicle v ON p.Person_ID = v.Owner_ID
    WHERE v.VehicleType = 'Car'
)
SELECT co.Person_Name, COUNT(i.Incident_No) AS HighSeverityIncidents
FROM CarOwners co
LEFT JOIN Incident i ON co.Student_ID = i.Student_ID AND i.Severity = 'High'
GROUP BY co.Person_Name
ORDER BY HighSeverityIncidents DESC;

-- Q35: Rank 'Found' lost items by report date, per storage location
SELECT Item_No, Description, ItemCategory, Storage_Location, Report_Date,
       RANK() OVER (PARTITION BY Storage_Location ORDER BY Report_Date ASC) AS AgeRank
FROM LostItem
WHERE Status = 'Found';

-- Q36: Categorize parcels as Overdue / Collected-Resolved / Active
SELECT ParcelID, Student_ID, Status, Pickup_Deadline,
       CASE
           WHEN Status = 'Pending' AND Pickup_Deadline < CURRENT_DATE THEN 'Overdue'
           WHEN Status = 'Delivered' OR Status = 'Cancelled' THEN 'Collected/Resolved'
           ELSE 'Active'
       END AS ParcelCategory
FROM Parcel;

-- Q37: Most recent incident reported by each student
SELECT p.Person_Name, i.Type, i.Description, i.TimeReported
FROM Incident i
JOIN Student s ON i.Student_ID = s.Student_ID
JOIN Person p ON s.Person_ID = p.Person_ID
WHERE i.TimeReported = (
    SELECT MAX(i2.TimeReported) FROM Incident i2 WHERE i2.Student_ID = i.Student_ID
)
ORDER BY p.Person_Name;

-- Q38: Average golf cart rides for visitors visiting a 'Bicycle' owner
SELECT AVG(RideCount) AS AvgRidesPerBicycleVisitor
FROM (
    SELECT v.Visitor_ID, COUNT(rv.Cart_No) AS RideCount
    FROM Visitor v
    JOIN Student s ON v.Student_ID = s.Student_ID
    JOIN Person p ON s.Person_ID = p.Person_ID
    JOIN Vehicle veh ON p.Person_ID = veh.Owner_ID
    LEFT JOIN Rides_Visitor rv ON v.Visitor_ID = rv.Visitor_ID
    WHERE veh.VehicleType = 'Bicycle'
    GROUP BY v.Visitor_ID
) AS VisitorRides;

-- ---------------------------------------------------------------------
-- SECTION 5: Function & trigger demo (defined in schema.sql)
-- ---------------------------------------------------------------------

-- Q39: Use the GetStudentName() function
SELECT GetStudentName(1);

-- Q40: Trigger demo — inserting into Claim auto-updates LostItem.Status to 'Claimed'
-- (See trg_AfterClaimInsert in schema.sql)
-- INSERT INTO Claim (Item_No, Claim_Date, Claimer_Details) VALUES (3, CURRENT_DATE, 'Verified by ID card');
-- SELECT Status FROM LostItem WHERE Item_No = 3;  -- now returns 'Claimed'

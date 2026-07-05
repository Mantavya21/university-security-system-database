-- 1. Person: base entity for the ISA hierarchy (Student / Visitor / Guard)
DROP TABLE IF EXISTS Person CASCADE;
CREATE TABLE Person (
    Person_ID SERIAL PRIMARY KEY,
    Person_Name VARCHAR(80) NOT NULL,
    Phone VARCHAR(20),
    Email VARCHAR(100) UNIQUE,
    Gender VARCHAR(10) CHECK (Gender IN ('Male','Female','Other'))
);

-- 2. Student
DROP TABLE IF EXISTS Student CASCADE;
CREATE TABLE Student (
    Student_ID SERIAL PRIMARY KEY,
    Person_ID INT NOT NULL,
    FOREIGN KEY (Person_ID) REFERENCES Person(Person_ID) ON DELETE CASCADE
);

-- 3. Visitor (optionally linked to the student they are visiting)
DROP TABLE IF EXISTS Visitor CASCADE;
CREATE TABLE Visitor (
    Visitor_ID SERIAL PRIMARY KEY,
    Student_ID INT REFERENCES Student(Student_ID) ON DELETE SET NULL,
    Person_ID INT NOT NULL REFERENCES Person(Person_ID) ON DELETE CASCADE
);

-- 4. Guard
DROP TABLE IF EXISTS Guard CASCADE;
CREATE TABLE Guard (
    Guard_ID SERIAL PRIMARY KEY,
    Duty_Date DATE NOT NULL,
    Place VARCHAR(80),
    StartTime TIME,
    EndTime TIME,
    DutyHours NUMERIC(4,2),
    Person_ID INT NOT NULL REFERENCES Person(Person_ID) ON DELETE CASCADE
);

-- 5. GolfCart
DROP TABLE IF EXISTS GolfCart CASCADE;
CREATE TABLE GolfCart (
    Cart_No SERIAL PRIMARY KEY,
    Capacity INT CHECK (Capacity > 0),
    Pickup VARCHAR(80),
    DropPoint VARCHAR(80)
);

-- 6. Vehicle
DROP TABLE IF EXISTS Vehicle CASCADE;
CREATE TABLE Vehicle (
    RegistrationNo VARCHAR(20) PRIMARY KEY,
    VehicleType VARCHAR(30) CHECK (VehicleType IN ('Car','Bike','Scooter','Bicycle')),
    Owner_ID INT NOT NULL REFERENCES Person(Person_ID) ON DELETE CASCADE
);

-- 7. LostItem
DROP TABLE IF EXISTS LostItem CASCADE;
CREATE TABLE LostItem (
    Item_No SERIAL PRIMARY KEY,
    ItemCategory VARCHAR(50),
    Description TEXT,
    Storage_Location VARCHAR(80),
    Status VARCHAR(20) CHECK (Status IN ('Found','Claimed','Unclaimed')),
    Report_Date DATE,
    Student_ID INT NOT NULL REFERENCES Student(Student_ID) ON DELETE CASCADE
);

-- 8. Claim
DROP TABLE IF EXISTS Claim CASCADE;
CREATE TABLE Claim (
    Claim_ID SERIAL PRIMARY KEY,
    Item_No INT NOT NULL REFERENCES LostItem(Item_No) ON DELETE CASCADE,
    Claim_Date DATE,
    Claimer_Details TEXT
);

-- 9. Parcel
DROP TABLE IF EXISTS Parcel CASCADE;
CREATE TABLE Parcel (
    ParcelID SERIAL PRIMARY KEY,
    Delivery_Time TIMESTAMP,
    Place VARCHAR(80),
    ReceiverID INT REFERENCES Person(Person_ID) ON DELETE SET NULL,
    Status VARCHAR(20) CHECK (Status IN ('Pending','Delivered','Cancelled')),
    Pickup_Deadline DATE,
    Guard_ID INT REFERENCES Guard(Guard_ID) ON DELETE SET NULL,
    Student_ID INT REFERENCES Student(Student_ID) ON DELETE SET NULL
);

-- 10. Incident
DROP TABLE IF EXISTS Incident CASCADE;
CREATE TABLE Incident (
    Incident_No SERIAL PRIMARY KEY,
    Type VARCHAR(50),
    Severity VARCHAR(20) CHECK (Severity IN ('Low','Medium','High')),
    Description TEXT,
    Status VARCHAR(20) CHECK (Status IN ('Open','Resolved','Under Review')),
    TimeReported TIMESTAMP,
    Student_ID INT REFERENCES Student(Student_ID) ON DELETE SET NULL
);

-- 11. EntryExit
DROP TABLE IF EXISTS EntryExit CASCADE;
CREATE TABLE EntryExit (
    ID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Entry_Time TIMESTAMP,
    Exit_Time TIMESTAMP,
    Purpose VARCHAR(120),
    Student_ID INT REFERENCES Student(Student_ID) ON DELETE SET NULL,
    Visitor_ID INT REFERENCES Visitor(Visitor_ID) ON DELETE SET NULL
);

-- 12. Rides_Student (M:N between GolfCart and Student)
DROP TABLE IF EXISTS Rides_Student CASCADE;
CREATE TABLE Rides_Student (
    Cart_No INT REFERENCES GolfCart(Cart_No) ON DELETE CASCADE,
    Student_ID INT REFERENCES Student(Student_ID) ON DELETE CASCADE,
    PRIMARY KEY (Cart_No, Student_ID)
);

-- 13. Rides_Visitor (M:N between GolfCart and Visitor)
DROP TABLE IF EXISTS Rides_Visitor CASCADE;
CREATE TABLE Rides_Visitor (
    Cart_No INT REFERENCES GolfCart(Cart_No) ON DELETE CASCADE,
    Visitor_ID INT REFERENCES Visitor(Visitor_ID) ON DELETE CASCADE,
    PRIMARY KEY (Cart_No, Visitor_ID)
);

-- Function: get a student's full name from their Student_ID
CREATE OR REPLACE FUNCTION GetStudentName(s_id INT)
RETURNS VARCHAR(80) AS $$
DECLARE
    student_name VARCHAR(80);
BEGIN
    SELECT p.Person_Name
    INTO student_name
    FROM Person p
    JOIN Student s ON p.Person_ID = s.Person_ID
    WHERE s.Student_ID = s_id;
    RETURN student_name;
END;
$$ LANGUAGE plpgsql;

-- Trigger: auto-mark a lost item as 'Claimed' when a Claim is inserted
CREATE OR REPLACE FUNCTION UpdateLostItemStatus()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE LostItem
    SET Status = 'Claimed'
    WHERE Item_No = NEW.Item_No;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_AfterClaimInsert
AFTER INSERT ON Claim
FOR EACH ROW
EXECUTE FUNCTION UpdateLostItemStatus();

-- Student: Emre Yavuz 22SOFT1022
-- Assignment: Hospital Database SQL Script
-- Date: May 04, 2025
-- Notes:
-- - Query 10 modified to use 2023 dates for sample data consistency.
-- - CHECK constraints require MySQL 8.0+.
-- - Passwords are plain text for sample data; in production, SHA-256 hashing would be used.

-- PART A: CREATING THE TABLES

-- Lookup table for gender types. Keeps things like 'M' for male, 'F' for female, etc.
CREATE TABLE GenderType (
    genderCode CHAR(1) PRIMARY KEY,
    description VARCHAR(50) NOT NULL
);

-- Lookup table for visit statuses. Tracks if a visit is scheduled, completed, or canceled.
CREATE TABLE VisitStatus (
    statusCode VARCHAR(20) PRIMARY KEY,
    description VARCHAR(50) NOT NULL
);

-- SystemUser table. Everyone—patients, doctors, staff—starts here.
CREATE TABLE SystemUser (
    userId INT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    fullName VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255)
);

-- Add email format check. Makes sure emails have an @ and a domain.
ALTER TABLE SystemUser ADD CONSTRAINT chk_email CHECK (email LIKE '%@%.%');

-- Add comment for password hashing. Passwords should be stored as SHA-256 hashes.
ALTER TABLE SystemUser MODIFY COLUMN password VARCHAR(255) 
COMMENT 'SHA-256 ile hashlenmiş parola';

-- UserRole table. Tracks roles (patient, doctor, staff). Users can have multiple roles.
CREATE TABLE UserRole (
    userId INT,
    role ENUM('patient', 'doctor', 'staff') NOT NULL,
    PRIMARY KEY (userId, role),
    FOREIGN KEY (userId) REFERENCES SystemUser(userId) ON DELETE CASCADE
);

-- Patient table. Every patient is a user, with extra details like birth date or gender.
CREATE TABLE Patient (
    userId INT PRIMARY KEY,
    birthDate DATE,
    genderCode CHAR(1) NOT NULL,
    insurancePolId VARCHAR(50),
    FOREIGN KEY (userId) REFERENCES SystemUser(userId) ON DELETE CASCADE,
    FOREIGN KEY (genderCode) REFERENCES GenderType(genderCode)
);

-- Add comment for insurance ID encryption. Should be stored encrypted.
ALTER TABLE Patient MODIFY COLUMN insurancePolId VARCHAR(50) 
COMMENT 'Şifrelenmiş olarak saklanmalı';

-- Department table. Cardiology, neurology, etc. Managers are defined without foreign keys initially.
CREATE TABLE Department (
    departmentID INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100),
    medManagerID INT, -- Will reference Doctor later
    adManagerID INT   -- Will reference Staff later
);

-- Doctor table. Tracks the doctor’s specialty and department (if assigned).
CREATE TABLE Doctor (
    userId INT PRIMARY KEY,
    specialty VARCHAR(100),
    departmentId INT, -- Will reference Department later
    FOREIGN KEY (userId) REFERENCES SystemUser(userId) ON DELETE CASCADE
);

-- Staff table. Nurses, receptionists, technicians, their roles are here.
CREATE TABLE Staff (
    userId INT PRIMARY KEY,
    role VARCHAR(50),
    FOREIGN KEY (userId) REFERENCES SystemUser(userId) ON DELETE CASCADE
);

-- Add foreign keys for Department and Doctor to resolve cyclic dependency.
ALTER TABLE Department
    ADD FOREIGN KEY (medManagerID) REFERENCES Doctor(userId) ON DELETE SET NULL,
    ADD FOREIGN KEY (adManagerID) REFERENCES Staff(userId) ON DELETE SET NULL;

ALTER TABLE Doctor
    ADD FOREIGN KEY (departmentId) REFERENCES Department(departmentID) ON DELETE SET NULL;

-- Laboratory table. Labs might be tied to a department, with a doctor and technician.
CREATE TABLE Laboratory (
    labId INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    connectedDept INT,
    respDoctorID INT,
    respSID INT,
    FOREIGN KEY (connectedDept) REFERENCES Department(departmentID) ON DELETE SET NULL,
    FOREIGN KEY (respDoctorID) REFERENCES Doctor(userId) ON DELETE SET NULL,
    FOREIGN KEY (respSID) REFERENCES Staff(userId) ON DELETE SET NULL
);

-- Allergies table. Patients can have multiple allergies, stored separately.
CREATE TABLE Allergies (
    userId INT,
    alID INT,
    allergyName VARCHAR(100) NOT NULL,
    PRIMARY KEY (userId, alID),
    FOREIGN KEY (userId) REFERENCES Patient(userId) ON DELETE CASCADE
);

-- Visit table. Tracks patient-doctor visits, date, time, and status. AUTO_INCREMENT removed.
CREATE TABLE Visit (
    visitId INT PRIMARY KEY, -- AUTO_INCREMENT removed
    patientId INT,
    doctorId INT,
    date DATE NOT NULL,
    time TIME NOT NULL,
    statusCode VARCHAR(20) NOT NULL,
    UNIQUE (patientId, doctorId, date, time),
    FOREIGN KEY (patientId) REFERENCES Patient(userId) ON DELETE CASCADE,
    FOREIGN KEY (doctorId) REFERENCES Doctor(userId) ON DELETE CASCADE,
    FOREIGN KEY (statusCode) REFERENCES VisitStatus(statusCode)
);

-- Add date check. Ensures visit dates are on or after 2000-01-01.
ALTER TABLE Visit ADD CONSTRAINT chk_visit_date CHECK (date >= '2000-01-01');

-- Report table. Stores the doctor’s diagnosis, billing, and links to a visit.
CREATE TABLE Report (
    reportId INT PRIMARY KEY,
    diagnosis TEXT NOT NULL,
    billing DECIMAL(8,2),
    visitId INT,
    FOREIGN KEY (visitId) REFERENCES Visit(visitId) ON DELETE SET NULL
);

-- Prescription table. Medication, instructions, and links to a visit.
CREATE TABLE Prescription (
    prescriptionId INT PRIMARY KEY,
    medicationName VARCHAR(100) NOT NULL,
    dosageInstructions TEXT,
    visitId INT,
    FOREIGN KEY (visitId) REFERENCES Visit(visitId) ON DELETE SET NULL
);

-- Test table. Tracks tests during a visit, results, and links. AUTO_INCREMENT removed.
CREATE TABLE Test (
    testId INT PRIMARY KEY, -- AUTO_INCREMENT removed
    visitId INT,
    name VARCHAR(100) NOT NULL,
    labId INT,
    result TEXT,
    reportId INT,
    prescriptionId INT,
    FOREIGN KEY (visitId) REFERENCES Visit(visitId) ON DELETE CASCADE,
    FOREIGN KEY (labId) REFERENCES Laboratory(labId) ON DELETE SET NULL,
    FOREIGN KEY (reportId) REFERENCES Report(reportId) ON DELETE SET NULL,
    FOREIGN KEY (prescriptionId) REFERENCES Prescription(prescriptionId) ON DELETE SET NULL
);

-- Add indexes for performance. Speeds up queries on patient, doctor, date, and visit lookups.
CREATE INDEX idx_visit_patient ON Visit(patientId);
CREATE INDEX idx_visit_doctor_date ON Visit(doctorId, date);
CREATE INDEX idx_test_visit ON Test(visitId);

-- PART B: INSERTING THE DATA

-- Gender types. Simple but keeps things consistent.
INSERT INTO GenderType VALUES
('M', 'Male'),
('F', 'Female'),
('O', 'Other');

-- Visit statuses. For example, 'canceled' means the patient didn’t show up.
INSERT INTO VisitStatus VALUES
('scheduled', 'Scheduled'),
('completed', 'Completed'),
('canceled', 'Canceled');

-- SystemUsers. Everyone goes here—patients, doctors, staff. Phone and address can be empty.
INSERT INTO SystemUser (userId, email, password, fullName, phone, address) VALUES
(1, 'john.doe@email.com', 'password123', 'John Doe', '555-123-4567', '123 Main St'),
(2, 'jane.smith@email.com', 'password456', 'Jane Smith', '555-234-5678', '456 Elm St'),
(3, 'bob.johnson@email.com', 'password789', 'Bob Johnson', '555-345-6789', '789 Oak St'),
(4, 'alice.williams@email.com', 'passwordabc', 'Alice Williams', '555-456-7890', '101 Pine St'),
(5, 'charlie.brown@email.com', 'passworddef', 'Charlie Brown', '555-567-8901', '202 Maple St'),
(6, 'diana.miller@email.com', 'passwordghi', 'Diana Miller', '555-678-9012', '303 Cedar St'),
(7, 'edward.davis@email.com', 'passwordjkl', 'Edward Davis', '555-789-0123', '404 Birch St'),
(8, 'fiona.garcia@email.com', 'passwordmno', 'Fiona Garcia', '555-890-1234', '505 Spruce St'),
(9, 'george.rodriguez@email.com', 'passwordpqr', 'George Rodriguez', '555-901-2345', '606 Walnut St'),
(10, 'hannah.martinez@email.com', 'passwordstu', 'Hannah Martinez', '555-012-3456', '707 Cherry St'),
(11, 'ivan.hernandez@email.com', 'passwordvwx', 'Ivan Hernandez', '555-123-4568', '808 Ash St'),
(12, 'julie.lopez@email.com', 'passwordyz1', 'Julie Lopez', '555-234-5678', '909 Oak St'),
(13, 'kevin.gonzalez@email.com', 'password234', 'Kevin Gonzalez', '555-345-6789', '111 Elm St'),
(14, 'lisa.wilson@email.com', 'password567', 'Lisa Wilson', '555-456-7890', '222 Pine St'),
(15, 'mike.anderson@email.com', 'password890', 'Mike Anderson', '555-567-8901', '333 Maple St'),
(16, 'nancy.thomas@email.com', 'passwordabc', 'Nancy Thomas', '555-678-9012', '444 Cedar St'),
(17, 'oscar.taylor@email.com', 'passworddef', 'Oscar Taylor', '555-789-0123', '555 Birch St'),
(18, 'patricia.moore@email.com', 'passwordghi', 'Patricia Moore', '555-890-1234', '666 Spruce St'),
(19, 'quincy.jackson@email.com', 'passwordjkl', 'Quincy Jackson', '555-901-2345', '777 Walnut St'),
(20, 'rachel.martin@email.com', 'passwordmno', 'Rachel Martin', '555-012-3456', '888 Cherry St'),
(21, 'staff1@email.com', 'staffpass1', 'Staff Member 1', '555-111-2222', '100 Staff St'),
(22, 'staff2@email.com', 'staffpass2', 'Staff Member 2', '555-222-3333', '200 Staff St'),
(23, 'staff3@email.com', 'staffpass3', 'Staff Member 3', '555-333-4444', '300 Staff St'),
(24, 'staff4@email.com', 'staffpass4', 'Staff Member 4', '555-444-5555', '400 Staff St');

-- User roles. Assign roles to users (patient, doctor, staff).
INSERT INTO UserRole (userId, role) VALUES
(1, 'patient'),
(2, 'patient'),
(3, 'patient'),
(4, 'patient'),
(5, 'patient'),
(6, 'patient'),
(7, 'patient'),
(8, 'doctor'),
(9, 'doctor'),
(10, 'doctor'),
(11, 'doctor'),
(12, 'doctor'),
(13, 'doctor'),
(14, 'doctor'),
(15, 'doctor'),
(16, 'doctor'),
(17, 'doctor'),
(18, 'doctor'),
(19, 'doctor'),
(20, 'staff'),
(21, 'staff'),
(22, 'staff'),
(23, 'staff'),
(24, 'staff');

-- Patients. Each is a user with extra info like insurance.
INSERT INTO Patient VALUES
(1, '1980-05-15', 'M', 'INS12345'),
(2, '1975-09-22', 'F', 'INS23456'),
(3, '1990-03-10', 'M', 'INS34567'),
(4, '1988-07-30', 'F', 'INS45678'),
(5, '1965-12-25', 'M', 'INS56789'),
(6, '1972-04-18', 'F', 'INS67890'),
(7, '1995-01-05', 'M', 'INS78901');

-- Departments. Each has a doctor and staff manager (if assigned).
INSERT INTO Department VALUES
(1, 'Cardiology', 'Heart and cardiovascular system', 8, 23),
(2, 'Neurology', 'Nervous system', 9, 23),
(3, 'Orthopedics', 'Musculoskeletal system', 10, 23),
(4, 'Pediatrics', 'Child health', 11, 23),
(5, 'Dermatology', 'Skin', 12, 23),
(6, 'Ophthalmology', 'Eye', 13, 23);

-- Doctors. Department assignments included directly.
INSERT INTO Doctor VALUES
(8, 'Cardiology', 1),
(9, 'Neurology', 2),
(10, 'Orthopedics', 3),
(11, 'Pediatrics', 4),
(12, 'Dermatology', 5),
(13, 'Ophthalmology', 6),
(14, 'Cardiology', 1),
(15, 'Neurology', 2),
(16, 'Orthopedics', 3),
(17, 'Pediatrics', 4),
(18, 'Dermatology', 5),
(19, 'Ophthalmology', 6);

-- Staff. Nurses, technicians, receptionists, their roles are here.
INSERT INTO Staff VALUES
(20, 'Nurse'),
(21, 'Receptionist'),
(22, 'Lab Technician'),
(23, 'Administrative Manager'),
(24, 'Nurse');

-- Laboratories. Each is linked to a department (optional), with a doctor and technician.
INSERT INTO Laboratory VALUES
(1, 'Cardiac Lab', 1, 8, 22),
(2, 'Neuro Lab', 2, 9, 22),
(3, 'Ortho Lab', 3, 10, 22),
(4, 'Pediatric Lab', 4, 11, 22),
(5, 'Dermatology Lab', 5, 12, 22),
(6, 'Ophthalmology Lab', 6, 13, 22);

-- Allergies. Some patients have multiple allergies, so we store them here.
INSERT INTO Allergies VALUES
(1, 1, 'Penicillin'),
(1, 2, 'Peanuts'),
(2, 1, 'Shellfish'),
(3, 1, 'Dust mites'),
(4, 1, 'Pollen'),
(5, 1, 'Latex'),
(6, 1, 'Eggs'),
(7, 1, 'Soy'),
(4, 2, 'Penicillin'),
(5, 2, 'Dairy');

-- Visits. Tracks who saw which doctor, when, and the status. Explicit IDs used.
INSERT INTO Visit (visitId, patientId, doctorId, date, time, statusCode) VALUES
(1, 1, 8, '2023-01-15', '09:00:00', 'completed'),
(2, 1, 9, '2023-01-20', '10:30:00', 'completed'),
(3, 2, 8, '2023-01-17', '11:00:00', 'completed'),
(4, 3, 10, '2023-01-22', '14:00:00', 'completed'),
(5, 4, 11, '2023-01-25', '15:30:00', 'completed'),
(6, 5, 12, '2023-01-27', '09:30:00', 'completed'),
(7, 6, 13, '2023-01-30', '10:00:00', 'completed'),
(8, 1, 8, '2023-02-15', '14:00:00', 'canceled'),
(9, 2, 9, '2023-02-17', '11:30:00', 'canceled'),
(10, 3, 10, '2023-02-20', '09:00:00', 'canceled'),
(11, 4, 11, '2023-02-22', '10:30:00', 'canceled'),
(12, 1, 8, '2023-03-15', '09:00:00', 'completed'),
(13, 1, 9, '2023-04-20', '10:30:00', 'scheduled'),
(14, 2, 8, '2023-04-25', '11:00:00', 'scheduled'),
(15, 3, 10, '2023-04-28', '14:00:00', 'scheduled');

-- Reports. Diagnosis, billing, and which visit they’re tied to.
INSERT INTO Report (reportId, diagnosis, billing, visitId) VALUES
(1, 'Hypertension, recommended lifestyle changes', 150.00, 1),
(2, 'Migraine, prescribed medication', 175.00, 2),
(3, 'Arthritis, physical therapy recommended', 200.00, 3),
(4, 'Common cold, rest and fluids', 100.00, 5),
(5, 'Eczema, prescribed topical treatment', 125.00, 6),
(6, 'Cataracts, surgery recommended', 300.00, 7),
(7, 'Follow-up for hypertension, medication adjusted', 100.00, 12);

-- Prescriptions. Medication, instructions, and which visit they’re tied to.
INSERT INTO Prescription (prescriptionId, medicationName, dosageInstructions, visitId) VALUES
(1, 'Lisinopril', '10mg once daily', 1),
(2, 'Hydrochlorothiazide', '25mg once daily', 1),
(3, 'Sumatriptan', '50mg as needed for migraine', 2),
(4, 'Propranolol', '40mg twice daily', 2),
(5, 'Ibuprofen', '800mg three times daily with food', 3),
(6, 'Naproxen', '500mg twice daily as needed for pain', 4),
(7, 'Acetaminophen', '500mg every 6 hours as needed', 5),
(8, 'Hydrocortisone Cream', 'Apply to affected areas twice daily', 6),
(9, 'Cetirizine', '10mg once daily', 6),
(10, 'Timolol Eye Drops', '1 drop in affected eye twice daily', 7),
(11, 'Amlodipine', '5mg once daily', 12);

-- Tests. Links to a visit, lab, and optionally a report or prescription.
INSERT INTO Test (testId, visitId, name, labId, result, reportId, prescriptionId) VALUES
(1, 1, 'Blood Pressure', 1, '140/90 mmHg', 1, 1),
(2, 1, 'ECG', 1, 'Normal sinus rhythm', 1, 2),
(3, 1, 'Cholesterol Panel', 1, 'Total: 220, LDL: 140, HDL: 45', 1, 2),
(4, 2, 'MRI Brain', 2, 'No abnormalities detected', 2, 3),
(5, 2, 'EEG', 2, 'Normal', 2, 4),
(6, 3, 'X-ray Hip', 3, 'Mild osteoarthritis', 3, 5),
(7, 3, 'Blood Test', 1, 'Normal', 3, NULL),
(8, 4, 'X-ray Knee', 3, 'Moderate osteoarthritis', 3, 6),
(9, 4, 'Blood Test', 1, 'Normal', 3, NULL),
(10, 5, 'Strep Test', 4, 'Negative', 4, 7),
(11, 6, 'Skin Biopsy', 5, 'Consistent with eczema', 5, 8),
(12, 6, 'Allergy Test', 5, 'Positive for dust mites', 5, 9),
(13, 7, 'Eye Pressure Test', 6, 'Elevated at 25 mmHg', 6, 10),
(14, 7, 'Vision Test', 6, '20/40 right eye, 20/60 left eye', 6, NULL),
(15, 12, 'Blood Pressure', 1, '130/85 mmHg', 7, 11);

-- Transaction example. Adds a new visit and report, linking them atomically.
START TRANSACTION;
INSERT INTO Visit (visitId, patientId, doctorId, date, time, statusCode) 
VALUES (16, 1, 8, '2023-05-01', '14:00:00', 'scheduled');
INSERT INTO Report (reportId, diagnosis, billing, visitId) 
VALUES (8, 'Routine checkup', 120.00, 16);
COMMIT;

-- PART C: QUERIES

-- 1. Which labs are tied to which departments, and who’s in charge? List them all.
SELECT
    l.labId,
    l.name AS labName,
    d.name AS departmentName,
    doc.userId AS doctorId,
    u1.fullName AS doctorName,
    s.userId AS technicianId,
    u2.fullName AS technicianName
FROM
    Laboratory l
LEFT JOIN
    Department d ON l.connectedDept = d.departmentID
LEFT JOIN
    Doctor doc ON l.respDoctorID = doc.userId
JOIN
    SystemUser u1 ON doc.userId = u1.userId
LEFT JOIN
    Staff s ON l.respSID = s.userId
JOIN
    SystemUser u2 ON s.userId = u2.userId;

-- 2. Which departments have more than 5 doctors? Let’s count.
SELECT
    d.departmentID,
    d.name,
    COUNT(doc.userId) AS doctorCount
FROM
    Department d
LEFT JOIN
    Doctor doc ON d.departmentID = doc.departmentId
GROUP BY
    d.departmentID, d.name
HAVING
    COUNT(doc.userId) > 5;

-- 3. Find all tests ordered during a visit for a patient. Using doctorId = 8, patientId = 1
SELECT
    t.testId,
    t.visitId,
    v.patientId,
    p.fullName AS patientName,
    v.doctorId,
    d.fullName AS doctorName,
    v.date,
    v.time,
    t.name AS testName,
    l.name AS labName,
    t.result
FROM
    Test t
JOIN
    Visit v ON t.visitId = v.visitId
JOIN
    SystemUser p ON v.patientId = p.userId
JOIN
    SystemUser d ON v.doctorId = d.userId
LEFT JOIN
    Laboratory l ON t.labId = l.labId
WHERE
    v.doctorId = 8 AND v.patientId = 1;

-- 4. Which labs ran tests for patients from other departments? Find cross-department cases.
SELECT DISTINCT
    l.labId,
    l.name AS labName,
    l.connectedDept AS labDepartment,
    doc.departmentId AS patientDoctorDepartment
FROM
    Laboratory l
JOIN
    Test t ON l.labId = t.labId
JOIN
    Visit v ON t.visitId = v.visitId
JOIN
    Doctor doc ON v.doctorId = doc.userId
WHERE
    l.connectedDept <> doc.departmentId;

-- 5. Find technicians whose labs ran more than 10 tests in a given month. Using '2023-01'
SELECT
    s.userId AS technicianId,
    u.fullName AS technicianName,
    l.labId,
    l.name AS labName,
    COUNT(t.testId) AS testCount
FROM
    Staff s
JOIN
    Laboratory l ON s.userId = l.respSID
JOIN
    Test t ON l.labId = t.labId
JOIN
    Visit v ON t.visitId = v.visitId
JOIN
    SystemUser u ON s.userId = u.userId
WHERE
    DATE_FORMAT(v.date, '%Y-%m') = '2023-01'
GROUP BY
    s.userId, u.fullName, l.labId, l.name
HAVING
    COUNT(t.testId) > 10;

-- 6. List all visits for a patient, sorted by date. Using patientId = 1
SELECT
    v.visitId,
    v.patientId,
    u1.fullName AS patientName,
    v.doctorId,
    u2.fullName AS doctorName,
    v.date,
    v.time,
    vs.description AS status
FROM
    Visit v
JOIN
    SystemUser u1 ON v.patientId = u1.userId
JOIN
    SystemUser u2 ON v.doctorId = u2.userId
JOIN
    VisitStatus vs ON v.statusCode = vs.statusCode
WHERE
    v.patientId = 1
ORDER BY
    v.date, v.time;

-- 7. Which patients canceled more than 3 visits? Let’s count.
SELECT
    v.patientId,
    u.fullName AS patientName,
    COUNT(*) AS canceledVisits
FROM
    Visit v
JOIN
    SystemUser u ON v.patientId = u.userId
WHERE
    v.statusCode = 'canceled'
GROUP BY
    v.patientId, u.fullName
HAVING
    COUNT(*) > 3;

-- 8. Find patients who never scheduled a visit.
SELECT
    p.userId,
    u.fullName
FROM
    Patient p
JOIN
    SystemUser u ON p.userId = u.userId
LEFT JOIN
    Visit v ON p.userId = v.patientId
WHERE
    v.patientId IS NULL;

-- 9. Which doctors has a patient seen? Using patientId = 1
SELECT DISTINCT
    v.doctorId,
    u.fullName AS doctorName,
    d.specialty,
    dep.name AS departmentName
FROM
    Visit v
JOIN
    SystemUser u ON v.doctorId = u.userId
JOIN
    Doctor d ON v.doctorId = d.userId
LEFT JOIN
    Department dep ON d.departmentId = dep.departmentID
WHERE
    v.patientId = 1;

-- 10. How many visits did each doctor have in early January 2023? Count them.
SELECT
    v.doctorId,
    u.fullName AS doctorName,
    COUNT(*) AS visitCount
FROM
    Visit v
JOIN
    SystemUser u ON v.doctorId = u.userId
WHERE
    v.date BETWEEN '2023-01-01' AND '2023-01-07'
GROUP BY
    v.doctorId, u.fullName;

-- 11. Get a patient’s full visit history (visits, reports, prescriptions). Using patientId = 1
SELECT
    v.visitId,
    v.patientId,
    up.fullName AS patientName,
    v.doctorId,
    ud.fullName AS doctorName,
    v.date,
    v.time,
    vs.description AS status,
    r.diagnosis,
    r.billing,
    t.name AS testName,
    t.result,
    p.medicationName,
    p.dosageInstructions
FROM
    Visit v
JOIN
    SystemUser up ON v.patientId = up.userId
JOIN
    SystemUser ud ON v.doctorId = ud.userId
JOIN
    VisitStatus vs ON v.statusCode = vs.statusCode
LEFT JOIN
    Test t ON v.visitId = t.visitId
LEFT JOIN
    Report r ON v.visitId = r.visitId
LEFT JOIN
    Prescription p ON v.visitId = p.visitId
WHERE
    v.patientId = 1
ORDER BY
    v.date, v.time;
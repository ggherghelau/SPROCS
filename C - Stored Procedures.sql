-- Stored Procedures (Sprocs)
-- File: C - Stored Procedures.sql

USE [A01-School]
GO

-- Take the following queries and turn them into stored procedures.

-- 1.   Selects the studentID's, CourseID and mark where the Mark is between 70 and 80
SELECT  StudentID, CourseId, Mark
FROM    Registration
WHERE   Mark BETWEEN 70 AND 80 -- BETWEEN is inclusive
--      Place this in a stored procedure that has two parameters,
--      one for the upper value and one for the lower value.
--      Call the stored procedure ListStudentMarksByRange

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'ListStudentMarksByRange')
    DROP PROCEDURE ListStudentMarksByRange
GO

CREATE PROCEDURE ListStudentMarksByRange
  
    @MinMark    decimal,
    @MaxMark    decimal
AS
    IF @MinMark IS NULL OR @MAxMark IS NULL
        RAISERROR('NULL is not an accepted value', 16, 1)
    ELSE IF @MinMark > @MaxMark
        RAISERROR('The lower limit cannot be bigger than the upper limit.', 16, 1)
    ELSE IF @MinMark<0 
        RAISERROR('The mark should be greater or equal to 0', 16, 1)
    ELSE IF @MAxMark >100
        RAISERROR('The mark should be lesser or equal to 100', 16, 1)
    ELSE
        SELECT  StudentID, CourseID, Mark
        FROM    Registration            --these 3 lines are only one statement, so we don't need begin and end
        WHERE   Mark BETWEEN @MinMark AND @MaxMark
RETURN
GO

EXEC    ListStudentMarksByRange 80, 100
/* ----------------------------------------------------- */

-- 2.   Selects the Staff full names and the Course ID's they teach.
SELECT  DISTINCT -- The DISTINCT keyword will remove duplate rows from the results
        FirstName + ' ' + LastName AS 'Staff Full Name',
        CourseId
FROM    Staff S
    INNER JOIN Registration R
        ON S.StaffID = R.StaffID
ORDER BY 'Staff Full Name', CourseId
--      Place this in a stored procedure called CourseInstructors.

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'CourseInstructors')
    DROP PROCEDURE CourseInstructors
GO
CREATE PROCEDURE CourseInstructors
AS
    SELECT  DISTINCT 
        FirstName + ' ' + LastName AS 'Staff Full Name',
        CourseId
    FROM    Staff S
    INNER JOIN Registration R
        ON S.StaffID = R.StaffID
    ORDER BY 'Staff Full Name', CourseId
RETURN
GO

EXEC CourseInstructors

/* ----------------------------------------------------- */

-- 3.   Selects the students first and last names who have last names starting with S.
SELECT  FirstName, LastName
FROM    Student
WHERE   LastName LIKE 'S%'
--      Place this in a stored procedure called FindStudentByLastName.
--      The parameter should be called @PartialName.
--      Do NOT assume that the '%' is part of the value in the parameter variable;
--      Your solution should concatenate the @PartialName with the wildcard.

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'FindStudentByLastName')
    DROP PROCEDURE FindStudentByLastName
GO
CREATE PROCEDURE FindStudentByLastName
    @PartialName    varchar(35)
AS
    IF @PartialName IS NULL
    BEGIN
        RAISERROR('The name has to have a value.', 16, 1)
    END
    ELSE
    BEGIN
        SELECT  FirstName, LastName
        FROM    Student
        WHERE   LastName LIKE @PartialName + '%'
    END
RETURN
GO

EXEC FindStudentByLastName B
/* ----------------------------------------------------- */

-- 4.   Selects the CourseID's and Coursenames where the CourseName contains the word 'programming'.
SELECT  CourseId, CourseName
FROM    Course
WHERE   CourseName LIKE '%programming%'
--      Place this in a stored procedure called FindCourse.
--      The parameter should be called @PartialName.
--      Do NOT assume that the '%' is part of the value in the parameter variable.

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE = N'PROCEDURE' AND ROUTINE_NAME = 'FindCourse')
    DROP PROCEDURE FindCourse
GO
CREATE PROCEDURE FindCourse
    @PartialName    varchar(35)
AS
    IF @PartialName IS NULL
    BEGIN
        RAISERROR('Last name has to have a value', 16, 1)
    END
    ELSE
    BEGIN
        SELECT  CourseId, CourseName
        FROM    Course
        WHERE   CourseName LIKE @PartialName + '%'
    END
RETURN
GO

EXEC FindCourse B
/* ----------------------------------------------------- */

-- 5.   Selects the Payment Type Description(s) that have the highest number of Payments made.
SELECT PaymentTypeDescription
FROM   Payment 
    INNER JOIN PaymentType 
        ON Payment.PaymentTypeID = PaymentType.PaymentTypeID
GROUP BY PaymentType.PaymentTypeID, PaymentTypeDescription 
HAVING COUNT(PaymentType.PaymentTypeID) >= ALL (SELECT COUNT(PaymentTypeID)
                                                FROM Payment 
                                                GROUP BY PaymentTypeID)
--      Place this in a stored procedure called MostFrequentPaymentTypes.


-- 6. Select the current Staff members that are in a particular job position
SELECT  FirstName + ' ' + LastName AS 'StaffFullName'
FROM    Position P
    INNER JOIN Staff S ON s.PositionID = P.PositionID
WHERE   DateReleased IS NULL
AND     PositionDescription = 'Instructor'
-- Place this in a stored procedure called StaffByPosition


-- 7. Select the staff members that have taught a particular course (e.g.: 'DMIT101')
SELECT  DISTINCT FirstName + ' ' + LastName AS 'StaffFullName',
        CourseID
FROM    Registration R
    INNER JOIN Staff S ON S.StaffID = R.StaffID
WHERE   DateReleased IS NULL
AND     CourseID = 'DMIT101'
-- This select should also accommodate inputs with wildcards. (Change = to LIKE)
-- Place this in a stored procedure called StaffByCourseExperience
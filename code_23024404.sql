-- Creating a new schema for the database
DROP DATABASE `co-workingSpace`;
CREATE SCHEMA `co-workingSpace`;

-- Setting this schema to be active
USE `co-workingSpace`;

-- Creating a location table, with several relevant columns, to store information about each co-working space location
-- LocationID is set to auto_increment, all primary keys will be set to this, this ensures uniqueness
-- and means primary keys do not have to be managed manually
CREATE TABLE location(
    locationID int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    locationName VARCHAR(20) NOT NULL,
    address VARCHAR(40) NOT NULL,
    capacity INT NOT NULL
);

-- Populating this table with test data
INSERT INTO location (locationName, address, capacity) VALUES
   ('North Cardiff', '123 North Cardiff Street', 30),
   ('North-West Cardiff', '456 North-West Cardiff Close', 45);

-- Test query - selecting every location that has a greater capacity than 30
SELECT * FROM location WHERE capacity >30;

-- Creating a users table, to store information about users
CREATE TABLE users(
    userID int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    usersLocationID int NOT NULL,
    firstName VARCHAR(40) NOT NULL,
    surname VARCHAR(40) NOT NULL,
    email VARCHAR(40) NOT NULL,
    membership_type VARCHAR(20),
    CONSTRAINT usersLocationID_FK FOREIGN KEY (usersLocationID) REFERENCES location(locationID)
);

-- Changing the name of the membership_type column to follow better naming conventions
ALTER TABLE users
CHANGE membership_type membershipType VARCHAR(20);

-- Populating this table with test data
INSERT INTO users (usersLocationID, firstName, surname, email, membershipType) VALUES
    (1, 'John', 'Doe', 'john.doe@example.com', 'Part-Time'),
    (2, 'Jane', 'Smith', 'jane.smith@example.com', 'Full-Time'),
    (1, 'Alice', 'Johnson', 'alice.johnson@example.com', 'Daily-Rate Payer'),
    (2, 'Bob', 'Brown', 'bob.brown@example.com', NULL),
    (1, 'Emma', 'Wilson', 'emma.wilson@example.com', 'Part-Time'),
    (2, 'James', 'Smith', 'james.smith@example.com', 'Full-Time'),
    (1, 'Olivia', 'Johnson', 'olivia.johnson@example.com', 'Full-Time'),
    (2, 'William', 'Brown', 'william.brown@example.com', NULL),
    (1, 'Sophia', 'Jones', 'sophia.jones@example.com', 'Part-Time'),
    (2, 'Benjamin', 'Davis', 'benjamin.davis@example.com', NULL),
    (1, 'Isabella', 'Martinez', 'isabella.martinez@example.com', 'Full-Time'),
    (2, 'Mason', 'Garcia', 'mason.garcia@example.com', 'Daily-Rate Payer'),
    (1, 'Charlotte', 'Rodriguez', 'charlotte.rodriguez@example.com', 'Part-Time'),
    (2, 'Henry', 'Wilson', 'henry.wilson@example.com', 'Full-Time');

-- Test query - select every user that is a full-time user and has their primary location as North-West Cardiff
SELECT * FROM users WHERE usersLocationID = 2 AND users.membershipType = 'Full-Time';

-- Creating a desk table, to store information about the desks in the co-working spaces
CREATE TABLE desk(
     deskID int NOT NULL PRIMARY KEY AUTO_INCREMENT,
     deskLocationID int NOT NULL,
     availabilty VARCHAR(3) NOT NULL,
     CONSTRAINT deskLocationID_FK FOREIGN KEY (deskLocationID) REFERENCES location(locationID)
);

-- Changing the name of the availabilty column since it was misspelled, and increasing the maximum length
ALTER TABLE desk
CHANGE availabilty availability VARCHAR (10) NOT NULL;

-- Increasing the maximum length of the availability column since it wasn't long enough for the word 'unavailable'
ALTER TABLE desk
MODIFY COLUMN availability VARCHAR (15) NOT NULL;

-- Populating this table with test data
-- Reference: https://www.mssqltips.com/sqlservertutorial/196/information-schema-tables/
-- Adding 30 desks to the North Cardiff Space, and 45 to the North-West space, setting them all to available
INSERT INTO desk (deskLocationID, availability)
SELECT 1, 'Available'
FROM (
         SELECT 1, NULL
         FROM information_schema.tables
         LIMIT 30
     ) AS data;

INSERT INTO desk (deskLocationID, availability)
SELECT 2, 'Available'
FROM (
         SELECT NULL AS data
         FROM information_schema.tables
         LIMIT 45
     ) AS data;

-- Setting 4 random desks to unavailable to represent dedicated desks
UPDATE desk
SET availability = 'Unavailable'
WHERE deskID IN (3,21,46,65);

-- Test query - select the ID of every desk that is available
SELECT deskID FROM desk WHERE desk.availability = 'Available';

-- Creating a desk booking table to represent information about dedicated desks
CREATE TABLE desk_booking(
     deskBookingID int NOT NULL PRIMARY KEY AUTO_INCREMENT,
     deskBookingUserID int NOT NULL,
     deskBookingDeskID int NOT NULL,
     CONSTRAINT deskBookingUserID_FK FOREIGN KEY (deskBookingUserID) REFERENCES users(userID),
     CONSTRAINT deskBookingDeskID_FK FOREIGN KEY (deskBookingDeskID) REFERENCES desk(deskID)
);

-- Populating this table with test data
INSERT INTO desk_booking (deskBookingUserID, deskBookingDeskID) VALUES
    (2,3),
    (6,21),
    (10,46),
    (11,65);

-- Test query - select all information about every desk that has been booked
SELECT * FROM desk_booking;

-- Creating a table to store information about the coffee shops
CREATE TABLE coffee_shop(
    coffeeLocationID int NOT NULL,
    capacity int NOT NULL,
    facilities VARCHAR(100),
    CONSTRAINT coffeeLocationID_FK FOREIGN KEY (coffeeLocationID) REFERENCES location(locationID)
);

-- Populating this table with test data
INSERT INTO coffee_shop (coffeeLocationID, capacity, facilities) VALUES
    (1, 20, 'Male and Female Toilets'),
    (2, 35, 'Only Female Toilets');

-- Test query - select coffee shop location ID and capacity where capacity is greater than 30
SELECT coffeeLocationID, capacity FROM coffee_shop WHERE capacity > 30;

-- Creating a table to store information about users who have purchased subscriptions to the coffee shops
CREATE TABLE coffee_shop_membership(
    coffeeMembershipLocationID int NOT NULL,
    coffeeMembershipUserID int NOT NULL,
    CONSTRAINT coffeeMembershipLocationID_FK FOREIGN KEY (coffeeMembershipLocationID) REFERENCES location(locationID),
    CONSTRAINT coffeeMembershipUserID FOREIGN KEY (coffeeMembershipUserID) REFERENCES users(userID)
);

-- Populating this table with test data
INSERT INTO coffee_shop_membership(coffeeMembershipLocationID, coffeeMembershipUserID) VALUES
   (1, 2),
   (2, 5),
   (1, 3),
   (1, 7);

-- Test query - select the user id and email of every user with a subscription to the coffee shop

SELECT csm.coffeeMembershipUserID, u.email
FROM coffee_shop_membership csm
JOIN users u on csm.coffeeMembershipUserID = u.userID;

-- Creating a table to store information about generated reports
CREATE TABLE report(
   reportID int NOT NULL PRIMARY KEY AUTO_INCREMENT,
   reportLocationID int NOT NULL,
   reportType VARCHAR(40) NOT NULL,
   CONSTRAINT reportLocationID_FK FOREIGN KEY (reportLocationID) REFERENCES location(locationID)
);

-- Populating this table with test data
INSERT INTO report(reportLocationID, reportType) VALUES
     (1, 'Desk Usage Report'),
     (1, 'Take-up of Membership Options Report'),
     (1, 'Location Popularity Report'),
     (2, 'Desk Usage Report'),
     (2, 'Take-up of Membership Options Report'),
     (2, 'Location Popularity Report');

-- Creating a table to store information about the individual meeting rooms in each co-working space
CREATE TABLE meeting_room(
    roomID int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    roomLocationID int NOT NULL,
    availabilty VARCHAR(3) NOT NULL,
    CONSTRAINT roomLocationID_FK FOREIGN KEY (roomLocationID) REFERENCES location(locationID)
);

-- Changing the name of the availabilty column since it was misspelled
ALTER TABLE meeting_room
    CHANGE availabilty availability VARCHAR (15) NOT NULL;

-- Removing the availability column as it would require a complex trigger to work correctly
ALTER TABLE meeting_room
DROP COLUMN availability;

-- Populating this table with test data
INSERT INTO meeting_room(roomLocationID) VALUES
     (1),
     (1),
     (2),
     (2);

-- Creating a table to store information about meeting room bookings
CREATE TABLE room_booking(
     roomBookingID int NOT NULL PRIMARY KEY AUTO_INCREMENT,
     roomBookingUserID int NOT NULL,
     roomBookingRoomID int NOT NULL,
     date DATE,
     time TIME,
     duration TIME,
     CONSTRAINT roomBookingUserID_FK FOREIGN KEY (roomBookingUserID) REFERENCES users(userID),
     CONSTRAINT roomBookingRoomID_FK FOREIGN KEY (roomBookingRoomID) REFERENCES meeting_room(roomID)
);

-- Populating this table with test data
INSERT INTO room_booking(roomBookingUserID, roomBookingRoomID, date, time, duration) VALUES
     (1,2,'2024-04-04','09:00:00','01:00:00'),
     (5,3,'2024-04-04','12:00:00','00:45:00'),
     (7,4,'2024-04-04','14:00:00','00:30:00');

-- Creating a table to store information about the different types of membership
CREATE TABLE membership_type(
    membershipTypeTypeID int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    membershipTypeTypeName VARCHAR(40) NOT NULL,
    price double NOT NULL,
    description VARCHAR(120)
);

ALTER TABLE membership_type
    CHANGE price price VARCHAR(10);

-- Populating this table with test data
INSERT INTO membership_type(membershipTypeTypeName, price, description) VALUES
    ('Full-Time', '£250/month', 'Unlimited access, access to private meeting rooms for 1 hour/day and a dedicated desk for an extra £50 a month.'),
    ('Part-Time', '£120/month', 'Access for up to 8 days/month and access to private meeting rooms for 1 hour/day'),
    ('Daily-Rate Payer', '£20/day', 'Access for one day');

-- Creating a table to store information about each which membership each user has
CREATE TABLE membership(
    membershipID int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    membershipUserID int NOT NULL,
    membershipTypeID int NOT NULL,
    CONSTRAINT membershipTypeID_FK FOREIGN KEY (membershipTypeID) REFERENCES membership_type(membershipTypeTypeID),
    CONSTRAINT membershipUserID_FK FOREIGN KEY (membershipUserID) REFERENCES users(userID)
);

-- Changing the membershipTypeID column to allow null values, e.g. if a users membership has expired
ALTER TABLE membership
    CHANGE column membershipTypeID membershipTypeID int;

-- Populating this table with test data
INSERT INTO membership(membershipUserID, membershipTypeID) VALUES
   (1, 2),
   (2, 1),
   (3, 3),
   (4, NULL),
   (5, 2),
   (6, 1),
   (7, 1),
   (8, NULL),
   (9, 2),
   (10, NULL),
   (11, 1),
   (12, 3),
   (13, 2),
   (14, 1);

-- Test query - select the userID, first name and surname of every user that has an active membership
SELECT m.membershipUserID, u.firstName, u.surname
FROM membership m
JOIN users u ON m.membershipUserID = u.userID
WHERE m.membershipTypeID IS NOT NULL
ORDER BY membershipUserID;



-- -------------------------------------------
/* STORED PROCEDURES */
-- Stored procedures allow you to execute many SQL statements and execute them at any point in the code
-- Using a delimiter allows you to define the boundaries of a stored procedure
-- It allows the use of semi-colons within the procedure without terminating at each semi-colon
DELIMITER $$

-- Creating a procedure, passing in a parameter and returning a value
CREATE PROCEDURE countFullTimeUsers(
    IN membershipTypeSP VARCHAR (20),
    OUT fullTimeCount INT
)

-- Count the number of users with the value that the procedure is called with
BEGIN
    SELECT COUNT(*) INTO fullTimeCount
    FROM users
    WHERE membershipType = membershipTypeSP;
end $$
DELIMITER ;

-- Call the procedure with a parameter to pass into, and a session variable as the output
CALL countFullTimeUsers('Full-Time', @FullTimeCount);
SELECT @FullTimeCount;

DELIMITER $$


-- A procedure with an INOUT parameter
-- INOUT parameter can receive input values and return output values
CREATE PROCEDURE addFullTimeUsers(
    INOUT fullTimeCount INT,
    IN addValue INT
)

-- Count the number of users with a 'Full-Time' membership
BEGIN
    SELECT COUNT(*) INTO fullTimeCount
    FROM users
    WHERE membershipType = 'Full-Time';

-- Add the number of Full-Time users to the add value that is passed in as a parameter
    SET fullTimeCount = fullTimeCount + addValue;
END$$
DELIMITER ;

-- Call the procedure with a session variable and pass in a parameter
CALL addFullTimeUsers(@FullTimeCountAdded, 5);
SELECT @FullTimeCountAdded;


-- ----------------------------------
/* VIEWS */
-- Views are virtual or logical tables which are defined as a SELECT query with joins
-- Create the view, and select the following columns
CREATE VIEW userByLocationID
AS
SELECT userID, usersLocationID, l.locationName firstName, surname, email, users.membershipType
FROM users
         -- Join the location table, this allows you to see columns from the location table
         INNER JOIN location l
                    ON users.usersLocationID = l.locationID;

-- Select the view
SELECT *
FROM userByLocationID;

-- ------------------------------------
/* TRIGGER */
-- Triggers are SQL code that is automatically executed in response to certain events on a particular table
DELIMITER $$

-- Create the trigger and specify the event that it should be executed on
CREATE TRIGGER userMembershipTrigger
    AFTER INSERT ON users
    FOR EACH ROW
-- I use a case statement (similar to an if statement) to allow me to check for various conditions
-- e.g. whether a membershipType of 'Full-Time' is inserted
-- Then insert a value, and the new userID into the membership table
BEGIN
    CASE
        WHEN NEW.membershipType = 'Full-Time' THEN
            INSERT INTO membership (membershipTypeID, membershipUserID)
            VALUES (1, NEW.userID);
        WHEN NEW.membershipType = 'Part-Time' THEN
            INSERT INTO membership (membershipTypeID, membershipUserID)
            VALUES (2, NEW.userID);
        WHEN NEW.membershipType = 'Daily-Rate Payer' THEN
            INSERT INTO membership (membershipTypeID, membershipUserID)
            VALUES (3, NEW.userID);
        END CASE;
END$$

DELIMITER ;


-- ----------------------------
/* FUNCTION */
-- A function is like a stored procedure, but returns a value
DELIMITER $$

CREATE FUNCTION numberOfDeskBookings()
RETURNS INTEGER
BEGIN
    RETURN(SELECT COUNT(deskBookingID)FROM desk_booking);
end $$

DELIMITER ;

SELECT numberOfDeskBookings() as 'Number of Desk Bookings';

 -- ----------------------------
/* TRANSACTION */
-- Transactions are sequences of one or more SQL statements that are treated as a single unit of work
-- I carried out this transaction within a stored procedure
DROP PROCEDURE IF EXISTS insertingUpdatingUsers;
DELIMITER $$

CREATE PROCEDURE insertingUpdatingUsers()
BEGIN
    -- Declare exit handler for rollback on exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
            ROLLBACK;
        END;

    -- Start the transaction
    START TRANSACTION;

    -- Insert statement
    INSERT INTO users(usersLocationID, firstName, surname, email, membershipType) VALUES
        (1, 'Transaction', 'Test', 'TransactionTest','Daily-Rate Payer');

    -- Update statement
    UPDATE users SET membershipType = 'Daily-Rate Payer'
    WHERE userID = 10;

    -- Commit the transaction
    COMMIT;
    -- Debug message to check this point in the code has been reached
    SELECT 'Transaction committed successfully.' AS DebugMessage;
END$$

DELIMITER ;

-- Call the stored procedure
CALL insertingUpdatingUsers();

-- ------------------------------
/* ERROR HANDLING */
-- I handle an error that occurs if inserted data exceeds the maximum length
DROP PROCEDURE IF EXISTS insertMembershipTypeError;
DELIMITER $$

-- Several parameters passed in
CREATE PROCEDURE insertMembershipTypeError(
    IN pMembershipTypeTypeName VARCHAR(40),
    IN pPrice VARCHAR(10),
    IN pDescription VARCHAR(120)
)

-- A continue handler is declared for error 22001, which is the error that occurs for data that is too long
-- A custom error message is created
-- I insert data to test the procedure
BEGIN
    DECLARE DataTooLong CONDITION FOR SQLSTATE '22001';
    DECLARE CONTINUE HANDLER FOR DataTooLong
    SELECT 'Inserted data is too long for the column.';
    INSERT INTO membership_type(membershipTypeTypeName, price, description) VALUES
        (pMembershipTypeTypeName, pPrice, pDescription);
end $$
DELIMITER ;

-- I call the stored procedure, and pass in several parameters, the second of which generates the error
CALL insertMembershipTypeError('Test Type', '£100000/Decade', 'Test Description');
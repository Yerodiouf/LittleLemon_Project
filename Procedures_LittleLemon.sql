-- =====================================================
-- LittleLemonDB : script corrigé
-- =====================================================

CREATE DATABASE IF NOT EXISTS LittleLemonDB;
USE LittleLemonDB;

-- =====================================================
-- TABLES
-- =====================================================

-- Table des clients
CREATE TABLE IF NOT EXISTS Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Email VARCHAR(100)
);

-- Table du personnel
CREATE TABLE IF NOT EXISTS Staff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Role VARCHAR(50)
);

-- Table des réservations
CREATE TABLE IF NOT EXISTS Bookings (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    BookingDate DATE NOT NULL,
    TableNumber INT NOT NULL,
    NumberOfGuests INT NOT NULL,
    CustomerID INT NOT NULL,
    StaffID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

-- Table des plats
CREATE TABLE IF NOT EXISTS MenuItems (
    MenuItemID INT AUTO_INCREMENT PRIMARY KEY,
    ItemName VARCHAR(100) NOT NULL,
    CourseName VARCHAR(100),
    CuisineName VARCHAR(100)
);

-- Table des menus
CREATE TABLE IF NOT EXISTS Menus (
    MenuID INT AUTO_INCREMENT PRIMARY KEY,
    MenuName VARCHAR(100) NOT NULL,
    MenuItemID INT,
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);

-- Table des commandes
CREATE TABLE IF NOT EXISTS Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    Quantity INT NOT NULL,
    TotalCost DECIMAL(10,2),
    CustomerID INT NOT NULL,
    MenuID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (MenuID) REFERENCES Menus(MenuID)
);

-- Table du statut de livraison
CREATE TABLE IF NOT EXISTS OrderDeliveryStatus (
    DeliveryID INT AUTO_INCREMENT PRIMARY KEY,
    DeliveryDate DATE,
    Status VARCHAR(50),
    OrderID INT NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

SHOW TABLES;
DESCRIBE Customers;
DESCRIBE Staff;
DESCRIBE Bookings;

-- =====================================================
-- DONNÉES DE TEST
-- =====================================================

INSERT INTO Customers (FullName, Phone, Email)
VALUES
('Mamadou Diop', '771234567', 'mamadou@gmail.com'),
('Aminata Fall', '761234567', 'aminata@gmail.com'),
('Ibrahima Sow', '701234567', 'ibrahima@gmail.com');

INSERT INTO Staff (FullName, Role)
VALUES
('Fatou Ndiaye', 'Manager'),
('Ousmane Ba', 'Receptionist');

INSERT INTO Bookings (BookingDate, TableNumber, NumberOfGuests, CustomerID, StaffID)
VALUES
('2026-11-20', 5, 2, 1, 1),
('2026-11-21', 3, 4, 2, 2),
('2026-11-22', 7, 3, 3, 1);

INSERT INTO MenuItems (ItemName, CourseName, CuisineName)
VALUES
('Thieboudienne', 'Main', 'Senegalese'),
('Salade grecque', 'Starter', 'Greek');

INSERT INTO Menus (MenuName, MenuItemID)
VALUES
('Menu du jour', 1),
('Menu léger', 2);

INSERT INTO Orders (OrderDate, Quantity, TotalCost, CustomerID, MenuID)
VALUES
('2026-11-20', 2, 7000.00, 1, 1),
('2026-11-21', 5, 12500.00, 2, 2);

SELECT * FROM Customers;
SELECT * FROM Staff;
SELECT * FROM Bookings;
SELECT * FROM Orders;

-- =====================================================
-- PROCÉDURES STOCKÉES
-- =====================================================

DROP PROCEDURE IF EXISTS GetMaxQuantity;
DROP PROCEDURE IF EXISTS ManageBooking;
DROP PROCEDURE IF EXISTS UpdateBooking;
DROP PROCEDURE IF EXISTS AddBooking;
DROP PROCEDURE IF EXISTS CancelBooking;

DELIMITER //

-- Quantité maximale commandée
CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT MAX(Quantity) AS MaxQuantity
    FROM Orders;
END //

-- Vérifier la disponibilité d'une table
CREATE PROCEDURE ManageBooking(
    IN p_BookingDate DATE,
    IN p_TableNumber INT
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Bookings
        WHERE BookingDate = p_BookingDate
          AND TableNumber = p_TableNumber
    ) THEN
        SELECT 'La table est déjà réservée.' AS BookingStatus;
    ELSE
        SELECT 'La table est disponible.' AS BookingStatus;
    END IF;
END //

-- Modifier la date d'une réservation
CREATE PROCEDURE UpdateBooking(
    IN p_BookingID INT,
    IN p_NewBookingDate DATE
)
BEGIN
    UPDATE Bookings
    SET BookingDate = p_NewBookingDate
    WHERE BookingID = p_BookingID;

    IF ROW_COUNT() > 0 THEN
        SELECT 'Réservation mise à jour.' AS BookingStatus;
    ELSE
        SELECT 'Aucune réservation trouvée avec cet ID.' AS BookingStatus;
    END IF;
END //

-- Ajouter une réservation (BookingID est généré automatiquement)
CREATE PROCEDURE AddBooking(
    IN p_BookingDate DATE,
    IN p_TableNumber INT,
    IN p_NumberOfGuests INT,
    IN p_CustomerID INT,
    IN p_StaffID INT
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Bookings
        WHERE BookingDate = p_BookingDate
          AND TableNumber = p_TableNumber
    ) THEN
        SELECT 'La table est déjà réservée à cette date.' AS BookingStatus;
    ELSE
        INSERT INTO Bookings (BookingDate, TableNumber, NumberOfGuests, CustomerID, StaffID)
        VALUES (p_BookingDate, p_TableNumber, p_NumberOfGuests, p_CustomerID, p_StaffID);

        SELECT 'Nouvelle réservation ajoutée.' AS BookingStatus,
               LAST_INSERT_ID() AS NewBookingID;
    END IF;
END //

-- Annuler une réservation
CREATE PROCEDURE CancelBooking(
    IN p_BookingID INT
)
BEGIN
    DELETE FROM Bookings
    WHERE BookingID = p_BookingID;

    IF ROW_COUNT() > 0 THEN
        SELECT 'Réservation annulée.' AS BookingStatus;
    ELSE
        SELECT 'Aucune réservation trouvée avec cet ID.' AS BookingStatus;
    END IF;
END //

DELIMITER ;

-- =====================================================
-- TESTS
-- =====================================================

CALL GetMaxQuantity();

CALL ManageBooking('2026-11-20', 5);   -- déjà réservée
CALL ManageBooking('2026-11-20', 8);   -- disponible

CALL UpdateBooking(1, '2026-11-25');
SELECT * FROM Bookings WHERE BookingID = 1;

CALL AddBooking('2026-11-26', 2, 3, 1, 2);
SELECT * FROM Bookings;

-- Annule la dernière réservation ajoutée (ID 4 si la base est neuve)
CALL CancelBooking(4);
SELECT * FROM Bookings;

-- Lister les procédures de la base
SHOW PROCEDURE STATUS WHERE Db = 'LittleLemonDB';
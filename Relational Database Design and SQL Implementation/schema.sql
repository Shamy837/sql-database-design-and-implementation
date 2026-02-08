DROP DATABASE IF EXISTS hand_me_down;
CREATE DATABASE hand_me_down;
USE hand_me_down;

DROP TABLE IF EXISTS BookInvPurchase;
DROP TABLE IF EXISTS CustomerReadingGroup;
DROP TABLE IF EXISTS ReadingGroup;
DROP TABLE IF EXISTS BookInventory;
DROP TABLE IF EXISTS Catalog;
DROP TABLE IF EXISTS Purchase;
DROP TABLE IF EXISTS Genre;
DROP TABLE IF EXISTS Bookmark;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Staff;

CREATE TABLE Genre (
GenreID CHAR(3) NOT NULL,
GenreName VARCHAR(255) NOT NULL,
CONSTRAINT check_GenreID CHECK (GenreID NOT REGEXP '[0-9]'),
CONSTRAINT check_GenreName CHECK (GenreName NOT REGEXP '[0-9]'),

PRIMARY KEY (GenreID)
);

CREATE TABLE Bookmark (
BookmarkID INT NOT NULL AUTO_INCREMENT,
ArtDesc VARCHAR(255) NOT NULL,

PRIMARY KEY (BookmarkID)
);

CREATE TABLE Customer (
CustomerID INT NOT NULL AUTO_INCREMENT,
CustomerFName VARCHAR(255) NOT NULL,
CustomerLName VARCHAR(255) NOT NULL,
CustomerNumber CHAR(10),

CONSTRAINT check_CustomerNumber CHECK (CustomerNumber REGEXP '^[0-9]{10}$'),
CONSTRAINT check_customerFName CHECK (CustomerFName NOT REGEXP '[0-9]'),
CONSTRAINT check_customerLName CHECK (CustomerLName NOT REGEXP '[0-9]'),

UNIQUE(CustomerFName, CustomerLName, CustomerNumber),

PRIMARY KEY (CustomerID)
);

CREATE TABLE Staff (
YearHired YEAR NOT NULL,
OrderHired INT UNSIGNED NOT NULL,
StaffFName VARCHAR(255) NOT NULL,
StaffLName VARCHAR(255) NOT NULL,
StaffNumber CHAR(10),
Salary DECIMAL(8,2) UNSIGNED NOT NULL,

CONSTRAINT check_YearHired CHECK (YearHired >= 2024 ), /* This assumes that the store first opened in 2024, staff couldn't be hired prior */
CONSTRAINT check_StaffNumber CHECK (StaffNumber REGEXP '^[0-9]{10}$'),
CONSTRAINT check_staffFName CHECK (StaffFName NOT REGEXP '[0-9]'),
CONSTRAINT check_staffLName CHECK (StaffLName NOT REGEXP '[0-9]'),

PRIMARY KEY(YearHired, OrderHired)
);

CREATE TABLE Catalog (
ISBN_13 CHAR(13) NOT NULL,
Title VARCHAR(255) NOT NULL,
AuthorFName VARCHAR(255) NOT NULL,
AuthorLName VARCHAR(255) NOT NULL,
Publisher VARCHAR(255) NOT NULL,
PageCount INT UNSIGNED NOT NULL,
GenreID CHAR(3) NOT NULL,

CONSTRAINT check_ISBN_13 CHECK (ISBN_13 REGEXP '^[0-9]{13}$'),
CONSTRAINT check_AuthorFName CHECK (AuthorFName NOT REGEXP '[0-9]'),
CONSTRAINT check_AuthorLName CHECK (AuthorLName NOT REGEXP '[0-9]'),

PRIMARY KEY (ISBN_13),
FOREIGN KEY (GenreID) REFERENCES Genre(GenreID)
	ON UPDATE CASCADE 
    ON DELETE RESTRICT 
);

CREATE TABLE BookInventory (
BookInvID INT NOT NULL AUTO_INCREMENT,
isNew BOOLEAN NOT NULL,
BookDesc VARCHAR(255),
Price DECIMAL(8,2) UNSIGNED NOT NULL,
BookmarkID INT UNIQUE NOT NULL,
ISBN_13 CHAR(13) NOT NULL,

PRIMARY KEY (BookInvID),
FOREIGN KEY (BookmarkID) REFERENCES Bookmark(BookmarkID)
	ON UPDATE CASCADE
    ON DELETE RESTRICT,
FOREIGN KEY (ISBN_13) REFERENCES Catalog(ISBN_13)
	ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE TABLE ReadingGroup (
GroupName VARCHAR(255) NOT NULL,
GenreID CHAR(3) UNIQUE NOT NULL,

PRIMARY KEY (GroupName),
FOREIGN KEY (GenreID) REFERENCES Genre(GenreID)
	ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE TABLE Purchase (
PurchaseID INT NOT NULL AUTO_INCREMENT,
TimeOfSale TIME,
DateOfSale DATE,
CustomerID INT NOT NULL,
YearHired YEAR NOT NULL,
OrderHired INT UNSIGNED NOT NULL,

CONSTRAINT check_TimeOfSale CHECK (TimeOfSale <= "19:59:59"), /* This assumes that the store closes at 8PM, therefore the last transaction could only take place at 19:59:59*/
CONSTRAINT check_DateOfSale CHECK (DateOfSale >= "2024-01-01"), /* This assumes the store first opened January 1st 2024, transactions couldn't have been done prior */
PRIMARY KEY (PurchaseID),
FOREIGN KEY (YearHired, OrderHired) REFERENCES Staff(YearHired, OrderHired)
	ON UPDATE CASCADE
    ON DELETE RESTRICT,
FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
	ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE TABLE CustomerReadingGroup (
GroupName VARCHAR(255) NOT NULL,
CustomerID INT NOT NULL,

PRIMARY KEY (GroupName, CustomerID),
FOREIGN KEY (GroupName) REFERENCES ReadingGroup(GroupName)
	ON UPDATE CASCADE
    ON DELETE RESTRICT,
FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
	ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE TABLE BookInvPurchase (
BookInvID INT NOT NULL UNIQUE,
PurchaseID INT NOT NULL,

PRIMARY KEY (BookInvID, PurchaseID),
FOREIGN KEY (BookInvID) REFERENCES BookInventory(BookInvID)
	ON UPDATE CASCADE
    ON DELETE RESTRICT,
FOREIGN KEY (PurchaseID) REFERENCES Purchase(PurchaseID)
	ON UPDATE CASCADE
    ON DELETE RESTRICT
);

/*GENRE*/
INSERT INTO Genre VALUES
("HIS","History"),
("HOR","Horror"),
("ROM","Romantic"),
("SCI","Sci-Fi"),
("ADV", "Adventure");
/*GENRE*/

/*STAFF*/
INSERT INTO Staff (YearHired, OrderHired, StaffFName, StaffLName, StaffNumber, Salary) VALUES
(2024,1,"Amy","Smith","9161837473",3500),
(2024,2,"Thomas","Vang","2969923248",2752),
(2024,3,"Marcus","Garcia","9161123369",3010),
(2025,1,"Elizabeth","Connaway","2797711023",2100),
(2025,2,"Allen","Jackson","9161023582",2800);
/*STAFF*/

/*CUSTOMER*/
INSERT INTO Customer (CustomerFName, CustomerLName, CustomerNumber) VALUES
("James","Corden","9161237643"),
("Blake","Beasley", NULL),
("Jacob","Ford","2794753118"),
("Danielle","Perkins","9167545822"),
("Juliet","Olsen","5301198283");
/*CUSTOMER*/

/*BOOKMARK*/
INSERT INTO Bookmark (ArtDesc) VALUES
("Ocean w/ Whale"),
("Light Blue Background, Snowy"),
("White Background & Red Text "),
("Black Background & Gold Text"),
("Grass Background"),
("Ocean w/ Whale");
/*BOOKMARK*/

/*CATALOG*/
INSERT INTO Catalog VALUES
("9780525658672","The American Revolution: An Intimate History", "Geoffrey", "Ward","Knopf Doubleday", 608, "HIS"),
("9781538774229", "Brimstone", "Callie", "Hart", "Grand Central", 672, "SCI"),
("9781501142970", "IT", "Stephen", "King", "Scribner", 1168, "HOR"),
("9780063430402", "Good Spirits", "B.K.", "Borison", "HarperCollins", 384, "ROM"),
("9781454959809", "Moby Dick", "Herman", "Melville", "Union Square & Co.", 688, "ADV"),
("9780441013593", "Dune", "Frank", "Herbert", "Penguin Publishing Group", 704, "SCI");
/*CATALOG*/

/*BOOKINVENTORY*/
INSERT INTO BookInventory (isNew, BookDesc, Price, BookmarkID, ISBN_13) VALUES
(TRUE, NULL, 40.00, 5, "9780525658672"),
(FALSE, "Torn Spine", 22.99, 4, "9781538774229"),
(TRUE, NULL, 21.50, 3, "9781501142970"),
(FALSE, "Ripped Cover", 12.15, 2, "9780063430402"),
(FALSE, "Missing Pages", 16.00, 1, "9781454959809"),
(FALSE, "Missing Pages", 40.00, 6, "9780525658672");
/*BOOKINVENTORY*/

/*READINGGROUP*/
INSERT INTO ReadingGroup VALUES
("The Adventurous Bunch", "ADV"),
("The Historians", "HIS"),
("Spooky Crew", "HOR"),
("Lovers Quarrel", "ROM"),
("The Aliens", "SCI");
/*READINGGROUP*/

/*PURCHASE*/
INSERT INTO Purchase (TimeOfSale, DateOfSale, CustomerID, YearHired, OrderHired) VALUES
(TIME('8:37:12'),DATE('2025-11-01'),1,2024,1),
(TIME('12:15:42'),DATE('2025-11-03'),1,2024,2),
(TIME('17:01:08'),DATE('2025-11-12'),3,2025,1),
(TIME('19:44:55'),DATE('2025-11-26'),5,2025,1),
(TIME('10:24:19'),DATE('2025-10-30'),2,2025,2);
/*PURCHASE*/

/*CUSTOMERREADINGGROUP*/
INSERT INTO CustomerReadingGroup VALUES
("The Adventurous Bunch",2), ("The Historians",1),
("The Adventurous Bunch",3), ("The Historians",5),
("The Adventurous Bunch",4), ("The Historians",3),
("Spooky Crew",3), ("The Aliens",3),		
("Spooky Crew",5), ("The Aliens",2),
("Spooky Crew",4), ("The Aliens",1),
("Spooky Crew",1), ("Lovers Quarrel",4), 
("Spooky Crew",2), ("Lovers Quarrel",1);
/*CUSTOMERREADINGGROUP*/

/*BOOKINVPURCHASE*/
INSERT INTO BookInvPurchase VALUES
(1,1), (2,3), (4,3), (5,4);
/*BOOKINVPURCHASE*/

/*VIEW*/
USE hand_me_down;
DROP VIEW IF EXISTS PurchaseDetails;
CREATE OR REPLACE VIEW PurchaseDetails AS
SELECT
    Purchase.PurchaseID,
    Purchase.DateOfSale,
    Purchase.TimeOfSale,
    Customer.CustomerFName,
    Customer.CustomerLName,
    Staff.StaffFName,
    Staff.StaffLName,
    BookInventory.BookInvID,
    Catalog.Title,
    BookInventory.Price,
    (SELECT SUM(BookInventory.Price)
        FROM BookInvPurchase 
        JOIN BookInventory ON BookInvPurchase.BookInvID = BookInventory.BookInvID
        WHERE BookInvPurchase.PurchaseID = Purchase.PurchaseID
    ) AS PurchaseTotal
FROM Purchase 
JOIN Customer 
    ON Purchase.CustomerID = Customer.CustomerID
JOIN Staff 
    ON Purchase.YearHired = Staff.YearHired
   AND Purchase.OrderHired = Staff.OrderHired
JOIN BookInvPurchase 
    ON Purchase.PurchaseID = BookInvPurchase.PurchaseID
JOIN BookInventory 
    ON BookInvPurchase.BookInvID = BookInventory.BookInvID
JOIN Catalog
    ON BookInventory.ISBN_13 = Catalog.ISBN_13;
/*VIEW*/

SELECT * FROM PurchaseDetails;

/* QUERY 1: shows the total amount that each customer has spent at the bookstore*/
SELECT
    c.CustomerFName,
    c.CustomerLName,
    SUM(bi.Price) AS TotalSpent
FROM Customer c
JOIN Purchase p
    ON c.CustomerID = p.CustomerID
JOIN BookInvPurchase bip
    ON p.PurchaseID = bip.PurchaseID
JOIN BookInventory bi
    ON bip.BookInvID = bi.BookInvID
GROUP BY
    c.CustomerID,
    c.CustomerFName,
    c.CustomerLName
ORDER BY
    TotalSpent DESC;
/* QUERY 1 */
    
/* QUERY 2: shows the number of members in each reading group */
SELECT
    rg.GroupName,
    g.GenreName,
    COUNT(crg.CustomerID) AS MemberCount
FROM ReadingGroup rg
JOIN Genre g
    ON rg.GenreID = g.GenreID
LEFT JOIN CustomerReadingGroup crg
    ON crg.GroupName = rg.GroupName
GROUP BY
    rg.GroupName,
    g.GenreName
ORDER BY
    MemberCount DESC,
    rg.GroupName;
/* QUERY 2 */

/* QUERY 3: shows the books that are currently in inventory that have not been sold yet*/
SELECT
    bi.BookInvID,
    cat.Title,
    bi.Price,
    bi.isNew,
    bi.BookDesc
FROM BookInventory bi
JOIN Catalog cat
    ON bi.ISBN_13 = cat.ISBN_13
LEFT JOIN BookInvPurchase bip
    ON bip.BookInvID = bi.BookInvID
WHERE bip.PurchaseID IS NULL;
/* QUERY 3 */

/*QUERY 4: selects active customers within the most groups and displays their name and how much they have spent at the bookstore*/
SELECT 
    CustomerFName,
    CustomerLName,
    ROUND(SUM(Price), 2) AS TotalPurchase
FROM
    Customer
        LEFT JOIN
    Purchase ON Customer.CustomerID = Purchase.CustomerID
        LEFT JOIN
    BookInvPurchase ON Purchase.PurchaseID = BookInvPurchase.PurchaseID
        LEFT JOIN
    BookInventory ON BookInvPurchase.BookInvID = BookInventory.BookInvID
WHERE
    Customer.CustomerID IN (SELECT 
            CustomerID
        FROM
            CustomerReadingGroup
        GROUP BY CustomerID
        HAVING COUNT(customerID) = ALL (SELECT 
                MAX(ccid)
            FROM
                (SELECT 
                    CustomerID, COUNT(customerID) AS ccid
                FROM
                    CustomerReadingGroup
                GROUP BY customerID) AS CountTable))
GROUP BY CustomerFName, CustomerLName;
/*QUERY 4*/
-- define the width of the display (example: 150 columns)
set linesize 120;

-- define the page size -- no of rows to be printed before the header appears
set pagesize 120;

DROP TABLE DeliveryDriver CASCADE CONSTRAINTS;
DROP TABLE DeliveryTruck CASCADE CONSTRAINTS;
DROP TABLE Customer CASCADE CONSTRAINTS;
DROP TABLE Items CASCADE CONSTRAINTS;
DROP TABLE OrderItems CASCADE CONSTRAINTS;
DROP TABLE Orders CASCADE CONSTRAINTS;
DROP TABLE Website CASCADE CONSTRAINTS;

CREATE TABLE DeliveryTruck
(TruckID INT PRIMARY KEY,
AreaCode VARCHAR(10)
);

INSERT INTO DeliveryTruck (TruckID, AreaCode) VALUES( 1, '48192');
INSERT INTO DeliveryTruck (TruckID, AreaCode) VALUES ( 2, '48193');
INSERT INTO DeliveryTruck (TruckID, AreaCode) VALUES ( 3, '48123');

CREATE TABLE DeliveryDriver
(EmployeeID INT PRIMARY KEY,
TruckID INT,
Name VARCHAR(255),
Address VARCHAR(255),
FOREIGN KEY (TruckID) REFERENCES DeliveryTruck(TruckID)
);

INSERT INTO DeliveryDriver (EmployeeID, TruckID, Name, Address) VALUES (101, 1, 'Alex Benkarski', '512 12th St, Mt Pleasant, MI');
INSERT INTO DeliveryDriver (EmployeeID, TruckID, Name, Address) VALUES (102, 2, 'Michael Strange', '1024 Oak St, Lansing, MI');
INSERT INTO DeliveryDriver (EmployeeID, TruckID, Name, Address) VALUES (103, 3, 'Aiden Jastrzembski', '619 30th St, Mt Pleasant, MI');

CREATE TABLE Customer
(CustomerID INT PRIMARY KEY,
PhoneNumber VARCHAR(20),
Name VARCHAR(255),
Address VARCHAR(225)
);

INSERT INTO Customer (CustomerID, PhoneNumber, Name, Address) VALUES (200, '7343012152', 'Michael Smith', '415 Elm St Mt. Pleasant MI');
INSERT INTO Customer (CustomerID, PhoneNumber, Name, Address) VALUES (201, '9792152143', 'Jack Cole', '102 Broomfield St Mt. Pleasant MI');
INSERT INTO Customer (CustomerID, PhoneNumber, Name, Address) VALUES (202, '3131235235', 'Alex Rose', '6123 Lansing St Lansing MI');

CREATE TABLE Orders
(OrderID INT PRIMARY KEY,
DeliveryAddress VARCHAR(255),
CustomerID INT,
FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

-- Trigger to track changes in the Orders table
CREATE OR REPLACE TRIGGER Orders_Trigger
BEFORE INSERT OR UPDATE OR DELETE ON Orders
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    DBMS_OUTPUT.PUT_LINE('New order added with ID: ' || :NEW.OrderID);
  ELSIF UPDATING THEN
    DBMS_OUTPUT.PUT_LINE('Order updated with ID: ' || :OLD.OrderID || ' -> ' || :NEW.OrderID);
  ELSIF DELETING THEN
    DBMS_OUTPUT.PUT_LINE('Order deleted with ID: ' || :OLD.OrderID);
  END IF;
END;

INSERT INTO Orders (OrderID, DeliveryAddress, CustomerID) VALUES (400, '415 Elm St Mt. Pleasant MI', 200);
INSERT INTO Orders (OrderID, DeliveryAddress, CustomerID) VALUES (401, '102 Broomfield St Mt. Pleasant MI', 201);
INSERT INTO Orders (OrderID, DeliveryAddress, CustomerID) VALUES (402, '6123 Lansing St Lansing MI', 202);

CREATE TABLE Items
(ItemID INT PRIMARY KEY,
Name VARCHAR(255),
Price DECIMAL(10,2)
);

INSERT INTO Items (ItemID, Name, Price) VALUES (300, 'Tablet', 199.00);
INSERT INTO Items (ItemID, Name, Price) VALUES (301, 'Laptop', 499.00);
INSERT INTO Items (ItemID, Name, Price) VALUES (302, 'Phone', 1000.00);

CREATE TABLE OrderItems
(OrderID INT,
ItemID INT,
Quantity INT,
PRIMARY KEY (OrderID, ItemID),
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
FOREIGN KEY (ItemID) REFERENCES Items(ItemID)
);

INSERT INTO OrderItems (OrderID, ItemID, Quantity) VALUES (400, 301, 5);
INSERT INTO OrderItems (OrderID, ItemID, Quantity) VALUES (401, 302, 1);
INSERT INTO OrderItems (OrderID, ItemID, Quantity) VALUES (402, 301, 2);

CREATE TABLE Website
(WebsiteID INT PRIMARY KEY,
OrderID INT,
FulfillmentStatus VARCHAR(50),
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

INSERT INTO Website (WebsiteID, OrderID, FulfillmentStatus) VALUES (500, 400, 'Processing');
INSERT INTO Website (WebsiteID, OrderID, FulfillmentStatus) VALUES (501, 401, 'Shipped');
INSERT INTO Website (WebsiteID, OrderID, FulfillmentStatus) VALUES (502, 402, 'Delivered');

SELECT * FROM DeliveryTruck;
SELECT * FROM DeliveryDriver;
SELECT * FROM Customer;
SELECT * FROM Items;
SELECT * FROM Orders;
SELECT * FROM OrderItems;
SELECT * FROM Website;

-- View to display items delivered with details and order status
CREATE VIEW DeliveredItems AS
SELECT i.Name, i.Price, w.FulfillmentStatus
FROM Items i
JOIN OrderItems oi ON i.ItemID = oi.ItemID
JOIN Orders o ON oi.OrderID = o.OrderID
JOIN Website w ON o.OrderID = w.OrderID
WHERE w.FulfillmentStatus = 'Delivered';

-- Display the view
SELECT * FROM DeliveredItems;

--find the most expensive ItemID
SELECT Name, MAX(Price) AS HighestPrice FROM Items GROUP BY Name;

-- list all customers in Mt. Pleasant
SELECT Name, Address FROM Customer WHERE Address LIKE '%Mt. Pleasant%';

-- list all items delivered, with item details and order status
SELECT i.Name, i.Price, w.FulfillmentStatus
FROM Items i
JOIN OrderItems oi ON i.ItemID = oi.ItemID
JOIN Orders o ON oi.OrderID = o.OrderID
JOIN Website w ON o.OrderID = w.OrderID;

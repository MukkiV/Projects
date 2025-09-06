-- CUSTOMER DATA ANALYSIS

-- TASK - 1 TOP 10 CUSTOMERS BY CREDIT LIMIT
SELECT customerName, creditLimit FROM customers 
ORDER BY creditLimit DESC LIMIT 10;

-- TASK - 2 AVERAGE CREDIT LIMIT FOR CUSTOMERS IN EACH COUNTRY
SELECT country, AVG(creditLimit) AS Average FROM customers
GROUP BY country;

-- TASK - 3 NUMBER OF CUSTOMER IN EACH STATE
SELECT state, COUNT(customerNumber) AS Total_customers FROM customers
GROUP BY state;

-- TASK - 4 CUSTOMERS WHO HAVENT PLACED ANY ORDER
SELECT customerNumber, customerName FROM customers
WHERE customerNumber NOT IN (SELECT customerNumber FROM orders);

-- TASK - 5 TOTAL SALES OF EACH CUSTOMER
SELECT customers.customerName, SUM(payments.amount) AS Total_sales FROM customers
JOIN payments ON customers.customerNumber = payments.customerNumber
GROUP BY customers.customerName;

-- TASK - 6 CUSTOMERS AND SALES REPRENSTATIVES
SELECT customers.customerName, employees.lastName AS Representatives FROM customers
JOIN employees ON customers.salesRepEmployeeNumber = employees.employeeNumber;

-- TASK - 7 CUSTOMER INFORMATION WITH RECENT PAYMENT
SELECT customers.customerName, payments.paymentDate, payments.amount FROM customers
JOIN payments ON customers.customerNumber = payments.customerNumber
ORDER BY paymentDate DESC;

-- TASK - 8 CUSTOMERS EXCEED THEIR CREDIT LIMIT
SELECT customers.customerName, SUM(payments.amount) AS Total_Amount, customers.creditLimit 
FROM customers JOIN payments ON customers.customerNumber = payments.customerNumber
GROUP BY customers.customerName, customers.creditLimit 
HAVING SUM(payments.amount) > customers.creditLimit;

-- TASK - 9 SPECIFIC PRODUCT LINE
DELIMITER //
CREATE PROCEDURE product_line(IN products_line VARCHAR(100))
BEGIN

SELECT customers.customerName, products.productLine  FROM customers 
JOIN orders ON customers.customerNumber = orders.customerNumber
JOIN orderdetails ON orderdetails.orderNumber = orders.orderNumber
JOIN products ON orderdetails.productCode = products.productCode
WHERE products_line = products.productLine;

END//
DELIMITER ;

CALL product_line("Planes");

-- TASK - 10 CUSTOMER WHO PURCHASED MOST EXPENSIVE PRODUCT

SELECT DISTINCT customers.customerName,products.productLine, products.MSRP FROM customers 
JOIN orders ON customers.customerNumber = orders.customerNumber
JOIN orderdetails ON orderdetails.orderNumber = orders.orderNumber
JOIN products ON orderdetails.productCode = products.productCode
WHERE products.MSRP = (SELECT MAX(MSRP) FROM products );

-- OFFICE DATA ANALYSIS
-- TASK - 1 NUMBER OF EMPLOYEES WORKING IN EACH OFFICE

SELECT offices.city, COUNT(employees.employeeNumber) AS Total_employees FROM employees
JOIN offices ON offices.officeCode = employees.officeCode
GROUP BY offices.city;

-- TASK - 2 OFFICE WITH LESS THAN CERTAIN NUMBER OF EMPLOYEES

DELIMITER // 
CREATE PROCEDURE Num_of_employees(IN Num_emp INT)
BEGIN

SELECT offices.city, COUNT(employees.employeeNumber) AS Total_employees FROM employees
JOIN offices ON offices.officeCode = employees.officeCode
GROUP BY offices.city HAVING COUNT(employees.employeeNumber) < Num_emp;
END//
DELIMITER ;

CALL Num_of_employees(6);

-- TASK - 3 OFFICE ALONG WITH TERRITORIES

SELECT officeCode, city , territory FROM offices ;

-- TASK - 4 OFFICES THAT HAS NO EMPLOYEES

SELECT offices.officeCode, offices.city, COUNT(employees.employeeNumber)
FROM employees JOIN offices
ON offices.officeCode = employees.officeCode
GROUP BY offices.officeCode, offices.city HAVING COUNT(employees.employeeNumber)<1;

-- TASK - 5 MOST PROFITABLE OFFICE

SELECT o.city, SUM(od.quantityOrdered*od.priceEach) AS Total_sales FROM offices o
JOIN employees e ON e.officeCode = o.officeCode
JOIN customers c ON c.salesRepEmployeeNumber = e.employeeNumber
JOIN orders ord ON ord.customerNumber = c.customerNumber
JOIN orderdetails od ON od.orderNumber = ord.orderNumber
GROUP BY o.city ORDER BY Total_sales DESC LIMIT 1;

-- TASK - 6 OFFICE THAT HAS HIGHEST NUMBER OF EMPLOYEES

SELECT offices.city, COUNT(employees.employeeNumber) AS Total_employees FROM employees
JOIN offices ON offices.officeCode = employees.officeCode
GROUP BY offices.city ORDER BY Total_employees DESC LIMIT 1;

-- TASK - 7 AVERAGE CREDIT LIMIT OF CUSTOMER IN EACH OFFICE

SELECT offices.city, AVG(customers.creditLimit) AS Avg_credit_limit FROM customers
JOIN employees ON employees.employeeNumber = customers.salesRepEmployeeNumber
JOIN offices ON offices.officeCode = employees.officeCode
GROUP BY offices.city ORDER BY Avg_credit_limit DESC LIMIT 1;

-- TASK - 8 NUMBER OF OFFICE IN EACH COUNTRY

SELECT country, COUNT(city) FROM offices
GROUP BY country;


-- PRODUCT DATA ANALYSIS
-- TASK - 1 NUMBER OF PRODUCT IN EACH PRODUCT LINE

SELECT productLine, COUNT(productName) AS Total_products FROM products
GROUP BY productLine ORDER BY Total_products DESC;

-- TASK - 2 PRODUCT WITH THE HIGHEST AVG PRICE

SELECT productLine, SUM(MSRP) AS Total_price FROM products
GROUP BY productLine ORDER BY Total_price DESC LIMIT 1;

-- TASK - 3 PRODUCTS WITHIN PRICE RANGE

SELECT productName, MSRP FROM products
WHERE MSRP BETWEEN 50 AND 100;

-- TASK - 4 TOTAL SALES FOR PRODUCT LINE

SELECT products.productLine, SUM(orderdetails.quantityOrdered*orderdetails.priceEach) AS Total_sales
FROM products JOIN orderdetails ON products.productCode = orderdetails.productCode
GROUP BY products.productLine ORDER BY Total_sales DESC;

-- TASK - 5 PRODUCTS WITH LOW INVENTORY LEVELS

SELECT productName, quantityInStock FROM products 
WHERE quantityInStock <= 10;

-- TASK - 6 MOST EXPENSIVE PRODUCT BASED ON MSRP

SELECT productName, MAX(MSRP) AS Expensive FROM products 
GROUP BY productName ORDER BY Expensive DESC LIMIT 1;

-- TASK - 7 TOTAL SALES FOR EACH PRODUCT

SELECT products.productName, SUM(orderdetails.quantityOrdered*orderdetails.priceEach) AS Total_sales
FROM products JOIN orderdetails ON products.productCode = orderdetails.productCode
GROUP BY products.productName ORDER BY Total_sales DESC;

-- TASK - 8 TOP SELLING PRODUCTS BASED ON TOTAL QTY

DELIMITER // 
CREATE PROCEDURE Qty_ordered(IN Top_list INT)
BEGIN

SELECT products.productName, SUM(orderdetails.quantityOrdered) AS Total_Qty FROM products
JOIN orderdetails ON orderdetails.productCode = products.productCode
GROUP BY products.productName ORDER BY Total_Qty DESC LIMIT Top_list;

END//
DELIMITER ;

CALL Qty_ordered(10);

-- TASK - 9 LOW INVENTORY LVL FOR CLASSIC CARS AND MOTORCYCLES

SELECT productName, quantityInStock FROM products 
WHERE quantityInStock <= 10 AND productLine IN ("Motorcycles", "Classic Cars");

-- TASK - 10 PRODUCTS ORDERED BY MORE THAN 10 CUSTOMERS

SELECT customers.customerName, SUM(orderdetails.quantityOrdered) AS Total_Qty FROM customers
JOIN orders ON orders.customerNumber = customers.customerNumber
JOIN orderdetails ON orderdetails.orderNumber = orders.orderNumber
GROUP BY customers.customerName HAVING Total_Qty >=10 ORDER by Total_Qty DESC;

-- TASK - 11 PRODUCTS THAT HAS BEEN ORDERED MORE THAN AVG IN THEIR PRODUCT LINE

SELECT  p1.productName, p1.productLine, COUNT(p1.productCode) AS Total_orders FROM orderdetails
JOIN products p1  ON p1.productCode = orderdetails.productCode
GROUP BY  p1.productCode 
HAVING Total_orders > (SELECT AVG(Total_count) 
FROM (SELECT COUNT(p2.productCode) AS Total_count FROM orderdetails od
JOIN products p2 ON p2.productCode = od.productCode
WHERE p2.productLine = p1.productLine
GROUP BY p2.productCode)AS Avg_table);

-- EMPLOYEE DATA ANALYSIS
-- TASK - 1 TOTAL NUMBER OF EMPLOYEES

SELECT COUNT(employeeNumber) AS Total_employees FROM employees;

-- TASK - 2 ALL EMPLOYEES INFORMATION

SELECT * FROM employees;

-- TASK - 3 NUMBER OF EMPLOYEES WITH JOB TITLE

SELECT jobTitle, COUNT(employeeNumber) AS Total_employees FROM employees 
GROUP BY jobTItle ORDER BY Total_employees DESC;

-- TASK - 4 EMPLOYEES WHO DONT HAVE MANAGER

SELECT firstName, lastName FROM employees WHERE reportsTo IS NULL;

-- TASK - 5 TOTAL SALES FOR EACH EMPLOYEES

SELECT employees.firstName, SUM(quantityOrdered * priceEach) AS Total_sales FROM employees
JOIN customers ON customers.salesRepEmployeeNumber = employees.employeeNumber
JOIN orders ON orders.customerNumber = customers.customerNumber 
JOIN orderdetails ON orderdetails.orderNumber = orders.orderNumber
GROUP BY employees.firstName ORDER BY Total_sales DESC;

-- TASK - 6 MOST PROFITABLE SALES REPRENSENTATIVE

SELECT employees.firstName, SUM(quantityOrdered * priceEach) AS Total_sales, 
SUM(quantityOrdered *buyPrice ) AS Total_cost, (SUM(quantityOrdered * priceEach) - SUM(quantityOrdered *buyPrice )) AS Profit FROM employees
JOIN customers ON customers.salesRepEmployeeNumber = employees.employeeNumber
JOIN orders ON orders.customerNumber = customers.customerNumber 
JOIN orderdetails ON orderdetails.orderNumber = orders.orderNumber
JOIN products ON products.productCode = orderdetails. productCode
GROUP BY employees.firstName ORDER BY Profit DESC;

-- TASK  - 7 EMPLOYEES SOLD MROE THAN AVG IN THEIR OFFICE

SELECT e.firstName,e.lastName,e.officeCode FROM employees e
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY e.employeeNumber
HAVING SUM(od.quantityOrdered * od.priceEach) >
(SELECT AVG(emp_sales) FROM (SELECT e2.officeCode,SUM(od2.quantityOrdered * od2.priceEach) AS emp_sales
FROM employees e2 JOIN customers c2 ON e2.employeeNumber = c2.salesRepEmployeeNumber
JOIN orders o2 ON c2.customerNumber = o2.customerNumber 
JOIN orderdetails od2 ON o2.orderNumber = od2.orderNumber
WHERE e2.officeCode = e.officeCode GROUP BY e2.employeeNumber) AS office_avg);


-- ORDER ANALYSIS
-- TASK - 1 AVERAGE ORDER AMOUNT FOR EACH CUSTOMER

SELECT customers.customerName , AVG(orderdetails.quantityOrdered * orderdetails.priceEach) AS Average_sales FROM customers
JOIN orders ON orders.customerNumber = customers.customerNumber
JOIN orderdetails ON orderdetails.orderNumber = orders.orderNumber
GROUP BY customers.customerName ORDER BY Average_sales DESC;

-- TASK - 2 NUMBERS OF ORDERS PLACED IN EACH MONTH

SELECT MONTHNAME(orderDate) AS Months, COUNT(orderNumber) AS Total_orders FROM orders
GROUP BY MONTHNAME(orderDate);

-- TASK - 3 PENDING SHIPMENT

SELECT orderNumber, status FROM orders WHERE status = "Pending";

-- TASK - 4 ORDERS ALONG WITH CUSTOMER DETAILS

SELECT customers.customerName, orders.orderNumber FROM customers 
JOIN orders ON orders.customerNumber = customers.customerNumber;

-- TASK - 5 MOST RECENT ORDER

SELECT orderNumber, orderDate FROM orders ORDER BY orderDate DESC LIMIT 1;

-- TASK - 6 TOTAL SALES FOR EACH ORDER

SELECT orderNumber, SUM(quantityOrdered * priceEach) AS Total_sales FROM orderdetails GROUP BY orderNumber;

-- TASK - 7 HIGHEST VALUE ORDER ON TOTAL SALES

SELECT orderNumber, SUM(quantityOrdered * priceEach) AS Total_sales FROM orderdetails 
GROUP BY orderNumber ORDER BY Total_sales DESC;

-- TASK - 8 ORDER DETAILS

SELECT * FROM orderdetails;

-- TASK - 9 MOST FREQUENTLY ORDERED PRODUCTS

SELECT products.productName, COUNT(orderdetails.productCode) AS No_orders FROM orderdetails
JOIN products ON products.productCode = orderdetails.productCode
GROUP BY products.productName ORDER BY No_orders DESC LIMIT 1;

-- TASK - 10 TOTAL REVENUE FOR EACH ORDERS

SELECT orderNumber, SUM(quantityOrdered * priceEach) AS Total_revenue FROM orderdetails GROUP BY orderNumber;

-- TASK - 11 MOST PROFITABLE ORDER

SELECT orderNumber, SUM(quantityOrdered * priceEach) AS Total_revenue, SUM(quantityOrdered * buyPrice) AS Total_cost,
(SUM(quantityOrdered * priceEach) -SUM(quantityOrdered * buyPrice)) AS Total_profit 
FROM orderdetails JOIN products ON products.productCode = orderdetails.productCode
GROUP BY orderNumber ORDER BY Total_profit DESC;

-- TASK - 12 ALL ORDERS WITH PRODUCT INFORMATION

SELECT * FROM orderdetails JOIN products ON products.productCode = orderdetails.productCode;

-- TASK - 13 ORDERS WITH DELAYED SHIPPING

SELECT orderNumber, requiredDate, shippedDate FROM orders
WHERE shippedDate > requiredDate;

-- TASK - 14 MOST POPURAL COMBINATION WITHIN ORDERS

SELECT od1.productCode AS product1, od2.productCode AS product2, COUNT(*) AS combination_count
FROM orderdetails od1 JOIN orderdetails od2 ON od1.orderNumber = od2.orderNumber 
AND od1.productCode < od2.productCode GROUP BY od1.productCode, od2.productCode
ORDER BY combination_count DESC LIMIT 10;

-- TASK - 15 TOP 10 MOST PROFITABLE ORDER 

SELECT orderNumber, SUM(quantityOrdered * priceEach) AS Total_revenue, SUM(quantityOrdered * buyPrice) AS Total_cost,
(SUM(quantityOrdered * priceEach) -SUM(quantityOrdered * buyPrice)) AS Total_profit 
FROM orderdetails JOIN products ON products.productCode = orderdetails.productCode
GROUP BY orderNumber ORDER BY Total_profit DESC LIMIT 10;

-- TASK - 16 TRIGGER FOR UPDATE CUSTOMER CREDIT LIMIT

DELIMITER // 
CREATE TRIGGER update_credit AFTER INSERT ON orderdetails FOR EACH ROW
BEGIN
DECLARE Total_purchase DECIMAL(10, 3);
DECLARE cust_id INT;

SET Total_purchase = NEW.quantityOrdered * NEW.priceEach;

SELECT customerNumber INTO cust_id FROM orders WHERE orderNumber = NEW.orderNumber;

UPDATE customers SET creditLimit = creditLimit - Total_purchase
WHERE customerNumber = cust_id;
END //
DELIMITER ; 

DROP TRIGGER update_credit;

INSERT INTO orderdetails (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber) 
VALUES (10108, 'S32_1374', 5, 200.00, 1);

-- TASK - 17 TRIGGERS FOR QTY CHANGES

DELIMITER // 
CREATE TRIGGER QTY_change AFTER INSERT ON orderdetails FOR EACH ROW
BEGIN
DECLARE prod_it VARCHAR(100);
DECLARE Stock_available INT;

SET prod_it = NEW.productcode;

SELECT quantityInStock INTO Stock_available FROM products
WHERE productcode = prod_it;  

IF NEW.quantityOrdered <= 0 THEN 
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Ordered quantity must be greater than zero.';
END IF;

IF NEW.quantityOrdered <= Stock_available THEN
UPDATE products SET quantityInStock = quantityInStock - NEW.quantityOrdered 
WHERE productcode = prod_it;

ELSE SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Ordered quantity exceeds available stock.';
END IF;

END //
DELIMITER ; 

DROP TRIGGER QTY_change;

INSERT INTO orderdetails (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber) 
VALUES (10100, 'S10_1949', 100, 200.00, 1);





















































/**************************************
Author: Chantal Shirley
Dungeons & Dragons Merchant Database Script
Date: 5/6/20
Desc: This is a file containing the sql
script needed to generate the Dungeons &
Dragons Merchant Database.
***************************************/

/**************************************
Part 1 - The establishment of tables for
the Dungeons and Dragons Merchant database
***************************************/

-- create the database
DROP DATABASE IF EXISTS dnd;
-- dnd stands for Dungeons & Dragons the main
-- product of the Dungeon & Dragons merchant
CREATE DATABASE dnd;

-- select the database
USE dnd;

-- create the tables
CREATE TABLE customer_data 
(
	customer_id INT(11) PRIMARY KEY AUTO_INCREMENT
		COMMENT "The customer's unique assigned id number",
	customer_first_name VARCHAR(50) NOT NULL
		COMMENT "The first name of the customer",
	customer_last_name VARCHAR(50) NOT NULL
		COMMENT "The last name of the customer",
	customer_street_address VARCHAR(50) NOT NULL
		COMMENT "The street shipping address of the customer",
	customer_city VARCHAR(50) NOT NULL
		COMMENT	 "The city in which the shipping address of the customer is located",
	customer_state VARCHAR(3) NOT NULL
		COMMENT "The state in which the customer's shipping address is located",
	customer_zip VARCHAR(25) NOT NULL
		COMMENT "The zip code in which the customer's shipping address is located",
	customer_phone VARCHAR(25) NOT NULL
		COMMENT "The phone number by which the customer can be reached for shipping purposes"
) COMMENT "A table that houses the basic personal shipping address information for customers";

CREATE TABLE employees
(
	employee_id INT(11) PRIMARY KEY AUTO_INCREMENT
		COMMENT "The employee's unique assigned id number",
	employee_first_name VARCHAR(50) NOT NULL
		COMMENT "The employee's first name",
	employee_last_name VARCHAR(50) NOT NULL
		COMMENT "The employee's last name",
	employee_role ENUM('Owner'
		,"Software Engineer"
        , "Quality Control Engineer"
        , "Store Employee"
        , "Sales Agent"
        , "New Hiree") NOT NULL DEFAULT "New Hiree"
        COMMENT "A value indicating the employee's role with the merchant"
) COMMENT "A table that houses the basic employee personal information for the merchant";

CREATE TABLE dnd_inventory
(
	product_id INT(11) PRIMARY KEY AUTO_INCREMENT
		COMMENT "A product's unique assigned id number",
	product_name VARCHAR(100) NOT NULL
		COMMENT "The name of the product",
	product_description VARCHAR(500) NOT NULL
		COMMENT "A description of the product in the merchant's inventory",
	product_stock INT(11) NOT NULL DEFAULT 0
		COMMENT "An account of how much product is currently in stock with the merchant",
	product_unit_cost DECIMAL(9,2) NOT NULL
		COMMENT "The cost per unit of the product in question"
) COMMENT "A table that houses the current inventory information for the merchant";

CREATE TABLE suppliers
(
	supplier_name VARCHAR(100)
		COMMENT "The unique name of the supplier that the merchant orders from",
	supplied_product_sequence INT(11) 
		COMMENT "The second portion of the two-column primary key where the",
	product_id INT(11) NOT NULL
		COMMENT "A foreign key reference to the inventory table of the merchant",
	assigned_agent INT(11) NOT NULL
		COMMENT "A foreign key reference to the employee id of the assigned sales agent",
	supplier_phone_number VARCHAR(25) NOT NULL
		COMMENT "The phone number from which the supplier can be contacted",
	CONSTRAINT pk_supplier_product
		PRIMARY KEY (supplier_name, supplied_product_sequence)
        COMMENT "The constraint enforcing the primary key relationship on the two-column primary key",
	CONSTRAINT fk_product_id_dnd_inventory
		FOREIGN KEY (product_id)
        REFERENCES dnd_inventory (product_id),
	CONSTRAINT fk_assigned_agent
		FOREIGN KEY (assigned_agent)
        REFERENCES employees (employee_id)
) COMMENT "A table that houses the basic vendor information for ordering purposes";

CREATE TABLE orders
(
	order_no INT(11) PRIMARY KEY AUTO_INCREMENT
		COMMENT "The unique order number assigned to every order made by the customer",
	customer_id INT(11) NOT NULL
		COMMENT "A foreign key reference to the customer's table",
	order_date DATE NOT NULL
		COMMENT "The date the order was made",
	ship_date DATE NOT NULL
		COMMENT "The date the order was shipped",
	CONSTRAINT fk_customer_id_customers
		FOREIGN KEY (customer_id)
        REFERENCES customer_data (customer_id)
) COMMENT "A table that houses basic order information for customers";

CREATE TABLE invoices 
(
	invoice_id INT(11) PRIMARY KEY AUTO_INCREMENT
		COMMENT "The unique invoice number assigned to every invoice generated for an order",
	order_no INT(11) NOT NULL
		COMMENT "A foreign key reference to the order number from the orders table",
	invoice_due_date DATE NOT NULL
		COMMENT "The day in which the customer must pay for the entirety of their order",
	invoice_status ENUM('paid', 'outstanding'
		, 'processing') NOT NULL DEFAULT 'processing'
		COMMENT "An indication of whether or not an invoice has been paid",
	invoice_total DECIMAL(9,2)
		COMMENT "The total of the invoice is verified after an insertion event which has a trigger",
	invoice_payment DECIMAL(9,2)
		COMMENT "How much the customer has paid on the invoice at the moment",
	CONSTRAINT fk_order_no_orders
		FOREIGN KEY (order_no)
        REFERENCES orders (order_no)
) COMMENT "A table that houses all of the invoices which are generated from orders placed by customers";

CREATE TABLE invoice_line_items
(
	invoice_line_item_id INT(11) NOT NULL
		COMMENT "A two-column primary key and foreign key reference to the invoice_id",
	invoice_line_item_sequence INT(11) NOT NULL
		COMMENT "A way to distiguish each line item from another that is connected to a specific invoice",
	product_id INT(11) NOT NULL
		COMMENT "A foreign key reference to the unique identifying number of a specific product",
	product_qty INT(11) NOT NULL
		COMMENT "The quantity of a particular item ordered",
	product_in_stock ENUM('in-stock'
		, 'back-ordered', 'processing') NOT NULL DEFAULT 'processing'
		COMMENT "An indication of whether or not an ordered item is in stock",
	CONSTRAINT pk_invoice_line_items
		PRIMARY KEY (invoice_line_item_id, invoice_line_item_sequence)
        COMMENT "A constraint to establish the two column invoice_line_item primary key",
	CONSTRAINT fk_invoice_line_item_id_invoices
		FOREIGN KEY (invoice_line_item_id)
        REFERENCES invoices (invoice_id), -- A foreign key reference to the invoices table
	CONSTRAINT fk_line_item_product_id_dnd_inventory
		FOREIGN KEY (product_id)
        REFERENCES dnd_inventory (product_id) -- A foreign key reference to the dnd_inventory table
) COMMENT "A table that houses all of the individual billable products ordered by the customer";

CREATE TABLE employees_after_delete_audit
(
	employee_id INT(11) NOT NULL
		COMMENT "Old employee's unique assigned id number",
	employee_first_name VARCHAR(50) NOT NULL
		COMMENT "Old employee's first name",
	employee_last_name VARCHAR(50) NOT NULL
		COMMENT "Old employee's last name",
	employee_role VARCHAR(50) NOT NULL
        COMMENT "A value indicating the employee's old role with the merchant"
) COMMENT "A table that keeps track of deleted employee data";

/**************************************
Part 2 - Insertion of Sample Data
***************************************/
USE dnd;

-- adds data to the customer_data table
INSERT INTO	customer_data
(
	customer_data.customer_id
    , customer_data.customer_first_name
    , customer_data.customer_last_name
    , customer_data.customer_street_address
    , customer_data.customer_city
    , customer_data.customer_state
    , customer_data.customer_zip
    , customer_data.customer_phone
)
VALUES
(
	89545
    , 'Gwendolyn'
    , 'Maia'
    , '2932 1st Ave NE'
    , 'Genesis'
    , 'ME'
    , '38492'
    , '372-382-3493'
),
(
	NULL
    , 'Venice'
    , 'Margarita'
    , '8451 8th St SE'
    , 'Compton'
    , 'NJ'
    , '84565'
    , '884-596-8941'
),
(
	NULL
    , 'Luukas'
    , 'Tadeu'
    , '84 Senate St'
    , 'Verily'
    , 'TX'
    , '89453'
    , '854-568-1893'
),
(
	NULL
    , 'Erin'
    , 'Lykke'
    , '648 Blvd'
    , 'Senior'
    , 'CA'
    , '38785'
    , '198-523-7816'
),
(
	NULL
    , 'Mangatjay'
    , 'Arsene'
    , '902 Prism Rd'
    , 'Series'
    , 'MA'
    , '94164'
    , '328-684-8913'
),
(
	NULL
    , 'Trenton'
    , 'Chess'
    , '938 Tree Ave'
    , 'Cedar Falls'
    , 'MI'
    , '93185'
    , '456-325-2161'
),
(
	NULL
    , 'Celeste'
    , 'Dostie'
    , '1123 Second St'
    , 'Fare'
    , 'SD'
    , '21341'
    , '312-111-4654'
),
(
	NULL
    , 'Buddy'
    , 'Jurado'
    , '5th Ave SE'
    , 'Reeds'
    , 'SC'
    , '43168'
    , '412-843-4365'
);

-- statement confirming successful insertion
USE dnd;
SELECT *
FROM customer_data;

-- adds data to the employees table
INSERT INTO employees
(
	employees.employee_id
    , employees.employee_first_name
    , employees.employee_last_name
    , employees.employee_role
)
VALUES
(
	232132
    , 'Jenni'
    , 'Rushin'
    , "Software Engineer"
),
(
	NULL
    , 'Dan'
    , 'Dittmer'
    , "Sales Agent"
),
(
	NULL
    , 'Temeka'
    , 'Faz'
    , 'Owner'
),
(
	NULL
    , 'Lindsay'
    , 'Rader'
    , "Quality Control Engineer"
),
(
	NULL
    , 'Vicki'
    , 'Francese'
    , "Sales Agent"
),
(
	NULL
    , 'Gerald'
    , 'Haecker'
    , "Store Employee"
),
(
	NULL
    , 'Jenny'
    , 'Sjoberg'
    , "Sales Agent"
),
(
	NULL
    , 'Brigid'
    , 'Heins'
    , "Software Engineer"
),
(
	NULL
    , 'Rhiannon'
    , 'Latour'
    , DEFAULT
);

-- statement confirming successful insertion
USE dnd;
SELECT *
FROM employees;

-- adds data to the dnd_inventory table
INSERT INTO dnd_inventory
(
	dnd_inventory.product_id
    , dnd_inventory.product_name
    , dnd_inventory.product_description
    , dnd_inventory.product_stock
    , dnd_inventory.product_unit_cost
)
VALUES
(
	39312
    , "5th Edition Gift Set and Hobby Exclusive"
    , "A gift set for all you 5th edition D&D lovers!"
	, 8
    , 159.99
),
(
	NULL
    , "Dungeons and Dragons Starter Set"
    , "Everyone has to start somewhere right?"
	, 15
    , 19.99
),
(
	NULL
    , "Dungeons & Dragons Fantasy Roleplaying Game"
    , "A 4th Edition variation on the original Red Box!"
	, 15
    , 19.99
),
(
	NULL
    , "Lords of Waterdeep: A Dungeons & Dragons Board Game"
    , "Based in the city of Waterdeep this board 
		game takes you into the classic tales of D&D!"
	, 20
    , 49.99
),
(
	NULL
    , "Nolzur's Marvelous Miniatures Treant"
    , "A tree-humanoid like figure that comes with a rock miniature too!"
	, 31
    , 17.85
),
(
	NULL
    , "Dungeons & Dragons Heat Change Mug & Sticker"
    , "A mug that changes colors and comes with vinyl stickers!"
	, 12
    , 19.99
),
(
	NULL
    , "Dungeons & Dragons Nolzur's Marvelous Drow"
    , "A dark-elf miniature with contours for easy painting!"
	, 11
    , 24.15
),
(
	NULL
    , "Dungeons & Dragons Spell Effects Wall of Fire & Ice"
    , "This pre-painted miniature set offers you everything 
		you need to show off your fire and ice spells!"
	, 18
    , 35.99
),
(
	NULL
    , "D&D Icons of the Realms Multi-Bricks Storm King's Thunder"
    , "This prepackaged 8 count of miniature bricks comes 
		with at least 60 figures for you to start you Storm Kings Thunder Campaign!"
	, 25
    , 109.31
),
(
	NULL
    , "D&D Icons of the Realms Volo Mordenkainen's 
		Foes Elder Brain & Stalagmites"
    , "Looking to fight some brains and rock monsters in a cave?"
	, 13
    , 39.06
),
(
	NULL
    , "Dungeons and Dragons Catapult Miniature"
    , "A catapult for all your DM needs!"
	, 5
    , 16.45
),
(
	NULL
    , "Orc: A D&D Icons of the Realm
		Monster Menagerie II"
    , "A Single Miniature of Orc variety, it has a common rarity."
	, 5
    , 12.33
),
(
	NULL
    , "Dungeons & Dragons of the Mad Mage
		Board Game Premium Edition"
    , "Everything you need to get started in this 
		condensed board game adventure for the Mad Mage!"
	, 0
    , 85.99
);

-- statement confirming successful insertion
USE dnd;
SELECT *
FROM dnd_inventory;

-- adds data to the suppliers table
INSERT INTO suppliers
(
	suppliers.supplier_name
    , suppliers.supplied_product_sequence
    , suppliers.product_id
    , suppliers.assigned_agent
    , suppliers.supplier_phone_number
)
VALUES
(
	"Hobby Wholesalers"
    , 1
    , 39312
    , 232133
    , "238-320-0032"
),
(
	"Hobby Wholesalers"
    , 2
    , 39320
    , 232133
    , "238-320-0032"
),
(
	"Hobby Wholesalers"
    , 3
    , 39316
    , 232136
    , "845-653-8987"
),
(
	"Hobby Wholesalers"
    , 4
    , 39319
    , 232136
    , "845-653-8987"
),
(
	"RPG Warehouse"
    , 1
    , 39314
    , 232138
    , "246-568-4535"
),
(
	"RPG Warehouse"
    , 2
    , 39313
    , 232138
    , "246-568-4535"
),
(
	"RPG Warehouse"
    , 3
    , 39318
    , 232138
    , "246-568-4535"
),
(
	"RPG Warehouse"
    , 4
    , 39324
    , 232138
    , "246-568-4535"
),
(
	"RPG Warehouse"
    , 5
    , 39323
    , 232138
    , "246-568-4535"
),
(
	"Citadel Stockhouse"
    , 1
    , 39315
    , 232133
    , "145-582-6515"
),
(
	"Citadel Stockhouse"
    , 2
    , 39322
    , 232133
    , "145-582-6515"
),
(
	"Citadel Stockhouse"
    , 3
    , 39321
    , 232136
    , "145-582-6515"
),
(
	"Citadel Stockhouse"
    , 4
    , 39317
    , 232136
    , "145-582-6515"
);

-- statement confirming successful insertion
USE dnd;
SELECT *
FROM  suppliers;

-- adds data to the suppliers table
INSERT INTO orders
(
	orders.order_no
    , orders.customer_id
    , orders.order_date
    , orders.ship_date
)
VALUES
(
	23748293
    , 89549
    , '2020-03-28'
    , '2020-04-10'
),
(
	NULL
    , 89546
    , '2020-04-08'
    , '2020-04-12'
),
(
	NULL
    , 89547
    , '2020-04-13'
    , '2020-04-15'
),
(
	NULL
    , 89551
    , '2020-04-13'
    , '2020-04-23'
),
(
	NULL
    , 89552
    , '2020-04-13'
    , '2020-04-27'
),
(
	NULL
    , 89548
    , '2020-04-14'
    , '2020-04-20'
),
(
	NULL
    , 89550
    , '2020-04-16'
    , '2020-04-27'
),
(
	NULL
    , 89545
    , '2020-04-16'
    , '2020-04-27'
);



-- statement confirming successful insertion
USE dnd;
SELECT *
FROM  orders;

-- adds data to the invoices table
INSERT INTO invoices
(
	invoices.invoice_id
    , invoices.order_no
    , invoices.invoice_due_date
    , invoices.invoice_status
    , invoices.invoice_total
)
VALUES
(
	DEFAULT
    , 23748296
    , '2020-04-22'
    , DEFAULT
    , NULL
),
(
	DEFAULT
    , 23748300
    , '2020-04-26'
    , DEFAULT
    , NULL
),
(
	DEFAULT
    , 23748293
    , '2020-03-28'
    , 'outstanding'
    , NULL
),
(
	DEFAULT
    , 23748298
    , '2020-04-19'
    , 'outstanding'
    , NULL
),
(
	DEFAULT
    , 23748295
    , '2020-04-13'
    , DEFAULT
    , NULL
),
(
	DEFAULT
    , 23748299
    , '2020-04-16'
    , DEFAULT
    , NULL
),
(
	DEFAULT
    , 23748294
    , '2020-04-08'
    , DEFAULT
    , NULL
),
(
	DEFAULT
    , 23748297
    , '2020-04-26'
    , DEFAULT
    , NULL
);

-- statement confirming successful insertion
USE dnd;
SELECT *
FROM  invoices;

-- adds data to the invoice_line_items table
INSERT INTO invoice_line_items
(
	invoice_line_items.invoice_line_item_id
    , invoice_line_items.invoice_line_item_sequence
    , invoice_line_items.product_id
    , invoice_line_items.product_qty
    , invoice_line_items.product_in_stock
)
VALUES
(
	1
    , 1
    , 39312
    , 1
    , 'in-stock'
),
(
	1
    , 2
    , 39320
    , 1
    , 'in-stock'
),
(
	1
    , 3
    , 39319
    , 2
    , DEFAULT
),
(
	2
    , 1
    , 39324
    , 1
    , 'back-ordered'
),
(
	3
    , 1
    , 39315
    , 4
    , 'in-stock'
),
(
	4
    , 1
    , 39313
    , 1
    , DEFAULT
),
(
	4
    , 2
    , 39317
    , 3
    , 'in-stock'
),
(
	4
    , 3
    , 39313
    , 2
    , 'in-stock'
),
(
	5
    , 1
    , 39314
    , 2
    , 'in-stock'
),
(
	6
    , 1
    , 39318
    , 7
    , 'in-stock'
),
(
	7
    , 1
    , 39321
    , 1
    , 'in-stock'
),
(
	7
    , 2
    , 39322
    , 3
    , 'in-stock'
),
(
	8
    , 1
    , 39315
    , 1
    , 'in-stock'
);

-- statement confirming successful insertion
USE dnd;
SELECT *
FROM  invoice_line_items;

/**************************************
Part 3 - Create two triggers (there are three
	to include at least one for delete)
***************************************/
-- A trigger that validates the invoice_total amount
-- before entering the total
DELIMITER // 

CREATE TRIGGER invoice_total_verifier
	BEFORE UPDATE on invoices
    FOR EACH ROW
BEGIN
	DECLARE invoice_total_amount DECIMAL(9,2);
	
    SELECT 
		SUM((invoice_line_items.product_qty)*(dnd_inventory.product_unit_cost)) AS "Invoice Total"
	INTO
		invoice_total_amount
	FROM
		invoice_line_items
		JOIN
			dnd_inventory
				ON
					invoice_line_items.product_id =
						dnd_inventory.product_id
	WHERE
		invoice_line_item_id = NEW.invoice_id;
        
	IF invoice_total_amount != NEW.invoice_total THEN
		SIGNAL SQLSTATE 'HY000' -- A general error
			SET MESSAGE_TEXT = 'Your total did not match the total in the system!';
	END IF;
END//

DELIMITER ; 

/******************************
Code written to test trigger:

UPDATE
	invoices
SET
	invoices.invoice_total = 341.28
WHERE
	invoices.invoice_id = 1;
    
-----------------------------------

UPDATE
	invoices
SET
	invoices.invoice_total = 10
WHERE
	invoices.invoice_id = 1;
********************************/
    
-- A trigger that prevents over-paying, insertion of
-- negative values, and changing a status to "paid" if it is not

DELIMITER // 

CREATE TRIGGER payment_charge_verifier
	BEFORE UPDATE on invoices
    FOR EACH ROW
BEGIN
	DECLARE invoice_total_amount DECIMAL(9,2);
    DECLARE invoice_payment_status VARCHAR(50);
	
    SELECT 
		SUM((invoice_line_items.product_qty)*(dnd_inventory.product_unit_cost)) AS "Invoice Total"
	INTO
		invoice_total_amount
	FROM
		invoice_line_items
		JOIN
			dnd_inventory
				ON
					invoice_line_items.product_id =
						dnd_inventory.product_id
		JOIN
			invoices
				ON
					invoice_line_items.invoice_line_item_id =
						invoices.invoice_id
	WHERE
		invoice_line_item_id = NEW.invoice_id;
        
	SELECT
		invoices.invoice_payment
	INTO
		invoice_payment_status
	FROM
		invoices
	WHERE
		invoice_id = NEW.invoice_id;
        
	IF NEW.invoice_payment > invoice_total_amount THEN
		SIGNAL SQLSTATE 'HY000' -- A general error
			SET MESSAGE_TEXT = 'Customers cannot be overcharged!';
	END IF;
	IF NEW.invoice_payment < 0 THEN
		SIGNAL SQLSTATE 'HY000' -- A general error
			SET MESSAGE_TEXT = 'You cannot insert negative numbers!';
	END IF;
    IF NEW.invoice_status = 'paid' AND
		invoice_payment_status != invoice_total_amount THEN
		SIGNAL SQLSTATE 'HY000' -- A general error
			SET MESSAGE_TEXT = 'You cannot mark an account paid that has not met the balance!';
	END IF;
END//

DELIMITER ; 

/******************************
Code written to test trigger:
UPDATE
	invoices
SET
	invoices.invoice_payment = 5000
WHERE
	invoices.invoice_id = 1;
    
-----------------------------------
    
UPDATE
	invoices
SET
	invoices.invoice_payment = -34
WHERE
	invoices.invoice_id = 1;
    
-----------------------------------
    
UPDATE
	invoices
SET
	invoices.invoice_status = 'paid'
WHERE
	invoices.invoice_id = 1;

-----------------------------------

UPDATE
	invoices
SET
	invoices.invoice_status = 'outstanding'
WHERE
	invoices.invoice_id = 1;
**********************************/

-- A trigger that moves old employee data into an employee audit table
DELIMITER // 

CREATE TRIGGER assigned_agent
	BEFORE DELETE on employees
    FOR EACH ROW
BEGIN
	INSERT INTO
		employees_after_delete_audit VALUES
	(
		OLD.employee_id
        , OLD.employee_first_name
        , OLD.employee_last_name
        , OLD.employee_role
	);
END//

DELIMITER ; 

-- An example record of an employee being removed from the database
DELETE FROM
	employees
WHERE
	employees.employee_id = '232140';

-- A table demonstrating the revised employee table

SELECT * 
FROM
	employees;

-- A table demonstrating where the old data moved to
SELECT *
FROM
	employees_after_delete_audit;
	
/**************************************
Part 4 - Create two views
***************************************/
USE dnd;

-- This view displays whether customer's have 
-- paid or if their payment information is still processing
-- until stored procedures are called to populate the data
-- all columns will pull default responses for null results
CREATE OR REPLACE VIEW outstanding_or_processing_customer_payment AS
	SELECT
		CONCAT(customer_data.customer_first_name, ' ',customer_data.customer_last_name) 
			AS 'name'
		, invoices.invoice_id
        , IFNULL(invoices.invoice_total, "Currently Unavailable") AS 'invoice_total'
        , IFNULL(invoices.invoice_payment, "Currently Unavailable") AS 'invoice_payment'
        , IFNULL((invoices.invoice_total - invoices.invoice_payment), 'Payment Information Unavailable') AS 'balance_remaining'
	FROM
		customer_data
			JOIN
				orders
					ON
						customer_data.customer_id =
							orders.customer_id
			JOIN
				invoices
					ON
						orders.order_no =
							invoices.order_no
	WHERE
		invoices.invoice_status = 'outstanding' OR
        invoices.invoice_status = 'processing'
WITH CHECK OPTION; -- to avoid errors that might result from modified rows
        
-- Code that allows you to see the view
        
SELECT *
FROM
	outstanding_or_processing_customer_payment;
    
-- This view displays which companies are assigned to which sales agents
-- And displays the respective contact numbers they use for their assigned product
USE dnd;

CREATE OR REPLACE VIEW assigned_sales_agents AS
	SELECT
		CONCAT(employees.employee_first_name, ' ', employees.employee_last_name) AS 'employee_name'
        , suppliers.supplier_name
        , suppliers.supplier_phone_number
	FROM
		employees
			JOIN
				suppliers
					ON
						employees.employee_id =
							suppliers.assigned_agent
	GROUP BY
		CONCAT(employees.employee_first_name, ' ', employees.employee_last_name), supplier_name;
        
-- Code that allows you to see the view
        
SELECT *
FROM
	assigned_sales_agents;

/**************************************
Part 5 - Create four stored procedures
***************************************/
USE dnd;

/************************************** 
Stored Procedure One
***************************************/
-- This stored procedure populates the invoice_total column of the invoice table
-- using calculated values from the invoice_line_items table
DROP PROCEDURE IF EXISTS populate_invoice_totals;

DELIMITER // 

CREATE PROCEDURE populate_invoices_totals 
(
	var_invoice_id INT 
) 
BEGIN 
	DECLARE invoice_line_items_summed DECIMAL(9,2);
    
    -- Validating parameter entered
    IF var_invoice_id < 0 THEN
		SIGNAL SQLSTATE '22003' -- used to indicate a number out of bounds
			SET MESSAGE_TEXT =
				"You may not enter negative invoice id numbers",
			MYSQL_ERRNO = 1146;
    END IF;
    
	SELECT 
		SUM((invoice_line_items.product_qty)*(dnd_inventory.product_unit_cost)) AS "Invoice Total"
	INTO
		invoice_line_items_summed
	FROM
		invoice_line_items
		JOIN
			dnd_inventory
				ON
					invoice_line_items.product_id =
						dnd_inventory.product_id
	WHERE
		invoice_line_item_id = var_invoice_id;
        
	UPDATE
		invoices
	SET
		invoices.invoice_total = invoice_line_items_summed
	WHERE
		invoices.invoice_id = var_invoice_id;

END//
COMMENT "A stored procedure for populating invoice total amounts to existing accounts"
DELIMITER ; 
-- populating table values to show how the view is affected below
CALL populate_invoices_totals(1);
CALL populate_invoices_totals(2);
CALL populate_invoices_totals(3);
CALL populate_invoices_totals(4);
CALL populate_invoices_totals(5);
CALL populate_invoices_totals(6);
CALL populate_invoices_totals(7);
CALL populate_invoices_totals(8);


-- displaying newly updated view to demonstrate
--  a partially populated table in the view
SELECT *
FROM
	outstanding_or_processing_customer_payment;
    
/************************************** 
Stored Procedure Two
***************************************/
-- This stored procedure populates the invoice_payment column of the invoice table
DROP PROCEDURE IF EXISTS populate_invoice_payments;

DELIMITER // 

CREATE PROCEDURE populate_invoice_payments
(
	var_invoice_id INT,
    var_invoice_payment DECIMAL(9,2)
) 
BEGIN 
	IF var_invoice_id < 0 THEN
		SIGNAL SQLSTATE '22003' -- used to indicate a number out of bounds
			SET MESSAGE_TEXT =
				"You may not enter negative invoice id numbers",
			MYSQL_ERRNO = 1146;
    END IF;
    IF var_invoice_payment < 0 THEN
		SIGNAL SQLSTATE '22003' -- used to indicate a number out of bounds
			SET MESSAGE_TEXT =
				"You may not enter negative invoice payment amounts",
			MYSQL_ERRNO = 1146;
    END IF;
	UPDATE
		invoices
	SET
		invoices.invoice_payment = var_invoice_payment
	WHERE
		invoices.invoice_id = var_invoice_id;

END//
COMMENT "A stored procedure for populating invoice payment amounts to existing accounts"
DELIMITER ; 

-- populating table values to show how the view is affected below
CALL populate_invoice_payments(1, 341.28);
CALL populate_invoice_payments(2, 85.99);
CALL populate_invoice_payments(3, 5.03);
CALL populate_invoice_payments(4, 11.54);
CALL populate_invoice_payments(5, 39.98);
CALL populate_invoice_payments(6, 169.05);
CALL populate_invoice_payments(7, 88.41);
CALL populate_invoice_payments(8, 49.99);


-- displaying newly updated view to demonstrate
--  a populated table in the view
SELECT *
FROM
	outstanding_or_processing_customer_payment;
    
-- displaying the invoices table with updated invoice_payment information
SELECT *
FROM
	invoices;
    
/************************************** 
Stored Procedure Three
***************************************/
-- This stored procedure updates the paid columns
DROP PROCEDURE IF EXISTS update_paid_statuses;

DELIMITER // 

CREATE PROCEDURE update_paid_statuses
(
	var_invoice_id INT
) 
BEGIN 
	DECLARE var_invoice_payment DECIMAL(9,2);
    DECLARE var_invoice_total DECIMAL(9,2);

	IF var_invoice_id < 0 THEN
		SIGNAL SQLSTATE '22003' -- used to indicate a number out of bounds
			SET MESSAGE_TEXT =
				"You may not enter negative invoice id numbers",
			MYSQL_ERRNO = 1146;
    END IF;
    IF var_invoice_payment < 0 THEN
		SIGNAL SQLSTATE '22003' -- used to indicate a number out of bounds
			SET MESSAGE_TEXT =
				"You may not enter negative invoice payment amounts",
			MYSQL_ERRNO = 1146;
    END IF;
    
    SELECT 
		invoices.invoice_payment
    INTO 
		var_invoice_payment
	FROM
		invoices
	WHERE
		invoices.invoice_id = var_invoice_id;
        
	SELECT
		invoices.invoice_total
	INTO
		var_invoice_total
	FROM
		invoices
	WHERE
		invoices.invoice_id = var_invoice_id;
        
	IF var_invoice_payment != var_invoice_total THEN
		SIGNAL SQLSTATE '22003'
			SET MESSAGE_TEXT =
				"The invoice payment must be the same amount as the invoice total to use this function!",
			MYSQL_ERRNO = 1146;
	END IF;
    
	UPDATE
		invoices
	SET
		invoices.invoice_status = 'paid'
	WHERE
		invoices.invoice_id = var_invoice_id;

END//
COMMENT "A stored procedure for populating invoice payment status that have been paid"
DELIMITER ; 

-- populating table values to show how the view is affected below
CALL update_paid_statuses(1);
CALL update_paid_statuses(2);
CALL update_paid_statuses(5);
CALL update_paid_statuses(6);
CALL update_paid_statuses(7);
CALL update_paid_statuses(8);

-- displaying newly updated view to demonstrate
-- how the table has now become smaller
SELECT *
FROM
	outstanding_or_processing_customer_payment;
    
-- displaying how the invoices table has been
-- updated with the new "paid" statuses
SELECT *
FROM
	invoices;
    
/************************************** 
Stored Procedure Four
***************************************/
-- A stored procedure for displaying how many 
-- orders were ordered and how many orders
-- were shipped in a particular month

-- This stored procedure updates the paid columns
DROP PROCEDURE IF EXISTS count_of_orders_made;

DELIMITER // 

CREATE PROCEDURE count_of_orders_made
(
	var_order_month INT,
    var_order_year INT
) 
BEGIN 
	IF var_order_month < 1 THEN
		SIGNAL SQLSTATE '22003' -- used to indicate a number out of bounds
			SET MESSAGE_TEXT =
				"Months must be between 1 and 12",
			MYSQL_ERRNO = 1146;
    END IF;
    IF var_order_month > 12 THEN
		SIGNAL SQLSTATE '22003' -- used to indicate a number out of bounds
			SET MESSAGE_TEXT =
				"Months must be between 1 and 12",
			MYSQL_ERRNO = 1146;
    END IF;
    IF var_order_year < 2020 THEN
		SIGNAL SQLSTATE '22003' -- used to indicate a number out of bounds
			SET MESSAGE_TEXT =
				"Years must start in 2020, the year the company was established.",
			MYSQL_ERRNO = 1146;
    END IF;
    IF var_order_year > YEAR(CURDATE()) THEN
		SIGNAL SQLSTATE '22003' -- used to indicate a number out of bounds
			SET MESSAGE_TEXT =
				"Years must start in 2020, and end with the current year",
			MYSQL_ERRNO = 1146;
    END IF;

    SELECT
		CONCAT(var_order_month,'/', var_order_year) as month_and_year
		, COUNT(order_date) AS 'orders_made'
	FROM
		orders
	WHERE
		MONTH(order_date) = var_order_month AND
        YEAR(order_date) = var_order_year;

END//
COMMENT "A stored procedure that accepts integers as months and 4 digit integers as years and pulls the count of how many items were orded or shipped"
DELIMITER ; 

-- Demonstration of the data that can be pulled using the stored procedures

CALL count_of_orders_made(4, 2020);
CALL count_of_orders_made(3, 2020);

-- A way to cross check the counts made against the table they are being pulled from

SELECT *
FROM
	orders;
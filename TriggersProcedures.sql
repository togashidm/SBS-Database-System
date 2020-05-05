--
--	COPY AND PASTE TO SQL AND EXECUTE
--	THEN USE THE EXAMPLES FOR TESTING.
--

/*	PROCEDURE 1:
 
	Get the total sales made from the last 30 days
	by counting from the current date. To test this procedure, run
	
	CALL LastMonthTotalSales(@total);
	SELECT @total;
*/

DELIMITER //
CREATE PROCEDURE LastMonthTotalSales(OUT LastMonthTotalSales REAL )
BEGIN
	SELECT SUM(Price) 
		INTO LastMonthTotalSales
		FROM sales
		WHERE MONTH(Date) = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH));
END
//

##########################################################################

/*	PROCEDURE 2:
 
	Creates a table of customers that have bought a specific vehicle model
	To test this procedure, run with modelName in the sales table
	For example:
	
	CALL possibleSalesForNewModel('civic');
	
*/

DELIMITER
//
CREATE PROCEDURE possibleSalesForNewModel(modelName varchar(60) )
BEGIN
    DROP TABLE IF EXISTS alertnewmodeltocustomers;
	CREATE TABLE alertNewModeltoCustomers 
	AS
	SELECT * 
	FROM customers 
	JOIN (
    SELECT customer_id,model,date 
    FROM sales) 
    AS temp 
    USING(customer_id) where model=modelName;
END
//

##########################################################################

/* FUNCION

	This function calculates the bonus that each employee receives based on the previous sales month.
	It considers the previous sales month, the employee role and salary.
	To test this function Execute the two SQL lines:
	
	CALL LastMonthTotalSales(@total);
	SELECT companyBonus(@total, role, salary) as MonthBonus FROM employee
*/

DELIMITER //
CREATE FUNCTION companyBonus(
    monthSales REAL, role VarChar(60), salary double (10,2) ) 
RETURNS REAL
DETERMINISTIC
BEGIN
    DECLARE bonus double (10,2);
	-- First threshold
     IF monthSales > 75000  THEN
        IF role = 'Sales' OR role = 'Sales Assistant' THEN
        	SET bonus = monthSales*0.02 + Salary*0.5;
        ELSE
           	SET bonus = 200 + Salary*0.10;
        END IF;
	-- Second threshold	
    ELSEIF monthSales > 50000 THEN
    	IF role = 'Sales' OR role = 'Sales Assistant' THEN
        	SET bonus = monthSales*0.02;
        ELSE
        	SET bonus = Salary*0.05;
        END IF;
	-- Third threshold	
    ELSEIF monthSales > 10000 THEN
    	IF role = 'Sales' OR role = 'Sales Assistant' THEN
        	SET bonus = monthSales*0.01;
        END IF;
    END IF;
    -- return the bonus
    RETURN (bonus);
END//


##########################################################################

/* FIRST TRIGGER

It is fired when an insert is made in the car table
This updates Vehicle table with a VIN, vehicle_type and make.

To test this trigger you can use for example, for car:

INSERT INTO `car` (`VIN`, `Registration`, `Model`, `Colour`, `EngineSize`, `Mileage`, `Yr`, `Fuel`, `Price`) 
VALUES ('000CE3GK5AS176321', '171LK01', 'Civic', 'Baltic', '50', '0', '2015', 'Petrol', '25000.00')

and for motorcycle:

INSERT INTO `motorcycle` (`VIN`, `Registration`, `Model`, `Colour`, `EngineSize`, `Mileage`, `Yr`, `Fuel`, `Price`) 
VALUES ('XXXXE3GK5AS176321', '151LK001', 'SX 125', 'Platinum', '50', '0', '2018', 'Petrol', '45000.00')

 */
 
DELIMITER
//
CREATE TRIGGER addCar
AFTER INSERT ON car
FOR EACH ROW
BEGIN
     IF new.vin NOT IN(SELECT vin FROM vehicle) THEN
    	INSERT INTO vehicle(vin, Vehicle_Type, Make) 
		VALUES(new.vin, 'Car',(SELECT make from makemodel
                                   WHERE makemodel.model=new.model));
        END IF;
END;
//

#-------------------- REPEAT FOR MOTORCYCLE

DELIMITER
//
CREATE TRIGGER addMotorcycle
AFTER INSERT ON motorcycle
FOR EACH ROW
BEGIN
     IF new.vin NOT IN(SELECT vin FROM vehicle) THEN
    	INSERT INTO vehicle(vin, Vehicle_Type, Make) 
		VALUES(new.vin, 'Motorcycle',(SELECT make from makemodel
                                   WHERE makemodel.model=new.model));
        END IF;
END;
//


##########################################################################
/* SECOND TRIGGER 

	Based on the sales month, each employee may receive a bonus.
	This bonus is calculated by the Function companyBonus. 
	The previous sales month is obtained from the procedure LastMonthTotalSales
	
	This trigger is fired every time that a new sale is inserted. However,
	the bonus table is updated only if at least 30 days has passed since the
	previous bonus.
	
	To test this trigger, ensures that the most recent date in bonus table is > 30 days
	from now. Check the values of the current date in the bonus table. You can set to zero
	to make easy to see if the trigger is working.
	
	UPDATE bonus SET bonus=0.0, lastdate='2019-10-22';
	
	Because there is sale, you need to insert an existent customer or a new customer. Then insert a new sale:
	
	INSERT INTO `sales` (`VIN`, `Customer_ID`, `model`, `Date`, `Price`, `Employee_ID`) 
	VALUES ('100CE3GK5AS176321', '8', 'Q8', '2019-11-23', '10.00', '1');
*/

DELIMITER
//
CREATE TRIGGER employeeBonus 
AFTER INSERT ON sales 
FOR EACH ROW 
BEGIN 
	CALL LastMonthTotalSales(@total); 
	IF (SELECT DATEDIFF(NOW(), MAX(lastdate)) FROM bonus) > 30 
		THEN 
			UPDATE bonus 
				SET bonus = (SELECT companyBonus(@total, role, salary) 
					FROM employee 
					WHERE bonus.Employee_ID=employee.Employee_ID), 
					lastdate = CURRENT_DATE; 
	END IF; 
END;
// 

##########################################################################
/* THIRD TRIGGER 

	With the introduction of a new vehicle model, the table alertNewModeltoCustomers 
	will be updated with customers that have bought that model in the past.	
	To test this Trigger you need to introduce some model that is already in
	sales table.
	
	For example:
	
	INSERT INTO `car` (`VIN`, `Registration`, `Model`, `Colour`, `EngineSize`, `Mileage`, `Yr`, `Fuel`, `Price`) 
	VALUES ('000KE3GK5AS176321', '181LK01', 'Q8', 'Baltic', '50', '0', '2015', 'Petrol', '25000.00')
	
	NOTE: This trigger will ONLY work if PROCEDURE 2 was executed. (table alertNewModeltoCustomers must exist).
	
*/
DELIMITER
//
CREATE TRIGGER possibleSalesTrigger
BEFORE INSERT ON car 		#--changed AFTER to BEFORE in order to load the trigger
FOR EACH ROW
	BEGIN
		DELETE from alertNewModeltoCustomers;
		CREATE TEMPORARY table temptable (SELECT * 
			FROM customers 
			JOIN (
    		SELECT customer_id,model,date 
    		FROM sales) 
    		AS temp 
    		USING(customer_id) where model=new.model);
		IF new.model IN(SELECT model FROM sales) THEN
    		INSERT INTO alertnewmodeltocustomers
			select * FROM temptable; 
    	END IF;       
    END
//


##########################################################################
/* FOURTH TRIGGER 

	With the introduction of a new SALE item, the tables car,motorcycle and vehicle need
	to be updated by removing the item by using the vin number.
	
	To test this Trigger you need to introduce a new sale with the vin number of the item
	existent either on car or motorcycle tables.
	
	INSERT INTO `sales` (`VIN`, `Customer_ID`, `Date`, `Price`, `Employee_ID`) 
	VALUES ('000CE3GK5AS176321', '8', '2019-11-23', '10.00', '1');
	
	and for motorcycle
	
	INSERT INTO `sales` (`VIN`, `Customer_ID`, `model`, `Date`, `Price`, `Employee_ID`) 
	VALUES ('000CE3GK5AS176321', '8', 'Civic', '2019-11-23', '25000.00', '1');
	
	
	
*/

DELIMITER
//
CREATE TRIGGER removeItemfromStock
BEFORE INSERT ON sales
FOR EACH ROW
	BEGIN
		IF new.vin NOT IN(SELECT vin FROM sales) THEN
    		DELETE FROM car WHERE vin=new.vin;
            DELETE FROM motorcycle WHERE vin=new.vin;
            DELETE FROM vehicle WHERE vin=new.vin;            
    	END IF;       
    END
//

# SBS-Database-System

## 1. Summary
This database is designed for a Car and Motorcycle Selling company. The software used with this is called SBS. SBS boasts a single portal environment is leading the way in dealership technology. This innovative interface gives you access to what you need to help lower expenses, drive revenue and increase profits in every department.
The database is designed to collect data and stores it in useful tables that the client can use. The tables used are Customers, Employees, Sales, Vehicle, Cars, Motorcycles, and a Bonus table. All our database tables are designed to be concise and hold unnecessary data.
The customer wanted a system that was able to track their inventory as well as track sales and customer data. This would be used to help single out vehicles for clients to purchase as well as allow for marketing opportunities. 
In response to their request, we designed a system in which they can use to control the stock of new and used cars for a car/motorcycle dealership as well as sales and client information and to assign employee bonuses based on sales performance.  
The database also contains Views that allow the client to quickly access the most common queries that they have from various tables and help them in their business reports.
In summary, the database was designed using MySQL to attend the most of the needs of a Car and Motorcycle Selling company in a quick, robust and effective way. (Team: Robert Dolan – Richard Moloney – Denisio Togashi – Thomas Nugent)

## 2. Entity-relationship diagram


## 3. Database Structure


## 4. Database Functionalities
* The database is designed to collection data and stores it in useful tables that the client can use.
* The customer wanted a system that was able to track their inventory as well as track sales and customers data.
* To control the stock of new and used cars for a car/motorcycle dealership as well as sales and client information.
* To assign employee bonus based on sales performance.  
* The database also contains Views that allow the client to quick access the most common queries.

## 5. Trigger and Procedures

1. Get the total sales made from the last 30 days by counting from the current date. To test this procedure, run:
2. Creates a table of customers that have bought a specific vehicle model.
3. This function calculates the bonus that each employee receives based on the previous sales month.
4. This trigger that is fired when an insert is made in the car table. This updates Vehicle table with a VIN, vehicle_type and make. 
5. Based on the sales month, each employee may receive a bonus. This bonus is calculated by the Function companyBonus.  The previous sales month is obtained from the procedure LastMonthTotalSales. 
This trigger is fired every time that a new sale is inserted. However, the bonus table is updated only if at least 30 days has passed since the previous bonus.
6. With the introduction of a new vehicle model, the table alertNewModeltoCustomers 	will be updated with customers that have bought that model in the past.
7. With the introduction of a new SALE item, the tables car,motorcycle and vehicle need to be updated by removing the item by using the vin number.

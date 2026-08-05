create database amazon;

-- task 2
-- table name:customers, primary key:customerID, foreign key:-
-- table name:order_details, primary key:-, foreign key:orderID,productID, relationship: many products can be placed under one orderID
-- table name:orders, primary key:orderID, foreign key:customerID, relationship: one customer can place many orders
-- table name:products, primary key:productID, foreign key:-
-- table name:reviews, primary key:one customer can give many reviews for one product, one customer can give reviews for many products
-- table name:suppliers, primary key:supplierID, foreign key:-, one supplier can supplies many products

-- task 3
select*from amazon.customers;
select*from amazon.customers where city="Bettyport";
select*from amazon.products where category="Fruits";

-- task 4
-- Write DDL statements to recreate the Customers table with the following constraints:
-- CustomerID as the primary key.
-- Ensure Age cannot be null and must be greater than 18.
-- Add a unique constraint for Name.

alter table amazon.customers modify age int not null;
alter table amazon.customers add check (age>=18);
alter table amazon.customers add unique(name);

-- task 5
-- insert 3 new rows into the products table using insert statement
insert into amazon.products(ProductID,ProductName,Category,SubCategory,PricePerUnit,StockQuantity,SupplierID) values("bcf5cc36-0e00-47d4-ba0f-22f389b6250f","War Diar","Dairy",
"Sub-Dairy-4",198,349,"260e110g-437a-41b7-9f41-5nd10791e1a3"),("bcf5cc36-0e02-47d4-da0f-22h389m6251q","Want Fruit","Fruits","Sub-Fruit-1",120,300,"260e110g-437a-43b7-9f41-5nd90798e1a8"),
("bcf5cc36-7e00-47g4-ba0h-22e389b6250f","Understand Vegetable","Vegetables","Sub-Vegetables-3",204,70,"260e110g-433a-51b7-9f301-5nd10791k1a3");

-- task 6
-- update the stock quantity of a product where productID matches a specific ID
update amazon.products set StockQuantity=40 where ProductID="064d30f7-40a7-4059-b207-a31372b5d549";

-- task 7
-- delete a supplier from the suppliers table where their city matches a specific val
delete from amazon.suppliers where city="Jerryview";

-- task 8
-- Add a CHECK constraint to ensure that ratings in the Reviews table are between 1 and 5.
alter table amazon.reviews add check (rating between 1 and 5);
-- Add a DEFAULT constraint for the PrimeMember column in the Customers table (default value: "No").
alter table amazon.customers change PrimeMember PrimeMember varchar(50);
alter table amazon.customers alter PrimeMember set default "No";

-- task 9
-- WHERE clause to find orders placed after 2024-01-01.
select*from amazon.orders where OrderDate>"2024-01-01";
-- HAVING clause to list products with average ratings greater than 4.
select ProductID,avg(Rating) from amazon.reviews group by ProductID having avg(Rating)>4;
-- GROUP BY and ORDER BY to rank products by total sales.


-- task 10
-- Calculate each customer's total spending.
select CustomerID,sum(OrderAmount) from amazon.orders group by CustomerID;
-- 2. Rank customers based on their spending.
select CustomerID,OrderAmount,OrderDate,rank() over(partition by CustomerID order by OrderAmount desc)as SpendingRank from amazon.orders;
-- 3. Identify customers who have spent more than ₹5000.
select*from amazon.orders where OrderAmount>5000;

-- task 11
-- Join the Orders and OrderDetails tables to calculate total revenue per order.
select ord.OrderID,sum(od.quantity*od.UnitPrice*(1-od.Discount))-ord.DiscountApplied as Total_revenue from amazon.orders as ord 
inner join amazon.order_details as od on ord.OrderID=od.OrderID group by OrderID order by Total_revenue desc;
-- Identify customers who placed the most order in specific time period.
select cus.name,count(od.OrderID) as Consumers from amazon.customers as cus 
inner join amazon.orders as od on cus.CustomerID=od.CustomerID group by cus.name order by Consumers desc limit 1;
-- Find the supplier with the most products in stock.
select supp.SupplierName,count(pro.StockQuantity) as Highproduct from amazon.suppliers as supp 
inner join amazon.products 
as pro on pro.SupplierID=supp.SupplierID 
group by supp.SupplierName order by Highproduct desc limit 1;

-- Task 12: Normalize the Products table to 3NF:
-- Separate product categories and subcategories into a new table.
create table amazon.productinfo(productID varchar(100),category text,subcategory text);
insert into amazon.productinfo(productID,category,subcategory) 
select ProductID,Category,SubCategory from amazon.products;
-- Create foreign keys to maintain relationships.
alter table amazon.productinfo add foreign key(productID) references products(ProductID);

-- Task 13: Write a subquery to:
-- Identify the top 3 products based on sales revenue.
select ProductName,ProductID,(select sum(od.quantity*od.UnitPrice*(1-od.Discount/100)) from
amazon.order_details as od where od.ProductID=od.ProductID) as Total_revenue from amazon.products
 group by ProductName,ProductID order by Total_revenue desc limit 3;
-- Find customers who haven’t placed any orders yet.
select CustomerID from amazon.customers where CustomerID not in(select CustomerID from amazon.orders);

-- Task 14: Provide actionable insights:
-- Which cities have the highest concentration of Prime members?
select City,count(PrimeMember) as High from amazon.customers where PrimeMember="Yes" group by City order by High desc; 
-- What are the top 3 most frequently ordered categories?
select pr.Category,sum(od.Quantity) as Topordered from amazon.products as pr 
inner join amazon.order_details as od on pr.ProductID=od.ProductID group by pr.Category order by Topordered desc limit 3;
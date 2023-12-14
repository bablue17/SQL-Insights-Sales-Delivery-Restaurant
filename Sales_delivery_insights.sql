create database project_2;
use project_2;
show tables;

select * from chefmozaccepts;
select * from chefmozcuisine;
select * from chefmozhours4;
select * from chefmozparking;
select * from cust_dimen;
select * from geoplaces2;
select * from market_fact;
select * from orders_dimen;
select * from prod_dimen;
select * from rating_final;
select * from shipping_dimen;
select * from usercuisine;
select * from userpayment;
select * from userprofile;


-- Question 1: Find the top 3 customers who have the maximum number of orders
#Tables Used:
select * from cust_dimen;
select * from market_fact;

select temp.Cust_id, temp.Customer_Name from
(select mf.Cust_id,cd.Customer_Name,count(Ord_id),
dense_rank() over(order by count(mf.Ord_id) desc) Rnk
from market_fact mf inner join cust_dimen cd
on mf.Cust_id = cd.Cust_id
group by Cust_id,cd.Customer_Name) temp
where Rnk<=3;


-- Question 2: Create a new column DaysTakenForDelivery that contains the date difference between Order_Date and Ship_Date.
select * from orders_dimen;
select * from shipping_dimen;
desc orders_dimen;
desc shipping_dimen;

select od.*,sd.Ship_Date,
datediff(str_to_date(sd.Ship_Date,'%d-%m-%Y'),str_to_date(od.Order_Date,'%d-%m-%Y')) as `Days Taken For Delivery`
from orders_dimen od inner join shipping_dimen sd
on od.Order_ID=sd.Order_ID;

-- Question 3: Find the customer whose order took the maximum time to get delivered.
select * from orders_dimen;
select * from shipping_dimen;
select * from market_fact;
select * from cust_dimen;

select cd.Cust_id,cd.Customer_Name,od.Order_Date,sd.Ship_Date,
max(datediff(str_to_date(sd.Ship_Date,'%d-%m-%Y'),(str_to_date(od.order_Date,'%d-%m-%Y')))) as `Maximum days`
from cust_dimen cd inner join market_fact mf
on cd.Cust_id=mf.Cust_id
inner join shipping_dimen sd
on mf.Ship_id=sd.Ship_id
inner join orders_dimen od
on sd.Order_ID=od.Order_ID
group by cd.Cust_id,cd.Customer_Name,od.Order_Date,sd.Ship_Date
order by `Maximum days` desc
limit 1;


-- Question 4: Retrieve total sales made by each product from the data (use Windows function)

select * from market_fact;
select * from prod_dimen;
select distinct pd.Product_Category,
sum(sales) over(partition by pd.Product_Category) as `Total Sales`
from prod_dimen pd inner join market_fact mf
on pd.Prod_id=mf.Prod_id;

-- Question 5: Retrieve the total profit made from each product from the data (use windows function)
select * from market_fact;

select distinct pd.Product_Category,
sum(profit) over(partition by pd.Product_Category) as `Total Profit`
from prod_dimen pd inner join market_fact mf
on pd.Prod_id=mf.Prod_id;

/*Question 6: Count the total number of unique customers in January and how many of them came back every month over the entire year
 in 2011*/
 
select * from market_fact;
select * from orders_dimen;

-- **Total Number of Unique customers in January:

select count(distinct Cust_id)as `Unique Customers in Jan`
from market_fact inner join orders_dimen
on market_fact.Ord_id=orders_dimen.Ord_id
where month(str_to_date(Order_Date,'%d-%m-%Y'))=1 ;


-- ** Count of those Customer Who came in every month of the Year of 2011
select count(distinct Cust_id) as `Customer in 2011`
from market_fact inner join orders_dimen
on market_fact.Ord_id=orders_dimen.Ord_id
where Year(str_to_date(Order_Date,'%d-%m-%Y'))=2011 and 
month(str_to_date(Order_Date,'%d-%m-%Y')) between 1 and 12
;

-- Part 2 – Restaurant:
-- 1.We need to find out the total visits to all restaurants under all alcohol categories available.
select * from geoplaces2;
select * from chefmozaccepts;

select gp.Alcohol ,
count(*) as `No.Of Visits`
from chefmozaccepts chf inner join geoplaces2 gp
on chf.placeID=gp.placeID
where gp.alcohol<>'No_Alcohol_Served'
group by gp.Alcohol;

-- Question 2: -Let's find out the average rating according to alcohol and price so that we can understand the rating in respective price categories as well.
select * from geoplaces2;
select * from rating_final;

select alcohol as Alcohol,price as Price ,avg(rating) as `Average Rating`
from rating_final rf inner join geoplaces2 gp
on rf.placeID=gp.placeID
group by alcohol,price; 

/*Question 3:  Let’s write a query to quantify that what are the parking availability as well in different alcohol categories along with the total 
number of restaurants.*/


SELECT g.Alcohol,cp.Parking_Lot,
COUNT(DISTINCT g.PlaceID) AS TotalRestaurants
FROM geoplaces2 g
JOIN chefmozaccepts c ON g.PlaceID = c.PlaceID
LEFT JOIN chefmozparking cp ON g.PlaceID = cp.PlaceID
GROUP BY g.Alcohol, cp.Parking_Lot
ORDER BY g.Alcohol, cp.Parking_Lot;


-- Question 4: -Also take out the percentage of different cuisine in each alcohol type.
select * from chefmozcuisine;
select * from geoplaces2;

select csn.Rcuisine,gp.alcohol,
count(*) * 100.0 / sum(Count(*)) over (partition by gp.alcohol) AS Percentage
from chefmozcuisine csn inner join geoplaces2 gp
on csn.placeID=gp.placeID
group by csn.Rcuisine,gp.alcohol;

-- Questions 5: - let’s take out the average rating of each state.
select * from geoplaces2;
select * from rating_final;

select state as State,avg(rating) as `Average Rating`,avg(food_rating) as `Average Food Rating`,avg(service_rating) as `Average Service Rating`
from geoplaces2 gp inner join rating_final rf
on gp.placeID=rf.placeID
group by state;


/*Questions 6: -' Tamaulipas' Is the lowest average rated state. Quantify the reason why it is the lowest rated by providing the summary on the basis 
of State, alcohol, and Cuisine.*/

select * from chefmozcuisine;
select * from geoplaces2;

select gp.state,gp.alcohol,csn.Rcuisine,
case 
when alcohol='No_Alcohol_Served' then 'Lowest rated state in terms of alcohol and cuisine'
end as `Summary`
from geoplaces2 gp inner join chefmozcuisine csn
on gp.placeID=csn.placeID
where state='Tamaulipas';


/**Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC and tried Mexican or Italian types of 
cuisine, and also their budget level is low.We encourage you to give it a try by not using joins.**/
select * from userprofile;
select * from rating_final;
select * from geoplaces2;
select * from chefmozcuisine;

select avg(distinct(up.weight)),avg(rf.food_rating),avg(rf.service_rating)
from userprofile up inner join rating_final rf
on up.userid=rf.userid
where up.userid in 
(select userid from usercuisine
where Rcuisine in ('Mexican','Italian') and userid in
(select userid from rating_final
where placeid=
(select placeid from geoplaces2
where name='KFC' and price='low')));























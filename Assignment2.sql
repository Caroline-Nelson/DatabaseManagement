Create view q1sub as 
Select statename, areacode.areaid, sum(Actsales) as sumsales
from states, areacode, factcoffee
where states.stateid=areacode.stateid and factcoffee.areaid=areacode.areaid and extract(year from factdate)=2013
group by statename, areacode.areaid;

SELECT X.statename, areaid, Avgsumsales, SUmsales
FROM 
(select statename, Round(Avg(sumsales),2) as Avgsumsales
from q1sub
group by statename) X, q1sub
WHERE x.statename = q1sub.statename AND q1sub.sumsales > 1.1*X.Avgsumsales
Order by statename;

Select areacode.areaid, sum(ActSales), Count(areacode.areaid) as Area
From factcoffee, states, areacode
where factcoffee.areaid=areacode.areaid and states.stateid=areacode.stateid
      and extract(year from factdate)=2012
Group by areacode.areaid, statename;

--NUMBER A2-works!*/
SELECT Prodname, Sales, Round(Prof/sales,2) as Margin from(
Select * from(
SELECT prodname, sum(actprofit) Prof, sum(actsales) Sales
FROM prodcoffee, factcoffee
where prodcoffee.productid=factcoffee.productid
group by prodname))
where Prof/Sales>=0.15
Order by sales DESC;

--A3Works*/
SELECT * from(
Select * from(
SELECT areaid, prodline as types, sum(actprofit) as TotProfits
from prodcoffee, factcoffee
where prodcoffee.productid=factcoffee.productid
      and extract(year from factdate)=2012
group by prodline, areaid)
Pivot(sum(Totprofits) for types in ('Leaves' as Leaves, 'Beans' as Beans)))
where Leaves>=2*Beans;

--B1 works!*/
Select * from(
Select areaid, Fyear-Syear as Diff from(
SELECT * from( 
SELECT areaid, extract(year from factdate) as Year, sum(actprofit) as Tot
from factcoffee
group by areaid, extract(year from factdate))
Pivot(sum(Tot) for year in (2012 as Fyear, 2013 as Syear)))
where Fyear-Syear>0
order by diff DESC)
where rownum<=5;

--B2 works!*/
Select Areaid, Prodname, Fyear-Syear from(
SELECT * from(
SELECT areaid,prodname, extract(year from factdate) as year, sum(actprofit) as tots
From prodcoffee, factcoffee
where prodcoffee.productid=factcoffee.productid
      and areaid in (845,631,508,626,712)
Group by areaid, prodname, extract(year from factdate))
Pivot(sum(tots) for year in (2012 as Fyear, 2013 as Syear)))
where Fyear-Syear<0
order by Fyear-Syear DESC;
--area code 475 is consistently declining on caffe mocha, colombian, and mint
--area code 650 is declining on Colombian
--some values are null, which could be skewing these results

--C1
SELECT * from(
Select Statename, (Sact-Sbud) as Sales, (Pact-Pbud) as Profits from(
Select * from(
SELECT statename, sum(budsales) as SBud, sum(budprofit) as PBud, sum(actsales) as SAct, sum(actprofit) as PAct
from states, areacode, factcoffee
where extract(year from factdate)=2012
      and states.stateid=areacode.stateid and areacode.areaid=factcoffee.areaid
Group by statename)))
order by sales DESC
fetch first 5 rows with ties;
--it seems like no state overbudgeted profit...

--C2
Select * from(
Select areaid, BudP,Prof, BudS,Sales from(
SELECT areacode.areaid, sum(budprofit) BudP, sum(budsales) BudS, sum(actprofit) Prof, sum(actsales) as Sales
FROM areacode, factcoffee, states
where areacode.areaid=factcoffee.areaid and states.stateid=areacode.stateid and extract(year from factdate)=2012
and statename in ('California','New York','Oregon','Iowa','Nevada')
group by areacode.areaid))
where Prof>1.1*BudP and sales>1.1*BudS;


--D1
Select Statemkt, prodname, Y2013-Y2012 as Diff from(
Select * from(
SELECT prodname, Statemkt, extract(year from factdate) as year,sum(actprofit) as Tots,
row_number() over (partition by statemkt order by sum(actsales) DESC) as rankid
from prodcoffee, factcoffee, areacode, states
where prodcoffee.productid=factcoffee.productid 
      and areacode.stateid=states.stateid 
      and factcoffee.areaid=areacode.areaid
Group by prodname, Statemkt, extract(year from factdate))
Pivot(sum(Tots)for year in (2012 as Y2012, 2013 as Y2013)))
where Y2013-Y2012>0
Order by Diff DESC;
--major market likes colombian, small market likes chamomile
--row_number() over (partition by statemkt order by sum(actsales) DESC) as rankid
Select Statesize, prodtype, Y2013-Y2012 as Diff from(
Select * from(
SELECT prodtype, StateSize, extract(year from factdate) as year,sum(actsales) as Tot
from prodcoffee, factcoffee, areacode, states
where prodcoffee.productid=factcoffee.productid 
      and areacode.stateid=states.stateid 
      and factcoffee.areaid=areacode.areaid
Group by prodtype, Statesize, extract(year from factdate))
Pivot(sum(Tot)for year in (2012 as Y2012, 2013 as Y2013)))
where Y2013-Y2012>0
Order by Diff DESC;
--Major market likes espresso, small market likes herbal tea

Select Statesize, prodtype, Y2013-Y2012 as Diff from(
Select * from(
SELECT prodtype, StateSize, extract(year from factdate) as year,sum(actsales) as Tot
from prodcoffee, factcoffee, areacode, states
where prodcoffee.productid=factcoffee.productid 
      and areacode.stateid=states.stateid 
      and factcoffee.areaid=areacode.areaid
Group by prodtype, Statesize, extract(year from factdate))
Pivot(sum(Tot)for year in (2012 as Y2012, 2013 as Y2013)))
where Y2013-Y2012>0
Order by Diff DESC;

--E*/
Select * from(
SELECT statename, Round(Mkt/TOT,3) from(
SELECT statename, sum(actsales) as Tot, sum(actmarkcost) as Mkt
FROM factcoffee, areacode, states
where factcoffee.areaid= areacode.areaid and areacode.stateid=states.stateid
group by statename)
order by Mkt/Tot)
where rownum<=5;
--MA, TX, IL, IO, CO
Select * from(
SELECT statename,prodname, actmarkcost,
row_number() over (partition by statename order by actmarkcost) as rankid
from states, areacode, factcoffee, prodcoffee
where states.stateid=areacode.stateid and factcoffee.areaid=areacode.areaid
and prodcoffee.productid=factcoffee.productid
and statename in ('Massachusetts','Texas','Illinois','Iowa','Colorado')
group by statename,prodname, actmarkcost)
where rankid=1;

Select * from(
SELECT statename, Round(Pro/TOT,3) from(
SELECT statename, sum(actsales) as Tot, sum(actprofit) as Pro
FROM factcoffee, areacode, states
where factcoffee.areaid= areacode.areaid and areacode.stateid=states.stateid
group by statename)
order by Pro/Tot DESC)
where rownum<=5;
--Yes they do

Select * from(
SELECT statename, Round(Mkt/TOT,3) from(
SELECT statename, sum(actsales) as Tot, sum(actmarkcost) as Mkt
FROM factcoffee, areacode, states
where factcoffee.areaid= areacode.areaid and areacode.stateid=states.stateid
group by statename)
order by Mkt/Tot DESC)
where rownum<=5;

SELECT statename, Y2-Y1 as Diff from(
SELECT * from(
SELECT statename, sum(actsales) sumsales, extract(year from factdate) year
FROM states, factcoffee, areacode
where states.stateid=areacode.stateid and factcoffee.areaid=areacode.areaid
and statename in ('Nevada','Wisconsin','New Mexico','Washington','New York')
group by statename, extract(year from factdate))
Pivot(sum(sumsales) for year in (2012 as Y1, 2013 as Y2)));
--Nevada, wisconsin, new mexico, washington, ny

SELECT actmarkcost, areacode.areaid, statename from factcoffee, areacode, states
where states.stateid=areacode.stateid and areacode.areaid=factcoffee.areaid
      and statename in ('Nevada', 'Wisconsin', 'New Mexico', 'Washington', 'New York')
group by areacode.areaid, statename, actmarkcost
order by actmarkcost DESC;
--702 NV, 775 NV, 212 NY, 518 NY, 347 NY

SELECT areacode.areaid, statename, sum(actprofit) as TotProf from factcoffee,states, areacode
where factcoffee.areaid=areacode.areaid and states.stateid=areacode.stateid
group by areacode.areaid,statename
order by TotProf;

select statename, count(areacode.areaid) as NumArea from areacode, states
where areacode.stateid=states.stateid
group by statename
order by NumArea DESC;

--A1*/
SELECT statename, Avg(sum(actsales)) from factcoffee, areacode, states
where factcoffee.areaid=areacode.areaid and states.stateid=areacode.stateid
      and extract(year from factdate)=2013
group by statename;

--SELECT * FROM(
--Select areaid, actp, row_number() over (partition by statename order by actp) as rankid from(
SELECT statename, areacode.areaid, sum(actprofit) as ActP
FROM states, areacode, factcoffee
where states.stateid=areacode.stateid and factcoffee.areaid=areacode.areaid
group by statename, areacode.areaid;
--where rankid=1;

--B2 A*/
Select Round(Count(Status)/sum(Total),4) as FracCancelled from(
SELECT Count(OrderID) as Total, status from orders
group by status)
where status='Returned';

Select status, sum(ordsales) as CancelledSales from orderdet, orders
where status='Returned' and orderdet.orderid=orders.orderid
Group by status;

SELECT * from(
select custname, sum(ordsales) from orderdet, orders, customers
where customers.custid=orderdet.custid and orderdet.orderid=orders.orderid
and status='Returned'
group by custname
order by sum(ordsales) DESC)
where rownum<=5;

select custname, sum(ordsales) as SumSales from orderdet, orders, customers
where customers.custid=orderdet.custid and orderdet.orderid=orders.orderid
group by custname
order by sum(ordsales) DESC;

select * from(
select custname, prodcat, count(prodcat) as Cat from products, customers, orderdet
where products.prodid=orderdet.prodid and customers.custid=orderdet.custid
group by custname, prodcat
order by custname)
pivot(sum(Cat) for prodcat in ('Technology' as tech, 'Office Supplies' as os, 'Furniture' as furn));

--NOT QUITE

SELECT Avg(Ordshipcost), Avg(orddiscount), orderid, prodname, Avg(ordsales), Avg(ordqty), produnitprice
FROM orderdet, products
Where orderdet.prodid=products.prodid
group by orderid, prodname;

SELECT round(AVG(diff),4) as AverageDiff FROM(
Select prodid, Theo-Totsales as Diff FROM(
SELECT prodid, ((produnitprice*ordqty)*(1-orddiscount)+ordshipcost) as theo, Totsales FROM(
SELECT orderdet.prodid, orddiscount, sum(ordsales) TotSales, produnitprice, ordshipcost, ordqty
FROM products, orderdet
where products.prodid=orderdet.prodid
group by orderdet.prodid, orddiscount, produnitprice, ordqty, ordshipcost)
group by prodid, ((produnitprice*ordqty)*(1-orddiscount)+ ordshipcost), TotSales));

SELECT COUNT(REGMANAGER) AS COUNT, REGMANAGER FROM(
SELECT * From(
Select regmanager, prodid, Theo-Totsales as Diff FROM(
SELECT regmanager, prodid, ((produnitprice*ordqty)*(1-orddiscount)+ordshipcost) as theo, Totsales FROM(
SELECT orderdet.prodid, regmanager,orddiscount, sum(ordsales) TotSales, produnitprice, ordshipcost, ordqty
FROM products, orderdet, customers, managers
where products.prodid=orderdet.prodid and managers.regid=customers.custreg and orderdet.custid=customers.custid
group by regmanager, orderdet.prodid, orddiscount, produnitprice, ordqty, ordshipcost)
group by regmanager, prodid, ((produnitprice*ordqty)*(1-orddiscount)+ ordshipcost), TotSales)
order by regmanager)
where Diff<0)
GROUP BY REGMANAGER;

--Question 5 part a*/
Select prodname from products
where REGEXP_LIKE (prodname, '\d'); 

--5b*/
Select * from(
select prodname, sum(ordsales)
from orderdet, products
where orderdet.prodid=products.prodid and extract(year from orddate)=2011
group by prodname
order by sum(ordsales) DESC)
where rownum<=5;

Select * from(
Select prodname, prodmargin*Sales from(
Select prodname, prodmargin, sum(ordsales) as Sales
from products, orderdet
where products.prodid=orderdet.prodid
group by prodname, prodmargin)
Order by prodmargin*Sales DESC)
where rownum<=10;

--Select * from(
select products.prodid, prodname, sum(ordsales)
from orderdet, products
where orderdet.prodid=products.prodid
group by products.prodid, prodname
order by sum(ordsales)
fetch first 5 rows only;
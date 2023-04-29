create database case3;
use case3;

-- how many different nodes make up different data banks?
select count(node_id) as unique_nodes
from customer_nodes;

-- how many nodes are there in each region?
select region_id,count(node_id) as mode_count
from customer_nodes
join regions
using (region_id)
group by region_id;

-- how many customers are divided amoong the regions?
select region_id,count(distinct customer_id) as customer
from customer_nodes
join regions
using(region_id)
group by region_id;

-- determine the total amount of trans for each region name
select region_name,sum(txn_amount) as 'total amount transacation'
from regions,customer_nodes,customer_transactions
where regions.region_id = customer_nodes.region_id and
customer_nodes.customer_id = customer_transactions.customer_id
group by region_name; 

-- How long does it take on an avg to move clients to a new node?
select round(avg(datediff(end_date,start_date)),2) 
as avg_days
from customer_nodes
where end_date!= '9999-12-31';

-- What is the unique count and total amount for each transaction type?
select txn_type,count(*) as unique_count,
sum(txn_amount) as total_amount
from customer_transactions
group by txn_type;

-- what is the avg number and size of past deposit across all customers?
select round(count(customer_id)/(select count(distinct customer_id)
from customer_transactions)) as avg_deposit_amount
from customer_transactions
where txn_type= 'deposit';

-- for each month how many data bank customer makes more than 1 deposit and atlest either 1 purchase or 1 withdrawal in a single month?
with cte_transaction_count as(
select customer_id,month(txn_date) as txn_month,
sum(if(txn_type='deposit',1,0)) as deposit_count,
sum(if(txn_type='withdrawal',1,0)) as withdrawal_count,
sum(if(txn_type='purchase',1,0)) as purchase_count 
from customer_transactions
group by customer_id,month(txn_date))

select txn_month,count(customer_id) as customer_count 
from cte_transaction_count
where deposit_count>1 and purchase_count=1 or withdrawal_count=1
group by txn_month;
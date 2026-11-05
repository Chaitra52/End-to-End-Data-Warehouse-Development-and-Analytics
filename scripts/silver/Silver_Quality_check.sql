---Quality check----

---- Quality check for silver.crm_cust_info 

---- Check for null or duplicates in Primary key

select cst_id, count(*) 
from silver.crm_cust_info
group by cst_id
having count(*) > 1 
 

----- Unwanted spaces 

select * 
from silver.crm_cust_info
where cst_firstname != TRIM(cst_firstname);

select * 
from silver.crm_cust_info
where cst_lastname != TRIM(cst_lastname);


---- Data standardization and consistency

select distinct cst_gndr
from silver.crm_cust_info

select distinct cst_marital_status
from silver.crm_cust_info




---- Quality check for silver.crm_prd_info 

---- Check for null or duplicates in Primary key

select prd_id, count(*) 
from bronze.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null 

----- To check if all the ID from crm_prd_info is present in sales details 

select 
	prd_id,
	prd_key,
	SUBSTRING(prd_key, 7, LEN(prd_key)) as prd_key
	from bronze.crm_prd_info
	where SUBSTRING(prd_key, 7, LEN(prd_key)) not in 
	(
	select distinct sls_prd_key from bronze.crm_sales_details)


----- To check if all the ID from crm_prd_info is present in bronze.erp_px_cat_g1v2
select 
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key,1,5), '-','_') as cat_id
	from bronze.crm_prd_info
	where REPLACE(SUBSTRING(prd_key,1,5), '-','_') not in 
	(
	select distinct id from bronze.erp_px_cat_g1v2)


----- Check for unwanted spaces

select prd_nm
from silver.crm_prd_info
where prd_nm != TRIM(prd_nm)

---- Check for NULLs or negative numbers
select prd_cost
from silver.crm_prd_info
where prd_cost < 0 or prd_cost is NULL

---- Data standardization and consistency
select distinct prd_line, count(prd_line)
from silver.crm_prd_info
group by prd_line

---- Check for invalid date orders
select * 
from silver.crm_prd_info
where prd_end_dt < prd_start_dt


---- Quality check for silver.sales_details

---- Check for invalid dates
select 
nullif(sls_ship_dt,0) sls_ship_dt
from silver.crm_sales_details
where sls_ship_dt <= 0 
or len(sls_ship_dt)!=8
or sls_ship_dt > 20500101
or sls_ship_dt < 19000101

---- Check for Invalid Date orders
select * 
from silver.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt

---- Check for data consistency: Between sales, quantity, price
---- Sales = Quantity * Price
---- Values muct not be NULL, zero, negative.
select distinct 
sls_sales,
sls_quantity,
sls_price
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null
or sls_sales <=0 or sls_quantity <= 0 or sls_price <=0
order by sls_sales, sls_quantity, sls_price



---- Quality check for erp_cust_az12
---- Identity out of range dates
select distinct
bdate 
from bronze.erp_cust_az12
where bdate < '1924-01-01' or bdate > getdate()

---- Data standardization and consistency 
select distinct gen
from bronze.erp_cust_az12

---- Quality check for erp_loc_a101
select distinct cntry
from bronze.erp_loc_a101
order by CNTRY

---- Quality check for erp_px_cat_g1v2
select * from bronze.erp_px_cat_g1v2
where cat!= TRIM(cat) or subcat != trim(subcat) or MAINTENANCE != trim(maintenance)

---- Data standardization and consistency
select distinct 
subcat
from bronze.erp_px_cat_g1v2

select distinct
cat 
from bronze.erp_px_cat_g1v2
 



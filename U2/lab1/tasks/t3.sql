-- adhoc view on customers data

select count(*), AGE
from SA_CUSTOMERS_DATA
group by age
order by age;

select count(*) count, COUNTRY
from SA_CUSTOMERS_DATA
group by COUNTRY
order by count DESC;

-- adhoc view on products data
select  MODEL_NAME , SPECS_NAME, count(*)
from SA_PRODUCTS_DATA
group by MODEL_NAME ,SPECS_NAME;


select count(*), COLOR_NAME
from SA_PRODUCTS_DATA
group by COLOR_NAME;

-- adhoc view on periods

select count(*), PERIOD_NAME
from SA_PERIODS_DATA
group by PERIOD_NAME

-- adhoc view on dealers

select count(*) count, COUNTRY
from SA_DEALERS_DATA
group by COUNTRY
ORDER BY count DESC;

-- merging

create table mg_products(
    model varchar(10),
    specs varchar(10),
    price number(10)
) tablespace TS_SA_CUSTOMERS_DATA_001;

alter table mg_products
modify specs varchar(50);

insert into mg_products
select MODEL_NAME, SPECS_NAME, DBMS_RANDOM.VALUE(50000, 100000), ROWNUM
from SA_PRODUCTS_DATA;

select * from mg_products;


merge into SA_PRODUCTS_DATA p
    using (select product_id, model, specs, price from mg_products group by product_id, model, specs, price) mg
    on (mg.PRODUCT_ID = p.PRODUCT_ID)
when matched then
    update set p.PRICE = mg.price
when not matched then
    insert (model_name, specs_name, price)
    VALUES (mg.model, mg.specs, mg.price);

select * from SA_PRODUCTS_DATA;
commit;

select * from SA_PRODUCTS_DATA, SA_CUSTOMERS_DATA;

-- segregate view

select cust.AGE AGE, count(cust.age)
from SA_CUSTOMERS.SA_CUSTOMERS_DATA cust, SA_CUSTOMERS.SA_DEALERS_DATA,SA_CUSTOMERS.SA_PRODUCTS_DATA
where SA_PRODUCTS_DATA.COLOR_NAME = 'black' and SA_DEALERS_DATA.COUNTRY = 'United States'
group by AGE
order by age asc;



-- Storage level
create tablespace ts_sa_customers_data_001
datafile '/oracle/u02/oradata/DMORCL21DB/slitvin_db/ts_sa_customers_data_001.dat'
size 150M
    autoextend on next 50M
logging
segment space management auto
extent management local;

create user SA_CUSTOMERS
identified by uniquepwd
default tablespace ts_sa_customers_data_001;

grant connect, resource to SA_CUSTOMERS;

create tablespace ts_sa_products_data_001
datafile '/oracle/u02/oradata/DMORCL21DB/slitvin_db/ts_sa_products_data_001.dat'
size 150M
    autoextend on next 50M
logging
segment space management auto
extent management local;

create user SA_PRODUCTS
identified by uniquepwd
default tablespace ts_sa_customers_data_001;

grant connect, resource to SA_PRODUCTS;


-- Cleansing level
create tablespace ts_dw_cl
datafile '/oracle/u02/oradata/DMORCL21DB/slitvin_db/ts_dw_cl.dat'
size 150M
    autoextend on next 50M
logging
segment space management auto
extent management local;

create user DW_CL
identified by uniquepwd
default tablespace ts_dw_cl;

grant connect, resource, create view to DW_CL;


-- DW level
create tablespace ts_dw_data_01
datafile '/oracle/u02/oradata/DMORCL21DB/slitvin_db/ts_dw_data_01.dat'
size 150M
    autoextend on next 50M
logging
segment space management auto
extent management local;

create user DW_DATA
identified by uniquepwd
default tablespace ts_dw_data_01;

grant connect, resource to DW_DATA;


-- DW - Prepare star cleansing level
create tablespace ts_sa_dw_cl_01
datafile '/oracle/u02/oradata/DMORCL21DB/slitvin_db/ts_sal_dw_cl_01.dat'
size 150M
    autoextend on next 50M
logging
segment space management auto
extent management local;

create user sa_dw_cl
identified by uniquepwd
default tablespace ts_sa_dw_cl_01;

grant connect, resource, create view to sa_dw_cl;

drop tablespace ts_sal_cl_001 including contents and datafiles;
drop user sal_cl;
-- star cleansing

create tablespace ts_sa_cl_001
datafile '/oracle/u02/oradata/DMORCL21DB/slitvin_db/ts_sa_cl_001.dat'
size 150M
    autoextend on next 50M
logging
segment space management auto
extent management local;

create user sa_cl
identified by uniquepwd
default tablespace ts_sa_cl_001;

grant connect, resource, create view to sa_cl;


-- star level

-- fact tablespace
create tablespace ts_sa_fct_sales_01
datafile '/oracle/u02/oradata/DMORCL21DB/slitvin_db/ts_sa_fct_sales_01.dat'
size 150M
    autoextend on next 50M
logging
segment space management auto
extent management local;

create user DM_FCT_SALES
identified by uniquepwd
default tablespace ts_sa_fct_sales_01;

grant connect, resource, create view to DM_FCT_SALES;

-- dimensions tablespaces
-- dim dealers
create tablespace ts_sa_dim_dealers_01
datafile '/oracle/u02/oradata/DMORCL21DB/slitvin_db/ts_sa_dim_dealers_01.dat'
size 150M
    autoextend on next 50M
logging
segment space management auto
extent management local;

create user DM_DEALERS
identified by uniquepwd
default tablespace ts_sa_dim_dealers_01;

grant connect, resource, create view to DM_DEALERS;

-- dim gen_periods
create tablespace ts_sa_dim_gen_periods_01
datafile '/oracle/u02/oradata/DMORCL21DB/slitvin_db/ts_sa_dim_gen_periods_01.dat'
size 150M
    autoextend on next 50M
logging
segment space management auto
extent management local;

create user dm_gen_periods
identified by uniquepwd
default tablespace ts_sa_dim_gen_periods_01;

grant connect, resource, create view to dm_gen_periods;

-- dim customers
create tablespace ts_sa_dim_customers_01
datafile '/oracle/u02/oradata/DMORCL21DB/slitvin_db/ts_sa_dim_customers_01.dat'
size 150M
    autoextend on next 50M
logging
segment space management auto
extent management local;

create user DM_CUSTOMERS
identified by uniquepwd
default tablespace ts_sa_dim_customers_01;

grant connect, resource, create view to DM_CUSTOMERS;

-- dim products
create tablespace ts_sa_dim_products_01
datafile '/oracle/u02/oradata/DMORCL21DB/slitvin_db/ts_sa_dim_products.dat'
size 150M
    autoextend on next 50M
logging
segment space management auto
extent management local;

create user DM_PRODUCTS
identified by uniquepwd
default tablespace ts_sa_dim_products_01;

grant connect, resource, create view to DM_PRODUCTS;

select creation_time, name from v$datafile;

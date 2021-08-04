drop package pkg_etl_dim_dw_products;
-- extract and load data from sa_dealers

create or replace package pkg_etl_dim_dw_products
as
    procedure load_sa_products;

end pkg_etl_dim_dw_products;

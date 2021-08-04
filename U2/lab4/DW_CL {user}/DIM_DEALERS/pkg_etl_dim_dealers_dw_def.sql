drop package pkg_etl_dim_dw_dealers;
-- extract and load data from sa_dealers

create or replace package pkg_etl_dim_dw_dealers
as
    procedure load_sa_dealers;

end pkg_etl_dim_dw_dealers;
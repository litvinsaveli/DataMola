DROP PACKAGE pkg_etl_dim_dw_products;
-- extract and load data from sa_dealers

CREATE OR REPLACE PACKAGE pkg_etl_dim_dw_products
AS
    PROCEDURE load_sa_products;

END pkg_etl_dim_dw_products;

DROP PACKAGE pkg_etl_dim_dw_dealers;
-- extract and load data from sa_dealers

CREATE OR REPLACE PACKAGE pkg_etl_dim_dw_dealers
AS
    PROCEDURE load_sa_dealers;

END pkg_etl_dim_dw_dealers;
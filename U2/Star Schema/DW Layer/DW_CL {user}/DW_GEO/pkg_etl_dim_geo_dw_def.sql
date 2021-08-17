DROP PACKAGE pkg_etl_dim_geo_dw;

CREATE OR REPLACE PACKAGE pkg_etl_dim_geo_dw
AS
    PROCEDURE load_dim_geo;

END pkg_etl_dim_geo_dw;

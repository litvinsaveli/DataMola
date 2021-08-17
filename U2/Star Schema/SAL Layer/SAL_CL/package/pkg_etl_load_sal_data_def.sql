CREATE OR REPLACE PACKAGE pkg_etl_load_sal_def
AS
    PROCEDURE load_dim_dealers;

    PROCEDURE load_dim_gen_periods;

    PROCEDURE load_geo_locations;
    PROCEDURE load_products;

    PROCEDURE load_time;

    PROCEDURE load_customers_scd;

    PROCEDURE load_fct;
END;


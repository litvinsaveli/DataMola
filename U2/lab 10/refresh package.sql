BEGIN
    pkg_etl_load_sal_def.load_dim_dealers;

    pkg_etl_load_sal_def.load_dim_gen_periods;

    pkg_etl_load_sal_def.load_geo_locations;

    pkg_etl_load_sal_def.load_products;

    pkg_etl_load_sal_def.load_customers_scd;

    pkg_etl_load_sal_def.load_time;

    pkg_etl_load_sal_def.load_fct;
END;


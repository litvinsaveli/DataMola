BEGIN
    pkg_etl_dim_customers_dw.load_sa_customers;
    pkg_etl_dim_geo_dw.load_dim_geo;
    pkg_etl_dim_dw_products.load_sa_products;
    pkg_etl_dim_dw_dealers.load_sa_dealers;
END;



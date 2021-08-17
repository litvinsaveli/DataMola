DROP TABLE dw_sales_fct CASCADE CONSTRAINTS;

CREATE TABLE dw_sales_fct
(
    event_dt     number(10),

    dealer_id    number(22)
        CONSTRAINT fk_dealer_id
            REFERENCES dw_dealers
                ON DELETE CASCADE,

    customer_id  number(22)
        CONSTRAINT fk_customer_surr_id
            REFERENCES dw_customers_scd
                ON DELETE CASCADE,
    geo_id       number(22)
        CONSTRAINT fk_geo_id
            REFERENCES dw_geo_locations
                ON DELETE CASCADE,
    product_id   number(22)
        CONSTRAINT fk_product_id
            REFERENCES dw_products
                ON DELETE CASCADE,
    time_id      date
        CONSTRAINT fk_time_id
            REFERENCES dw_time
                ON DELETE CASCADE,
    period_id    number(22)
        CONSTRAINT fk_period_id REFERENCES dw_gen_periods
            ON DELETE CASCADE,
    total_amount float,
    insert_dt    date NULL,
    update_dt    date NULL
) TABLESPACE ts_dw_layer_data_01;




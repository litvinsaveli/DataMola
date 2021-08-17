CREATE OR REPLACE PACKAGE BODY PKG_ETL_DIM_CUSTOMERS_DW
AS
    PROCEDURE load_sa_customers
    AS

    BEGIN

        MERGE INTO dw_data.dw_customers_scd dw
        USING (SELECT customer_id,
                      customer_name,
                      country,
                      city,
                      address,
                      product_id,
                      count,
                      insert_dt
               FROM sa_reports.customers) sa
        ON (sa.customer_name = dw.customer_name AND sa.customer_id = dw.customer_id)
        WHEN MATCHED
            THEN
            UPDATE
            SET dw.is_active = ('False'),
                dw.valid_to  = (SELECT SYSDATE FROM dual);

        INSERT INTO dw_data.dw_customers_scd (customer_id, customer_name, country, city, address, product_id,
                                              count, valid_from, insert_dt, update_dt)
        SELECT customer_id,
               customer_name,
               country,
               city,
               address,
               product_id,
               count,
               insert_dt,
               SYSDATE,
               SYSDATE
        FROM sa_reports.customers;
        COMMIT;
    END;
END;


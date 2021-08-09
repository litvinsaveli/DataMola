create or replace package body pkg_etl_dim_customers_dw

    as
    procedure load_sa_customers
        as


        begin

            merge into dw_data.DW_CUSTOMERS_SCD dw
                USING(SELECT customer_id,CUSTOMER_NAME, COUNTRY ,
                             CITY, ADDRESS, PRODUCT_ID,
                             COUNT, INSERT_DT
                FROM SA_REPORTS.CUSTOMERS) sa
                    ON (sa.customer_name = dw.CUSTOMER_NAME and sa.CUSTOMER_ID = dw.CUSTOMER_ID)
                WHEN MATCHED
                THEN UPDATE
                    SET dw.IS_ACTIVE = ('False'), dw.VALID_TO = (select sysdate from dual);


                insert into DW_DATA.DW_CUSTOMERS_SCD (customer_id, customer_name, country, city, address, product_id,
                        count, valid_from, insert_dt, update_dt)
                SELECT customer_id, CUSTOMER_NAME, COUNTRY ,
                             CITY, ADDRESS, PRODUCT_ID,
                             COUNT, INSERT_DT, sysdate, sysdate
                FROM SA_REPORTS.CUSTOMERS;
        commit;
        end;
end;


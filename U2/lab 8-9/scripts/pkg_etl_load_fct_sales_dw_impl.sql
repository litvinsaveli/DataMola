CREATE OR REPLACE PACKAGE BODY PKG_ETL_LOAD_FCT_SALES_DW
AS
    PROCEDURE load_fct_table
    AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE dw_sales_fct';
        DECLARE
            TYPE bigcursor IS ref cursor;

            TYPE ev_dt IS table of number(10);
            TYPE deal_id IS table of number(22);
            TYPE cust_id IS table of number(22);
            TYPE g_id IS table of number(22);
            TYPE prod_id IS table of number(22);
            TYPE t_id IS table of date;
            TYPE per_id IS table of number(22);
            TYPE t_amnt IS table of float ;
            TYPE ins_dt IS table of date ;
            TYPE upd_dt IS table of date ;

            cur      bigcursor;
            ev_dt1   ev_dt ;
            deal_id1 deal_id;
            cust_id1 cust_id;
            g_id1    g_id ;
            prod_id1 prod_id;
            t_id1    t_id ;
            per_id1  per_id ;
            t_amnt1  t_amnt ;
            ins_dt1  ins_dt ;

        BEGIN
            OPEN cur FOR SELECT /*+parallel (8) */
                             TO_NUMBER(TO_CHAR(t.time_id, 'YYYYMM')),
                             d.dealer_id,
                             c.customer_id,
                             g.geo_id,
                             p.product_id,
                             t.time_id,
                             pr.period_id,
                             c.count * p.price,
                             SYSDATE
                         FROM dw_dealers                     d
                                  LEFT JOIN dw_customers_scd c
                                            ON (c.country = d.country)
                                  LEFT JOIN dw_geo_locations g
                                            ON (d.country = g.country_name)
                                  LEFT JOIN dw_products      p
                                            ON (c.product_id = p.product_id)
                                  LEFT JOIN dw_time          t
                                            ON (c.valid_from = t.time_id)
                                  LEFT JOIN dw_gen_periods   pr
                                            ON (c.valid_from >= pr.start_dt AND c.valid_from <= pr.end_dt);

            LOOP
                FETCH cur BULK COLLECT INTO ev_dt1 , deal_id1, cust_id1, g_id1, prod_id1, t_id1, per_id1, t_amnt1, ins_dt1;

                FORALL i IN 1 .. deal_id1.COUNT
                    INSERT INTO dw_sales_fct (event_dt, dealer_id, customer_id, geo_id, product_id, time_id, period_id,
                                              total_amount, insert_dt)
                    VALUES (ev_dt1(i), deal_id1(i), cust_id1(i), g_id1(i), prod_id1(i), t_id1(i), per_id1(i),
                            t_amnt1(i), ins_dt1(i));
                COMMIT;
                EXIT WHEN cur%NOTFOUND;

            END LOOP;
        END;
    END;
END;





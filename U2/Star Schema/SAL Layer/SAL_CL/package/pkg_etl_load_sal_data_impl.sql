CREATE OR REPLACE PACKAGE BODY PKG_ETL_LOAD_SAL_DEF
AS
    PROCEDURE load_dim_dealers
    AS
    BEGIN
        MERGE INTO sal_data.dim_dealers target
        USING dw_data.dw_dealers source
        ON (source.dealer_id = target.dealer_id)
        WHEN MATCHED THEN
            UPDATE
            SET target.update_dt = SYSDATE,
                target.country   = source.country,
                target.address   = source.address,
                target.city      = source.city
        WHEN NOT MATCHED THEN
            INSERT (dealer_id, country, city, address, insert_dt, update_dt)
            VALUES (source.dealer_id, source.country, source.city, source.address, (SELECT SYSDATE FROM dual), NULL);
        COMMIT;
    END load_dim_dealers;

    PROCEDURE load_dim_gen_periods
    AS
    BEGIN
        MERGE INTO sal_data.dim_gen_periods target
        USING dw_data.dw_gen_periods source
        ON (target.period_id = source.period_id)
        WHEN MATCHED THEN
            UPDATE
            SET target.update_dt    = SYSDATE,
                target.period_name  = source.period_name,
                target.quartel_name = source.quartel_name,
                target.start_dt     = source.start_dt,
                target.end_dt       = source.end_dt
        WHEN NOT MATCHED THEN
            INSERT (period_id, end_dt, update_dt, quartel_name, insert_dt, start_dt, period_name)
            VALUES (source.period_id, source.end_dt, NULL, source.quartel_name, source.insert_dt, source.start_dt,
                    source.period_name);
        COMMIT;
    END load_dim_gen_periods;

    PROCEDURE load_geo_locations
    AS
    BEGIN
        MERGE INTO sal_data.dim_geo_locations target
        USING dw_data.dw_geo_locations source
        ON (target.geo_id = source.geo_id)
        WHEN MATCHED THEN
            UPDATE
            SET target.country_id      = source.country_id,
                target.country_name    = source.country_name,
                target.country_code_a2 = source.country_code_a2,
                target.country_code_a3 = source.country_code_a3,
                target.region_id       = source.region_id,
                target.region_code     = source.region_code,
                target.region_name     = source.region_name,
                target.update_dt       = SYSDATE
        WHEN NOT MATCHED THEN
            INSERT (geo_id, country_id, country_name, country_code_a2, country_code_a3, region_id, region_code,
                    region_name, insert_dt, update_dt)
            VALUES (source.geo_id, source.country_id, source.country_name, source.country_code_a2,
                    source.country_code_a3, source.region_id, source.region_code, source.region_name, SYSDATE,
                    NULL);
        COMMIT;
    END load_geo_locations;

    PROCEDURE load_products
    AS
    BEGIN
        MERGE INTO sal_data.dim_products target
        USING dw_data.dw_products source
        ON (target.product_id = source.product_id)
        WHEN MATCHED THEN
            UPDATE
            SET target.model        = source.model,
                target.specs        = source.specs,
                target.color        = source.color,
                target.price        = source.color,
                target.product_desc = source.product_desc,
                target.update_dt    = SYSDATE
        WHEN NOT MATCHED THEN
            INSERT (product_id, model, specs, color, price, product_desc, insert_dt, update_dt)
            VALUES (source.product_id, source.model, source.specs, source.color, source.price, source.product_desc,
                    SYSDATE, NULL);
        COMMIT;
    END load_products;

    PROCEDURE LOAD_TIME
    AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE sal_data.dim_time';
        INSERT INTO sal_data.dim_time (time_id, day_number_week, week_number, month_days_cnt, quarter_days_cnt,
                                       year_calendar, day_number_year, week_end_dt, month_number, quarter_begin_dt,
                                       quarter_number, day_number_month, day_name, month_name, quarter_end_dt,
                                       year_days_cnt)
        SELECT time_id,
               day_number_week,
               week_number,
               month_days_cnt,
               quarter_days_cnt,
               year_calendar,
               day_number_year,
               week_end_dt,
               month_number,
               quarter_begin_dt,
               quarter_number,
               day_number_month,
               day_name,
               month_name,
               quarter_end_dt,
               year_days_cnt
        FROM dw_data.dw_time;
        COMMIT;
    END LOAD_TIME;

    PROCEDURE load_customers_scd
    AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE sal_data.dim_customers_scd';
        INSERT INTO sal_data.dim_customers_scd (customer_surr_id, customer_id, customer_name, country, city, address,
                                                product_id, count, valid_from, insert_dt, update_dt)
        SELECT customer_surr_id,
               customer_id,
               customer_name,
               country,
               city,
               address,
               product_id,
               count,
               valid_from,
               insert_dt,
               update_dt

        FROM dw_data.dw_customers_scd;

        COMMIT;
    END load_customers_scd;

    PROCEDURE load_fct
    AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE sal_data.sales_fct';
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
                         FROM sal_data.dim_dealers                     d
                                  LEFT JOIN sal_data.dim_customers_scd c
                                            ON (c.country = d.country)
                                  LEFT JOIN sal_data.dim_geo_locations g
                                            ON (d.country = g.country_name)
                                  LEFT JOIN sal_data.dim_products      p
                                            ON (c.product_id = p.product_id)
                                  LEFT JOIN sal_data.dim_time          t
                                            ON (c.valid_from = t.time_id)
                                  LEFT JOIN sal_data.dim_gen_periods   pr
                                            ON (c.valid_from >= pr.start_dt AND c.valid_from <= pr.end_dt);

            LOOP
                FETCH cur BULK COLLECT INTO ev_dt1 , deal_id1, cust_id1, g_id1, prod_id1, t_id1, per_id1, t_amnt1, ins_dt1;

                FORALL i IN 1 .. deal_id1.COUNT
                    INSERT INTO sal_data.sales_fct (event_dt, dealer_id, customer_id, geo_id, product_id, time_id,
                                                    period_id,
                                                    total_amount, insert_dt)
                    VALUES (ev_dt1(i), deal_id1(i), cust_id1(i), g_id1(i), prod_id1(i), t_id1(i), per_id1(i),
                            t_amnt1(i), ins_dt1(i));
                COMMIT;
                EXIT WHEN cur%NOTFOUND;

            END LOOP;
        END;
    END load_fct;
END;


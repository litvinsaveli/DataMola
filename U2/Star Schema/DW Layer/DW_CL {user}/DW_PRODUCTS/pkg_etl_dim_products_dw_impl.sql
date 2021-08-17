CREATE OR REPLACE PACKAGE BODY PKG_ETL_DIM_DW_PRODUCTS
AS
    PROCEDURE load_sa_products
    AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE dw_data.dw_products';
        DECLARE

            CURSOR cur IS
                SELECT product_id, model, specs, color, price, product_desc, insert_dt FROM sa_reports.products;

            TYPE pidarray IS table of dw_data.dw_products.product_id%type;
            TYPE modelarray IS table of dw_data.dw_products.model%type;
            TYPE specsarray IS table of dw_data.dw_products.specs%type;
            TYPE colorarray IS table of dw_data.dw_products.color%type;
            TYPE pricearray IS table of dw_data.dw_products.price%type;
            TYPE p_descarray IS table of dw_data.dw_products.product_desc%type;
            TYPE ins_dtarray IS table of dw_data.dw_products.insert_dt%type;
            pID     pidarray;
            l_model modelarray;
            l_specs specsarray;
            l_color colorarray;
            l_price pricearray;
            p_desc  p_descarray;
            ins_dt  ins_dtarray;
        BEGIN
            OPEN cur;
            LOOP
                FETCH cur BULK COLLECT INTO pID,l_model, l_specs, l_color, l_price, p_desc, ins_dt;
                FORALL i IN 1 .. pID.COUNT
                    INSERT INTO dw_data.dw_products (product_id, model, specs, color, price, product_desc, insert_dt,
                                                     update_dt)
                    VALUES (pID(i), l_model(i), l_specs(i), l_color(i), l_price(i), p_desc(i), ins_dt(i),
                            (SELECT SYSDATE FROM dual));
                COMMIT;
                EXIT WHEN cur%NOTFOUND;
            END LOOP;
            CLOSE cur;
        END;
    END;
END;


create or replace package body PKG_ETL_DIM_DW_PRODUCTS
AS
    procedure load_sa_products
    AS
    BEGIN
        execute immediate 'TRUNCATE TABLE DW_DATA.DW_PRODUCTS';
        DECLARE

            CURSOR cur IS
            SELECT PRODUCT_ID,MODEL, SPECS, COLOR, PRICE, PRODUCT_DESC, INSERT_DT from SA_REPORTS.PRODUCTS;

            type pIDArray is table of DW_DATA.DW_PRODUCTS.product_id%type;
            type modelArray is table of DW_DATA.DW_PRODUCTS.model%type;
            type specsArray is table of DW_DATA.DW_PRODUCTS.SPECS%type;
            type colorArray is table of DW_DATA.DW_PRODUCTS.COLOR%type;
            type priceArray is table of DW_DATA.DW_PRODUCTS.price%type;
            type p_descArray is table of DW_DATA.DW_PRODUCTS.PRODUCT_DESC%type;
            type ins_dtArray is table of DW_DATA.DW_PRODUCTS.INSERT_DT%TYPE;

            pID pIDArray;
            l_model modelArray;
            l_specs specsArray;
            l_color colorArray;
            l_price priceArray;
            p_desc p_descArray;
            ins_dt ins_dtArray;
        BEGIN
            open cur;
            loop
                fetch cur bulk collect into  pID,l_model, l_specs, l_color, l_price, p_desc, ins_dt;
                forall i in 1 .. pID.count
                    insert into DW_DATA.DW_PRODUCTS (product_id, model, specs, color, price, PRODUCT_DESC, INSERT_DT, UPDATE_DT) values
                                            (pid(i), l_model(i), l_specs(i), l_color(i), l_price(i), p_desc(i), ins_dt(i), (select sysdate from dual));
                commit;
                exit when cur%notfound;
            end loop;
        close cur;
        end;
    end;
end;

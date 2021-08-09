create or replace package body pkg_etl_reload_dim_products_dw
as
    procedure load_dim_products
    as
    begin
        execute immediate 'truncate table dw_data.DW_PRODUCTS';
        declare
            type cv_products is ref cursor;

            type table_prod IS RECORD
                               (
                                   product_id   NUMBER(22),
                                   model        varchar(10),
                                   specs        varchar(30),
                                   color        varchar2(20),
                                   price        number(10),
                                   product_desc varchar(200),
                                   insert_dt    date
                               );

            cv_prod   cv_products;
            record1   table_prod;
            curid     number(22);
            query_cur varchar2(300);
            ret       number(22);
        begin

            query_cur :=
                        'select product_id, model, specs, color, price, product_desc, insert_dt from ' ||
                        '(select distinct product_id, model, specs, color, price, product_desc, insert_dt from SA_LAYER.PRODUCTS)';

            curid := dbms_sql.OPEN_CURSOR;
            dbms_sql.parse(curid, query_cur, dbms_sql.native);
            ret := dbms_sql.EXECUTE(curid);

            cv_prod := dbms_sql.TO_REFCURSOR(curid);
            loop
                fetch cv_prod
                    into record1;
                exit when cv_prod%notfound;

                insert into dw_data.DW_PRODUCTS (PRODUCT_ID, MODEL, SPECS, COLOR, PRICE, PRODUCT_DESC, INSERT_DT,
                                                 UPDATE_DT)
                values (record1.product_id, record1.model, record1.specs, record1.color, record1.price,
                        record1.product_desc, record1.insert_dt, sysdate);
                commit;

            end loop;

        end;
    end;
end;



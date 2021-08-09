create or replace package body pkg_etl_reload_dim_dealers
as
    procedure load_sa_dealers
    as
    begin
        execute immediate 'truncate table dw_data.DW_DEALERS';
        DECLARE
            TYPE curtype IS REF CURSOR;
            sql_stmt    CLOB;
            src_cur     curtype;
            curid       NUMBER;
            id_tmp      NUMBER;
            country_tmp VARCHAR(100);
            city_tmp    VARCHAR(50);
            address_tmp VARCHAR(200);
            insert_tmp  date;


        BEGIN

            sql_stmt := 'SELECT dealer_id, country, city, address, insert_dt FROM SA_LAYER.DEALERS';
            OPEN src_cur FOR sql_stmt;

            curid := DBMS_SQL.to_cursor_number(src_cur);

            DBMS_SQL.DEFINE_COLUMN(curid, 1, id_tmp);
            DBMS_SQL.DEFINE_COLUMN(curid, 2, country_tmp, 100);
            DBMS_SQL.DEFINE_COLUMN(curid, 3, city_tmp, 50);
            DBMS_SQL.DEFINE_COLUMN(curid, 4, address_tmp, 200);
            DBMS_SQL.DEFINE_COLUMN(curid, 7, insert_tmp);


            WHILE DBMS_SQL.fetch_rows(curid) > 0
                LOOP
                    DBMS_SQL.COLUMN_VALUE(curid, 1, id_tmp);
                    DBMS_SQL.COLUMN_VALUE(curid, 2, country_tmp);
                    DBMS_SQL.COLUMN_VALUE(curid, 3, city_tmp);
                    DBMS_SQL.COLUMN_VALUE(curid, 4, address_tmp);
                    DBMS_SQL.COLUMN_VALUE(curid, 5, insert_tmp);

                    INSERT INTO DW_DATA.DW_DEALERS
                    VALUES (id_tmp, country_tmp, city_tmp, address_tmp, insert_tmp, (select sysdate from dual));
                END LOOP;

            DBMS_SQL.close_cursor(curid);


            commit;
        END;
    end;
end;


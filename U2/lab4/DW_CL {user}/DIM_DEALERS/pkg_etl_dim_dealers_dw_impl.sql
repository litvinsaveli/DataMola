
create or replace package body pkg_etl_dim_dw_dealers
    AS
    PROCEDURE load_sa_dealers

        AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE DW_DATA.DW_DEALERS';
        DECLARE

            cursor cv is select dealer_id, country, city, address, insert_dt from sa_reports.dealers;
            c_dealer_id SA_REPORTS.DEALERS.DEALER_ID%TYPE;
            c_country SA_REPORTS.DEALERS.COUNTRY%TYPE;
            c_city SA_REPORTS.DEALERS.CITY%TYPE;
            c_address SA_REPORTS.DEALERS.ADDRESS%TYPE;
            c_insert_dt SA_REPORTS.DEALERS.INSERT_DT%TYPE;
        BEGIN

    OPEN cv;

        LOOP  -- Fetches 5 columns into variables
            FETCH cv INTO c_dealer_id, c_country, c_city, c_address, c_insert_dt;
            EXIT WHEN cv%NOTFOUND;
            insert into dw_data.DW_DEALERS (DEALER_ID,COUNTRY, city, address, INSERT_DT)
                        values (c_dealer_id, c_country, c_city, c_address, c_insert_dt);
        END LOOP;
        COMMIT;
        CLOSE cv;
        END;
    END;
END;


select * from DW_DATA.DW_DEALERS;
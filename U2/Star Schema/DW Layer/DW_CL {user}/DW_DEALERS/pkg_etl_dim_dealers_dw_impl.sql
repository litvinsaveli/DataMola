CREATE OR REPLACE PACKAGE BODY PKG_ETL_DIM_DW_DEALERS
AS
    PROCEDURE load_sa_dealers
    AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE dw_data.dw_dealers';
        DECLARE

            CURSOR cv IS SELECT dealer_id, country, city, address, insert_dt FROM sa_reports.dealers;
            c_dealer_id sa_reports.dealers.dealer_id%type;
            c_country   sa_reports.dealers.country%type;
            c_city      sa_reports.dealers.city%type;
            c_address   sa_reports.dealers.address%type;
            c_insert_dt sa_reports.dealers.insert_dt%type;
        BEGIN

            OPEN cv;

            LOOP
                -- Fetches 5 columns into variables
                FETCH cv INTO c_dealer_id, c_country, c_city, c_address, c_insert_dt;
                EXIT WHEN cv%NOTFOUND;
                INSERT INTO dw_data.dw_dealers (dealer_id, country, city, address, insert_dt)
                VALUES (c_dealer_id, c_country, c_city, c_address, c_insert_dt);
            END LOOP;
            COMMIT;
            CLOSE cv;
        END;
    END;
END;


SELECT *
FROM dw_data.dw_dealers;
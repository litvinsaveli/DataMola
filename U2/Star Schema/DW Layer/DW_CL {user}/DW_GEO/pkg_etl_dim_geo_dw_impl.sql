CREATE OR REPLACE PACKAGE BODY PKG_ETL_DIM_GEO_DW
AS
    PROCEDURE load_dim_geo
    AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE dw_data.dw_geo_locations';
        DECLARE
            TYPE geocursor IS ref cursor;

            TYPE geoidarray IS table of dw_data.dw_geo_locations.geo_id%type;
            TYPE cidarray IS table of dw_data.dw_geo_locations.country_id%type;
            TYPE cnamearray IS table of dw_data.dw_geo_locations.country_name%type;
            TYPE ccodea2array IS table of dw_data.dw_geo_locations.country_code_a2%type;
            TYPE ccodea3array IS table of dw_data.dw_geo_locations.country_code_a3%type;
            TYPE ridarray IS table of dw_data.dw_geo_locations.region_id%type;
            TYPE rcodearray IS table of dw_data.dw_geo_locations.region_code%type;
            TYPE rnamearray IS table of dw_data.dw_geo_locations.region_name%type;
            TYPE ins_dtarray IS table of dw_data.dw_geo_locations.insert_dt%type;

            cur           geocursor;
            geoID         geoidarray;
            countryID     cidarray;
            countryName   cnamearray;
            countryCodeA2 ccodea2array;
            countryCodeA3 ccodea3array;
            regID         ridarray;
            regCode       rcodearray;
            regName       rnamearray;
            insDT         ins_dtarray;

        BEGIN

            OPEN cur FOR SELECT geo_id,
                                country_id,
                                country_name,
                                country_code_a2,
                                country_code_a3,
                                region_id,
                                regio_code,
                                region_name,
                                insert_dt
                         FROM sa_reports.geo_locations;
            LOOP
                FETCH cur
                    BULK COLLECT INTO geoID,countryID,countryName, countryCodeA2, countryCodeA3, regID, regCode, regName, insDT;

                FORALL i IN 1 .. geoID.COUNT
                    INSERT INTO dw_data.dw_geo_locations (geo_id, country_id, country_name, country_code_a2,
                                                          country_code_a3, region_id, region_code, region_name,
                                                          insert_dt, update_dt)
                    VALUES (geoID(i), countryID(i), countryName(i), countryCodeA2(i), countryCodeA3(i),
                            regID(i), regCode(i), regName(i), insDT(i), (SELECT SYSDATE FROM dual));
                COMMIT;
                EXIT WHEN cur%NOTFOUND;
            END LOOP;
            CLOSE cur;
        END;
    END;
END;
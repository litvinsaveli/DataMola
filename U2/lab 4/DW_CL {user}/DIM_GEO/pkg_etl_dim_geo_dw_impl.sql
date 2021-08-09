create or replace package body pkg_etl_dim_geo_dw
AS
    procedure load_dim_geo
    AS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE DW_DATA.DW_GEO_LOCATIONS';
        DECLARE

            type GeoCursor is ref cursor;

            type geoIDArray is table of DW_DATA.DW_GEO_LOCATIONS.GEO_ID%type;
            type cIdArray is table of DW_DATA.DW_GEO_LOCATIONS.COUNTRY_ID%type;
            type cNameArray is table of DW_DATA.DW_GEO_LOCATIONS.COUNTRY_NAME%type;
            type cCodeA2Array is table of DW_DATA.DW_GEO_LOCATIONS.COUNTRY_CODE_A2%type;
            type cCodeA3Array is table of DW_DATA.DW_GEO_LOCATIONS.COUNTRY_CODE_A3%type;
            type rIdArray is table of DW_DATA.DW_GEO_LOCATIONS.REGION_ID%type;
            type rCodeArray is table of DW_DATA.DW_GEO_LOCATIONS.REGION_CODE%type;
            type rNameArray is table of DW_DATA.DW_GEO_LOCATIONS.REGION_NAME%type;
            type ins_dtArray is table of DW_DATA.DW_GEO_LOCATIONS.INSERT_DT%type;


            cur GeoCursor;
            geoID geoIDArray;
            countryID cIdArray;
            countryName cNameArray;
            countryCodeA2 cCodeA2Array;
            countryCodeA3 cCodeA3Array;
            regID rIdArray;
            regCode rCodeArray;
            regName rNameArray;
            insDT ins_dtArray;

        BEGIN

            open cur for select GEO_ID, COUNTRY_ID, COUNTRY_NAME, COUNTRY_CODE_A2, COUNTRY_CODE_A3,
                                REGION_ID, REGIO_CODE, REGION_NAME, INSERT_DT
                        from sa_reports.GEO_LOCATIONS;
            loop
                fetch cur
                    bulk collect into geoID,countryID,countryName, countryCodeA2, countryCodeA3, regID, regCode, regName, insDT;


                    forall i in 1 .. geoID.count
                    insert into DW_DATA.DW_GEO_LOCATIONS (GEO_ID, COUNTRY_ID, COUNTRY_NAME, COUNTRY_CODE_A2, COUNTRY_CODE_A3, REGION_ID, REGION_CODE, REGION_NAME, INSERT_DT, UPDATE_DT)
                    VALUES (geoID(i), countryID(i), countryName(i), countryCodeA2(i), countryCodeA3(i),
                    regID(i), regCode(i), regName(i), insDT(i), (select sysdate from dual));
                    commit;
                exit when cur%notfound;
            end loop;
        close cur;
        end;
    end;
end;
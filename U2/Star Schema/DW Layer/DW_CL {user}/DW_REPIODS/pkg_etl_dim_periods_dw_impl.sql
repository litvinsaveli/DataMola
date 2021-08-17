CREATE OR REPLACE PACKAGE BODY PKG_ETL_DIM_PERIODS_DW
AS
    PROCEDURE load_sa_periods
    AS

    BEGIN

        EXECUTE IMMEDIATE 'TRUNCATE TABLE dw_data.periods';
        DECLARE

            CURSOR cv IS SELECT start_dt, period_name, insert_dt, end_dt FROM sa_layer.periods;
            c_st_dt     dw_data.periods.start_dt%type;
            c_pname     dw_data.periods.period_name%type;
            c_ins_dt    dw_data.periods.insert_dt%type;
            c_end_dt    dw_data.periods.end_dt%type;
            tab         varchar(20) := 'dw_data.periods';
            sql_ins_smt varchar2(300);

        BEGIN

            OPEN cv;
            LOOP
                FETCH cv INTO c_st_dt, c_pname, c_ins_dt, c_end_dt;
                EXIT WHEN cv%NOTFOUND;

                sql_ins_smt := 'insert into ' || tab || ' values(:st_dt, :pname, :ins_dt, :end_dt,:upd_dt)';
                EXECUTE IMMEDIATE sql_ins_smt USING c_st_dt, c_pname, c_ins_dt, c_end_dt, SYSDATE;
            END LOOP;
            COMMIT;
            CLOSE cv;

        END;
    END;
END;




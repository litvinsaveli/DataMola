create or replace package body pkg_etl_dim_periods_dw
as
    procedure load_sa_periods
    as

    begin

        execute immediate 'truncate table dw_data.PERIODS';
        declare

            cursor cv is select start_dt, period_name, insert_dt, end_dt, rownum from sa_layer.PERIODS;
            c_st_dt     dw_data.PERIODS.START_DT%type;
            c_pname     dw_data.PERIODS.PERIOD_NAME%type;
            c_ins_dt    dw_data.PERIODS.INSERT_DT%type;
            c_end_dt    dw_data.PERIODS.END_DT%type;
            rn          number(22);
            tab         varchar(20) := 'dw_data.periods';
            sql_ins_smt varchar2(300);

        begin


            open cv;
            loop
                fetch cv into c_st_dt, c_pname, c_ins_dt, c_end_dt, rn;
                exit when cv%notfound;

                sql_ins_smt := 'insert into ' || tab || ' values(:st_dt, :pname, :ins_dt, :end_dt,:upd_dt, :pid)';
                execute immediate sql_ins_smt using c_st_dt, c_pname, c_ins_dt, c_end_dt, sysdate, rn;
            end loop;
            commit;
            close cv;

        end;
    end;
end;



begin
    pkg_etl_dim_periods_dw.LOAD_SA_PERIODS;
end;
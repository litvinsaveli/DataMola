create or replace package body pkg_synchronize_fct_table_dw
as
    procedure load_fct
    as
    begin
        declare
            type cv is ref cursor;


            type int_data is table of int;
            type float_data is table of float;
            type date_data is table of date;
            type varchar_data is table of varchar(200);

            cursor_cv cv;

        begin
            open cursor_cv for select end;


        end;
    end;


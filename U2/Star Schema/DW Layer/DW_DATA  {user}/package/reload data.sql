BEGIN
    pkg_etl_load_fct_sales_dw.load_fct_table;
END;

SELECT *
FROM dw_sales_fct;
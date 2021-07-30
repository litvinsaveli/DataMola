
-- dealers
INSERT INTO SA_DEALERS_DATA

SELECT  c.Country, g.PART_DESC region,c.City, c.Address, c.PHONE
FROM SA_CUSTOMERS_DATA c
cross join U_DW_REFERENCES.LC_GEO_PARTS g
where PART_DESC = 'Europe';

commit;

-- products

UPDATE SA_PRODUCTS_DATA
SET PRODUCT_DESC = ('Tesla model ' || MODEL_NAME || ' ' || SPECS_NAME ||' In '|| COLOR_NAME ||' color ')
WHERE MODEL_NAME IN ('Y', 'X', '3', 'S');
commit;
select * from SA_PRODUCTS_DATA
;
-- periods


insert into SA_PERIODS_DATA (START_DT, END_DT, INSERT_DT)
select
    stdate + 30 + rn,
    stdate + 60 + rn,
    to_date(to_char(sysdate, 'YYYY-MM-DD'), 'YYYY-MM-DD')

FROM
(select to_date('2015-07-13', 'YYYY-MM-DD') stdate,
        ROWNUM rn
from dual
connect by level <= 1000);
commit;

update sa_customers.sa_periods_data
set PERIOD_NAME = 'Fourth'
where  to_number(to_char(start_dt, 'MM')) >= 10;

commit;

select * from SA_CUSTOMERS_DATA, SA_PERIDOS_DATA;
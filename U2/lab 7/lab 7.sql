-- mat.view refresh on demand

CREATE MATERIALIZED VIEW sales_by_month_reports
    REFRESH ON DEMAND
AS
SELECT dealer, country, year, month, count, total_amount, mad
FROM dw_data.monthly_report
WHERE country = 'Belarus'
    MODEL
        PARTITION BY (dealer, country)
        DIMENSION BY (year, month)
        MEASURES (total_amount,count, 0 mad)
        RULES (
        mad[year, month] = ROUND((total_amount[CV(year), CV(month)] - (AVG(total_amount)[cv(YEAR), MONTH])) /
                                 total_amount[CV(year), CV(month)], 7)
        )
ORDER BY dealer, year, month;


UPDATE monthly_report
SET total_amount = total_amount + 20000
WHERE country = 'Belarus'
  AND month = 7;

COMMIT;

BEGIN
    dbms_mview.refresh('mv_sales_by_month_reports');
END;

SELECT *
FROM dw_data.sales_by_month_reports;

-- mat.view refresh on commit

CREATE MATERIALIZED VIEW dw_data.sales_by_month_reports_commit
    REFRESH ON COMMIT
AS
SELECT dealer, country, year, month, count, total_amount, mad
FROM dw_data.monthly_report
WHERE country = 'Belarus'
    MODEL
        PARTITION BY (dealer, country)
        DIMENSION BY (year, month)
        MEASURES (total_amount,count, 0 mad)
        RULES (
        mad[year, month] = ROUND((total_amount[CV(year), CV(month)] - (AVG(total_amount)[cv(YEAR), MONTH])) /
                                 total_amount[CV(year), CV(month)], 7)
        )
ORDER BY dealer, year, month;

SELECT *
FROM dw_data.sales_by_month_reports_commit;

UPDATE monthly_report
SET total_amount = total_amount - 20000
WHERE country = 'Belarus'
  AND month = 7;

COMMIT;

SELECT *
FROM dw_data.sales_by_month_reports_commit;

-- mat.view at definitive time

DROP MATERIALIZED VIEW sales_by_month_reports_at_time;

CREATE MATERIALIZED VIEW sales_by_month_reports_at_time
    REFRESH COMPLETE START WITH (SYSDATE) NEXT (SYSDATE + 1 / 1440) WITH ROWID ENABLE QUERY REWRITE
AS
SELECT dealer, country, year, month, count, total_amount, mad
FROM dw_data.monthly_report
WHERE country = 'Belarus'
    MODEL
        PARTITION BY (dealer, country)
        DIMENSION BY (year, month)
        MEASURES (total_amount,count, 0 mad)
        RULES (
        mad[year, month] = ROUND((total_amount[CV(year), CV(month)] - (AVG(total_amount)[cv(YEAR), MONTH])) /
                                 total_amount[CV(year), CV(month)], 7)
        )
ORDER BY dealer, year, month;

UPDATE monthly_report
SET total_amount = total_amount - 20000
WHERE country = 'Belarus'
  AND month = 7;
COMMIT;

SELECT *
FROM dw_data.monthly_report
WHERE country = 'Belarus'

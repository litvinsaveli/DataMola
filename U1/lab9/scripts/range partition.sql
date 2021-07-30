create table l9.calendar(
	time_id date not null,
	day_name varchar(20),
	day_number_month varchar(20),
	day_number_week varchar(20),
	CALENDAR_MONTH_NAME VARCHAR2(20),
    CALENDAR_MONTH_IN_YEAR VARCHAR2(20),
    CALENDAR_YEAR_NAME VARCHAR2(20)
)
PARTITION BY RANGE (time_id)
(
PARTITION PART_1 VALUES LESS THAN (TO_DATE('1/01/2008', 'DD/MM/YYYY')) tablespace lab9_1,
PARTITION PART_2 VALUES LESS THAN (TO_DATE('1/01/2009', 'DD/MM/YYYY')) tablespace lab9_2
);

alter table l9.calendar
    merge partitions part_1, part_2 into partition part_3
        tablespace lab9;
        
alter table l9.calendar
    move partition part_3
        tablespace lab9_1 nologging compress;
        
alter table l9.calendar
    split partition part_3
        at (to_date('1/01/2005', 'DD/MM/YYYY'))
            into(partition part_1, partition part_2);
            
alter table l9.calendar
    truncate partition part_1;
            
alter table l9.calendar
    drop partition part_1;
    


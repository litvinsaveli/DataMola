create tablespace exit_task
datafile '/oracle/u02/oradata/DMORCL21DB/slitvin_db/db_exit_task_data_01.dat'
SIZE 150M
 AUTOEXTEND ON NEXT 50
 SEGMENT SPACE MANAGEMENT AUTO;

create tablespace exit_task_02
datafile '/oracle/u02/oradata/DMORCL21DB/slitvin_db/db_exit_task_data_02.dat'
SIZE 150M
 AUTOEXTEND ON NEXT 50
 SEGMENT SPACE MANAGEMENT AUTO;

create tablespace ts_exit_task_idx_01
datafile '/oracle/u02/oradata/DMORCL21DB/slitvin_db/db_exit_task_idx_01.dat'
SIZE 150M
 AUTOEXTEND ON NEXT 50
 SEGMENT SPACE MANAGEMENT AUTO;


create user u_exit_task identified by uniquepwd default tablespace exit_task;

alter user u_exit_task quota unlimited on ts_exit_task_idx_01;





drop table DIM_TIME cascade constraints;

/*==============================================================*/
/* Table: DIM_TIME                                              */
/*==============================================================*/
create table DIM_TIME (
   TIME_ID              DATE                  not null,
   YEAR_NUMBER          NUMBER(4),
   YEAR_DAYS_CNT        NUMBER(3),
   QUARTER_NUMBER       NUMBER(1),
   QUARTER_DAYS_CNT     NUMBER(3),
   QUARTER_BEGIN_DT     DATE,
   QUARTER_END_DT       DATE,
   MONTH_NUMBER         NUMBER(2),
   MONTH_NAME           VARCHAR(20),
   MONTH_DAYS_CNT       NUMBER(3),
   WEEK_NUMBER          NUMBER(2),
   WEEK_END_DT          DATE,
   DAY_NAME             VARCHAR(30),
   DAY_NUMBER_WEEK      NUMBER(1),
   DAY_NUMBER_MONTH     NUMBER(2),
   DAY_NUMBER_YEAR      NUMBER(3),
   constraint PK_DIM_TIME primary key (TIME_ID)
);
CREATE INDEX idx_dim_time ON dim_time(time_id DESC);


INSERT INTO DIM_TIME
SELECT

    TRUNC( sd + rn ), -- time_id
    TO_CHAR( sd + rn, 'YYYY' ), -- year_calendar
    ( TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
    - TRUNC( sd + rn, 'YEAR' ) ) + 1, -- year days_cnt

    TO_CHAR( sd + rn, 'Q' ), --quarter_number
        ( ( CASE
          WHEN TO_CHAR( sd + rn, 'Q' ) = 1 THEN
            TO_DATE( '03/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
          WHEN TO_CHAR( sd + rn, 'Q' ) = 2 THEN
            TO_DATE( '06/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
          WHEN TO_CHAR( sd + rn, 'Q' ) = 3 THEN
            TO_DATE( '09/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
          WHEN TO_CHAR( sd + rn, 'Q' ) = 4 THEN
            TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
        END ) - TRUNC( sd + rn, 'Q' ) + 1 ), --  quarter_days_cnt

    TRUNC( sd + rn, 'Q' ), -- quarter begin_dt

        ( CASE
          WHEN TO_CHAR( sd + rn, 'Q' ) = 1 THEN
            TO_DATE( '03/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
          WHEN TO_CHAR( sd + rn, 'Q' ) = 2 THEN
            TO_DATE( '06/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
          WHEN TO_CHAR( sd + rn, 'Q' ) = 3 THEN
            TO_DATE( '09/30/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
          WHEN TO_CHAR( sd + rn, 'Q' ) = 4 THEN
            TO_DATE( '12/31/' || TO_CHAR( sd + rn, 'YYYY' ), 'MM/DD/YYYY' )
        END ), -- quarter_end_dt


        TO_CHAR( sd + rn, 'MM' ), --month_number
        TO_CHAR( sd + rn, 'FMMonth' ), -- month_name
        TO_CHAR( LAST_DAY( sd + rn ), 'DD' ), -- month_days_cnt

        TO_CHAR( sd + rn, 'W' ), -- week_number
            ( CASE
                  WHEN TO_CHAR( sd + rn, 'D' ) IN ( 1, 2, 3, 4, 5, 6 ) THEN
                    NEXT_DAY( sd + rn, 'СУББОТА' )
                  ELSE
                    ( sd + rn )
                END ), -- week_end_date

        TO_CHAR( sd + rn, 'fmDay' ), -- day_name
        TO_CHAR( sd + rn, 'D' ), -- day_number_week
        TO_CHAR( sd + rn, 'DD' ), -- day_number_month
        TO_CHAR( sd + rn, 'DDD' ) -- day_number_yearth

    FROM
  (
    SELECT
      TO_DATE( '12/31/2007', 'MM/DD/YYYY' ) sd,
      rownum rn
    FROM dual
      CONNECT BY level <= 8000
  );

drop table DIM_PERIODS cascade constraints;

/*==============================================================*/
/* Table: DIM_PERIODS                                           */
/*==============================================================*/
create table DIM_PERIODS (
   PERIOD_ID            NUMBER(22,0)          not null,
   PERIOD_NAME          VARCHAR2(20),
   START_DT             DATE,
   END_DT               DATE,
   INSERT_DT            DATE,
   UPDATE_DT            DATE,
   constraint PK_DIM_PERIODS primary key (PERIOD_ID)
);

drop table DIM_DEALERS cascade constraints;

/*==============================================================*/
/* Table: DIM_DEALERS                                           */
/*==============================================================*/
create table DIM_DEALERS (
   DEALER_ID            NUMBER(22)            not null,
   COUNTRY              CHAR(20)              not null,
   REGION               CHAR(20),
   CITY                 CHAR(25),
   ADRESS               CHAR(50),
   PHONE                CHAR(20),
   constraint PK_DIM_DEALERS primary key (DEALER_ID)
);

drop table DIM_GEO cascade constraints;

/*==============================================================*/
/* Table: DIM_GEO                                               */
/*==============================================================*/
create table DIM_GEO (
   GEO_ID               NUMBER(22)            not null,
   COUNTRY_ID           NUMBER(22,0),
   COUNTRY_NAME         CHAR(20),
   COUNTRY_CODE         NUMBER(10),
   COUNTRY_CODE_A2      CHAR(2),
   COUNTRY_CODE_A3      CHAR(3),
   COUNTRY_DESC         VARCHAR2(150),
   REGIO_ID             NUMBER(22,0),
   REGIO_CODE           NUMBER(10),
   REGIO_NAME           CHAR(20),
   REGIO_DESC           VARCHAR2(150),
   CITY_ID              NUMBER(22,0),
   CITY_CODE            NUMBER(10),
   CITY_NAME            CHAR(25),
   CITY_DESC            VARCHAR2(150),
   INSERT_DT            DATE,
   UPDATE_DT            DATE,
   constraint PK_DIM_GEO primary key (GEO_ID)
);


drop table DIM_PRODUCTS cascade constraints;

/*==============================================================*/
/* Table: DIM_PRODUCTS                                          */
/*==============================================================*/
create table DIM_PRODUCTS (
   PRODUCT_ID           NUMBER(22,0)          not null,
   MODEL_ID             NUMBER(22,0),
   MODEL_NAME           VARCHAR2(10),
   SPECS_ID             NUMBER(22,0),
   SPECS_NAME           VARCHAR2(20),
   COLOR_ID             NUMBER(22,0),
   COLOR_NAME           CHAR(25),
   PRODUCT_DESC         CHAR(160),
   PRICE                NUMBER(10),
   INSERT_DT            DATE,
   UPDATE_DT            DATE,
   constraint PK_DIM_PRODUCTS primary key (PRODUCT_ID)
);



--drop sequence u_dw_references.sq_lng_types_t_id;

create sequence SEQ_CUSTOMERS_SURR_ID;

grant SELECT on SEQ_CUSTOMERS_SURR_ID to u_exit_task;

drop table P_DIM_CUSTOMERS_SCD cascade constraints;

/*==============================================================*/
/* Table: PARENT TABLE P_DIM_CUSTOMERS_SCD TO CONNECT WITH FACT                                    */
/*==============================================================*/

create table P_DIM_CUSTOMERS_SCD (
    CUSTOMER_SURR_ID     NUMBER(22,0)          not null,
    FIRST_NAME VARCHAR(20),
    LAST_NAME VARCHAR(20),
    constraint pk_p_dim_customers_scd primary key (CUSTOMER_SURR_ID)
)organization index tablespace ts_exit_task_idx_01;

/*==============================================================*/
/* Table: CHILD TABLE C_DIM_CUSTOMERS_SCD TO ARCHIVE DATA                                   */
/*==============================================================*/
ALTER TABLE C_DIM_CUSTOMERS_SCD
   DROP CONSTRAINT fk_surr_id;

DROP TABLE C_DIM_CUSTOMERS_SCD CASCADE CONSTRAINTS;

create table C_DIM_CUSTOMERS_SCD (
   CUSTOMER_SURR_ID     NUMBER(22,0)          not null,
   FIRST_NAME           CHAR(20),
   LAST_NAME            CHAR(20),
   COUNTRY              CHAR(20),
   CITY                 CHAR(25),
   ADRESS               CHAR(50),
   ZIP_CODE             NUMBER(10),
   EMAIL                CHAR(30),
   PHONE                CHAR(20),
   AGE                  NUMBER(3,1),
   VALID_FROM           DATE,
   VALID_TO             DATE                  not null,
   IS_ACTIVE            VARCHAR2(4),
   INSERT_DT            DATE,
   constraint pk_c_dim_customers_scd primary key (CUSTOMER_SURR_ID, VALID_TO)
            using index tablespace ts_exit_task_idx_01
)
tablespace exit_task;


ALTER TABLE C_DIM_CUSTOMERS_SCD
   ADD CONSTRAINT fk_surr_id FOREIGN KEY (CUSTOMER_SURR_ID)
      REFERENCES P_DIM_CUSTOMERS_SCD (customer_surr_id)
      ON DELETE CASCADE;


drop index "Reference_6_FK";

drop index "Reference_5_FK";

drop index "Reference_4_FK";

drop index "Reference_3_FK";

drop index "Reference_2_FK";

drop index "Reference_1_FK";

drop table FCT_SALES_MM cascade constraints;

/*==============================================================*/
/* Table: FCT_SALES_MM                                          */
/*==============================================================*/
create table FCT_SALES_MM (
   SALES_ID             NUMBER(22,0)          not null,
   TIME_ID              DATE,
   PERIOD_ID            NUMBER(22,0),
   CUSTOMER_SURR_ID     NUMBER(22,0),
   GEO_ID               NUMBER(22),
   DEALER_ID            NUMBER(22),
   PRODUCT_ID           NUMBER(22,0),
   TOTAL_AMNT           numeric(8,2),
   MAD                  numeric(5,2),
   constraint PK_FCT_SALES_MM primary key (SALES_ID)
)
    partition by range (TIME_ID) subpartition by hash (CUSTOMER_SURR_ID)
        SUBPARTITIONS 4 store in (exit_task, exit_task_02)
        (partition sales_q1 values less than (to_date('2021-04-01', 'YYYY-MM-DD')),
         partition sales_q2 values less than (to_date('2021-07-01', 'YYYY-MM-DD')),
         partition sales_q3 values less than (to_date('2021-10-01', 'YYYY-MM-DD')),
         partition sales_q4 values less than (to_date('2021-12-31', 'YYYY-MM-DD'))
        );

/*==============================================================*/
/* Index: "Reference_1_FK"                                      */
/*==============================================================*/
create index "Reference_1_FK" on FCT_SALES_MM (
   TIME_ID ASC
);

/*==============================================================*/
/* Index: "Reference_2_FK"                                      */
/*==============================================================*/
create index "Reference_2_FK" on FCT_SALES_MM (
   PERIOD_ID ASC
);

/*==============================================================*/
/* Index: "Reference_3_FK"                                      */
/*==============================================================*/
create index "Reference_3_FK" on FCT_SALES_MM (
   CUSTOMER_SURR_ID ASC
);

/*==============================================================*/
/* Index: "Reference_4_FK"                                      */
/*==============================================================*/
create index "Reference_4_FK" on FCT_SALES_MM (
   GEO_ID ASC
);

/*==============================================================*/
/* Index: "Reference_5_FK"                                      */
/*==============================================================*/
create index "Reference_5_FK" on FCT_SALES_MM (
   DEALER_ID ASC
);

/*==============================================================*/
/* Index: "Reference_6_FK"                                      */
/*==============================================================*/
create index "Reference_6_FK" on FCT_SALES_MM (
   PRODUCT_ID ASC
);

alter table FCT_SALES_MM
   add constraint FK_FCT_SALE_REFERENCE_DIM_TIME foreign key (TIME_ID)
      references DIM_TIME (TIME_ID);

alter table FCT_SALES_MM
   add constraint FK_FCT_SALE_REFERENCE_DIM_PERI foreign key (PERIOD_ID)
      references DIM_GEN_PERIODS (PERIOD_ID);

alter table FCT_SALES_MM
   add constraint FK_FCT_SALE_REFERENCE_DIM_CUST foreign key (CUSTOMER_SURR_ID)
      references P_DIM_CUSTOMERS_SCD;

alter table FCT_SALES_MM
   add constraint FK_FCT_SALE_REFERENCE_DIM_GEO foreign key (GEO_ID)
      references DIM_GEO (GEO_ID);

alter table FCT_SALES_MM
   add constraint FK_FCT_SALE_REFERENCE_DIM_DEAL foreign key (DEALER_ID)
      references DIM_DEALERS (DEALER_ID);

alter table FCT_SALES_MM
   add constraint FK_FCT_SALE_REFERENCE_DIM_PROD foreign key (PRODUCT_ID)
      references DIM_PRODUCTS (PRODUCT_ID);


grant select on u_exit_task to SAVELI;
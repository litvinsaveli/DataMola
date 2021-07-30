CREATE TABLE l9.orders
    ( order_id           NUMBER(12),
      order_date         DATE,
      order_mode         VARCHAR2(8),
      customer_id        NUMBER(6),
      order_status       NUMBER(2),
      order_total        NUMBER(8,2),
      sales_rep_id       NUMBER(6),
      promotion_id       NUMBER(6),
      CONSTRAINT orders_pk PRIMARY KEY(order_id)
    )
  PARTITION BY RANGE(order_date)
    ( PARTITION Q1_2005 VALUES LESS THAN (TO_DATE('01-04-2005','DD-MM-YYYY')),
      PARTITION Q2_2005 VALUES LESS THAN (TO_DATE('01-07-2005','DD-MM-YYYY')),
      PARTITION Q3_2005 VALUES LESS THAN (TO_DATE('01-10-2005','DD-MM-YYYY')),
      PARTITION Q4_2005 VALUES LESS THAN (TO_DATE('01-01-2006','DD-MM-YYYY'))
    );

CREATE TABLE l9.order_items
    ( order_id           NUMBER(12) NOT NULL,
      line_item_id       NUMBER(3)  NOT NULL,
      product_id         NUMBER(6)  NOT NULL,
      unit_price         NUMBER(8,2),
      quantity           NUMBER(8),
      CONSTRAINT order_items_fk
      FOREIGN KEY(order_id) REFERENCES l9.orders(order_id)
    )
    PARTITION BY REFERENCE(order_items_fk);

alter table l9.order_items
    move partition q1_2005
        tablespace lab9;

alter table l9.order_items
    truncate partition q1_2005;
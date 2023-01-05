DROP MATERIALIZED VIEW GKDW.GK_ACCOUNT_REVENUE_MV;
CREATE MATERIALIZED VIEW GKDW.GK_ACCOUNT_REVENUE_MV 
TABLESPACE GDWLRG
PCTUSED    0
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          104K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
           )
NOCACHE
LOGGING
NOCOMPRESS
PARALLEL ( DEGREE DEFAULT INSTANCES DEFAULT )
BUILD IMMEDIATE
REFRESH FORCE ON DEMAND
WITH PRIMARY KEY
AS 
/* Formatted on 29/01/2021 12:19:15 (QP5 v5.115.810.9015) */
  SELECT   dim_year,
           dim_quarter,
           dim_month_num,
           dim_period_name,
           course_ch,
           course_mod,
           course_pl,
           course_type,
           acct_name,
           acct_id,
           ops_country,
           naics_description,
           annual_us_sales,
           employees_total,
           rollup_account,
           bemfab,
           match_grade,
           conf_code,
           bemfab_acct_match,
           SUM (rev_amt) rev_amt
    FROM   (  SELECT   td.dim_year,
                       td.dim_year || '-' || LPAD (td.dim_quarter, 2, '0')
                          dim_quarter,
                       td.dim_year || '-' || LPAD (td.dim_month_num, 2, '0')
                          dim_month_num,
                       td.dim_period_name,
                       cd.course_ch,
                       cd.course_mod,
                       cd.course_pl,
                       cd.course_type,
                       c.acct_name,
                       c.acct_id,
                       SUBSTR (ed.ops_country, 1, 3) ops_country,
                       nd.naics_desc naics_description,
                       nd.annual_sales annual_us_sales,
                       nd.employees_total,
                       CASE
                          WHEN r.rollup_acct_name IS NOT NULL
                          THEN
                             r.rollup_acct_name
                          WHEN nd.global_ult_business_name IS NOT NULL
                          THEN
                             UPPER (nd.global_ult_business_name)
                          WHEN nd.parent_hq_name IS NOT NULL
                          THEN
                             UPPER (nd.parent_hq_name)
                          WHEN nd.company_name IS NOT NULL
                          THEN
                             UPPER (nd.company_name)
                          ELSE
                             UPPER (c.acct_name)
                       END
                          rollup_account,
                       CASE
                          WHEN bemfab = 'M' THEN 'Match'
                          WHEN bemfab = 'N' THEN 'Non-DUNS Record'
                          WHEN bemfab = 'O' THEN 'Out of Business'
                          WHEN bemfab IN ('A', 'S', 'D', 'X') THEN 'No Match'
                          ELSE bemfab
                       END
                          bemfab,
                       match_grade,
                       conf_code,
                       bemfab_acct_match,
                       SUM(CASE
                              WHEN f.attendee_type = 'Unlimited' AND book_amt = 0
                              THEN
                                 u.book_amt
                              ELSE
                                 f.book_amt
                           END)
                          rev_amt
                FROM                        order_fact f
                                         INNER JOIN
                                            event_dim ed
                                         ON f.event_id = ed.event_id
                                      INNER JOIN
                                         course_dim cd
                                      ON ed.course_id = cd.course_id
                                         AND ed.ops_country = cd.country
                                   INNER JOIN
                                      cust_dim c
                                   ON f.cust_id = c.cust_id
                                LEFT OUTER JOIN
                                   gk_acct_rollup r
                                ON c.acct_id = r.acct_id
                             INNER JOIN
                                time_dim td
                             ON ed.start_date = td.dim_date
                          LEFT OUTER JOIN
                             gk_unlimited_avg_book_v u
                          ON f.cust_id = u.cust_id
                       LEFT OUTER JOIN
                          gk_naics_dnb_cust_v nd
                       ON c.acct_id = nd.cust_key
               WHERE       td.dim_year >= 2006
                       AND f.enroll_status != 'Cancelled'
                       AND c.acct_name IS NOT NULL
            GROUP BY   td.dim_year,
                       td.dim_year || '-' || LPAD (td.dim_quarter, 2, '0'),
                       td.dim_year || '-' || LPAD (td.dim_month_num, 2, '0'),
                       td.dim_period_name,
                       cd.course_ch,
                       cd.course_mod,
                       cd.course_pl,
                       cd.course_type,
                       c.acct_name,
                       c.acct_id,
                       SUBSTR (ed.ops_country, 1, 3),
                       nd.naics_desc,
                       nd.annual_sales,
                       nd.employees_total,
                       CASE
                          WHEN r.rollup_acct_name IS NOT NULL
                          THEN
                             r.rollup_acct_name
                          WHEN nd.global_ult_business_name IS NOT NULL
                          THEN
                             UPPER (nd.global_ult_business_name)
                          WHEN nd.parent_hq_name IS NOT NULL
                          THEN
                             UPPER (nd.parent_hq_name)
                          WHEN nd.company_name IS NOT NULL
                          THEN
                             UPPER (nd.company_name)
                          ELSE
                             UPPER (c.acct_name)
                       END,
                       bemfab,
                       match_grade,
                       conf_code,
                       bemfab_acct_match
            UNION
              SELECT   td.dim_year,
                       td.dim_year || '-' || LPAD (td.dim_quarter, 2, '0')
                          dim_quarter,
                       td.dim_year || '-' || LPAD (td.dim_month_num, 2, '0')
                          dim_month_num,
                       td.dim_period_name,
                       pd.prod_channel,
                       pd.prod_modality,
                       pd.prod_line,
                       pd.prod_family,
                       c.acct_name,
                       c.acct_id,
                       UPPER (SUBSTR (f.bill_to_country, 1, 3)) ops_country,
                       nd.naics_desc naics_description,
                       nd.annual_sales annual_us_sales,
                       nd.employees_total,
                       CASE
                          WHEN r.rollup_acct_name IS NOT NULL
                          THEN
                             r.rollup_acct_name
                          WHEN nd.global_ult_business_name IS NOT NULL
                          THEN
                             UPPER (nd.global_ult_business_name)
                          WHEN nd.parent_hq_name IS NOT NULL
                          THEN
                             UPPER (nd.parent_hq_name)
                          WHEN nd.company_name IS NOT NULL
                          THEN
                             UPPER (nd.company_name)
                          ELSE
                             UPPER (c.acct_name)
                       END
                          rollup_account,
                       CASE
                          WHEN bemfab = 'M' THEN 'Match'
                          WHEN bemfab = 'N' THEN 'Non-DUNS Record'
                          WHEN bemfab = 'O' THEN 'Out of Business'
                          WHEN bemfab IN ('A', 'S', 'D', 'X') THEN 'No Match'
                          ELSE bemfab
                       END
                          bemfab,
                       match_grade,
                       conf_code,
                       bemfab_acct_match,
                       SUM (f.book_amt) rev_amt
                FROM                     sales_order_fact f
                                      INNER JOIN
                                         product_dim pd
                                      ON f.product_id = pd.product_id
                                   INNER JOIN
                                      cust_dim c
                                   ON f.cust_id = c.cust_id
                                LEFT OUTER JOIN
                                   gk_acct_rollup r
                                ON c.acct_id = r.acct_id
                             INNER JOIN
                                time_dim td
                             ON f.book_date = td.dim_date
                          LEFT OUTER JOIN
                             gk_unlimited_avg_book_v u
                          ON f.cust_id = u.cust_id
                       LEFT OUTER JOIN
                          gk_naics_dnb_cust_v nd
                       ON c.acct_id = nd.cust_key
               WHERE       td.dim_year >= 2006
                       AND f.record_type = 'SalesOrder'
                       AND f.so_status != 'Cancelled'
                       AND acct_name IS NOT NULL
            GROUP BY   td.dim_year,
                       td.dim_year || '-' || LPAD (td.dim_quarter, 2, '0'),
                       td.dim_year || '-' || LPAD (td.dim_month_num, 2, '0'),
                       td.dim_period_name,
                       pd.prod_channel,
                       pd.prod_modality,
                       pd.prod_line,
                       pd.prod_family,
                       c.acct_name,
                       c.acct_id,
                       UPPER (SUBSTR (f.bill_to_country, 1, 3)),
                       nd.naics_desc,
                       nd.annual_sales,
                       nd.employees_total,
                       CASE
                          WHEN r.rollup_acct_name IS NOT NULL
                          THEN
                             r.rollup_acct_name
                          WHEN nd.global_ult_business_name IS NOT NULL
                          THEN
                             UPPER (nd.global_ult_business_name)
                          WHEN nd.parent_hq_name IS NOT NULL
                          THEN
                             UPPER (nd.parent_hq_name)
                          WHEN nd.company_name IS NOT NULL
                          THEN
                             UPPER (nd.company_name)
                          ELSE
                             UPPER (c.acct_name)
                       END,
                       bemfab,
                       match_grade,
                       conf_code,
                       bemfab_acct_match)
GROUP BY   dim_year,
           dim_quarter,
           dim_month_num,
           dim_period_name,
           course_ch,
           course_mod,
           course_pl,
           course_type,
           acct_name,
           acct_id,
           ops_country,
           naics_description,
           annual_us_sales,
           employees_total,
           rollup_account,
           bemfab,
           match_grade,
           conf_code,
           bemfab_acct_match;

COMMENT ON MATERIALIZED VIEW GKDW.GK_ACCOUNT_REVENUE_MV IS 'snapshot table for snapshot GKDW.GK_ACCOUNT_REVENUE_MV';

GRANT SELECT ON GKDW.GK_ACCOUNT_REVENUE_MV TO DWHREAD;
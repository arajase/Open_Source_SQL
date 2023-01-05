CREATE PROCEDURE SALES.TOTAL_REVENUE(IN S_MONTH INTEGER,
    IN S_YEAR INTEGER, OUT TOTAL DECIMAL(10,2))
    PARAMETER STYLE JAVA READS SQL DATA LANGUAGE JAVA EXTERNAL NAME 
    'com.example.sales.calculateRevenueByMonth';
	
CALL SALES.TOTAL_REVENUE('S_MONTH','S_YEAR','TOTAL');

create table vbap_sorted
tablespace vbap_copy
storage (initial 500m
next 50m
freelists 30
maxextents unlimited
)
as
select /*+ index(vbap vbap___0) */
*
from
sapr3.vbap
;

create table
   vbap_sorted
tablespace
   vbap_copy
storage (
   initial 500m
   next 50m
   maxextents unlimited
   )
parallel (degree 4)
as
select *
from
sapr3.vbap
order by
mandt,
vbeln,
posnr;
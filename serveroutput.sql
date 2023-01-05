set serveroutput_cursor on 
declare
  cursor empcur is 
    select employee_id, trunc(months_between(sysdate,hire_date) / 12) exp
    from employees;
  v_increment number(2);
begin
    for emprec in empcur
    loop
        -- find out increment based on experience (exp)
        v_increment :=  case 
           when emprec.exp > 10 then 20
           when emprec.exp > 5  then 15
           else 10
        end;
        
        update employees set salary = salary + (salary * v_increment / 100)
        where employee_id = emprec.employee_id;
        
        
        dbms_output.put_line(emprec.employee_id || ' salary was incremented by ' || v_increment || '%');
        
   end loop;
end;   

set serveroutput on 
begin
   update employees set salary = 5000
   where  department_id = 200;
   
   if sql%found then
       dbms_output.put_line('Updated ' || sql%rowcount || ' employees!');
       rollback;
   else
       dbms_output.put_line('Employee not found!');
   end if;
   
end;   

-- Dynamic SQL

CREATE OR REPLACE PACKAGE PKG_DYNAMIC_EXEC
AS
  PROCEDURE pr_task_1(
      p1 NUMBER);
  PROCEDURE pr_task_2(
      p1 NUMBER);
  PROCEDURE pr_task_3(
      p1 NUMBER);
END PKG_DYNAMIC_EXEC;
/
CREATE OR REPLACE PACKAGE BODY PKG_DYNAMIC_EXEC
AS
PROCEDURE pr_task_1(
    p1 IN NUMBER)
IS
BEGIN
  DBMS_OUTPUT.PUT_LINE(' INSIDE pr_task_1.Value of Arg ->'|| p1);
END;
PROCEDURE pr_task_2(
    p1 IN NUMBER)
IS
BEGIN
  DBMS_OUTPUT.PUT_LINE(' INSIDE pr_task_2.Value of Arg -> '|| p1 );
END;
PROCEDURE pr_task_3(
    p1 IN NUMBER)
IS
BEGIN
  DBMS_OUTPUT.PUT_LINE(' INSIDE pr_task_3.Value of Arg -> '|| p1);
END;
END PKG_DYNAMIC_EXEC;
/
--Calling a apecific procedure dynamically based on the conditions.
SET SERVEROUTPUT ON;
DECLARE
  procnum NUMBER(2) :=
  CASE
  WHEN TO_CHAR(SYSDATE,'W') IN ( 1,2 ) THEN -- 1st and 2nd day of the week.
    1
  WHEN TO_CHAR(SYSDATE,'W') IN ( 3, 4 ) THEN -- 3rd nd 4th
    2
  ELSE
    3
  END;
  arg              NUMBER(5) := TO_NUMBER(TO_CHAR(SYSDATE,'MM'));
  p_proceduce_call VARCHAR2(1000);
BEGIN
  p_proceduce_call := 'BEGIN PKG_DYNAMIC_EXEC.pr_task_'||procnum||'(:arg);END;';  --use local variables and bind variable arguments.
  DBMS_OUTPUT.PUT_LINE(p_proceduce_call);
  EXECUTE IMMEDIATE p_proceduce_call USING arg;
END;
/
SELECT TO_CHAR(SYSDATE+2,'W' ) , TO_NUMBER(TO_CHAR(SYSDATE,'MM')) FROM DUAL;


-- TRIGGER

SET SERVEROUTPUT ON;
CREATE OR REPLACE TRIGGER alert_chg_glif10 
AFTER   INSERT  ON GLIF10
FOR EACH ROW WHEN (NEW.LCY_AMT > 100000)
BEGIN
DBMS_OUTPUT.PUT_LINE('TRANSACTION > 1 LAKH, AMOUNT = '||:NEW.LCY_AMT||' BRANCH = '||:NEW.BRCH);
DBMS_OUTPUT.PUT_LINE('USER = '||sys.login_user);
END;
/

INSERT INTO GLIF10 SELECT * FROM  GLIF3 WHERE BRCH LIKE '%1%';
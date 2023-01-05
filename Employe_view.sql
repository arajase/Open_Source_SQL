--Creates a view v_employes with columns of employes , departments.

CREATE OR REPLACE VIEW v_employees
AS
  (SELECT e.employee_id,
    e.first_name,
    d.department_name,
    e.salary
  FROM employees e
  LEFT OUTER JOIN departments d
  ON d.department_id = e.department_id
  );

  --Use join with the original table to get another additional column.
  
SELECT e.employee_id ,
  e.first_name
FROM v_employees v,
  employees e
WHERE e.EMPLOYEE_ID = v.EMPLOYEE_ID
AND v.DEPARTMENT_NAME = 'HR'; 


CURSOR c1 IS SELECT empno, ename, job, sal FROM emp 
   WHERE sal > 2000; 
CURSOR c2 RETURN dept%ROWTYPE IS 
   SELECT * FROM dept WHERE deptno = 10;
CURSOR c3 (start_date DATE) IS
   SELECT empno, sal FROM emp WHERE hiredate > start_date;
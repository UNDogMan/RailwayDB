create user repadmin identified by Password1; 
grant connect, resource to repadmin; 
execute dbms_repcat_admin.grant_admin_any_schema('repadmin'); 
grant comment any table to repadmin; 
grant lock any table to repadmin; 
execute dbms_defer_sys.register_propagator('repadmin');

connect repadmin/Password1@rwpdb

create database link rwpdb2
 connect to repadmin identified by repadmin 
 using 'rwpdb2'; 

connect repadmin/Password1@rwpdb2 

create database link rwpdb 
 connect to repadmin identified by repadmin 
 using 'rwpdb';

-- Add jobs to NAVDB 
connect repadmin/Password1@rwpdb;

begin 
 dbms_defer_sys.schedule_push(
 destination => 'rwpdb2', 
 interval => 'SYSDATE + 1/(60*24)', 
 next_date => sysdate, 
 stop_on_error => FALSE, 
 delay_seconds => 0, 
 parallelism => 1); 
end; 
/
 
begin 
dbms_defer_sys.schedule_purge( 
 next_date => sysdate, 
 interval => 'sysdate + 1/24', 
 delay_seconds => 0, 
 rollback_segment => ''); 
end; 
/
 
-- Add jobs to MYDB 
connect repadmin/Password1@rwpdb2 
begin 
 dbms_defer_sys.schedule_push( 
 destination => 'rwpdb', 
 interval => 'SYSDATE + 1/(60*24)', 
 next_date => sysdate, 
 stop_on_error => FALSE, 
 delay_seconds => 0, 
 parallelism => 1); 
end; 
/ 
begin 
dbms_defer_sys.schedule_purge( 
 next_date => sysdate, 
 interval => 'sysdate + 1/24', 
 delay_seconds => 0, 
 rollback_segment => ''); 
end; 
/

connect repadmin/Password1@rwpdb
BEGIN
  DBMS_REPCAT.DROP_MASTER_REPGROUP('REPG');
END;
/
BEGIN 
 DBMS_REPCAT.CREATE_MASTER_REPGROUP( 
 gname => 'REPG', 
 qualifier => '', 
 group_comment => ''); 
END; 
/
BEGIN
  for i in (select * from dba_objects where OWNER = 'RW_ADMIN' and OBJECT_TYPE='TABLE') loop
    dbms_output.put_line(i.OBJECT_NAME);
    DBMS_REPCAT.CREATE_MASTER_REPOBJECT( 
     gname => 'REPG', type => 'TABLE',sname => 'RW_ADMIN', oname => i.OBJECT_NAME);
  end loop;
END;
/
BEGIN
  for i in (select * from dba_objects where OWNER = 'RW_ADMIN' and OBJECT_TYPE='TABLE') loop
    dbms_output.put_line(i.OBJECT_NAME);
    DBMS_REPCAT.GENERATE_REPLICATION_SUPPORT(
     sname => 'RW_ADMIN',oname => i.OBJECT_NAME,type => 'TABLE',
     min_communication => TRUE,
     generate_80_compatible => FALSE);
  end loop;
END;
/
BEGIN 
 DBMS_REPCAT.RESUME_MASTER_ACTIVITY( 
 gname => 'REPG'); 
END; 
/

SELECT *
FROM dba_repcatlog;
/

BEGIN 
 DBMS_REPCAT.SUSPEND_MASTER_ACTIVITY( 
 gname => 'REPG'); 
END; 
/
BEGIN 
 DBMS_REPCAT.ADD_MASTER_DATABASE( 
 gname => 'REPG', 
 master => 'rwpdb2'); 
END;
/
BEGIN 
 DBMS_REPCAT.RESUME_MASTER_ACTIVITY( 
 gname => 'REPG'); 
END; 
/
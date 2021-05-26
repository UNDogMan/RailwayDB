BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'remove_tokens',
   job_type           =>  'PLSQL_BLOCK',
   job_action         =>  'delete TOKENS',
   start_date         =>  '10-05-2021 23:59:59',
   repeat_interval    =>  'FREQ=MONTHLY',
   auto_drop          =>   FALSE);
  DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'arch_tickets',
   job_type           =>  'PLSQL_BLOCK',
   job_action         =>  'update ORDER_TABLE set STATUS = 2 where STATUS = 0 and ORDERDATE < SYSDATE',
   start_date         =>  '10-05-2021 02:00:00',
   repeat_interval    =>  'FREQ=DAILY',
   auto_drop          =>   FALSE);
  commit;
END;
/
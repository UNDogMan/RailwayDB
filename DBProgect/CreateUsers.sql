create user RW_CLIENT identified by Password1;
create user RW_MANAGER identified by Password1;
/
grant execute on RW_AUTH to RW_CLIENT;
grant execute on RW_USER to RW_CLIENT;
grant execute on RW_NET_CLIENT to RW_CLIENT;
grant execute on RW_ORDER to RW_CLIENT;
grant execute on RW_NOTIFICATION_CLIENT to RW_CLIENT;
/
grant execute on RW_NET to RW_MANAGER;
grant execute on RW_ORDER_MANAGER to RW_MANAGER;
grant execute on RW_ORDER_MANAGER to RW_MANAGER;
grant execute on RW_NOTIFICATION to RW_MANAGER;
/
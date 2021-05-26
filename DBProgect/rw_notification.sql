create or replace package rw_notification as
    type t_notification_table is table of NOTIFICATION%ROWTYPE;

    procedure add_notification(text nvarchar2, start_d date, end_d date);
    procedure update_notification(idN number, text nvarchar2, start_d date, end_d date);
    procedure remove_notification(idN number);
    function get_all_notifications return t_notification_table pipelined;
    function get_today_notifications return t_notification_table pipelined;
end rw_notification;
/
create or replace package body rw_notification as
    procedure add_notification(text nvarchar2, start_d date, end_d date) as
    begin
        insert into NOTIFICATION(MESSAGE, START_DATE, END_DATE) values (text, start_d, end_d);
        commit;
    exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end add_notification;
    procedure update_notification(idN number, text nvarchar2, start_d date, end_d date)as
    begin
        update NOTIFICATION set MESSAGE = text, START_DATE = start_d, END_DATE = end_d where ID = idN;
        commit;
    exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end update_notification;
    procedure remove_notification(idN number) as
    begin
        delete NOTIFICATION where ID = idN;
        commit;
    exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end remove_notification;
    function get_all_notifications return t_notification_table pipelined is
    begin
        for i in (select * from NOTIFICATION) loop
                pipe row ( i );
            end loop;
    end get_all_notifications;
    function get_today_notifications return t_notification_table pipelined is
    begin
        for i in (select * from NOTIFICATION where SYSDATE between START_DATE and END_DATE) loop
                pipe row ( i );
            end loop;
    end get_today_notifications;
end rw_notification;
/
create or replace package rw_notification_client as
    type t_notification_table is table of NOTIFICATION%ROWTYPE;
    function get_today_notifications return t_notification_table pipelined;
end rw_notification_client;
/
create or replace package body rw_notification_client as
    function get_today_notifications return t_notification_table pipelined is
    begin
        for i in (select * from NOTIFICATION where SYSDATE between START_DATE and END_DATE) loop
                pipe row ( i );
            end loop;
    end get_today_notifications;
end rw_notification_client;

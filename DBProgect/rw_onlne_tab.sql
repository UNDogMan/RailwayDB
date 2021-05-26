create or replace package rw_online_tab is
    type t_online_tab_table is table of ONLINE_TABLE%rowtype;

    procedure add_train_to_tab(train_id int, dp_id int, arrival_time date, depart_time date);
    procedure edit_train_in_tab(train_id int, dp_id int, arrival_time date, depart_time date);
    procedure remove_train(train_id int);
    function get_online_tab return t_online_tab_table pipelined;
end rw_online_tab;
/
create or replace package body rw_online_tab is

    procedure add_train_to_tab(train_id int, dp_id int, arrival_time date, depart_time date) is
        count_t int;
    begin
        select count(*) into count_t from ONLINE_TABLE;
        if(count_t != 0) then
            raise_application_error(-20001, 'the train has already been added to the online_table');
        end if;
        insert into ONLINE_TABLE(TRAIN, DESTPOINT, ARRIVE, DEPART) values(train_id, dp_id, arrival_time, depart_time);
    end add_train_to_tab;

    procedure edit_train_in_tab(train_id int, dp_id int, arrival_time date, depart_time date)is
    begin
        update ONLINE_TABLE set DESTPOINT = dp_id, ARRIVE = arrival_time, DEPART = depart_time where TRAIN = train_id;
    end edit_train_in_tab;

    procedure remove_train(train_id int)is
    begin
        delete ONLINE_TABLE where TRAIN = train_id;
    end remove_train;

    function get_online_tab return t_online_tab_table pipelined is
    begin
        for i in (
            select * from ONLINE_TABLE)
        loop
            PIPE ROW ( i );
        end loop;
    end get_online_tab;

end rw_online_tab;
/
create or replace package rw_online_tab_client is
    type t_online_tab_table is table of ONLINE_TABLE%rowtype;
    function get_online_tab return t_online_tab_table pipelined;
end rw_online_tab_client;
/
create or replace package body rw_online_tab_client is
    function get_online_tab return t_online_tab_table pipelined is
    begin
        for i in (
            select * from ONLINE_TABLE)
        loop
            PIPE ROW ( i );
        end loop;
    end get_online_tab;
end rw_online_tab_client;
/
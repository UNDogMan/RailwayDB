create or replace package rw_order as
    type t_ticket_table is table of TICKET%rowtype;

    function get_order(key raw) return ORDER_TABLE%rowtype;
    procedure create_order(key raw, order_id out raw);
    procedure cancel_order(key raw, order_id raw);
    procedure paid_order(key raw, order_id raw);

    procedure add_ticket(key raw, order_id raw, train_id number, src number,
        dest number, pass number, carrige_num number, seat_num number);
    procedure remove_ticket(key raw, ticket_id raw);
    function get_tickets(key raw) return t_ticket_table pipelined;
end rw_order;
/
create or replace package body rw_order as
    function get_order(key raw)
    return ORDER_TABLE%rowtype
    is
        user_id number;
        orow ORDER_TABLE%rowtype;
    begin
        user_id := RW_AUTH.IS_LOGIN(key);
        if user_id is null then
            return null;
        end if;
        select * into orow from ORDER_TABLE
        where USERID = user_id and STATUS = 1;
        return orow;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end get_order;

    procedure create_order(
        key raw,
        order_id out raw
    ) is
        user_id number;
        guid raw(16);
    begin
        user_id := RW_AUTH.IS_LOGIN(key);
        if user_id is null then
            return;
        end if;
        guid := SYS_GUID();
        insert into ORDER_TABLE(ID, USERID, ORDERDATE, STATUS)
        values (guid, user_id, SYSDATE, 1)
        returning ID into  order_id;
        commit;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end create_order;

    procedure cancel_order(
        key raw, order_id raw
    ) is
        user_id number;
    begin
        user_id := RW_AUTH.IS_LOGIN(key);
        if user_id is null then
            return;
        end if;
        delete ORDER_TABLE where ID = order_id;
        commit;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end cancel_order;

    procedure paid_order(
        key raw, order_id raw
    )is
        user_id number;
    begin
        user_id := RW_AUTH.IS_LOGIN(key);
        if user_id is null then
            return;
        end if;
        update ORDER_TABLE set STATUS = 2 where ID = order_id;
        commit;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end paid_order;

    procedure add_ticket(
        key raw,
        order_id raw,
        train_id number,
        src number,
        dest number,
        pass number,
        carrige_num number,
        seat_num number
    )is
        guid raw(16);
        user_id number;
        trow TRAIN%rowtype;
        pathcur sys_refcursor;
        pc number;
        pt number;
        pd number;
    begin
        user_id := RW_AUTH.IS_LOGIN(key);
        if user_id is null then
            return;
        end if;
        trow := RW_NET.GET_TRAIN_INFO(train_id);
        pathcur := RW_NET.GET_PATH_DATA2(trow.ROUTE, src, dest);
        --open pathcur;
        loop
            exit when pathcur%notfound;
            fetch pathcur into pd, pc, pt;
        end loop;
        guid := SYS_GUID();
        insert into TICKET (ID, ORDERID, TRAIN, "FROM", "TO", PASSENGER, COST, CARIGENUM, SEATNUM)
        values(guid, order_id, train_id, src, dest, pass, pc, carrige_num, seat_num);
        commit;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end add_ticket;

    procedure remove_ticket(
        key raw,
        ticket_id raw
    ) is
        user_id number;
    begin
        user_id := RW_AUTH.IS_LOGIN(key);
        if user_id is null then
            return;
        end if;
        delete TICKET where ID = ticket_id;
        commit;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end remove_ticket;

    function get_tickets(
        key raw
    ) return t_ticket_table pipelined is
        user_id number;
        trow TICKET%rowtype;
    begin
        user_id := RW_AUTH.IS_LOGIN(key);
        if user_id is null then
            return;
        end if;
        for i in (
            select t.* from TICKET t
            inner join ORDER_TABLE o on t.ORDERID = o.ID
            where o.USERID = user_id)
        loop
            PIPE ROW ( i );
        end loop;
    end;
end rw_order;
/
create or replace package rw_order_manager as

    function get_ticket(
        tid raw
    ) return TICKET%ROWTYPE;
end rw_order_manager;
/
create or replace package body rw_order_manager as
    function get_ticket(
        tid raw
    ) return TICKET%ROWTYPE is
        ans TICKET%ROWTYPE;
    begin
    select * into ans from TICKET where ID = tid;
    return ans;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end get_ticket;
end rw_order_manager;
create or replace package rw_net as
    type t_destpoint_table is table of DESTPOINT%rowtype;
    type t_route_table is table of ROUTE%rowtype;
    type t_number is table of number;
    TYPE r_path_info IS RECORD (
      dest      number := 0,
      cost      number := 0,
      pathtime  number := 0);
   TYPE t_path_info IS TABLE OF r_path_info;

    function get_destpoints return t_destpoint_table pipelined;
    procedure create_destpoint(namedp nvarchar2, descriptiondp nvarchar2, dpid out number);
    procedure update_destpoint(dpid number, namedp nvarchar2, descriptiondp nvarchar2);
    procedure remove_destpoint(dpid number);

    function get_routes return t_route_table pipelined;
    procedure create_route(idr number, info nvarchar2);
    procedure remove_route(idr number);

    procedure add_connection_to_route(routec number, fromds_lID number, ds number,
        costc number,tm number,dplid out number);
    function routes_for_path(src number, dest number)
        return t_number pipelined;
    function get_path_data(routeid number, src number, dest number)
        return t_path_info pipelined;
    function get_path_data2(routeid number, src number, dest number)
        return sys_refcursor;

    procedure create_train(tnum number, ttype number, troute number, tid out number);
    procedure remove_train(tid number);
    procedure update_train(tid number, tnum number, ttype number, troute number);
    function get_train_info(tid number) return TRAIN%rowtype;
end rw_net;
/
create or replace package body rw_net is
    function get_destpoints return t_destpoint_table pipelined
    is begin
        for i in (select * from DESTPOINT) loop
            PIPE ROW ( i );
        end loop;
    end get_destpoints;

    procedure create_destpoint(
        namedp nvarchar2,
        descriptiondp nvarchar2,
        dpid out number
    ) is
    begin
        insert into DESTPOINT(NAME, DESCRIPTION)
        values (namedp, descriptiondp)
        returning ID into dpid;
        commit;
        exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end create_destpoint;

    procedure update_destpoint(
        dpid number,
        namedp nvarchar2,
        descriptiondp nvarchar2
    ) is
    begin
    update DESTPOINT set NAME = namedp, DESCRIPTION = descriptiondp
    where ID = dpid;
    commit;
        exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end update_destpoint;

    procedure remove_destpoint(
        dpid number
    ) is
    begin
    for i in (select d1.ID id1,
                     d2.ID id2,
                     d2.NEXT next2,
                     d2.COST cost2,
                     d2.COST time2
    from DS_LINKS d1
    inner join DS_LINKS d2 on d1.NEXT = d2.ID
    where d2.DESTPOINT = dpid
    for update) loop
            update DS_LINKS set
                                NEXT = i.next2,
                                COST = COST + i.cost2,
                                TIMEMINUT = TIMEMINUT + i.time2
            where ID = i.id1;
            delete DS_LINKS where ID = i.id2;
    end loop;
    delete DESTPOINT where ID = dpid;
    commit;
        exception
            when others then
                rollback;
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end remove_destpoint;

    function get_routes return t_route_table pipelined is
    begin
        for i in (select * from ROUTE) loop
            PIPE ROW ( i );
        end loop;
    end get_routes;

    procedure create_route(idr number, info nvarchar2) is
    begin
        insert into ROUTE values(idr, info);
        commit;
        exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end create_route;

    procedure remove_route(idr number) is
    begin
        delete ROUTE where ID = idr;
        commit;
        exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end remove_route;

    procedure add_connection_to_route(
        routec number,
        fromds_lID number,
        ds number,
        costc number,
        tm number,
        dplid out number
    ) is
    begin
        insert into DS_LINKS(ROUTE, DESTPOINT, COST, TIMEMINUT, NEXT)
        values (routec, ds, costc, tm, null) returning ID into dplid;
        update DS_LINKS set NEXT = dplid where ID = fromds_lID;
        commit;
        exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end add_connection_to_route;

    function routes_for_path(src number, dest number)
        return t_number pipelined is
        l_return sys_refcursor;
        num number;
    begin
        open l_return for
        with d(destination) as (
            select dest from dual
        )
        select ROUTE from d
        left join (select ROUTE, DESTPOINT from DS_LINKS
        START WITH DESTPOINT = src
        CONNECT BY PRIOR NEXT = ID) a
            on d.destination = a.DESTPOINT;
        LOOP
            FETCH l_return INTO num;
            EXIT WHEN l_return%NOTFOUND;
             PIPE ROW ( num );
        END LOOP;
    end routes_for_path;

    function get_path_data(routeid number, src number, dest number)
        return t_path_info pipelined
    is
        l_return sys_refcursor;
        pathr r_path_info;
        destn number;
        costn number;
        pathtimen number;
    begin
        open l_return for
        select d2.DESTPOINT dest,
                           sum(d1.COST) over (ORDER BY d1.ROUTE, d1.DESTPOINT) cost,
                           sum(d1.TIMEMINUT) over (ORDER BY d1.ROUTE, d1.DESTPOINT, d2.DESTPOINT) pathtime

        from DS_LINKS d1
        left join DS_LINKS d2 on d1.NEXT = d2.ID
        where d1.ROUTE = routeid
        start with d1.DESTPOINT = src
        CONNECT BY PRIOR d1.NEXT = d1.ID and d1.DESTPOINT != dest;
        loop
            FETCH l_return INTO destn, costn, pathtimen;
            EXIT WHEN l_return%NOTFOUND;
            pathr.dest := destn;
            pathr.cost := costn;
            pathr.pathtime := pathtimen;
            PIPE ROW ( pathr );
        end loop;
    end get_path_data;

    function get_path_data2(routeid number, src number, dest number)
        return sys_refcursor
    is
        l_return sys_refcursor;
    begin
        open l_return for
        select d2.DESTPOINT dest,
               sum(d1.COST) over(ORDER BY d1.ROUTE, d1.DESTPOINT) cost,
               sum(d1.TIMEMINUT) over(ORDER BY d1.ROUTE, d1.DESTPOINT, d2.DESTPOINT) pathtime
        from DS_LINKS d1
        left join DS_LINKS d2 on d1.NEXT = d2.ID
        where d1.ROUTE = routeid
        start with d1.DESTPOINT = src
        CONNECT BY PRIOR d1.NEXT = d1.ID and d1.DESTPOINT != dest;
        return l_return;
    end get_path_data2;

    procedure create_train(
        tnum number,
        ttype number,
        troute number,
        tid out number
    ) is
    begin
        insert into TRAIN("NUMBER", TRAIN_TYPE, ROUTE)
        values (tnum, ttype, troute)
        returning ID into tid;
        commit;
        exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end create_train;

    procedure remove_train(
        tid number
    )is
    begin
        delete TRAIN where ID = tid;
        commit;
        exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end remove_train;

    procedure update_train(
        tid number,
        tnum number,
        ttype number,
        troute number
    )is
        trow TRAIN%rowtype;
    begin
        select * into trow from TRAIN where ID = tid;
        if tnum is not null then
            trow."NUMBER" := tnum;
        end if;
        if ttype is not null then
            trow.TRAIN_TYPE := ttype;
        end if;
        if troute is not null then
            trow.ROUTE := troute;
        end if;
        update TRAIN set ROW = trow
        where ID = tid;
        commit;
        exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end update_train;

    function get_train_info(tid number)
    return TRAIN%rowtype
    is
        trow TRAIN%rowtype;
    begin
        select * into trow from TRAIN where ID = tid;
        return trow;
    exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end get_train_info;
end rw_net;
/
create or replace package rw_net_client as
    type t_destpoint_table is table of DESTPOINT%rowtype;
    type t_number is table of number;
    type r_path_info IS RECORD (
      dest      number := 0,
      cost      number := 0,
      pathtime  number := 0);
    type t_path_info IS TABLE OF r_path_info;

    function get_destpoints return t_destpoint_table pipelined;

    function get_train_info(tid number) return TRAIN%rowtype;
    function routes_for_path(src number, dest number)
        return t_number pipelined;
    function get_path_data(routeid number, src number, dest number)
        return t_path_info pipelined;
end rw_net_client;
/
create or replace package body rw_net_client as
    function get_destpoints return t_destpoint_table pipelined
    is begin
        for i in (select * from DESTPOINT) loop
            PIPE ROW ( i );
        end loop;
    end get_destpoints;

    function get_train_info(tid number)
    return TRAIN%rowtype
    is
        trow TRAIN%rowtype;
    begin
        select * into trow from TRAIN where ID = tid;
        return trow;
    exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end get_train_info;

    function routes_for_path(src number, dest number)
        return t_number pipelined is
        l_return sys_refcursor;
        num number;
    begin
        open l_return for
        with d(destination) as (
            select dest from dual
        )
        select ROUTE from d
        left join (select ROUTE, DESTPOINT from DS_LINKS
        START WITH DESTPOINT = src
        CONNECT BY PRIOR NEXT = ID) a
            on d.destination = a.DESTPOINT;
        LOOP
            FETCH l_return INTO num;
            EXIT WHEN l_return%NOTFOUND;
             PIPE ROW ( num );
        END LOOP;
    end routes_for_path;

    function get_path_data(routeid number, src number, dest number)
        return t_path_info pipelined
    is
        l_return sys_refcursor;
        pathr r_path_info;
        destn number;
        costn number;
        pathtimen number;
    begin
        open l_return for
        select d2.DESTPOINT dest,
                           sum(d1.COST) over (ORDER BY d1.ROUTE, d1.DESTPOINT) cost,
                           sum(d1.TIMEMINUT) over (ORDER BY d1.ROUTE, d1.DESTPOINT, d2.DESTPOINT) pathtime

        from DS_LINKS d1
        left join DS_LINKS d2 on d1.NEXT = d2.ID
        where d1.ROUTE = routeid
        start with d1.DESTPOINT = src
        CONNECT BY PRIOR d1.NEXT = d1.ID and d1.DESTPOINT != dest;
        loop
            FETCH l_return INTO destn, costn, pathtimen;
            EXIT WHEN l_return%NOTFOUND;
            pathr.dest := destn;
            pathr.cost := costn;
            pathr.pathtime := pathtimen;
            PIPE ROW ( pathr );
        end loop;
    end get_path_data;
end rw_net_client;

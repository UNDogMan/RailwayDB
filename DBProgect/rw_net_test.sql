declare
    did number;
begin
    RW_NET.CREATE_DESTPOINT(N'B', N'description for ' || N'B', did);
    DBMS_OUTPUT.PUT_LINE(did);
end;
/
declare
begin
    RW_NET.CREATE_ROUTE(1, n'1');
end;
/
select * from DESTPOINT;
select * from ROUTE;
/
declare
    dplid number;
    dpfrom number := null;
begin
    for i in 1..4 loop
        rw_net.ADD_CONNECTION_TO_ROUTE(1, dpfrom, i, 10, 10, dplid);
        dpfrom := dplid;
        end loop;
end;
/
select * from DS_LINKS order by ID;

--ROUTES WITH PATH
with d(dest) as (
    select 5 from dual
)
select ROUTE from d
left join
(select ROUTE, DESTPOINT from DS_LINKS
START WITH DESTPOINT = 1
CONNECT BY PRIOR NEXT = ID) a on d.dest = a.DESTPOINT;

--path data
select d2.DESTPOINT dest,
       sum(d1.COST) over(ORDER BY d1.ROUTE, d1.DESTPOINT) cost,
       sum(d1.TIMEMINUT) over(ORDER BY d1.ROUTE, d1.DESTPOINT, d2.DESTPOINT) time
from DS_LINKS d1
left join DS_LINKS d2 on d1.NEXT = d2.ID
where d1.ROUTE = 1
start with d1.DESTPOINT = 1
CONNECT BY PRIOR d1.NEXT = d1.ID and d1.DESTPOINT != 3;

declare
    cur sys_refcursor;
    n number;
begin
    cur := RW_NET.ROUTES_FOR_PATH(1, 4);
    loop
        fetch cur into n;
        exit when cur%notfound;
        DBMS_OUTPUT.PUT_LINE(n);
    end loop;
    close cur;
end;

declare
    cur sys_refcursor;
    id number;
    cost number;
    time number;
begin
    cur := RW_NET.get_path_data(1, 1, 4);
    loop
        fetch cur into id, cost, time;
        exit when cur%notfound;
        DBMS_OUTPUT.PUT_LINE(id || '----' || cost || '----' || time);
    end loop;
    close cur;
end;
/
select d1.*, d2.* from DS_LINKS d1
    inner join DS_LINKS d2 on d1.NEXT = d2.ID
    where d2.DESTPOINT = 2
    for update;
/
begin
    for i in (select d1.ID id1,
                     d2.ID id2,
                     d2.NEXT next2,
                     d2.COST cost2,
                     d2.COST time2
    from DS_LINKS d1
    inner join DS_LINKS d2 on d1.NEXT = d2.ID
    where d2.DESTPOINT = 2
    for update) loop
            update DS_LINKS set
                                NEXT = i.next2,
                                COST = COST + i.cost2,
                                TIMEMINUT = TIMEMINUT + i.time2
            where ID = i.id1;
            delete DS_LINKS where ID = i.id2;
            DBMS_OUTPUT.PUT_LINE(i.id1);
    end loop;
end;
rollback;
select * from DS_LINKS;

select t.* from TICKET t
    inner join ORDER_TABLE o on t.ORDERID = o.ID
where o.USERID = 1;

select * from TABLE(RW_NET.GET_DESTPOINTS());
select * from TABLE ( RW_NET.ROUTES_FOR_PATH(1, 4) );
select * from TABLE ( RW_NET.GET_PATH_DATA(1, 1, 4) );
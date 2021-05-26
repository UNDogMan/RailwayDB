declare
    r raw(16);
begin
    select STANDARD_HASH('12312', 'MD5') into r from dual;
    for i in 1..100000 loop
        RW_AUTH.REGISTER(
            i || N' test name',
            i || N' test surname',
            i || N' test fathername',
            N'example' || i || N'@mail.com',
            N'm',
            SYSDATE,
            r);
    end loop;
end;
/
select * from USER_TABLE where id = 1;
/
declare
    r raw(16);
    uid number(10);
begin
    select STANDARD_HASH('12312', 'MD5') into r from dual;
    select ID into uid from USER_TABLE u
                where u.EMAIL = N'example' || 1 || N'@mail.com' and u.PASSWORD = r;
    DBMS_OUTPUT.PUT_LINE(uid);
end;
/
declare
    r raw(16);
    token raw(16);
begin
    select STANDARD_HASH('12312', 'MD5') into r from dual;
    for i in 1..100000 loop
        token := RW_AUTH.LOGIN(
            N'example' || i || N'@mail.com',
            r);
    end loop;
end;
/
select count(*) from TOKENS;
commit;
/
declare
    r raw(16);
    token raw(16);
begin
    select STANDARD_HASH('12312', 'MD5') into r from dual;
    token := RW_AUTH.LOGIN(
            N'example' || 10 || N'@mail.com',
            r);
    for i in 1..10000 loop
        RW_USER.ADD_PASSENGER(
                token,
                i || N' passenger test name',
                i || N' passenger test surname',
                i || N' passenger test fathername',
                N'm',
                SYSDATE,
                N'+375-33-11-11-111',
                1,
                N'MC1111111'
            );
    end loop;
end;
/
select count(*) from PASSENGER;
/
declare
    r raw(16);
    token raw(16);
    orderd raw(16);
begin
    select STANDARD_HASH('12312', 'MD5') into r from dual;
    token := RW_AUTH.LOGIN(
            N'example' || 1 || N'@mail.com',
            r);
    DBMS_OUTPUT.PUT_LINE(token);
    RW_ORDER.CREATE_ORDER(token, orderd);
end;
/
insert into TRAIN("NUMBER", TRAIN_TYPE, ROUTE) values (1, 1, 1);
/
declare
    r raw(16);
    token raw(16);
    orderd raw(16);
    orrow ORDER_TABLE%rowtype;
begin
    select STANDARD_HASH('12312', 'MD5') into r from dual;
    token := RW_AUTH.LOGIN(
            N'example' || 1 || N'@mail.com',
            r);
    DBMS_OUTPUT.PUT_LINE(token);
    orrow := RW_ORDER.GET_ORDER(token);

    for i in (select * from TABLE ( RW_ORDER.GET_TICKETS(token) )) loop
        DBMS_OUTPUT.PUT_LINE(i.ID);
    end loop;

end;
/
declare
begin
    for i in 1..100000 loop
        RW_NOTIFICATION.ADD_NOTIFICATION(
            i || N' test notification',
            SYSDATE + i,
            SYSDATE + i + 1
            );
    end loop;
end;
/
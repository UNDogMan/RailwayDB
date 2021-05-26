create or replace package rw_auth as
    procedure register(
        user_name nvarchar2,
        user_surname nvarchar2,
        user_fathername nvarchar2,
        user_email nvarchar2,
        user_sex nchar,
        user_birthday date,
        user_password raw
    );
    function login(
        emailL nvarchar2,
        passwordL raw
    ) return raw;
    function is_login(
        key raw
    ) return number;
end rw_auth;

create or replace package body rw_auth is

    procedure register(
        user_name nvarchar2,
        user_surname nvarchar2,
        user_fathername nvarchar2,
        user_email nvarchar2,
        user_sex nchar,
        user_birthday date,
        user_password raw
    ) is begin
        insert into USER_TABLE(NAME, SURNAME, FATHERNAME, EMAIL, SEX, BIRTHDAY, PASSWORD)
        values (user_name,
                user_surname,
                user_fathername,
                user_email,
                user_sex,
                user_birthday,
                user_password);
        commit;
        exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end register;

    function login(
        emailL nvarchar2,
        passwordL raw
    ) return raw is
        key raw(16);
        uid int := 0;
        begin
            select ID into uid from USER_TABLE u
                where u.EMAIL = emailL and u.PASSWORD = passwordL;
            if (uid < 0) then
                return null;
            end if;
            key := SYS_GUID();
            insert into TOKENS(USERID, TOKEN)
            values (uid, key);
            commit;
            return key;
        exception
            when NO_DATA_FOUND then
                return null;
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end login;


    function is_login(
        key raw
    ) return number is
        tikenid NUMBER := null;
    begin
        select USERID into tikenid from TOKENS where TOKEN = key;
        return tikenid;
        exception
            when NO_DATA_FOUND then
                return null;
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end is_login;
end rw_auth;

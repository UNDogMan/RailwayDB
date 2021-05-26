create or replace package rw_user as
    type t_passenger_table is table of PASSENGER%rowtype;
    type t_favorite_path_table is table of FAVORITE_PATH%rowtype;
    type t_favorite_train_table is table of FAVORITE_TRAIN%rowtype;

    procedure update_info(
        key raw, username nvarchar2, surname nvarchar2, father_name nvarchar2,
        email nvarchar2, sex nchar, birthday date);

    function get_passengers(key raw) return t_passenger_table pipelined;
    procedure add_passenger(
        key raw, passenger_name nvarchar2, passenger_surname nvarchar2,
        father_name nvarchar2, passenger_sex nchar, passenger_birthday date,
        phone_number nvarchar2, docid number, doc nvarchar2
    );
    procedure remove_passenger(key raw, passenger_id number);

    procedure add_favorite_path(key raw, fromD number, toD number);
    procedure remove_favorite_path(key raw, idFP number);
    function get_favorite_paths(key raw) return t_favorite_path_table pipelined;

    procedure add_favorite_train(key raw, idT number);
    procedure remove_favorite_train(key raw, idFT number);
    function get_favorite_trains(key raw) return t_favorite_train_table pipelined;
end rw_user;
/
create or replace package body rw_user as
    procedure update_info(
        key raw,
        username nvarchar2,
        surname nvarchar2,
        father_name nvarchar2,
        email nvarchar2,
        sex nchar,
        birthday date
    )as
        userid number;
        user_row USER_TABLE%rowtype;
    begin
        userid := RW_AUTH.IS_LOGIN(key);
        if userid is null then
            return;
        end if;
        select * into user_row from USER_TABLE where id = userid;
        if(username is not null) then
            user_row.name := username;
        end if;
        if(surname is not null) then
            user_row.surname := surname;
        end if;
        if(father_name is not null) then
            user_row.fathername:= father_name;
        end if;
        if(email is not null) then
            user_row.email := email;
        end if;
        if(sex is not null) then
            user_row.sex := sex;
        end if;
        if(birthday is not null) then
            user_row.birthday := birthday;
        end if;
        update USER_TABLE set ROW = user_row where ID = userid;
        commit;
    end update_info;

    function get_passengers(
        key raw
    ) return t_passenger_table pipelined is
        user_id number;
    begin
        user_id := RW_AUTH.IS_LOGIN(key);
        if user_id is null then
            return;
        end if;
        for i in (select * from PASSENGER
            where USERID = user_id) loop
                pipe row ( i );
            end loop;
    end get_passengers;

    procedure add_passenger(
        key raw,
        passenger_name nvarchar2,
        passenger_surname nvarchar2,
        father_name nvarchar2,
        passenger_sex nchar,
        passenger_birthday date,
        phone_number nvarchar2,
        docid number,
        doc nvarchar2
    ) as
        userid number;
        doc_regex nvarchar2(50);
    begin
        userid := RW_AUTH.IS_LOGIN(key);
        if userid is null then
            return;
        end if;
        select regex into doc_regex from DOC_TYPE where ID = docid;
        if not regexp_like(doc, doc_regex) then
            return;
        end if;
        insert into PASSENGER(USERID, NAME, SURNAME, FATHERNAME, SEX, BIRTHDAY, PHONENUMBER, DOCTYPE, DOCNUM)
        values (USERID,
                passenger_name,
                passenger_surname,
                father_name,
                passenger_sex,
                passenger_birthday,
                phone_number,
                docid,
                doc);
        commit;
        exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end add_passenger;

    procedure remove_passenger(
        key raw,
        passenger_id number
    )as
        userid number;
    begin
        userid := RW_AUTH.IS_LOGIN(key);
        if userid is null then
            return;
        end if;
        delete PASSENGER where ID = passenger_id;
    end remove_passenger;

    procedure add_favorite_path(key raw, fromD number, toD number) as
        userid number;
    begin
        userid := RW_AUTH.IS_LOGIN(key);
        if userid is null then
            return;
        end if;
        insert into FAVORITE_PATH(USERID, "FORM", "TO") values (userid, fromD, toD);
        commit;
    exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end add_favorite_path;
    procedure remove_favorite_path(key raw, idFP number) as
        userid number;
    begin
        userid := RW_AUTH.IS_LOGIN(key);
        if userid is null then
            return;
        end if;
        delete FAVORITE_PATH where ID = idFP;
        commit;
    exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end remove_favorite_path;
    function get_favorite_paths(key raw) return t_favorite_path_table pipelined is
        user_id number;
    begin
        user_id := RW_AUTH.IS_LOGIN(key);
        if user_id is null then
            return;
        end if;
        for i in (select * from FAVORITE_PATH
            where USERID = user_id) loop
                pipe row ( i );
            end loop;
    end get_favorite_paths;

    procedure add_favorite_train(key raw, idT number) as
        userid number;
    begin
        userid := RW_AUTH.IS_LOGIN(key);
        if userid is null then
            return;
        end if;
        insert into FAVORITE_TRAIN(USERID, TRAINID) values (userid, idT);
        commit;
    exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end add_favorite_train;
    procedure remove_favorite_train(key raw, idFT number)as
        userid number;
    begin
        userid := RW_AUTH.IS_LOGIN(key);
        if userid is null then
            return;
        end if;
        delete FAVORITE_TRAIN where ID = idFT;
        commit;
    exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end remove_favorite_train;
    function get_favorite_trains(key raw) return t_favorite_train_table pipelined is
        user_id number;
    begin
        user_id := RW_AUTH.IS_LOGIN(key);
        if user_id is null then
            return;
        end if;
        for i in (select * from FAVORITE_TRAIN
            where USERID = user_id) loop
                pipe row ( i );
            end loop;
    end get_favorite_trains;
end rw_user;

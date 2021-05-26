create or replace package rw_types as
    procedure add_train_type( train_description nvarchar2, train_id out number);
    procedure remove_train_type(train_id number);
    procedure update_train_type(train_id number, train_description nvarchar2);

    procedure add_order_status(status nvarchar2, description nvarchar2, status_id out number);
    procedure remove_order_status(status_id number);
    procedure update_order_status(status_id number,status nvarchar2, description nvarchar2);

    procedure add_doc_type(doc_title nvarchar2, doc_rgx nvarchar2, doc_id out number);
    procedure remove_doc_type(doc_id number);
    procedure update_doc_type(doc_id number, doc_title nvarchar2, doc_rgx nvarchar2);
end rw_types;
/
create or replace package body rw_types as
    procedure add_train_type(
        train_description nvarchar2,
        train_id out number)
        is
    begin
        insert into TRAIN_TYPE(DESCRIPTION)
        values(train_description)
        returning ID into train_id;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end add_train_type;

    procedure remove_train_type(
        train_id number
    )is
    begin
        delete TRAIN_TYPE where ID = train_id;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end remove_train_type;

    procedure update_train_type(
        train_id number,
        train_description nvarchar2
    )is
    begin
        update TRAIN_TYPE set DESCRIPTION = train_description
        where ID = train_id;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end update_train_type;

    procedure add_order_status(
        status nvarchar2,
        description nvarchar2,
        status_id out number
    )is
    begin
        insert into ORDER_STATUS(STATUS_DESCRIPTION, STATUS_NAME)
        values(status, description)
        returning ID into status_id;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end add_order_status;

    procedure remove_order_status(status_id number)is
    begin
        delete ORDER_STATUS where ID = status_id;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end remove_order_status;

    procedure update_order_status(status_id number,status nvarchar2, description nvarchar2)is
    begin
        update ORDER_STATUS set STATUS_NAME = status, STATUS_DESCRIPTION = description
        where ID = status_id;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end update_order_status;

    procedure add_doc_type(
        doc_title nvarchar2,
        doc_rgx nvarchar2,
        doc_id out number
    )is
    begin
        insert into DOC_TYPE(TITLE, REGEX)
        values(doc_title, doc_rgx)
        returning ID into doc_id;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end add_doc_type;

    procedure remove_doc_type(doc_id number)is
    begin
        delete DOC_TYPE where ID = doc_id;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end remove_doc_type;
    procedure update_doc_type(doc_id number, doc_title nvarchar2, doc_rgx nvarchar2)is
    begin
        update DOC_TYPE set TITLE = doc_title, REGEX = doc_rgx
        where ID = doc_id;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end update_doc_type;
end rw_types;
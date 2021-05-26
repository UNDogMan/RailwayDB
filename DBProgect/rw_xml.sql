

create or replace directory XMLDIR as 'C:\XML';

/
create or replace package rw_xml as
    procedure importTickets;
    procedure exportTickets;
end rw_xml;
/
create or replace package body rw_xml as

    procedure importTickets as
        F UTL_FILE.file_type;
        XMLTEXT CLOB;
    begin
        XMLTEXT := DBMS_XMLGEN.GETXML('select ID, ORDERID, TRAIN, "FROM", "TO", COST, CARIGENUM, SEATNUM, PASSENGER from TICKET');
        F := UTL_FILE.FOPEN('C:\XML', 'TICKETS.XML', 'W');
        UTL_FILE.PUT(F, XMLTEXT);
        UTL_FILE.FCLOSE(F);
    exception
            when others then
                raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end importTickets;

    procedure exportTickets as
    begin
        insert into TICKET(ID, ORDERID, TRAIN, "FROM", "TO", COST, CARIGENUM, SEATNUM, PASSENGER)
            select * from
                XMLTABLE('ROWSET/ROW'
                         PASSING XMLTYPE(BFILENAME('XMLDIR', 'TICKETS.XML'),
                         NLS_CHARSET_ID('CHAR_CS'))
                         columns ID raw(16) PATH 'ID',
                             ORDERID raw(16) PATH 'ORDERID', TRAIN int PATH 'TRAIN',
                             "FROM" int PATH '"FROM"', "TO" int PATH '"TO"',
                             COST number(5, 2) PATH 'COST', CARIGENUM number(2) PATH 'CARIGENUM',
                             SEATNUM number(3) PATH 'SEATNUM', PASSENGER int PATH 'PASSENGER'
                    );
        commit;
    exception
        when others then
            raise_application_error(-20001,'An error was occurred - '||SQLCODE||' -Message- '||SQLERRM);
    end exportTickets;
end rw_xml;

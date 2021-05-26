create table USER_TABLE
(
    ID raw(16) default SYS_GUID(),
    NAME nvarchar2(30) not null,
    SURNAME nvarchar2(30) not null,
    FATHERNAME nvarchar2(30),
    EMAIL      nvarchar2(30) not null,
    SEX nchar
        constraint SEX_CHECK
            check ( SEX in ('m', 'f')),
    BIRTHDAY date,
    PASSWORD raw(16) not null,
    constraint USER_PK primary key(ID)
);
/
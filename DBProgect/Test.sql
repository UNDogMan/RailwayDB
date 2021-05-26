select * from USER_TABLE;

declare
    key raw(16);
begin
    key := RW_AUTH.LOGIN('example1@mail.com', N'');
end;
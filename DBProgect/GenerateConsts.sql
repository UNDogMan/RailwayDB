insert into TRAIN_TYPE(DESCRIPTION) values (N'������������ ������-������');
insert into TRAIN_TYPE(DESCRIPTION) values (N'������������ �������-������');
insert into TRAIN_TYPE(DESCRIPTION) values (N'��������������� ������-������');
insert into TRAIN_TYPE(DESCRIPTION) values (N'��������������� �������-�����');
insert into TRAIN_TYPE(DESCRIPTION) values (N'�������������');
/
insert into ORDER_STATUS(STATUS_NAME, STATUS_DESCRIPTION) values (N'�����������', N'����� �������, �������� ����� ���������������');
insert into ORDER_STATUS(STATUS_NAME, STATUS_DESCRIPTION) values (N'������� ���������', N'����� ���������');
insert into ORDER_STATUS(STATUS_NAME, STATUS_DESCRIPTION) values (N'�������', N'����� �������, ������ � ������');
/
insert into DOC_TYPE(TITLE, REGEX) values (N'������� ��', N'[A-Z]{2}[0-9]{7}');
insert into DOC_TYPE(TITLE, REGEX) values (N'������� ��', N'[A-Z]{2}[0-9]{7}');
/
commit;
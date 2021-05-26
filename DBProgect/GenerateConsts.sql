insert into TRAIN_TYPE(DESCRIPTION) values (N'Региональные эконом-класса');
insert into TRAIN_TYPE(DESCRIPTION) values (N'Региональные бизнесс-класса');
insert into TRAIN_TYPE(DESCRIPTION) values (N'Межрегиональные эконом-класса');
insert into TRAIN_TYPE(DESCRIPTION) values (N'Межрегиональные бизнесс-касса');
insert into TRAIN_TYPE(DESCRIPTION) values (N'Международные');
/
insert into ORDER_STATUS(STATUS_NAME, STATUS_DESCRIPTION) values (N'Действующие', N'Заказ оплачен, билетами можно воспользоваться');
insert into ORDER_STATUS(STATUS_NAME, STATUS_DESCRIPTION) values (N'Требует активации', N'Заказ неоплачен');
insert into ORDER_STATUS(STATUS_NAME, STATUS_DESCRIPTION) values (N'Ахивный', N'Заказ оплачен, билеты в архиве');
/
insert into DOC_TYPE(TITLE, REGEX) values (N'Паспорт РБ', N'[A-Z]{2}[0-9]{7}');
insert into DOC_TYPE(TITLE, REGEX) values (N'Паспорт РФ', N'[A-Z]{2}[0-9]{7}');
/
commit;
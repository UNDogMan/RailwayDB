create tablespace ts_rwpdb
  datafile 'C:\app\tablespaces\ts_rwpdb.dbf'
  size 5M
  autoextend on next 5M
  maxsize 500M
  extent management local;

create temporary tablespace ts_rwpdb_temp
  tempfile 'C:\app\tablespaces\ts_rwpdb_temp.dbf'
  size 5M
  autoextend on next 5M
  maxsize 250M
  extent management local;

SELECT * FROM dba_tablespaces;

grant all privileges to RW_ADMIN;
-- Filename: example_01_Partial_or_Piecemeal_Database_Restore_in_ MS_SQL_Server.sql
-- Function: Partial or Piecemeal Database Restore in MS SQL Server
-- Doc: https://sqlwizard.blog/2020/03/09/partial-or-piecemeal-database-restore-in-ms-sql-server/

-- Letop
-- Azure SQL managed instance ondersteunt geen databases die gebruik maken van file groups


-- Problem Statement:
-- These days data is growing rapidly and maintaining its availability as per defined RTO & RPO has become
-- biggest challenge for a DBA. This blog post will help you to design the recovery of such database.
--
-- Suppose, we have a database over 10TB, which is a combination of transactional and historical data (not a
-- good design I know). The severity of the processes running on transactional data are high and cannot be
-- taken down for more than 1 hour. Historical data is only being used by reports which can wait in case of
-- disaster.
--
-- Recovery Solutions: 
-- Physical partition of database: 
-- You can physically move historical data into different database on different drives. This will reduce the
-- main database size and can help to meet desired RTO and RPO of transactional and historical databases. This
-- solution is quite complex in terms of implementation and maintenance as you would need to keep your
-- historical data updated.
--
-- SQL Server Table Partitioning on different Filegroups and piecemeal restore:
--
--
-- What is table partitioning: 
-- Table partitioning is a way to divide a large table into smaller,
-- more manageable parts without having to create separate tables for each part. The data of partitioned tables
-- and indexes is divided into units that can be spread across more than one filegroup in a database. The data
-- is partitioned horizontally, so that groups of rows are mapped into individual partitions. All partitions of
-- a single index or table must reside in the same database. 
--
-- How this will solve our problem:  
-- We can distribute historical and transactional data into different filegroups
-- using table partitioning and use piecemeal restore feature to recover transactional data first so that all the
-- dependent process can access the data. We would need to design the database to make use of this piecemeal
-- restoration, this will involve categorization of filegroups as per their severity.
--
-- I will only cover 2nd option that is database recovery with piecemeal restore as this is a preferred option.
-- In this example, we have a database with multiple filegroups and table partitioned across the filegroups: (I will
-- cover table partitioning in details later in another blog post)
--
-- Database name: PiecemealRestoreDB
--
-- Primary filegroup (default) – If we have designed this database keeping piecemeal restore in mind then we need to
--                               keep Primary filegroup as small as we can.
-- Filegroup_C                 – This data needs to be recovered first as most critical processes are dependent on
--                               the data stored in this filegroup
-- Filegroup_B                 – After recovering FILEGROUP_C, this data needs to be recovered as less business critical
--                               processes are dependent on the data stored in FILEGROUP_B
-- Filegroup_A                 – This filegroup only contains historical data and can be recovered later as reports
--                               running on top of this data are not business critical and can wait until recovery
--                               process has been completed.
--

--    | name                     | fileid | filegroup   |
--  --+--------------------------+--------+-------------+
--  1 | PieceMealRestoreDB_Data1 | 1      | PRIMARY     |
--  2 | PieceMealRestoreDB_log   | 2      | NULL        |
--  3 | PieceMealRestoreDB_Data2 | 3      | FILEGROUP_A |
--  4 | PieceMealRestoreDB_Data3 | 4      | FILEGROUP_B |
--  5 | PieceMealRestoreDB_Data4 | 5      | FILEGROUP_C |


-- CREATE PARTITION FUNCTION & SCHEME
USE PieceMealRestoreDB
GO
CREATE PARTITION FUNCTION pf_Emp_Joining_date (DATETIME) AS RANGE RIGHT FOR VALUES('2018-01-01 00:00:00', '2020-01-01 00:00:00')
CREATE PARTITION SCHEME ps_Emp_Joining_date AS PARTITION pf_Emp_Joining_date TO ([FILEGROUP_A], [FILEGROUP_B], [FILEGROUP_C])
GO
-- CREATE TABLE
CREATE TABLE dbo.EmployeePartitionedTable
    (
      emp_id INT NOT NULL ,
      emp_JoiningDate DATETIME NOT NULL ,
      Emp_name VARCHAR(50) NOT NULL ,
      CONSTRAINT pk_empid_joiningDate PRIMARY KEY CLUSTERED
        ( emp_id, emp_JoiningDate )
    )
ON  ps_Emp_Joining_date(emp_JoiningDate)
GO
 
-- INSERT TEST DATA
INSERT  INTO dbo.EmployeePartitionedTable
        SELECT  1 ,
                '2017-01-02 00:00:00' ,
                'Peter'
INSERT  INTO dbo.EmployeePartitionedTable
        SELECT  2 ,
                '2018-01-02 00:00:00' ,
                'John'
INSERT  INTO dbo.EmployeePartitionedTable
        SELECT  3 ,
                '2019-01-02 00:00:00' ,
                'Sam'
INSERT  INTO dbo.EmployeePartitionedTable
        SELECT  4 ,
                '2020-01-02 00:00:00' ,
                'Smith'
GO


-- Zie script example_01_Partial_or_Piecemeal_Database_Restore_in_ MS_SQL_Server.sql
-- afmaken obv de tekst

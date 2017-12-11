drop table if exists critical_spares;
CREATE TABLE `critical_spares` (
  `cop_id` varchar(30) DEFAULT 'noid',
  `UNIQUEPARTID` varchar(112) DEFAULT NULL,
  `PartId` int(11) NOT NULL DEFAULT '0',
  `PartNumber` varchar(70) NOT NULL,
  `Description` varchar(252) DEFAULT NULL,
  `SSAISRID` varchar(30),
  `Details` longtext,
  `locationgroup` varchar(30),
  `Location` varchar(30),
  `serialnumber` varchar(41),
  `LastUpdatedDate` varchar(10) DEFAULT NULL,
  `criticallevel` decimal(28,9),
  Primary Key (cop_id)
);
drop table if exists critical_spares_changes;
create table critical_spares_changes (
  `operation` varchar(10) default 'add',
  `cop_id` varchar(30) DEFAULT 'noid',
  `UNIQUEPARTID` varchar(112) DEFAULT NULL,
  `PartId` int(11) NOT NULL DEFAULT '0',
  `PartNumber` varchar(70) NOT NULL,
  `Description` varchar(252) DEFAULT NULL,
  `SSAISRID` varchar(30),
  `Details` longtext,
  `locationgroup` varchar(30),
  `Location` varchar(30),
  `serialnumber` varchar(41),
  `LastUpdatedDate` varchar(10) DEFAULT NULL,
  `criticallevel` decimal(28,9)
);
drop table if exists critical_spares_change_histories;
create table critical_spares_change_histories (
  `change_date` datetime default now(),
  `operation` varchar(10) default 'add',
  `cop_id` varchar(30) DEFAULT 'noid',
  `UNIQUEPARTID` varchar(112) DEFAULT NULL,
  `PartId` int(11) NOT NULL DEFAULT '0',
  `PartNumber` varchar(70) NOT NULL,
  `Description` varchar(252) DEFAULT NULL,
  `SSAISRID` varchar(30),
  `Details` longtext,
  `locationgroup` varchar(30),
  `Location` varchar(30),
  `serialnumber` varchar(41),
  `LastUpdatedDate` varchar(10) DEFAULT NULL,
  `criticallevel` decimal(28,9)
);

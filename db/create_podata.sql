drop table if exists podata_critical_spares;
CREATE TABLE `podata_critical_spares` (
  `cop_id` varchar(30) NOT NULL,
  `podata_id` varchar(37) DEFAULT NULL,
  `num` varchar(25) DEFAULT NULL,
  `polineitem` int(11) DEFAULT NULL,
  `partnum` varchar(70) DEFAULT NULL,
  `serialnum` varchar(41) DEFAULT NULL,
  `ssaisrid` varchar(30) DEFAULT NULL,
  `revision` varchar(15) DEFAULT NULL,
  `description` varchar(256) DEFAULT NULL,
  `qtytofulfill` decimal(28,9) DEFAULT NULL,
  `polineitemnote` longtext DEFAULT NULL,
  `DateReceived` varchar(10) DEFAULT NULL,
  `LastMemoEntry` longtext DEFAULT NULL,
  `Status` varchar(15) DEFAULT NULL,
  `requestingsite` varchar(41) DEFAULT NULL,
  `IsCriticalSpare` varchar(1) NOT NULL DEFAULT 'Y',
  `POCategory` varchar(41) DEFAULT NULL,
  PRIMARY KEY (cop_id)
);
drop table if exists podata_critical_spares_changes;
create table podata_critical_spares_changes (
  `operation` varchar(10) default 'add',
  `cop_id` varchar(30) NOT NULL,
  `podata_id` varchar(37) DEFAULT NULL,
  `num` varchar(25) DEFAULT NULL,
  `polineitem` int(11) DEFAULT NULL,
  `partnum` varchar(70) DEFAULT NULL,
  `serialnum` varchar(41) DEFAULT NULL,
  `ssaisrid` varchar(30) DEFAULT NULL,
  `revision` varchar(15) DEFAULT NULL,
  `description` varchar(256) DEFAULT NULL,
  `qtytofulfill` decimal(28,9) DEFAULT NULL,
  `polineitemnote` longtext DEFAULT NULL,
  `DateReceived` varchar(10) DEFAULT NULL,
  `LastMemoEntry` longtext DEFAULT NULL,
  `Status` varchar(15) DEFAULT NULL,
  `requestingsite` varchar(41) DEFAULT NULL,
  `IsCriticalSpare` varchar(1) NOT NULL DEFAULT 'Y',
  `POCategory` varchar(41) DEFAULT NULL
);
drop table if exists podata_critical_spares_change_histories;
create table podata_critical_spares_change_histories (
  `change_date` datetime default now(),
  `operation` varchar(10) default null,
  `cop_id` varchar(30) NOT NULL,
  `podata_id` varchar(37) DEFAULT NULL,
  `num` varchar(25) DEFAULT NULL,
  `polineitem` int(11) DEFAULT NULL,
  `partnum` varchar(70) DEFAULT NULL,
  `serialnum` varchar(41) DEFAULT NULL,
  `ssaisrid` varchar(30) DEFAULT NULL,
  `revision` varchar(15) DEFAULT NULL,
  `description` varchar(256) DEFAULT NULL,
  `qtytofulfill` decimal(28,9) DEFAULT NULL,
  `polineitemnote` longtext DEFAULT NULL,
  `DateReceived` varchar(10) DEFAULT NULL,
  `LastMemoEntry` longtext DEFAULT NULL,
  `Status` varchar(15) DEFAULT NULL,
  `requestingsite` varchar(41) DEFAULT NULL,
  `IsCriticalSpare` varchar(1) NOT NULL DEFAULT 'Y',
  `POCategory` varchar(41) DEFAULT NULL
);
CREATE or REPLACE VIEW podata_critical_spares_view as
select
(CONCAT(REPLACE(po.num, 'AAL-', ' ') , ':' , poitem.polineitem)) as podata_id,
po.num,
poitem.polineitem,
poitem.partnum,
serial.serialnum,
ssaisrid.info ssaisrid,
poitem.revlevel as revision,
poitem.description,
poitem.qtytofulfill,
REPLACE(REPLACE(poitem.note, CHAR(13), ' '),CHAR(10), ' ') as polineitemnote,
DATE_FORMAT(rcptitem.datereceived,'%m/%d/%Y') as DateReceived,
REPLACE(REPLACE(memo.memo, CHAR(13), ' '), CHAR(10), ' ') as LastMemoEntry,
pos.name as Status,
requestingsite.info as requestingsite,
(case iscritical.info when 1 THEN 'Y' ELSE 'N' end) as IsCriticalSpare,
pocategory.info as POCategory
from bha.po po
inner join bha.poitem poitem on poitem.poid = po.id
inner join bha.poitemtype poitemtype on poitemtype.id = poitem.typeid
left join bha.part part on poitem.partid = part.id
left join bha.customvarchar ssaisrid on ssaisrid.customfieldid = 36 and ssaisrid.recordid = part.id
left join bha.customvarchar failurerpt on failurerpt.customfieldid = 26 and failurerpt.recordid = po.id
left join bha.customset dpas on dpas.customfieldid = 6 and dpas.recordid = po.id
left join bha.pickitem on pickitem.partid = part.id and pickitem.poitemid = poitem.id and pickitem.ordertypeid = 10
left join bha.trackinginfo ti on ti.parttrackingid = 4 and ti.tableid = -1515431424 and ti.recordid = pickitem.id
inner join bha.trackinginfosn serial on serial.trackinginfoid = ti.id and serial.parttrackingid = 4
left join bha.customfield cf on upper(cf.name) LIKE upper('%PO%Contract%Type%') and cf.customfieldtypeid = 7 and cf.tableid = 397076832
left join bha.customset contracttype on contracttype.customfieldid = cf.id and contracttype.recordid = po.id
left join bha.postatus pos on pos.id = po.statusid
left join bha.memo memo on memo.id  =
         (
         SELECT  memo.id
         FROM    bha.memo memo
         WHERE   memo.recordid = po.id AND memo.tableid = 397076832
         ORDER BY memo.id desc
         LIMIT 1
         )
left join bha.customset requestingsite on requestingsite.customfieldid = 29 and requestingsite.recordid = po.id
left join bha.custominteger iscritical on iscritical.customfieldid = 32 and iscritical.recordid = poitem.partid
left join bha.customset pocategory on pocategory.customfieldid = 31 and pocategory.recordid = po.id
left join bha.receiptitem rcptitem on rcptitem.poitemid = poitem.id
where iscritical.info = 1
      and pos.name not in ('Void')
order by po.num, poitem.polineitem, pos.name;

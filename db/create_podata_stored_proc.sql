Drop Procedure if exists GetPodataCriticalSpareDiffs;
DELIMITER //
 CREATE PROCEDURE GetPodataCriticalSpareDiffs()
   BEGIN

    drop table if exists podata_critical_spares_tmp;
    /* Get a current view of what's going on */

    CREATE TEMPORARY TABLE podata_critical_spares_tmp (cop_id varchar(30) default 'noid')
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



    update podata_critical_spares_tmp set DateReceived = 'None' where DateReceived is null;

    truncate podata_critical_spares_changes;
    insert into podata_critical_spares_changes
              select 'add' as operation, a.*
              from podata_critical_spares_tmp a
              where a.podata_id not in
                   (select b.podata_id from podata_critical_spares b);


      insert into podata_critical_spares_changes
              select 'delete' as operation, a.*
              from podata_critical_spares a
              where a.podata_id not in
                    (select b.podata_id from podata_critical_spares_tmp b);

    /* This complicated query brought to you by MySQL because they don't support EXCEPT */

      update podata_critical_spares_tmp a
         set a.cop_id =
             (select b.cop_id from podata_critical_spares b where b.podata_id = a.podata_id);

      insert into podata_critical_spares_changes
          select 'update' as operation, a.*
          from podata_critical_spares_tmp a
          left join podata_critical_spares b
          on
             a.podata_id = b.podata_id and
             a.num = b.num and
             a.polineitem = b.polineitem and
             a.partnum = b.partnum and
             a.serialnum = b.serialnum and
             a.ssaisrid = b.ssaisrid and
             a.revision = b.revision and
             a.description = b.description and
             a.qtytofulfill = b.qtytofulfill and
             a.polineitemnote = b.polineitemnote and
             a.DateReceived = b.DateReceived and
             a.LastMemoEntry = b.LastMemoEntry and
             a.Status = b.Status and
             a.requestingsite = b.requestingsite and
             a.IsCriticalSpare = b.IsCriticalSpare and
             a.POCategory = b.POCategory
          where b.podata_id is null and
                a.podata_id not in (select podata_id from
                podata_critical_spares_changes where operation = 'add');






  END //
DELIMITER ;

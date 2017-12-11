 Drop Procedure if exists GetCriticalSpareDiffs;
DELIMITER //
 CREATE PROCEDURE GetCriticalSpareDiffs()
   BEGIN

    drop table if exists critical_spares_tmp;
    /* Get a current view of what's going on */

    CREATE TEMPORARY TABLE  critical_spares_tmp (cop_id varchar(30) default 'noid')
    Select
    CONCAT(Part.Num , ':' , sn.serialnum) as UNIQUEPARTID,
    Part.Id PartId,
    Part.Num PartNumber,
    Part.Description,
    ssaisrid.info SSAISRID,
    Part.Details,
    lg.name locationgroup,
    loc.Name Location,
    sn.serialnum serialnumber,
    DATE_FORMAT(inventory.eventdate,'%m/%d/%Y') as LastUpdatedDate,
    w.criticallevel criticallevel
    from bha.Part Part
    left join bha.custominteger iscritical on iscritical.customfieldid = 32 and iscritical.recordid = part.id
    left join bha.customvarchar ssaisrid on ssaisrid.customfieldid = 36 and ssaisrid.recordid = part.id
    left join bha.inventorylog inventory on inventory.partid = part.id
    left join bha.Location loc on loc.id = inventory.endlocationid
    left join bha.LocationGroup lg on lg.id = loc.locationgroupid
    left join bha.Tag t on t.partid = part.id and t.locationid = loc.id
    left join bha.Serial ser on ser.tagid = t.id
    left join bha.SerialNum sn on sn.serialid = ser.id
    left join Watch w on w.itemid = part.id
    where iscritical.info = 1 and part.activeflag = 1 and sn.SerialNum != '' and w.sysuserid = 8
    group by part.id, part.num, part.description, part.details, lg.name, loc.name, sn.serialnum, w.criticallevel, ssaisrid.info
    Order By Part.Description, part.num, lg.name, loc.name;



    truncate critical_spares_changes;
    insert into critical_spares_changes
              select 'add' as operation, a.*
              from critical_spares_tmp a
              where a.UNIQUEPARTID not in
                   (select b.UNIQUEPARTID from critical_spares b);


      insert into  critical_spares_changes
              select 'delete' as operation, a.*
              from  critical_spares a
              where a.UNIQUEPARTID not in
                    (select b.UNIQUEPARTID from  critical_spares_tmp b);

    /* This complicated query brought to you by MySQL because they don't support EXCEPT */

      update  critical_spares_tmp a
         set a.cop_id =
             (select b.cop_id from  critical_spares b where b.UNIQUEPARTID = a.UNIQUEPARTID);

      insert into  critical_spares_changes
          select 'update' as operation, a.*
          from  critical_spares_tmp a
          left join  critical_spares b
          on
             a.UNIQUEPARTID = b.UNIQUEPARTID and
             a.PartId = b.PartId and
             a.PartNumber = b.PartNumber and
             a.Description = b.Description and
             a.SSAISRID = b.SSAISRID and
             a.Details = b.Details and
             a.locationgroup = b.locationgroup and
             a.Location = b.Location and
             a.serialnumber = b.serialnumber and
             a.LastUpdatedDate = b.LastUpdatedDate and
             a.criticallevel = b.criticallevel
          where b.UNIQUEPARTID is null and
                a.UNIQUEPARTID not in (select UNIQUEPARTID from  critical_spares_changes where operation = 'add');



  END //
DELIMITER ;

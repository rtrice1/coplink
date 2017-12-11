CREATE VIEW `ssa_po_items` AS
SELECT DISTINCT concat(`bha`.`po`.`id`,':',`bha`.`poitem`.`poLineItem`,':',coalesce(date_format(`rcptitem`.`dateReceived`,'%m%d%y%H%i%s'),'0')) AS `ID`,
                `bha`.`po`.`num` AS `ponum`,
                (CASE
                     WHEN ((`pototal`.`pototalcost` > 3500)
                           AND (`pototal`.`pototalcost` < 750000)) THEN 'Over Micro Less Than TINA'
                     WHEN (`pototal`.`pototalcost` > 750000) THEN 'TINA'
                     ELSE 'Less Than Micro'
                 END) AS `threshold`,
                `bha`.`poitem`.`poLineItem` AS `polineitemnum`,
                `bha`.`poitem`.`partNum` AS `partnum`,
                `sn`.`serialNum` AS `serialnum`,
                `ssaisrid`.`info` AS `ssaisrid`,
                `bha`.`poitem`.`revLevel` AS `revision`,
                `bha`.`poitem`.`description` AS `description`,
                `bha`.`uom`.`code` AS `uom`,
                `bha`.`poitem`.`qtyToFulfill` AS `qtytofulfill`,
                `bha`.`poitem`.`unitCost` AS `unitcost`,
                (`bha`.`poitem`.`qtyToFulfill` * `bha`.`poitem`.`unitCost`) AS `extcost`,
                coalesce(`cust`.`name`,'') AS `customerjob`,
                replace(replace(`bha`.`poitem`.`note`,char(13),' '),char(10),' ') AS `polineitemnote`,
                `bha`.`po`.`dateCreated` AS `datecreated`,
                `bha`.`po`.`dateIssued` AS `dateissued`,
                `bha`.`poitem`.`dateScheduledFulfillment` AS `duedate`,
                `daterequestreceived`.`info` AS `daterequestreceived`,
                `daterfqsent`.`info` AS `daterfqsent`,
                `datequotereceived`.`info` AS `datequotereceived`,
                `datepricesubcomplete`.`info` AS `datepricesubcomplete`,
                `rcptitem`.`dateReceived` AS `datereceived`,
                `bha`.`vendor`.`name` AS `vendor`,
                `bha`.`po`.`buyer` AS `buyer`,
                replace(replace(`bha`.`memo`.`memo`,char(13),' '),char(10),' ') AS `lastmemoentry`,
                coalesce(`contract2`.`info`,`contract`.`info`) AS `contract`,
                `failurerpt`.`info` AS `failurereportnumber`,
                `pos`.`name` AS `status`,
                `requestingsite`.`info` AS `requestingsite`,
                `enddestination`.`info` AS `destinationsite`,
                (CASE `iscritical`.`info`
                     WHEN 1 THEN 'true'
                     ELSE 'false'
                 END) AS `iscriticalspare`,
                `pocategory`.`info` AS `pocategory`,
                (CASE
                     WHEN (`showoncop`.`info` = 1) THEN 'true'
                     ELSE 'false'
                 END) AS `showoncop`,
                `prioritylevel`.`info` AS `prioritylevel`
FROM ((((((((((((((((((((((((((((((((`bha`.`po`
                                     JOIN `bha`.`poitem` on((`bha`.`poitem`.`poId` = `bha`.`po`.`id`)))
                                    JOIN `bha`.`vendor` on((`bha`.`po`.`vendorId` = `bha`.`vendor`.`id`)))
                                   JOIN `bha`.`poitemtype` on((`bha`.`poitemtype`.`id` = `bha`.`poitem`.`typeId`)))
                                  LEFT JOIN `bha`.`uom` on((`bha`.`uom`.`id` = `bha`.`poitem`.`uomId`)))
                                 LEFT JOIN `bha`.`part` on((`bha`.`poitem`.`partId` = `bha`.`part`.`id`)))
                                LEFT JOIN `bha`.`customvarchar` `contract` on(((`contract`.`customFieldId` = 15)
                                                                               AND (`contract`.`recordId` = `bha`.`po`.`id`))))
                               LEFT JOIN `bha`.`customvarchar` `ssaisrid` on(((`ssaisrid`.`customFieldId` = 36)
                                                                              AND (`ssaisrid`.`recordId` = `bha`.`part`.`id`))))
                              LEFT JOIN `bha`.`customset` `contract2` on(((`contract2`.`customFieldId` = 18)
                                                                          AND (`contract2`.`recordId` = `bha`.`po`.`id`))))
                             LEFT JOIN `bha`.`customvarchar` `failurerpt` on(((`failurerpt`.`customFieldId` = 26)
                                                                              AND (`failurerpt`.`recordId` = `bha`.`po`.`id`))))
                            LEFT JOIN `bha`.`customset` `dpas` on(((`dpas`.`customFieldId` = 6)
                                                                   AND (`dpas`.`recordId` = `bha`.`po`.`id`))))
                           LEFT JOIN `bha`.`pickitem` on(((`bha`.`pickitem`.`partId` = `bha`.`part`.`id`)
                                                          AND (`bha`.`pickitem`.`poItemId` = `bha`.`poitem`.`id`)
                                                          AND (`bha`.`pickitem`.`orderTypeId` = 10))))
                          LEFT JOIN `bha`.`serial` `ser` on((`ser`.`tagId` = `bha`.`pickitem`.`tagId`)))
                         LEFT JOIN `bha`.`serialnum` `sn` on((`sn`.`serialId` = `ser`.`id`)))
                        LEFT JOIN `bha`.`trackinginfo` `ti` on(((`ti`.`partTrackingId` = 4)
                                                                AND (`ti`.`tableId` = -(1515431424))
                                                                AND (`ti`.`recordId` = `bha`.`pickitem`.`id`))))
                       LEFT JOIN `bha`.`trackinginfosn` `serial` on(((`serial`.`trackingInfoId` = `ti`.`id`)
                                                                     AND (`serial`.`partTrackingId` = 4))))
                      LEFT JOIN `bha`.`customfield` `cf` on(((upper(`cf`.`name`) LIKE convert(upper('%PO%Contract%Type%') USING utf8))
                                                             AND (`cf`.`customFieldTypeId` = 7)
                                                             AND (`cf`.`tableId` = 397076832))))
                     LEFT JOIN `bha`.`customset` `contracttype` on(((`contracttype`.`customFieldId` = `cf`.`id`)
                                                                    AND (`contracttype`.`recordId` = `bha`.`po`.`id`))))
                    LEFT JOIN `bha`.`customer` `cust` on((`cust`.`id` = `bha`.`poitem`.`customerId`)))
                   LEFT JOIN `bha`.`postatus` `pos` on((`pos`.`id` = `bha`.`po`.`statusId`)))
                  LEFT JOIN `bha`.`memo` on((`bha`.`memo`.`id` =
                                               (SELECT `bha`.`memo`.`id`
                                                FROM `bha`.`memo`
                                                WHERE ((`bha`.`memo`.`recordId` = `bha`.`po`.`id`)
                                                       AND (`bha`.`memo`.`tableId` = 397076832))
                                                ORDER BY `bha`.`memo`.`id` DESC
                                                LIMIT 1))))
                 LEFT JOIN `bha`.`customset` `requestingsite` on(((`requestingsite`.`customFieldId` = 29)
                                                                  AND (`requestingsite`.`recordId` = `bha`.`po`.`id`))))
                LEFT JOIN `bha`.`custominteger` `iscritical` on(((`iscritical`.`customFieldId` = 32)
                                                                 AND (`iscritical`.`recordId` = `bha`.`poitem`.`partId`))))
               LEFT JOIN `bha`.`customset` `pocategory` on(((`pocategory`.`customFieldId` = 31)
                                                            AND (`pocategory`.`recordId` = `bha`.`po`.`id`))))
              LEFT JOIN `bha`.`customtimestamp` `daterequestreceived` on(((`daterequestreceived`.`customFieldId` = 44)
                                                                          AND (`daterequestreceived`.`recordId` = `bha`.`po`.`id`))))
             LEFT JOIN `bha`.`customtimestamp` `daterfqsent` on(((`daterfqsent`.`customFieldId` = 42)
                                                                 AND (`daterfqsent`.`recordId` = `bha`.`po`.`id`))))
            LEFT JOIN `bha`.`customtimestamp` `datequotereceived` on(((`datequotereceived`.`customFieldId` = 43)
                                                                      AND (`datequotereceived`.`recordId` = `bha`.`po`.`id`))))
           LEFT JOIN `bha`.`customtimestamp` `datepricesubcomplete` on(((`datepricesubcomplete`.`customFieldId` = 45)
                                                                        AND (`datepricesubcomplete`.`recordId` = `bha`.`po`.`id`))))
          LEFT JOIN
            (SELECT `bha`.`po`.`id` AS `id`,
                    max(`poi`.`poLineItem`) AS `totalpolineitem`,
                    sum(`poi`.`totalCost`) AS `pototalcost`
             FROM (`bha`.`po`
                   LEFT JOIN `bha`.`poitem` `poi` on((`poi`.`poId` = `bha`.`po`.`id`)))
             GROUP BY `bha`.`po`.`id`) `pototal` on((`pototal`.`id` = `bha`.`po`.`id`)))
         LEFT JOIN `bha`.`custominteger` `showoncop` on(((`showoncop`.`customFieldId` = 47)
                                                         AND (`showoncop`.`recordId` = `bha`.`po`.`id`))))
        LEFT JOIN `bha`.`receiptitem` `rcptitem` on((`rcptitem`.`poItemId` = `bha`.`poitem`.`id`)))
       LEFT JOIN `bha`.`customset` `prioritylevel` on(((`prioritylevel`.`customFieldId` = 30)
                                                       AND (`prioritylevel`.`recordId` = `bha`.`po`.`id`))))
      LEFT JOIN `bha`.`customset` `enddestination` on(((`enddestination`.`customFieldId` = 38)
                                                       AND (`enddestination`.`recordId` = `bha`.`po`.`id`))))
WHERE ((`pos`.`name` NOT IN ('Void',
                             'Bid Request'))
       AND (not((`bha`.`poitem`.`partNum` LIKE '%svc%')))
       AND (not((`bha`.`poitem`.`partNum` LIKE '%tax%')))
       AND (not((`bha`.`vendor`.`name` LIKE '%ads, inc%'))));

 drop table if exists podatawarehouse;
 set group_concat_max_len = 74056;
 create table podatawarehouse as 
select
        (CONCAT(po.id, ':', poitem.polineitem, ':', coalesce(receiptitem.datereceived, 'n/a'))) as ID,
	            po.num as ponum,

		        case 
				      when pototal.pototalcost > 3500 and  pototal.pototalcost < 750000 then 'Over Micro Less Than TINA'
					          when pototal.pototalcost > 750000 then 'TINA'
							      else 'Less Than Micro'
								        end as Threshold,
									            poitem.polineitem as polineitemnum,
										        poitem.partnum,
											            sn.serialnum,
												        ssaisrid.info ssaisrid,
													                poitem.revlevel as revision,
															            poitem.description,
																        uom.code as UoM,
																	            poitem.qtytofulfill,
																		        poitem.unitcost,
																			                poitem.qtytofulfill * poitem.unitcost as extcost,
																					            COALESCE(cust.name, '') as customerjob,
																						        REPLACE(REPLACE(poitem.note, CHAR(13), ' '), CHAR(10), ' ') as polineitemnote,
																							            po.datecreated as DateCreated,
																								        po.dateissued as DateIssued,
																									                poitem.datescheduledfulfillment as DueDate,
																											            daterequestreceived.info as DateRequestReceived,
																												        daterfqsent.info as DateRFQSent,
																													            datequotereceived.info as DateQuoteReceived,
																														        datepricesubcomplete.info as DatePriceSubComplete,
																															                receiptitem.datereceived as DateReceived,
																																	                receipts.dates as AllDatesReceived,
																																			                receipts.qtyreceivedtodate as QtyReceivedToDate,
																																					            vendor.name as vendor,
																																						        po.buyer,
																																							            REPLACE(REPLACE(memo.memo, CHAR(13), ' '), CHAR(10), ' ') as LastMemoEntry,
																																								        coalesce(contract2.info, contract.info) as contract,
																																									                failurerpt.info as failurereportnumber,
																																											            pos.name as Status,
																																												        requestingsite.info as requestingsite,
																																													            enddestination.info as destinationsite,
																																														        (case iscritical.info when 1 THEN 'true' ELSE 'false' end) as IsCriticalSpare,
																																															                pocategory.info as POCategory,
																																																	            case when showoncop.info = 1 then 'true' else 'false' end as ShowOnCop,
																																																			            prioritylevel.info as PriorityLevel,
																																																				            warrantyinfo.info as warrantyinfo,
																																																					          
																																																					(case 
																																																					when TRIM(TRAILING '.' from TRIM(TRAILING '0' from poitem.qtyToFulfill)) > TRIM(TRAILING '.' from TRIM(TRAILING '0' from poitem.qtyFulfilled)) THEN 'false'
																																																					ELSE 'true' end) as LineUF, 

																																																						    subq.unfulfill as totalpolines,

																																																						    (case 
																																																							    WHEN subq1.unfulfill1 > 0 or subq1.unfulfill1 != '' THEN CONCAT(TRUNCATE(TRIM(TRAILING '.' from TRIM(TRAILING '0' from (1-(subq1.unfulfill1 / subq.totalpolines))*100)),0), '%')
																																																								    ELSE '' end)
																																																									        as POFill

																																																										                from bha.po

																																																												            inner join bha.poitem on poitem.poid = po.id
																																																													        inner join bha.vendor on po.vendorid = vendor.id
																																																														            inner join bha.poitemtype on poitemtype.id = poitem.typeid
																																																															        left join bha.uom on uom.id = poitem.uomid
																																																																                left join bha.part on poitem.partid = part.id
																																																																		            left join bha.customvarchar contract on contract.customfieldid = 15 and contract.recordid = po.id
																																																																			        left join bha.customvarchar ssaisrid on ssaisrid.customfieldid = 36 and ssaisrid.recordid = part.id
																																																																				            left join bha.customset contract2 on contract2.customfieldid = 18 and contract2.recordid = po.id
																																																																					        left join bha.customvarchar failurerpt on failurerpt.customfieldid = 26 and failurerpt.recordid = po.id
																																																																						                left join bha.customset dpas on dpas.customfieldid = 6 and dpas.recordid = po.id
																																																																								            left join bha.pickitem on pickitem.partid = part.id and pickitem.poitemid = poitem.id and pickitem.ordertypeid = 10
																																																																									        left join bha.Serial ser on ser.tagid = pickitem.tagid
																																																																										            left join bha.SerialNum sn on sn.serialid = ser.id
																																																																											        left join bha.trackinginfo ti on ti.parttrackingid = 4 and ti.tableid = -1515431424 and ti.recordid = pickitem.id
																																																																												                left join bha.trackinginfosn serial on serial.trackinginfoid = ti.id and serial.parttrackingid = 4
																																																																														            left join bha.customfield cf on upper(cf.name)LIKE upper('%PO%Contract%Type%') and cf.customfieldtypeid = 7 and cf.tableid = 397076832
																																																																															        left join bha.customset contracttype on contracttype.customfieldid = cf.id and contracttype.recordid = po.id
																																																																																            left join bha.customer cust on cust.id = poitem.customerid
																																																																																	        left join bha.postatus pos on pos.id = po.statusid
																																																																																		        left join bha.memo on memo.id =
																																																																																			                (SELECT  memo.id
																																																																																						            FROM    bha.memo
																																																																																							        WHERE   memo.recordid = po.id AND memo.tableid = 397076832
																																																																																								            ORDER BY memo.id desc
																																																																																									                LIMIT 1
																																																																																											        )

																																																																																												            left join bha.customset requestingsite on requestingsite.customfieldid = 29 and requestingsite.recordid = po.id
																																																																																													        left join bha.custominteger iscritical on iscritical.customfieldid = 32 and iscritical.recordid = poitem.partid
																																																																																														                left join bha.customset pocategory on pocategory.customfieldid = 31 and pocategory.recordid = po.id
																																																																																																            left join bha.customtimestamp daterequestreceived on daterequestreceived.customfieldid = 44 and daterequestreceived.recordid = po.id
																																																																																																	        left join bha.customtimestamp daterfqsent on daterfqsent.customfieldid = 42 and daterfqsent.recordid = po.id
																																																																																																		            left join bha.customtimestamp datequotereceived on datequotereceived.customfieldid = 43 and datequotereceived.recordid = po.id
																																																																																																			        left join bha.customtimestamp datepricesubcomplete on datepricesubcomplete.customfieldid = 45 and datepricesubcomplete.recordid = po.id
																																																																																																				                left join bha.custominteger showoncop on showoncop.customfieldid = 47 and showoncop.recordid = po.id
																																																																																																						            -- left join bha.receiptitem rcptitem on rcptitem.poitemid = poitem.id
																																																																																																							            left join bha.customset prioritylevel on prioritylevel.customfieldid = 30 and prioritylevel.recordid = po.id
																																																																																																								            left join bha.customset enddestination on enddestination.customfieldid = 38 and enddestination.recordid = po.id
																																																																																																									        left join bha.customvarchar warrantyinfo on warrantyinfo.customfieldid = 80 and warrantyinfo.recordid = po.id


																																																																																																										left join
																																																																																																										        (select
																																																																																																												        po.id,
																																																																																																													            max(poi.polineitem) as totalpolineitem,
																																																																																																														                Sum(poi.totalcost) as pototalcost
																																																																																																																from bha.po
																																																																																																																        left join bha.poitem poi on poi.poid = po.id
																																																																																																																	            group by po.id)as pototal 
																																																																																																																	    on pototal.id = po.id
																																																																																																																	            
																																																																																																																	    
																																																																																																																	    left join 
																																																																																																																	             (select 
																																																																																																																			             poi.poid,
																																																																																																																				                 max(poi.polineitem) as totalpolines,
																																																																																																																						         count(poi.qtyfulfilled) as unfulfill        
																																																																																																																							    from bha.po 
																																																																																																																							             left join bha.poitem poi on poi.poid = po.id 
																																																																																																																								         group by poi.poid
																																																																																																																									             order by totalpolines desc
																																																																																																																										                 ) as subq 
																																																																																																																												on subq.poid = po.id
																																																																																																																												      
																																																																																																																												   
																																																																																																																												left join 
																																																																																																																												        (select 
																																																																																																																														        poi1.poid,
																																																																																																																															            count(poi1.qtyfulfilled) as unfulfill1 
																																																																																																																																        from bha.po 
																																																																																																																																	                left join bha.poitem poi1 on poi1.poid = po.id 
																																																																																																																																			        where 
																																																																																																																																				            poi1.qtyFulfilled  < poi1.qtyToFulfill
																																																																																																																																					        group by poi1.poid
																																																																																																																																						            ) as subq1 
																																																																																																																																							        on subq1.poid = po.id          

																																																																																																																																								left join 
																																																																																																																																								    (select 
																																																																																																																																									        poitemid,
																																																																																																																																										        GROUP_CONCAT(
																																																																																																																																												        CONCAT('Qty ', FORMAT(qty,0), ' on ', DATE_FORMAT(dateReceived,'%m/%d/%Y'))
																																																																																																																																													        SEPARATOR ' & ' ) as dates,
																																																																																																																																													        FORMAT(SUM(qty), 0) as qtyreceivedtodate
																																																																																																																																														        from bha.receiptitem
																																																																																																																																															        
																																																																																																																																															        where poitemid is not null 
																																																																																																																																																            and dateReceived is not null
																																																																																																																																																	        group by receiptitem.poitemid
																																																																																																																																																		        
																																																																																																																																																		        )    
																																																																																																																																																			        as receipts
																																																																																																																																																				        
																																																																																																																																																				        on receipts.poitemid = poitem.id
																																																																																																																																																					        
																																																																																																																																																					left join bha.receiptitem on receiptitem.id =
																																																																																																																																																					        (SELECT  bha.receiptitem.id
																																																																																																																																																							    FROM    bha.receiptitem
																																																																																																																																																							WHERE   bha.receiptitem.poitemid = poitem.id 
																																																																																																																																																							    ORDER BY receiptitem.id desc
																																																																																																																																																							        LIMIT 1
																																																																																																																																																								        )
																																																																																																																																																									 
																																																																																																																																																									    

																																																																																																																																																									                where pos.name not in ('Void', 'Bid Request') and poitem.partnum not like '%svc%' and poitem.partnum not like '%tax%' and vendor.name not like '%ads, inc%'
																																																																																																																																																											            order by poitem.datescheduledfulfillment desc, prioritylevel.info, po.num, poitem.polineitem, pos.name

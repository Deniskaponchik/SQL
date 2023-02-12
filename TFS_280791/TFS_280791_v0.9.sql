USE BPMonline7_14880;

select distinct Null[ID],'0'[ID_Type],Null[Bunch_id]
	,circuitFULL.StringValue AS Circuit_FULL
	/*,case 
       when sii.Name = 'New Trgroup' then o1.value
       when sii.name = 'New TRGroup INT' then o2.value
     end as [circuit_id] */
	, circuit.value as [circuit_id]
	, NULL[equipment_type], NULL[mac],NULL[vpi],NULL[vci]
	, Switch.StringValue AS switch_id
	, Bunch.Value AS bunch_type
	/*, CONCAT (region.StringValue, ';', traffic.StringValue, ';', operator.StringValue, ';', protocol.StringValue, ';', DestTrunkGroup.StringValue) description*/
	, CONCAT (
		(case 
			when sii.Name = 'New Trgroup' then region.StringValue
			when sii.name = 'New TRGroup INT' then regionINT.StringValue
         end), ';', 
		 traffic.StringValue, ';', operator.StringValue, ';', protocol.StringValue, ';',	 
		 (case 
			when sii.Name = 'New Trgroup' then destination.StringValue
			when sii.name = 'New TRGroup INT' then destinationINT.StringValue
         end)		 
		 ) description
	,c.RegisteredOn AS begin_time
	,NULL[end_time]
	,(case 
			when sii.Name = 'New Trgroup' then region.StringValue
			when sii.name = 'New TRGroup INT' then regionINT.StringValue
       end) region_id
	,NULL[upload_time],NULL[file_id],c.Number as sr
	,'https://bpm.tele2.ru/0/Nui/ViewModule.aspx#CardModuleV2/CasePage/edit/'+cast(c.Id as nvarchar(64))

from [case] c
left join ServiceItem si on si.Id=c.UsrSystemId
left join ServiceItem sii on sii.Id=c.ServiceItemId
left join CaseStatus cs on cs.Id=c.StatusId
outer apply (
              select StringValue from UsrSpecificationInCase 
			  where UsrCaseId = c.Id 
			  and SpecificationId = '6F6A28CF-CA6A-46B0-9FD5-0B8C831B55F0' /* New TRGroup INT */
) as destinationINT
outer apply (
              select StringValue from UsrSpecificationInCase 
			  where UsrCaseId = c.Id 
			  and SpecificationId = '2D607A92-2276-40C8-8E22-E429AF1FBCF8' /* New TRGroup */
) as destination
outer apply (
              select StringValue from UsrSpecificationInCase 
			  where UsrCaseId = c.Id 
			  and SpecificationId = '308F943C-2641-4838-A73A-BC1092CA67B5'
) as protocol
outer apply (
              select StringValue from UsrSpecificationInCase 
			  where UsrCaseId = c.Id 
			  and SpecificationId = 'CFD1AAAE-5EAC-4798-A002-D1EF490F38D4'
) as operator
outer apply (
              select StringValue from UsrSpecificationInCase 
			  where UsrCaseId = c.Id 
			  and SpecificationId = '66EC25BC-6175-4A27-A68F-BEEDF88855BF'
) as traffic
outer apply (
              select StringValue from UsrSpecificationInCase 
			  where UsrCaseId = c.Id 
			  and SpecificationId = '9BF1467F-C542-4EF0-BDEB-BC0EE2592403' /* New TRGroup INT */
) as regionINT
outer apply (
              select StringValue from UsrSpecificationInCase 
			  where UsrCaseId = c.Id 
			  and SpecificationId = '0E215349-E971-4706-92CF-01F689B23CD0' /* New TRGroup */
) as region
outer apply (
              select StringValue from UsrSpecificationInCase 
			  where UsrCaseId = c.Id 
			  and SpecificationId = '37EE5CE2-1D29-41C9-96BB-64B03B80B90D'
			  /*and SpecificationId IN (
				'37EE5CE2-1D29-41C9-96BB-64B03B80B90D'
				, '49F2669E-6321-44F5-90BA-8755929BAF3A'
			  )*/
) as circuitFULL
outer apply (
              select StringValue from UsrSpecificationInCase 
			  where UsrCaseId = c.Id 
			  and SpecificationId = 'C0A6432E-3A5B-49B0-B561-43231A334269'
) as Switch
outer apply (
       select Value from string_split(
	   (
                REPLACE(
                      REPLACE(
                           REPLACE(
                                (
                                  select StringValue from UsrSpecificationInCase 
								  Where UsrCaseId = c.Id 
								  and SpecificationId = 'D9C4FE91-E6B6-4459-9561-C830F6C75D5B'
                                  ), 'входящий','0'
                              ), 'исходящий' , '1' 
                       ), 'двунаправленные' , '3'
                )
		),',')
) as Bunch
outer apply (
       select Value from string_split(
	   (
	        REPLACE(
                REPLACE(
				   REPLACE(
                      REPLACE(
                           REPLACE(
                                  REPLACE(
                                     REPLACE(
                                          REPLACE(
                                               REPLACE(
                                                      REPLACE(
                                                         REPLACE(
                                                                   (
                                                                        select StringValue from UsrSpecificationInCase 
																		where UsrCaseId = c.Id 
																		and SpecificationId = '37EE5CE2-1D29-41C9-96BB-64B03B80B90D'
                                                                ), ', ',','
                                                             ), '\' , ',' 
                                                      ), ';' , ','
                                                 ), '-' , ','
                                               ), ' ' , ','
                                        ), ':' , ','
                                  ), '/', ','
                           ), '.', ','
                      ), '|', ','
				    ), '&', ','
			      ), char(10), ','
               )
		),',')

) as circuit
/*outer apply (
       select Value from string_split((
                REPLACE(
                      REPLACE(
                           REPLACE(
                                  REPLACE(
                                     REPLACE(
                                          REPLACE(
                                               REPLACE(
                                                      REPLACE(
                                                         REPLACE(
                                                                   (
                                                                          select StringValue from UsrSpecificationInCase 
																		  where UsrCaseId = c.Id 
																		  and SpecificationId = '37EE5CE2-1D29-41C9-96BB-64B03B80B90D'
                                                                ), ', ',','
                                                             ), '\' , ',' 
                                                      ), ';' , ','
                                                 ), '-' , ','
                                               ), ' ' , ','
                                        ), ':' , ','
                                  ), '/', ','
                           ), '.', ','
                      ), ' |', ','
                )),',')

) as o2 */
where si.Name in ('IC')
and sii.Name in ('New Trgroup', 'New TRGroup INT')
and cs.Name in ('Решено','Закрыто')

/*ORDER BY begin_time DESC*/


and c.SolutionProvidedOn between dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2)))) 
and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))


/*
and c.Number = 'SR04883583'
and c.Number IN ('SR04377502','SR04223621')
*/

and circuit.value <> ''









/* Константин
select 
	c.Number
	, usic.StringValue
from [case] c
left join ServiceItem si on si.Id=c.UsrSystemId
left join ServiceItem sii on sii.Id=c.ServiceItemId
left join CaseStatus cs on cs.Id=c.StatusId
left join UsrSpecificationInCase usic on usic.UsrCaseId = c.id

where si.Name in ('IC')
and sii.Name in ('New Trgroup', 'New TRGroup INT')
and cs.Name in ('Решено','Закрыто')
and c.SolutionProvidedOn between dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2)))) 
and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))
*/




/*Для поиска id в Перечне параметров*/
/*
select 
	c.Number
	, usic.StringValue
	, us.id

from [case] c

/*left join ServiceItem si on si.Id=c.UsrSystemId
left join ServiceItem sii on sii.Id=c.ServiceItemId*/
/*left join CaseStatus cs on cs.Id=c.StatusId*/

left join UsrSpecificationInCase usic on usic.UsrCaseId = c.id
left join UsrSpecification us on us.id = usic.SpecificationId

where 
/*si.Name in ('IC')
and sii.Name in ('New Trgroup', 'New TRGroup INT')*/
ServiceItemId IN (
	'3F47ABFD-FEA4-41C7-9CBE-ECBB977E83A8'   /*New Trgroup*/
	, '14D426EF-D493-475D-A157-FDC19EC1B04D' /*New TRGroup INT*/
	)

/*and cs.Name in ('Решено','Закрыто')*/
and StatusId IN (
	'3E7F420C-F46B-1410-FC9A-0050BA5D6C38' /*Закрыто*/
	, 'AE7F411E-F46B-1410-009B-0050BA5D6C38' /*Решено*/
	)

/*and Number = 'SR05313700'*/
and Number IN ('SR04974275','SR05018803')


and c.SolutionProvidedOn between dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2)))) 
and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))
*/


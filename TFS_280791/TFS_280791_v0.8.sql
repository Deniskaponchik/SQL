USE BPMonline7_14880;

WITH
/* ������� ������ ��� ������ ���������� �� ��������� ������ */
NewCase (sr, srid, begin_time, UsrParametersSet, CircuitFULL, circuit_id, switch_id, traffic, operator, protocol, DestTrunkGroup, BunchText, bunch_type, region_id) AS (
SELECT
	/* sr - ������������ ����� ��������� (�����, ������������) */
	Number,
	id,
	/* begin_time - ���� ����������� ��������� (���) */
	RegisteredOn,
	UsrParametersSet,
	/*
	(SELECT stringvalue FROM UsrSpecificationInCase where usrcase.id = c.id and SpecificationID = ''),
	sic.*, ss.*
	*/


	/* circuit_id - �� ����������. <������������ ��������� �����>. 
	���� ������������ � ������ ���� ��������� - �� ����� � ������ ����� ��������� �� ������� ���������. 
	��� �������� ����� ����������� ����� �������. 
	� ������ ������� �� ��������� - ���������� �������� (�� ���� ������ "������������ ������") */
	(
	   REPLACE(
	      REPLACE(
		     (
		         SELECT VALUE
	             FROM STRING_SPLIT (UsrParametersSet, char(10))
	             WHERE value LIKE '5.������������ ��������� �����:%' OR value LIKE '60.������������ ��������� �����%'
	          ), '5.������������ ��������� �����: ' , ''
		  ), '60.������������ ��������� �����: ', ''
	   )
	) CircuitFULL,
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
									replace(
				   		               (
											  SELECT VALUE
											  FROM STRING_SPLIT (UsrParametersSet, char(10))
											  WHERE value LIKE '60.������������ ��������� �����%' OR value LIKE '5.������������ ��������� �����:%'
										   ), '60.������������ ��������� �����: ', ''
									   ), '5.������������ ��������� �����: ', ''
								   ), ', ',','
							    ), '\' , ','	
						     ), ';' , ','
						  ), '-' , ','
						), ' ' , ','
	                 ), ':' , ','
				), '/', ','
			 ), '.', ','
		  ), '|', ','
		  /*), '[�-��-�]', ''*/
	   )
	) circuit_id,
	/* ����� ����� ��������:	= + @ #    	*/


	
	(   /* switch_id - �� ����������. <����� �����������> */
	   REPLACE(
	      REPLACE(
		     (
		         SELECT VALUE
	             FROM STRING_SPLIT (UsrParametersSet, char(10))
	             WHERE value LIKE '3.����� �����������:%' OR value LIKE '40.����� �����������:%'
	          ), '3.����� �����������: ' , ''
		  ), '40.����� �����������: ', ''
	   )
	) switch_id,


	/* description - ��� �� ���������� (� ��� ����� ������ - ���� �� ���. ����������). ���� ����������� ��� ���� "������". � ����� ������ ��� ���������� �����, � ������ �������������. � ���� ������, ���� �������� ��������� - ������� ��� ����� ','. ��������� ����������� ��� ���������� ����:
       <������/�>, <��� �������>,  <�������� �����>, <�������� ����������>, <���������� ��������� �����> */
	/* ���� ��� ������ ��� ����������� ����, � ����� � �������� ������� �������� STRING_AGG */
	( /* ��� ������� */
	   REPLACE(
	      REPLACE(
		     (
		         SELECT VALUE
	             FROM STRING_SPLIT (UsrParametersSet, char(10))
	             WHERE value LIKE '2.��� �������:%' OR value LIKE '45.��� �������:%'
	          ), '2.��� �������: ' , ''
		  ), '45.��� �������: ', ''
	   )
	) traffic,
	( /* �������� ����� */
	 /*  REPLACE(*/
	      REPLACE(
		     (
		         SELECT VALUE
	             FROM STRING_SPLIT (UsrParametersSet, char(10))
	             WHERE value LIKE '51.�������� �����:%' /*OR value LIKE '45.��� �������:%'*/
	          ), '51.�������� �����: ' , ''
		 /* ), '45.��� �������: ', ''*/
	   )
	) operator,
	/* �������� ���������� */
	( 
	   REPLACE(
	      REPLACE(
		     (
		         SELECT VALUE
	             FROM STRING_SPLIT (UsrParametersSet, char(10))
	             WHERE value LIKE '91.�������� ����������:%' OR value LIKE '92.�������� ����������:%'
	          ), '91.�������� ����������: ' , ''
		  ), '92.�������� ����������: ', ''
	   )
	) protocol,
	( /* ���������� ��������� ����� */
	   REPLACE(
	      REPLACE(
		     (
		         SELECT VALUE
	             FROM STRING_SPLIT (UsrParametersSet, char(10))
	             WHERE value LIKE '90.���������� ��������� �����:%' OR value LIKE '7.���������� ��������� �����:%'
	          ), '90.���������� ��������� �����: ' , ''
		  ), '7.���������� ��������� �����: ', ''
	   )
	) DestTrunkGroup,



	/* bunch_type - �� ����������. ����������� ��������. ��� ��������� �� ����������� ��������� � �������� �������������, ���:
		0 � ��������		1 � ���������			3 � ���������������
	    ��������, ���� ������� "��������;���������������" � ���� �������� "0,3" */
	(
	   SELECT right(rtrim(VALUE),charindex(' ',reverse(rtrim(VALUE))+' ')-1)
	   from (
		     SELECT VALUE
	         FROM STRING_SPLIT (UsrParametersSet, char(10))
	         WHERE value LIKE '6.��������������%' OR value LIKE '80.��������������%'
	      ) Bunch
	) BunchText,
	(
	   REPLACE(
	      REPLACE(
		     REPLACE(
			    REPLACE(
				   	(
						SELECT right(rtrim(VALUE),charindex(' ',reverse(rtrim(VALUE))+' ')-1)
					    from (
		                   SELECT VALUE
	                       FROM STRING_SPLIT (UsrParametersSet, char(10))
	                       WHERE value LIKE '6.��������������%' OR value LIKE '80.��������������%'
					    ) Bun
	                 ), ';' , ','
				), '���������������', '3'
			 ), '���������', '1'
		  ), '��������', '0'
	   )
	) bunch_type,




	/* ������ */
	/* region_id - ������ (���� �� ��� ����������. ���� ������� ��������� �������� - ����� ,) */
	/* � �������� �������� � � ����� ���� ���������. ������ � ������������ ��������� ��������
	(
	   REPLACE(
	      (
	      SELECT right(rtrim(VALUE),charindex(' ',reverse(rtrim(VALUE))+' ')-1)
	      from (
		        SELECT VALUE
	            FROM STRING_SPLIT (UsrParametersSet, char(10))
	            WHERE value LIKE '10.������%' OR value LIKE '1.������%'
	            ) Reg
	      ), ';' , ','
       )
	) region_id, */
	(
	   REPLACE(
		     REPLACE(
			    REPLACE(
				   	(
		                   SELECT VALUE
	                       FROM STRING_SPLIT (UsrParametersSet, char(10))
	                       WHERE value LIKE '10.������:%' OR value LIKE '1.������:%'
	                 ), ';' , ','
				), '10.������: ', ''
			 ), '1.������: ', ''
	   )
	) region_id

	/*,SolutionDate*/

FROM [Case] AS c

/*
LEFT JOIN UsrSpecificationInCase sis on sic.UsrCaseId = c.id
LEFT JOIN UsrSpecification ss on ss.id = sic.SpecificationId
*/

WHERE 
	/* ������ ����� ("New Trgroup" ��� "New TRGroup INT" 
	ServiceItemId IN (
		SELECT id
		FROM ServiceItem
		WHERE Name IN (
			'New Trgroup'
		  , 'New TRGroup INT'
		  )

	) AND  */

	/* ��������� ����� (������ ��� ������� 
	StatusId IN (
		SELECT id
		FROM CaseStatus
		WHERE Name IN (
			'������'
		  , '�������'
		  )
	) */

	
	/*ORDER BY SolutionDate DESC*/
	/*ORDER BY RegisteredOn DESC*/
	Number = 'SR04826173'

	/* ����������� ���������� ����� "���������� �����" */
	/*(  ���� 
		SolutionProvidedOn > datefromparts(year(getdate()), month(getdate()), 1) and
		SolutionProvidedOn <= dateadd(month, 1, datefromparts(year(getdate()), month(getdate()), 1))
	) */
	/* StackOverflow */
	/*(   
		SolutionProvidedOn < datefromparts(year(getdate()), month(getdate()), 1) and
		SolutionProvidedOn >= dateadd(month, 1, datefromparts(year(getdate()), month(getdate()), 1))
	) */
	/*(SolutionProvidedOn between cast('01-01-2022' as datetime2) and cast('02-01-2022' as datetime2))*/
	/* ����������
	(
	SolutionProvidedOn between dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))
	and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))
	)*/

)
	  

SELECT
	/* id - ������ ���� */
	Null AS id,
	/* id_type - �������� "0" */
	0 AS id_type,
	/* bunch_id - ������ ���� */
	Null AS bunch_id,
	/* circuit_id - �� ����������. <������������ ��������� �����>. 
	���� ������������ � ������ ���� ��������� - �� ����� � ������ ����� ��������� �� ������� ���������. 
	��� �������� ����� ����������� ����� �������. 
	� ������ ������� �� ��������� - ���������� �������� (�� ���� ������ "������������ ������") */
	CircuitFULL,
	value circuit_id,
    /* equipment_type - ������ ���� */
	Null AS equipment_type,
    /* mac - ������ ���� */
	Null AS mac,
    /* vpi - ������ ���� */
	Null AS vpi,
    /* vci - ������ ���� */
	Null AS vci,
    /* switch_id - �� ����������. <����� �����������> */
	switch_id,
	/* bunch_type - �� ����������. ����������� ��������. ��� ��������� �� ����������� ��������� � �������� �������������, ���:
		0 � ��������		1 � ���������			3 � ���������������
	    ��������, ���� ������� "��������;���������������" � ���� �������� "0,3" */
	bunch_type,

	/* description - ��� �� ���������� (� ��� ����� ������ - ���� �� ���. ����������). ���� ����������� ��� ���� "������". � ����� ������ ��� ���������� �����, � ������ �������������. � ���� ������, ���� �������� ��������� - ������� ��� ����� ','. ��������� ����������� ��� ���������� ����:
      <������/�>, <��� �������>,  <�������� �����>, <�������� ����������>, <���������� ��������� �����> */	
	/*STRING_AGG(
	   (
	      SELECT region_id FROM NewCase
	      UNION
		  SELECT traffic FROM NewCase
	      UNION
		  SELECT operator FROM NewCase
	      UNION
		  SELECT DestTrunkGroup FROM NewCase
	   ), ','
	) description,*/
	CONCAT (region_id, ',', traffic, ',', operator, ',', protocol, ',', DestTrunkGroup) description,


	/* begin_time - ���� ����������� ��������� (���) */
	begin_time,
	/* end_time - ������ ���� */
	Null AS end_time,
	/* region_id - ������ (���� �� ��� ����������. ���� ������� ��������� �������� - ����� ,) */
	region_id ,
	/* upload_time - ������ ���� */ 
	Null AS upload_time,
    /* file_id - ������ ���� */
	Null AS file_id,
	/* sr - ������������ ����� ��������� (�����, ������������) */
	sr,
	'https://bpm.tele2.ru/0/Nui/ViewModule.aspx#CardModuleV2/CasePage/edit/'+cast(srid as nvarchar(64))


FROM NewCase
cross apply
STRING_SPLIT (circuit_id, ',')

/*WHERE circuit_id NOT LIKE '%[�-��-�]%' AND circuit_id NOT LIKE ' '*/

/*ORDER BY begin_time DESC*/







USE BPMonline7_14880;
select distinct Null[ID],'0'[ID_Type],Null[Bunch_id]
	,o3.StringValue AS Circuit_FULL
	/*,case 
       when sii.Name = 'New Trgroup' then o1.value
       when sii.name = 'New TRGroup INT' then o2.value
     end as [circuit_id] */
	, o1.value as [circuit_id]
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
	,c.Number as sr
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
) as o3
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
                                  ), '��������','0'
                              ), '���������' , '1' 
                       ), '���������������' , '3'
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
                )
		),',')

) as o1
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
and cs.Name in ('������','�������')
/*
and c.SolutionProvidedOn between dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2)))) 
and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))
*/
and c.Number IN ('SR04377502','SR04223621')











/* ����������
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
and cs.Name in ('������','�������')
and c.SolutionProvidedOn between dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2)))) 
and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))
*/




/*��� ������ id � ������� ����������*/
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

/*and cs.Name in ('������','�������')*/
and StatusId IN (
	'3E7F420C-F46B-1410-FC9A-0050BA5D6C38' /*�������*/
	, 'AE7F411E-F46B-1410-009B-0050BA5D6C38' /*������*/
	)

/*and Number = 'SR05313700'*/
and Number IN ('SR04974275','SR05018803')


and c.SolutionProvidedOn between dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2)))) 
and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))



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







/* ����������
select c.Number from [case] c
left join ServiceItem si on si.Id=c.UsrSystemId
left join ServiceItem sii on sii.Id=c.ServiceItemId
left join CaseStatus cs on cs.Id=c.StatusId
where si.Name in ('IC')
and sii.Name in ('New Trgroup', 'New TRGroup INT')
and cs.Name in ('������','�������')
and c.SolutionProvidedOn between dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2)))) 
and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))
*/

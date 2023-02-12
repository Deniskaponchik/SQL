/*  */

USE BPMonline7_8888;

/*DECLARE @CountTG INTEGER*/

WITH
/* ������� ������ ��� ������ ���������� �� ��������� ������ */
NewCase (sr, begin_time, UsrParametersSet, CircuitFULL, circuit_id, switch_id, traffic, operator, DestTrunkGroup, BunchText, bunch_type, region_id) AS (
SELECT
	/* sr - ������������ ����� ��������� (�����, ������������) */
	Number,
	/* begin_time - ���� ����������� ��������� (���) */
	RegisteredOn,
	UsrParametersSet,

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
				   		               (
							              SELECT VALUE
	                                      FROM STRING_SPLIT (UsrParametersSet, char(10))
	                                      WHERE value LIKE '60.������������ ��������� �����%' OR value LIKE '5.������������ ��������� �����:%'
						               ), '60.������������ ��������� �����: ', ''
							       ), '5.������������ ��������� �����: ', ''
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
	/* ??? �������� ���������� ???
	( 
	   REPLACE(
	      REPLACE(
		     (
		         SELECT VALUE
	             FROM STRING_SPLIT (UsrParametersSet, char(10))
	             WHERE value LIKE '2.�������� ����������:%' OR value LIKE '45.��� �������:%'
	          ), '2.�������� ����������: ' , ''
		  ), '45.��� �������: ', ''
	   )
	) protocol, */
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

FROM [BPMonline7_8888].[dbo].[Case] AS �
WHERE 
	/* ������ ����� ("New Trgroup" ��� "New TRGroup INT" */
	ServiceItemId IN (
		SELECT id
		FROM ServiceItem
		WHERE Name IN (
			'New Trgroup'
		  , 'New TRGroup INT'
		  )
	) AND 
	/* ��������� ����� (������ ��� ������� */
	StatusId IN (
		SELECT id
		FROM CaseStatus
		WHERE Name IN (
			'������'
		  , '�������'
		  )
	)

	/* ����������� ���������� ����� "���������� �����" 
	/*MONTH(SolutionProvidedOn) = MONTH(DATEADD(NOW(), INTERVAL -1 MONTH)) AND YEAR(SolutionProvidedOn) = YEAR(NOW())*/
	/*MONTH(SolutionProvidedOn) = MONTH(DATEADD(NOW(), INTERVAL -1 MONTH)) and
	YEAR(SolutionProvidedOn) = YEAR(DATEADD(NOW(), INTERVAL -1 MONTH))*/
	(
		SolutionProvidedOn < datefromparts(year(getdate()), month(getdate()), 1) and
		SolutionProvidedOn >= dateadd(month, 1, datefromparts(year(getdate()), month(getdate()), 1))
	) */

)
	  

SELECT
	/* id - ������ ���� */
	Null AS id,
	/* id_type - �������� "0" */
	0 AS id_type,
	/* bunch_id - ������ ���� */
	Null AS id,
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

	/*
	STRING_AGG(
	   (
	      SELECT region_id FROM NewCase
	      UNION
		  SELECT traffic FROM NewCase
	      UNION
		  SELECT operator FROM NewCase
	      UNION
		  SELECT DestTrunkGroup FROM NewCase
	   ), ','
	) description, */

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
	sr


FROM NewCase
cross apply
STRING_SPLIT (circuit_id, ',')

WHERE circuit_id NOT LIKE '%[�-��-�]%' /*AND circuit_id NOT LIKE ' '*/


ORDER BY begin_time DESC








/* ����
USE BPMonline7_8888
select 
		 syst.name AS �������
       , serv.name AS ������
       , isnull(o.name, r.name)
       , voc.name
       , v.UsrRegionCodes
from UsrVisa v
       left join ServiceItem serv on serv.id = v.UsrServiceItemId
       left join ServiceItem syst on syst.id = serv.UsrSystemId
       left join contact o on o.id = v.UsrVisaOwnerId
       left join UsrVisaRoles r on r.id = v.UsrVisaRolesId
       left join UsrVisaOwner vo on vo.UsrVisaRoleId = v.UsrVisaRolesId
       left join contact voc on voc.id = vo.VisaContactId
where serv.id is not null
       and syst.id is not null
ORDER BY �������*/


/* ������ ����� */
/* ServiceItem.Id = Cases.ServiceItemId = TRUE 
SELECT ServiceItem.Id, ServiceItem.Name, Cases.ServiceItemId
FROM [BPMonline7_8888].[dbo].[ServiceItem] AS ServiceItem
JOIN [BPMonline7_8888].[dbo].[Case] AS Cases
ON ServiceItem.Id = Cases.ServiceItemId */



/*����� ��������� �������
USE BPMonline7_8888

SELECT  
		f.name AS ForeignKey ,
        SCHEMA_NAME(f.SCHEMA_ID) AS SchemaName ,
        OBJECT_NAME(f.parent_object_id) AS TableName ,
        COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnName ,
        SCHEMA_NAME(o.SCHEMA_ID) ReferenceSchemaName ,
        OBJECT_NAME(f.referenced_object_id) AS ReferenceTableName ,
        COL_NAME(fc.referenced_object_id, fc.referenced_column_id)
                                              AS ReferenceColumnName
FROM    
		sys.foreign_keys AS f
        INNER JOIN sys.foreign_key_columns AS fc
               ON f.OBJECT_ID = fc.constraint_object_id
        INNER JOIN sys.objects AS o ON o.OBJECT_ID = fc.referenced_object_id
        WHERE OBJECT_NAME(f.parent_object_id)='SysAdminUnit'    /* ������� �������, �� ������� ����� �����*/
ORDER BY 
		TableName ,
        ReferenceTableName;
*/

/* ����� ������ ����������� �� ���������
select * 
from [BPMonline7_8888].[dbo].ShowAllDeps 
where PKTable = 'UsrSystem'  /* ������� �������, �� ������� ����� ����� */
ORDER BY FKTable 
*/
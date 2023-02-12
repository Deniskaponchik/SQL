/*  */

USE BPMonline7_8888;


DECLARE @CountTG INTEGER




WITH
/* ������� ������ ��� ������ ���������� �� ��������� ������ */
NewCase (Number, RegisteredOn, UsrParametersSet, SolutionProvidedOn) AS (
SELECT
	/* sr - ������������ ����� ��������� (�����, ������������) */
	Number,
	/* begin_time - ���� ����������� ��������� (���) */
	RegisteredOn,
	/* circuit_id - �� ����������. <������������ ��������� �����>. 
	���� ������������ � ������ ���� ��������� - �� ����� � ������ ����� ��������� �� ������� ���������. 
	��� �������� ����� ����������� ����� �������. 
	� ������ ������� �� ��������� - ���������� �������� (�� ���� ������ "������������ ������") */
	UsrParametersSet,



	(
	   SELECT VALUE
	   /*FROM string_split(Replace(UsrParametersSet,char(13)+Char(10),','),',')*/
	   /*FROM string_split(Replace(UsrParametersSet,char(13),','),',')*/
	   FROM STRING_SPLIT (UsrParametersSet, char(10))
	   /*WHERE ordinal = 2*/
	   WHERE value LIKE '10.������%' OR value LIKE '1.������%'
	   )
	RegionFull,
	/* �������� �� ��, ��� ��������� ���������� ��������� ��������
	(
	   SELECT VALUE
	   FROM STRING_SPLIT (
	      (
		     SELECT VALUE
	         FROM STRING_SPLIT (UsrParametersSet, char(10))
	         WHERE value LIKE '10.������%' OR value LIKE '1.������%'
	      ), ' '
		)
	   WHERE value NOT LIKE '10.������' OR value NOT LIKE '1.������'
	   ) Region
	   */
	/*( 
	   SELECT LEFT (VALUE,charindex(' ',VALUE+' ',2)) 
	   from (
		     SELECT VALUE
	         FROM STRING_SPLIT (UsrParametersSet, char(10))
	         WHERE value LIKE '10.������%' OR value LIKE '1.������%'
	      ) Region
	)*/
	(
	   SELECT right(rtrim(VALUE),charindex(' ',reverse(rtrim(VALUE))+' ')-1)
	   from (
		     SELECT VALUE
	         FROM STRING_SPLIT (UsrParametersSet, char(10))
	         WHERE value LIKE '10.������%' OR value LIKE '1.������%'
	      ) Region
	)



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

	  

SELECT *
/*
CASE
   WHEN 
   */

/*
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
	circuit_id,
    /* equipment_type - ������ ���� */
	Null AS equipment_type,
    /* mac - ������ ���� */
	Null AS mac,
    /* vpi - ������ ���� */
	Null AS vpi,
    /* vci - ������ ���� */
	Null AS vci,
    /* switch_id - �� ����������. <����� �����������> */
	Null AS equipment_type,
*/

FROM STRING_SPLIT (NewCase.UsrParametersSet, '\n', 1)

WHERE VALUE = 'SR03724647'







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
/*
��� ���������� SolutionDate? 
����� �� ������ �������� ������� �� �������

*/


USE	BPMonline_80
GO
CREATE VIEW VwBPM5_RPA_OBO_COPS_Product_TT_Stats
AS 

USE	BPMonline_80
select DISTINCT


		/* ��������� ����� 2566 */
		(  
		/*USE	BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR

		/* ��������� ��������� */
		JOIN (
			SELECT id
			FROM StatusOfIncident
			WHERE name = '��������� �� ������'
			) AS SOI
		ON SR.StatusOfIncidentId = SOI.Id
		/*ORDER BY SolutionDate DESC*/

		/* ������ ����� ����������������� B2C */
		join (
			SELECT id
			FROM Service
			WHERE ServiceName = '����������������� B2C'
			) AS S
		ON SR.ServiceId = S.Id

		/* ������� �������� �������� */ 
		JOIN (
			SELECT ServiceRequestId /*, Value*/
			FROM DescriptionInIncident
			WHERE Value IN
			/*Value LIKE '������ �� ������� �������� �������%'*/
			    ('�������������� �� ������ ��������'
			   , '�������������� ������ � ���.���� �� ���.����'
			   , '�������������� �� ������ ��������'
			   , '����� ���������'
			   , '������ �� ������� �������� �������. �������������.'
			   )
			   /*AND Value = '������ �� ������� �������� �������. �������������.'*/
			) AS DII
		ON SR.Id = DII.ServiceRequestId

		/* ����������� �� ����� ������*/
	    JOIN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			) AS mr
		ON SR.MacroregionId = mr.id

		WHERE
		/* ���� ������� ������ ��� ����� 36 ��������� �����
		   ���� ������� ������ ��� ����� ������� 
		   ��� ���������� SolutionDate? */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		SolutionDate between current_timestamp AND DATEADD(hh, 36, current_timestamp)
		/*SolutionDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)*/
		/*SELECT DATEADD(hh, 36, current_timestamp)*/

		/*
		StatusOfIncidentId = '92FE5FFE-60C4-4CCE-A0CC-8F6F2B3E3AB0'
		AND
		MacroregionId <> 'B5516AA4-8E0C-461A-A0E3-41194BCD5B1F'
		*/

	) AS "CritAdmin",
	
	
	
	
	
	/* ��������� Prod */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR

		/* ��������� ��������� */
		JOIN (
			SELECT id
			FROM StatusOfIncident
			WHERE name = '��������� �� ������'
			) AS SOI
		ON SR.StatusOfIncidentId = SOI.Id
		/*ORDER BY SolutionDate DESC*/

		/* ������ ����� */
		join (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
				  '����������������� B2C'
				, 'USSD'
				, '�����������'
				, '�������� � ���������'
				, '������� ������'
				, '�������� ���������'
				, '����� ����'
				, '�� �������'
				)
			) AS S
		ON SR.ServiceId = S.Id

		/* ������� �������� �������� */ 
		JOIN (
			SELECT ServiceRequestId /*, Value*/
			FROM DescriptionInIncident
			/*WHERE Value LIKE '������ �� ������� �������� �������%'*/
			WHERE Value IN (		
			     '������ �� ������� �������� �������. �������������.'
			   , '������ �����������'
			   , '������� ���������� �����������'
			   )
			   /*AND Value = '������ �� ������� �������� �������. �������������.'*/
			) AS DII
		ON SR.Id = DII.ServiceRequestId

		/* ����������� �� ����� ������*/
	    JOIN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			) AS mr
		ON SR.MacroregionId = mr.id

		/* �������� �������� ��� */
	    /*JOIN ( 
			SELECT id
			FROM StatusMarker
			WHERE name <> '��������'
			) AS SM
		ON SM.Id = SR.StatusMarkerId */



		WHERE
		/* ���� ������� ������ ��� ����� 1 ��������� ����
		   ���� ������� ������ ��� ����� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp)
		/*SolutionDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)*/
		/*SELECT DATEADD(hh, 36, current_timestamp)*/


		/* �������� �������� ��� */
		AND IsMassIncident = 0

		/*
			StatusOfIncidentId = '92FE5FFE-60C4-4CCE-A0CC-8F6F2B3E3AB0'
			AND
			MacroregionId <> 'B5516AA4-8E0C-461A-A0E3-41194BCD5B1F'
			*/

	) AS "CritProd",



		
	
	
	/* ������������ */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR

		/* ��������� ��������� */
		JOIN (
			SELECT id
			FROM StatusOfIncident
			WHERE name = '��������� �� ������'
			) AS SOI
		ON SR.StatusOfIncidentId = SOI.Id
		/*ORDER BY SolutionDate DESC*/

		/* ������ ����� */
		join (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
				  '����������������� B2C'
				, 'USSD'
				, '�����������'
				, '������� ������'
				, '������ Upsale'
				, '����� ����'
				)
			) AS S
		ON SR.ServiceId = S.Id

		/* ������� �������� �������� */ 
		JOIN (
			SELECT ServiceRequestId /*, Value*/
			FROM DescriptionInIncident
			/*WHERE Value LIKE '������ �� ������� �������� �������%'*/
			WHERE Value IN (		
			     '������ �� ������� �������� �������. �������������.'
			   , '������ �����������'
			   , '������� ���������� �����������'
			   )
			   /*AND Value = '������ �� ������� �������� �������. �������������.'*/
			) AS DII
		ON SR.Id = DII.ServiceRequestId


		/* ������ ���������� ����� OBO */ 
		JOIN (
			SELECT id /*, Value*/
			FROM SysAdminUnit
			/*WHERE Value LIKE '������ �� ������� �������� �������%'*/
			WHERE Name = 'OBO'
			) AS SAU
		ON SR.DestionationGroupId = SAU.Id


		/* ������� */ 
		JOIN (
			SELECT ??? /*, Value*/
			FROM ???
			/*WHERE Value LIKE '������ �� ������� �������� �������%'*/
			WHERE Value NOT IN (		
			     '��������� ������������ ��� ���������� � CRM'
			   , '��������� ������������ ��� ���������� � UMB'
			   , '��������� ������������ ��� ���������� � WD'
			   , 'ms crm cc'
			   )
			   /*AND Value = '������ �� ������� �������� �������. �������������.'*/
			) AS ???
		ON SR.Id = DII.


		/* ����������� �� ����� ������*/
	    JOIN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			) AS mr
		ON SR.MacroregionId = mr.id





		WHERE
		/* ���� ������� ������ ��� ����� 1 ��������� ����
		   ���� ������� ������ ��� ����� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp)
		/*SolutionDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)*/
		/*SELECT DATEADD(hh, 36, current_timestamp)*/


		/* �������� �������� ��� */
		AND IsMassIncident = 0

		/* ������ ������� �� ��������� */
		AND StatusMarkerId IS NULL



	) AS "Returned",







FROM
	ServiceRequest




		
-- Query the view  
SELECT 
	  CritAdmin AS '��������� �����'
	, CritProd AS '��������� Prod'
	, Returned AS '������������'

FROM VwBPM5_RPA_OBO_COPS_Product_TT_Stats 










/* ��������� �����
USE BPMonline_80
SELECT id
FROM ServiceRequest;

SELECT SA
FROM ServiceRequest;
*/


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
        WHERE OBJECT_NAME(f.parent_object_id)='ServiceRequest'    /* ������� �������, �� ������� ����� �����*/
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
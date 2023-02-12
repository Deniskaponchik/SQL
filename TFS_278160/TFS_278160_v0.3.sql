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

		/* ��������� ���������
		JOIN (
			SELECT id
			FROM StatusOfIncident
			WHERE name = '��������� �� ������'
			) AS SOI
		ON SR.StatusOfIncidentId = SOI.Id */
		/* ������ ����� ����������������� B2C
		join (
			SELECT id
			FROM Service
			WHERE ServiceName = '����������������� B2C'
			) AS S
		ON SR.ServiceId = S.Id */
		/* ������� �������� ��������
		JOIN (
			SELECT ServiceRequestId /*, Value*/
			FROM DescriptionInIncident
			WHERE Value IN (
			     '�������������� �� ������ ��������'
			   , '�������������� ������ � ���.���� �� ���.����'
			   , '�������������� �� ������ ��������'
			   , '����� ���������'
			   , '������ �� ������� �������� �������. �������������.'
			   )
			   /*AND Value = '������ �� ������� �������� �������. �������������.'*/
			) AS DII
		ON SR.Id = DII.ServiceRequestId  */
		/* ����������� �� ����� ������
	    JOIN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			) AS mr
		ON SR.MacroregionId = mr.id */


		WHERE
		/* ��������� ��������� */
		StatusOfIncidentId = (
			SELECT id
			FROM StatusOfIncident
			WHERE name = '��������� �� ������'
			) AND

		/* ������ ����� ����������������� B2C */
		ServiceId = (
			SELECT id
			FROM Service
			WHERE ServiceName = '����������������� B2C'
			) AND

		/* ������� �������� �������� */ 
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (
			     '�������������� �� ������ ��������'
			   , '�������������� ������ � ���.���� �� ���.����'
			   , '�������������� �� ������ ��������'
			   , '����� ���������'
			   , '������ �� ������� �������� �������. �������������.'
			   )
			) AND

		/* ���� ������� ������ ��� ����� 36 ��������� �����
		   ���� ������� ������ ��� ����� ������� 
		   ��� ���������� SolutionDate? */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		  SolutionDate between current_timestamp AND DATEADD(hh, 36, current_timestamp) AND
		/*SolutionDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)*/
		/*SELECT DATEADD(hh, 36, current_timestamp)*/

		/* ����������� �� ����� ������*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			)

	) AS "CritAdmin",
	
	
	
	
	
	/* ��������� Prod */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR

		/* ��������� ���������
		JOIN (
			SELECT id
			FROM StatusOfIncident
			WHERE name = '��������� �� ������'
			) AS SOI
		ON SR.StatusOfIncidentId = SOI.Id */
		/* ������ ����� 
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
		ON SR.ServiceId = S.Id */
		/* ������� �������� ��������
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
		ON SR.Id = DII.ServiceRequestId  */
		/* ����������� �� ����� ������
	    JOIN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			) AS mr
		ON SR.MacroregionId = mr.id */
		/* �������� �������� ��� */
	    /*JOIN ( 
			SELECT id
			FROM StatusMarker
			WHERE name <> '��������'
			) AS SM
		ON SM.Id = SR.StatusMarkerId */



		WHERE
		/* ��������� ��������� */
		StatusOfIncidentId = (
			SELECT id
			FROM StatusOfIncident
			WHERE name = '��������� �� ������'
			) AND

		/* ������ ����� */
		ServiceId IN (
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
			) AND

		/* ������� �������� �������� */ 
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (		
			     '������ �� ������� �������� �������. �������������.'
			   , '������ �����������'
			   , '������� ���������� �����������'
			   )
			) AND

		/* ���� ������� ������ ��� ����� 1 ��������� ����
		   ���� ������� ������ ��� ����� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND
		/*SolutionDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)*/
		/*SELECT DATEADD(hh, 36, current_timestamp)*/

		/* ����������� �� ����� ������*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			) AND

		/* �������� �������� ��� */
		IsMassIncident = 0

	) AS "CritProd",



		
	
	
	/* ������������ */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR

		/* ��������� ��������� 
		JOIN (
			SELECT id
			FROM StatusOfIncident
			WHERE name = '��������� �� ������'
			) AS SOI
		ON SR.StatusOfIncidentId = SOI.Id */
		/* ������ �����
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
		ON SR.ServiceId = S.Id  */
		/* ������� �������� ��������
		JOIN (
			SELECT ServiceRequestId /*, Value*/
			FROM DescriptionInIncident
			WHERE Value IN (		
			     '������ �� ������� �������� �������. �������������.'
			   , '������ �����������'
			   , '������� ���������� �����������'
			   )
			) AS DII
		ON SR.Id = DII.ServiceRequestId  */
		/* ������ ���������� ����� OBO 
		JOIN (
			SELECT id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AS SAU
		ON SR.DestionationGroupId = SAU.Id  */
		/* ����������� �� ����� ������
	    JOIN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			) AS mr
		ON SR.MacroregionId = mr.id */
		/* �������  
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
		ON SR.Id = DII. */


		WHERE
		/* ��������� ��������� */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 '��������� �� ������'
			   , '� ������'
			   )
			) AND

		/* ������ ����� */
		ServiceId IN (
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
			) AND

		/* ������� �������� �������� */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (		
			     '������ �� ������� �������� �������. �������������.'
			   , '������ �����������'
			   , '������� ���������� �����������'
			   )
			) AND

		/* ������ ���������� ����� OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* ����������� �� ����� ������*/
		MacroregionId = ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			) AND

		/* ���� ������� ������ ��� ����� 1 ��������� ����
		   ���� ������� ������ ��� ����� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND
		/*SolutionDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)*/
		/*SELECT DATEADD(hh, 36, current_timestamp)*/

		/* ������� �� ����� */ 
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Value NOT IN (		
			     '��������� ������������ ��� ���������� � CRM'
			   , '��������� ������������ ��� ���������� � UMB'
			   , '��������� ������������ ��� ���������� � WD'
			   , 'ms crm cc'
			   )
			) AND

		/* �������� �������� ��� */
		IsMassIncident = 0 AND

		/* ������ ������� �� ��������� */
		StatusMarkerId IS NULL

	) AS "Returned",





	/* ����� */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* ��������� ��������� */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 '��������� �� ������'
			   , '� ������ ???'
			   )
			) AND

		/* ������ ����� */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      '����������������� B2C'
				, '�������� � ���������'
				, '������� ������'
				, '�������� ���������'
				, '����� ����'
				, '�����������'
				, '������ Upsale'
				, 'USSD'
				, '�� �������'
				)
			) AND

		/* ������� �������� �������� */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (		
			     '������ �� ������� �������� �������. �������������.'
			   , '������ �����������'
			   , '������� ���������� �����������'
			   , '������� 1 ��'
			   , '��������'
			   )
			) AND

		/* ������ ���������� ����� OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* ����������� �� ����� ������*/
		MacroregionId = ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			) AND

		/* ���� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* ������� ����� */ 
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     '��������� ������������ ��� ���������� � CRM'
			   , '��������� ������������ ��� ���������� � UMB'
			   , '��������� ������������ ��� ���������� � WD'
			   , 'ms crm cc'
			   )
			)

		/* �������� �������� ��� 
		IsMassIncident = 0 AND */

		/* ������ ������� �� ��������� 
		StatusMarkerId IS NULL */

	) AS "New",





	/* USSD */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* ��������� ��������� */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 '��������� �� ������'
			   , '� ������'
			   )
			) AND

		/* ������ ����� */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      '����������������� B2C'
				, 'USSD'
				)
			) AND

		/* ������� �������� �������� */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value = '������ �� ������� �������� �������. �������������.'
			) AND

		/* ������ ���������� ����� OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* ����������� �� ����� ������*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			) AND

		/* ���� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* ������� ����� */ 
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     '��������� ������������ ��� ���������� � CRM'
			   , '��������� ������������ ��� ���������� � UMB'
			   , '��������� ������������ ��� ���������� � WD'
			   , 'ms crm cc'
			   )
			)

		/* �������� �������� ��� 
		IsMassIncident = 0 AND */

		/* ������ ������� �� ��������� 
		StatusMarkerId IS NULL */

	) AS "USSD",





	/* �������� ��������� �Ѩ ������ */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* ��������� ��������� */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 '��������� �� ������'
			   , '� ������'
			   )
			) AND

		/* ������ ����� */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      '����������������� B2C'
				, '�������� ���������'
				)
			) AND

		/* ������� �������� �������� */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value = '������ �� ������� �������� �������. �������������.'
			) AND

		/* ������ ���������� ����� OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* ����������� �� ����� ������*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			)

		/* ���� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* ������� �����  
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     '��������� ������������ ��� ���������� � CRM'
			   , '��������� ������������ ��� ���������� � UMB'
			   , '��������� ������������ ��� ���������� � WD'
			   , 'ms crm cc'
			   )
			) */

		/* �������� �������� ��� 
		IsMassIncident = 0 AND */

		/* ������ ������� �� ��������� 
		StatusMarkerId IS NULL */

	) AS "BonusProgramm",





	/* ������� ������ */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* ��������� ��������� */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 '��������� �� ������'
			   , '� ������'
			   )
			) AND

		/* ������ ����� */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      '����������������� B2C'
				, '������� ������'
				)
			) AND

		/* ������� �������� �������� */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value = '������ �� ������� �������� �������. �������������.'
			) AND

		/* ������ ���������� ����� OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* ����������� �� ����� ������*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			)

		/* ���� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* ������� �����  
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     '��������� ������������ ��� ���������� � CRM'
			   , '��������� ������������ ��� ���������� � UMB'
			   , '��������� ������������ ��� ���������� � WD'
			   , 'ms crm cc'
			   )
			) */

		/* �������� �������� ��� 
		IsMassIncident = 0 AND */

		/* ������ ������� �� ��������� 
		StatusMarkerId IS NULL */

	) AS "ProfitTogether",





	/* ������ �� ������������ �������� */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* ��������� ��������� */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 '��������� �� ������'
			   , '� ������'
			   )
			) AND

		/* ������ ����� */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      '����������������� B2C'
				, '������ �����������'
				)
			) AND

		/* ������� �������� �������� */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (		
			     '������ �� ������� �������� �������. �������������.'
			   , '������ �����������'
			   , '������� 1 ��'
			   , '������ ����������� - �������'
			   , '��������'
			   , '������� ���������� �����������'			   
			   )
			) AND

		/* ������ ���������� ����� OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* ����������� �� ����� ������*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			)

		/* ���� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* ������� �����  
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     '��������� ������������ ��� ���������� � CRM'
			   , '��������� ������������ ��� ���������� � UMB'
			   , '��������� ������������ ��� ���������� � WD'
			   , 'ms crm cc'
			   )
			) */

		/* �������� �������� ��� 
		IsMassIncident = 0 AND */

		/* ������ ������� �� ��������� 
		StatusMarkerId IS NULL */

	) AS "CustomerServiceComplaints",






	/* �������� � ��������� */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* ��������� ��������� */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 '��������� �� ������'
			   , '� ������'
			   )
			) AND

		/* ������ ����� */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      '����������������� B2C'
				, '�������� � ���������'
				)
			) AND

		/* ������� �������� �������� */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value = '������ �� ������� �������� �������. �������������.'
			) AND

		/* ������ ���������� ����� OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* ����������� �� ����� ������*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			)

		/* ���� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* ������� �����  
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     '��������� ������������ ��� ���������� � CRM'
			   , '��������� ������������ ��� ���������� � UMB'
			   , '��������� ������������ ��� ���������� � WD'
			   , 'ms crm cc'
			   )
			) */

		/* �������� �������� ��� 
		IsMassIncident = 0 AND */

		/* ������ ������� �� ��������� 
		StatusMarkerId IS NULL */

	) AS "PaymentProblems",









	/* �����������, ������ Upsale */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* ��������� ��������� */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 '��������� �� ������'
			   , '� ������'
			   )
			) AND

		/* ������ ����� */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      '����������������� B2C'
				, '������ Upsale'
				, '�����������'
				, '����� ����'
				)
			) AND

		/* ������� �������� �������� */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value = '������ �� ������� �������� �������. �������������.'
			) AND

		/* ������ ���������� ����� OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* ����������� �� ����� ������*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			)

		/* ���� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* ������� �����  */ 
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     '��������� ������������ ��� ���������� � CRM'
			   , '��������� ������������ ��� ���������� � UMB'
			   , '��������� ������������ ��� ���������� � WD'
			   , 'ms crm cc'
			   )
			)

		/* �������� �������� ��� 
		IsMassIncident = 0 AND */

		/* ������ ������� �� ��������� 
		StatusMarkerId IS NULL */

	) AS "TarificationUpsale",









	/* �� ������� */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* ��������� ��������� */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 '��������� �� ������'
			   , '� ������'
			   )
			) AND

		/* ������ ����� */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      '����������������� B2C'
				, '�� �������'
				)
			) AND

		/* ������� �������� �������� */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value = '������ �� ������� �������� �������. �������������.'
			) AND

		/* ������ ���������� ����� OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* ����������� �� ����� ������*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			)

		/* ���� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* ������� �����
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     '��������� ������������ ��� ���������� � CRM'
			   , '��������� ������������ ��� ���������� � UMB'
			   , '��������� ������������ ��� ���������� � WD'
			   , 'ms crm cc'
			   )
			)  */

		/* �������� �������� ��� 
		IsMassIncident = 0 AND */

		/* ������ ������� �� ��������� 
		StatusMarkerId IS NULL */

	) AS "Gaming",








	/* ����� ���� */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* ��������� ��������� */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 '��������� �� ������'
			   , '� ������'
			   )
			) AND

		/* ������ ����� */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      '����������������� B2C'
				, '����� ����'
				)
			) AND

		/* ������� �������� �������� */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value = '������ �� ������� �������� �������. �������������.'
			) AND

		/* ������ ���������� ����� OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* ����������� �� ����� ������*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			)

		/* ���� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* ������� �����
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     '��������� ������������ ��� ���������� � CRM'
			   , '��������� ������������ ��� ���������� � UMB'
			   , '��������� ������������ ��� ���������� � WD'
			   , 'ms crm cc'
			   )
			)  */

		/* �������� �������� ��� 
		IsMassIncident = 0 AND */

		/* ������ ������� �� ��������� 
		StatusMarkerId IS NULL */

	) AS "SmartNull",







	/* ������� ������� */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* ��������� ��������� */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 '��������� �� ������'
			   , '� ������'
			   , '������� ������'
			   , '���������� ������'
			   )
			) AND

		/* ������ ����� */
		ServiceId IN (
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
			) AND

		/* ������� �������� �������� */ 
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (
			     '������ �� ������� �������� �������. �������������.'
			   , '������ �����������'
			   , '������� ���������� �����������'
			   )
			) AND

		/* ������ ���������� ����� OBO  
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND */

		/* ����������� �� ����� ������*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			)

		/* ���� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* ������� �����
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     '��������� ������������ ��� ���������� � CRM'
			   , '��������� ������������ ��� ���������� � UMB'
			   , '��������� ������������ ��� ���������� � WD'
			   , 'ms crm cc'
			   )
			)  */

		/* �������� �������� ��� 
		IsMassIncident = 0 AND */

		/* ������ ������� �� ��������� 
		StatusMarkerId IS NULL */

	) AS "ExternalRequests",








	/* ��������� */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* ��������� ��������� */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 '��������� �� ������'
			   , '���������'
			   , '��������� ���'
			   , '��������� �� �����'
			   , '������������'
			   )
			) AND

		/* ������ ����� */
		ServiceId IN (
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
			) AND

		/* ������� �������� �������� */ 
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (
			     '������ �� ������� �������� �������. �������������.'
			   , '������ �����������'
			   , '������� ���������� �����������'
			   )
			) AND

		/* ������ ���������� ����� OBO  
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND */

		/* ����������� �� ����� ������*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			)

		/* ���� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* ������� �����
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     '��������� ������������ ��� ���������� � CRM'
			   , '��������� ������������ ��� ���������� � UMB'
			   , '��������� ������������ ��� ���������� � WD'
			   , 'ms crm cc'
			   )
			)  */

		/* �������� �������� ��� 
		IsMassIncident = 0 AND */

		/* ������ ������� �� ��������� 
		StatusMarkerId IS NULL */

	) AS "CallUp",










	/* �������� */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* ��������� ��������� */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 '��������� �� ������'
			   , '������'
			   )
			) AND

		/* ������ ����� */
		ServiceId IN (
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
			) AND

		/* ������� �������� �������� */ 
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (
			     '������ �� ������� �������� �������. �������������.'
			   , '������ �����������'
			   , '������� ���������� �����������'
			   )
			) AND

		/* ������ ���������� ����� OBO  
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND */

		/* ����������� �� ����� ������*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> '������'
			)

		/* ���� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* ������� �����
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     '��������� ������������ ��� ���������� � CRM'
			   , '��������� ������������ ��� ���������� � UMB'
			   , '��������� ������������ ��� ���������� � WD'
			   , 'ms crm cc'
			   )
			)  */

		/* �������� �������� ��� 
		IsMassIncident = 0 AND */

		/* ������ ������� �� ��������� 
		StatusMarkerId IS NULL */

	) AS "Resolved",







	/* 2� ���� */
	(   
		/*USE BPMonline_80*/
		SELECT * /* COUNT (SR.Id)*/
		FROM ServiceRequest AS SR
		WHERE
		/* ��������� ���������
		StatusOfIncidentId = (
			SELECT id
			FROM StatusOfIncident
			WHERE name = '��������� �� ������'
			) AND */

		/* ������ ����� */
		/*ServiceId*/ TechServiceId IN (
			SELECT id, ServiceName, ServiceParentId
			FROM Service
			/*WHERE ServiceName = '�������������� ������ � ���.���� �� ���.����'*/
			WHERE ServiceName = '������ �� ������� �������� �������. �������������'
			/*WHERE ServiceName = '����������������� B2C'*/
			/*WHERE id = 'B5AD8E37-ECD5-4EA8-8E68-23ABBE942016'*/
			/*WHERE id = '524A3A8E-FB29-E411-80BC-00155DFC1F77'*/
			) AND

		/* ������� �������� �������� */ 
		/*SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (
			     '������ �� ������� �������� �������. �������������'
			   , '�������������� �� ������ ��������'
			   , '�������������� ������ � ���.���� �� ���.����'
			   , '����� ���������'
			   )
			) AND*/
		TechServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			     '������ �� ������� �������� �������. �������������'
			   , '�������������� �� ������ ��������'
			   , '�������������� ������ � ���.���� �� ���.����'
			   , '����� ���������'
			   )
			) AND

		/* ������ ���������� ����� OBO  
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND */
	
		(
		/* ����������� ����� */
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name IN (
				'������ � ������� ������'
			  , '������'
			  , '����'
			) OR
		/* ������ ����� */
		RegionCodeId IN ( 
			SELECT id
			FROM RegionCode
			WHERE name IN (
				'IZH'
			  , 'IZH-CDMA'
			)
		) AND

		/* ������ �� ����� */
		RegionCodeId NOT IN ( 
			SELECT id
			FROM RegionCode
			WHERE name IN (
				'EKT'
			  , 'KRG'
			  , 'ORB'
			  , 'PRM'
			  , 'PRM-CDMA'
			  , 'KOM'
			)

		/* ���� ������� */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* ������� �����
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     '��������� ������������ ��� ���������� � CRM'
			   , '��������� ������������ ��� ���������� � UMB'
			   , '��������� ������������ ��� ���������� � WD'
			   , 'ms crm cc'
			   )
			)  */

		/* �������� �������� ��� 
		IsMassIncident = 0 AND */

		/* ������ ������� �� ��������� 
		StatusMarkerId IS NULL */

	) AS "2base",









FROM
	ServiceRequest




		
-- Query the view  
SELECT 
	  CritAdmin AS '��������� �����'
	, CritProd AS '��������� Prod'
	, Returned AS '������������'
	, New AS '�����'
	, USSD
	, BonusProgramm AS '�������� ���������'
	, ProfitTogether AS '������� ������'
	, CustomerServiceComplaints AS '������ �� ������������ ��������'
	, PaymentProblems AS '�������� � ���������'
	, TarificationUpsale AS '�����������, ������ Upsale'
	, Gaming AS '�� �������'
	, SmartNull AS '����� ����'
	, ExternalRequests AS '������� �������'
	, CallUp AS '��������'
	, Resolved AS '��������'
	, 2base AS '2� ����'
	, AS ''
	, AS ''


FROM VwBPM5_RPA_OBO_COPS_Product_TT_Stats 










/* ��������� �����
USE BPMonline_80
SELECT id
FROM ServiceRequest;

SELECT SA
FROM ServiceRequest;
*/


/*����� ��������� �������
USE BPMonline_80
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
/*
Что показывает SolutionDate? 
Могут ли вообще работать фильтры на скринах

*/


USE	BPMonline_80
GO
CREATE VIEW VwBPM5_RPA_OBO_COPS_Product_TT_Stats
AS 

USE	BPMonline_80
select DISTINCT


		/* Критичные админ 2566 */
		(  
		/*USE	BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR

		/* Состояние инцидента */
		JOIN (
			SELECT id
			FROM StatusOfIncident
			WHERE name = 'Назначена на группу'
			) AS SOI
		ON SR.StatusOfIncidentId = SOI.Id
		/*ORDER BY SolutionDate DESC*/

		/* Сервис равно Администрирование B2C */
		join (
			SELECT id
			FROM Service
			WHERE ServiceName = 'Администрирование B2C'
			) AS S
		ON SR.ServiceId = S.Id

		/* Краткое описание проблемы */ 
		JOIN (
			SELECT ServiceRequestId /*, Value*/
			FROM DescriptionInIncident
			WHERE Value IN
			/*Value LIKE 'Запрос на возврат денежных средств%'*/
			    ('Переоформление по смерти Абонента'
			   , 'Переоформление номера с физ.лица на физ.лицо'
			   , 'Переоформление по смерти абонента'
			   , 'Смена владельца'
			   , 'Запрос на возврат денежных средств. Мошенничество.'
			   )
			   /*AND Value = 'Запрос на возврат денежных средств. Мошенничество.'*/
			) AS DII
		ON SR.Id = DII.ServiceRequestId

		/* Макрорегион не равно Москва*/
	    JOIN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			) AS mr
		ON SR.MacroregionId = mr.id

		WHERE
		/* Срок решения меньше или равно 36 следующих часов
		   Срок решения больше или равно сегодня 
		   Что показывает SolutionDate? */
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
	
	
	
	
	
	/* Критичные Prod */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR

		/* Состояние инцидента */
		JOIN (
			SELECT id
			FROM StatusOfIncident
			WHERE name = 'Назначена на группу'
			) AS SOI
		ON SR.StatusOfIncidentId = SOI.Id
		/*ORDER BY SolutionDate DESC*/

		/* Сервис равно */
		join (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
				  'Администрирование B2C'
				, 'USSD'
				, 'Тарификация'
				, 'Проблемы с платежами'
				, 'Выгодно вместе'
				, 'Бонусная программа'
				, 'Умный ноль'
				, 'ТП Игровой'
				)
			) AS S
		ON SR.ServiceId = S.Id

		/* Краткое описание проблемы */ 
		JOIN (
			SELECT ServiceRequestId /*, Value*/
			FROM DescriptionInIncident
			/*WHERE Value LIKE 'Запрос на возврат денежных средств%'*/
			WHERE Value IN (		
			     'Запрос на возврат денежных средств. Мошенничество.'
			   , 'Запрос компенсации'
			   , 'Разовое начисление компенсации'
			   )
			   /*AND Value = 'Запрос на возврат денежных средств. Мошенничество.'*/
			) AS DII
		ON SR.Id = DII.ServiceRequestId

		/* Макрорегион не равно Москва*/
	    JOIN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			) AS mr
		ON SR.MacroregionId = mr.id

		/* Массовый инцидент НЕТ */
	    /*JOIN ( 
			SELECT id
			FROM StatusMarker
			WHERE name <> 'Массовый'
			) AS SM
		ON SM.Id = SR.StatusMarkerId */



		WHERE
		/* Срок решения меньше или равно 1 следующих дней
		   Срок решения больше или равно сегодня */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp)
		/*SolutionDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)*/
		/*SELECT DATEADD(hh, 36, current_timestamp)*/


		/* Массовый инцидент НЕТ */
		AND IsMassIncident = 0

		/*
			StatusOfIncidentId = '92FE5FFE-60C4-4CCE-A0CC-8F6F2B3E3AB0'
			AND
			MacroregionId <> 'B5516AA4-8E0C-461A-A0E3-41194BCD5B1F'
			*/

	) AS "CritProd",



		
	
	
	/* Возвращённые */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR

		/* Состояние инцидента */
		JOIN (
			SELECT id
			FROM StatusOfIncident
			WHERE name = 'Назначена на группу'
			) AS SOI
		ON SR.StatusOfIncidentId = SOI.Id
		/*ORDER BY SolutionDate DESC*/

		/* Сервис равно */
		join (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
				  'Администрирование B2C'
				, 'USSD'
				, 'Тарификация'
				, 'Выгодно вместе'
				, 'Услуги Upsale'
				, 'Умный ноль'
				)
			) AS S
		ON SR.ServiceId = S.Id

		/* Краткое описание проблемы */ 
		JOIN (
			SELECT ServiceRequestId /*, Value*/
			FROM DescriptionInIncident
			/*WHERE Value LIKE 'Запрос на возврат денежных средств%'*/
			WHERE Value IN (		
			     'Запрос на возврат денежных средств. Мошенничество.'
			   , 'Запрос компенсации'
			   , 'Разовое начисление компенсации'
			   )
			   /*AND Value = 'Запрос на возврат денежных средств. Мошенничество.'*/
			) AS DII
		ON SR.Id = DII.ServiceRequestId


		/* Группа назначения равно OBO */ 
		JOIN (
			SELECT id /*, Value*/
			FROM SysAdminUnit
			/*WHERE Value LIKE 'Запрос на возврат денежных средств%'*/
			WHERE Name = 'OBO'
			) AS SAU
		ON SR.DestionationGroupId = SAU.Id


		/* Изменил */ 
		JOIN (
			SELECT ??? /*, Value*/
			FROM ???
			/*WHERE Value LIKE 'Запрос на возврат денежных средств%'*/
			WHERE Value NOT IN (		
			     'Служебный пользователь для интеграции с CRM'
			   , 'Служебный пользователь для интеграции с UMB'
			   , 'Служебный пользователь для интеграции с WD'
			   , 'ms crm cc'
			   )
			   /*AND Value = 'Запрос на возврат денежных средств. Мошенничество.'*/
			) AS ???
		ON SR.Id = DII.


		/* Макрорегион не равно Москва*/
	    JOIN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			) AS mr
		ON SR.MacroregionId = mr.id





		WHERE
		/* Срок решения меньше или равно 1 следующих дней
		   Срок решения больше или равно сегодня */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp)
		/*SolutionDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)*/
		/*SELECT DATEADD(hh, 36, current_timestamp)*/


		/* Массовый инцидент НЕТ */
		AND IsMassIncident = 0

		/* Статус маркера не заполнено */
		AND StatusMarkerId IS NULL



	) AS "Returned",







FROM
	ServiceRequest




		
-- Query the view  
SELECT 
	  CritAdmin AS 'Критичные админ'
	, CritProd AS 'Критичные Prod'
	, Returned AS 'Возвращённые'

FROM VwBPM5_RPA_OBO_COPS_Product_TT_Stats 










/* Различные тесты
USE BPMonline_80
SELECT id
FROM ServiceRequest;

SELECT SA
FROM ServiceRequest;
*/


/*Найти связанные таблицы
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
        WHERE OBJECT_NAME(f.parent_object_id)='ServiceRequest'    /* указать таблицу, по которой хотим связи*/
ORDER BY 
		TableName ,
        ReferenceTableName;
*/


/* Поиск таблиц ссылающихся на указанную
select * 
from [BPMonline7_8888].[dbo].ShowAllDeps 
where PKTable = 'UsrSystem'  /* указать таблицу, по которой хотим связи */
ORDER BY FKTable 
*/
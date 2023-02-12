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

		/* Состояние инцидента
		JOIN (
			SELECT id
			FROM StatusOfIncident
			WHERE name = 'Назначена на группу'
			) AS SOI
		ON SR.StatusOfIncidentId = SOI.Id */
		/* Сервис равно Администрирование B2C
		join (
			SELECT id
			FROM Service
			WHERE ServiceName = 'Администрирование B2C'
			) AS S
		ON SR.ServiceId = S.Id */
		/* Краткое описание проблемы
		JOIN (
			SELECT ServiceRequestId /*, Value*/
			FROM DescriptionInIncident
			WHERE Value IN (
			     'Переоформление по смерти Абонента'
			   , 'Переоформление номера с физ.лица на физ.лицо'
			   , 'Переоформление по смерти абонента'
			   , 'Смена владельца'
			   , 'Запрос на возврат денежных средств. Мошенничество.'
			   )
			   /*AND Value = 'Запрос на возврат денежных средств. Мошенничество.'*/
			) AS DII
		ON SR.Id = DII.ServiceRequestId  */
		/* Макрорегион не равно Москва
	    JOIN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			) AS mr
		ON SR.MacroregionId = mr.id */


		WHERE
		/* Состояние инцидента */
		StatusOfIncidentId = (
			SELECT id
			FROM StatusOfIncident
			WHERE name = 'Назначена на группу'
			) AND

		/* Сервис равно Администрирование B2C */
		ServiceId = (
			SELECT id
			FROM Service
			WHERE ServiceName = 'Администрирование B2C'
			) AND

		/* Краткое описание проблемы */ 
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (
			     'Переоформление по смерти Абонента'
			   , 'Переоформление номера с физ.лица на физ.лицо'
			   , 'Переоформление по смерти абонента'
			   , 'Смена владельца'
			   , 'Запрос на возврат денежных средств. Мошенничество.'
			   )
			) AND

		/* Срок решения меньше или равно 36 следующих часов
		   Срок решения больше или равно сегодня 
		   Что показывает SolutionDate? */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		  SolutionDate between current_timestamp AND DATEADD(hh, 36, current_timestamp) AND
		/*SolutionDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)*/
		/*SELECT DATEADD(hh, 36, current_timestamp)*/

		/* Макрорегион не равно Москва*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			)

	) AS "CritAdmin",
	
	
	
	
	
	/* Критичные Prod */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR

		/* Состояние инцидента
		JOIN (
			SELECT id
			FROM StatusOfIncident
			WHERE name = 'Назначена на группу'
			) AS SOI
		ON SR.StatusOfIncidentId = SOI.Id */
		/* Сервис равно 
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
		ON SR.ServiceId = S.Id */
		/* Краткое описание проблемы
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
		ON SR.Id = DII.ServiceRequestId  */
		/* Макрорегион не равно Москва
	    JOIN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			) AS mr
		ON SR.MacroregionId = mr.id */
		/* Массовый инцидент НЕТ */
	    /*JOIN ( 
			SELECT id
			FROM StatusMarker
			WHERE name <> 'Массовый'
			) AS SM
		ON SM.Id = SR.StatusMarkerId */



		WHERE
		/* Состояние инцидента */
		StatusOfIncidentId = (
			SELECT id
			FROM StatusOfIncident
			WHERE name = 'Назначена на группу'
			) AND

		/* Сервис равно */
		ServiceId IN (
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
			) AND

		/* Краткое описание проблемы */ 
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (		
			     'Запрос на возврат денежных средств. Мошенничество.'
			   , 'Запрос компенсации'
			   , 'Разовое начисление компенсации'
			   )
			) AND

		/* Срок решения меньше или равно 1 следующих дней
		   Срок решения больше или равно сегодня */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND
		/*SolutionDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)*/
		/*SELECT DATEADD(hh, 36, current_timestamp)*/

		/* Макрорегион не равно Москва*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			) AND

		/* Массовый инцидент НЕТ */
		IsMassIncident = 0

	) AS "CritProd",



		
	
	
	/* Возвращённые */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR

		/* Состояние инцидента 
		JOIN (
			SELECT id
			FROM StatusOfIncident
			WHERE name = 'Назначена на группу'
			) AS SOI
		ON SR.StatusOfIncidentId = SOI.Id */
		/* Сервис равно
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
		ON SR.ServiceId = S.Id  */
		/* Краткое описание проблемы
		JOIN (
			SELECT ServiceRequestId /*, Value*/
			FROM DescriptionInIncident
			WHERE Value IN (		
			     'Запрос на возврат денежных средств. Мошенничество.'
			   , 'Запрос компенсации'
			   , 'Разовое начисление компенсации'
			   )
			) AS DII
		ON SR.Id = DII.ServiceRequestId  */
		/* Группа назначения равно OBO 
		JOIN (
			SELECT id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AS SAU
		ON SR.DestionationGroupId = SAU.Id  */
		/* Макрорегион не равно Москва
	    JOIN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			) AS mr
		ON SR.MacroregionId = mr.id */
		/* Изменил  
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
		ON SR.Id = DII. */


		WHERE
		/* Состояние инцидента */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 'Назначена на группу'
			   , 'В работе'
			   )
			) AND

		/* Сервис равно */
		ServiceId IN (
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
			) AND

		/* Краткое описание проблемы */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (		
			     'Запрос на возврат денежных средств. Мошенничество.'
			   , 'Запрос компенсации'
			   , 'Разовое начисление компенсации'
			   )
			) AND

		/* Группа назначения равно OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* Макрорегион не равно Москва*/
		MacroregionId = ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			) AND

		/* Срок решения меньше или равно 1 следующих дней
		   Срок решения больше или равно сегодня */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND
		/*SolutionDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)*/
		/*SELECT DATEADD(hh, 36, current_timestamp)*/

		/* Изменил не равно */ 
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Value NOT IN (		
			     'Служебный пользователь для интеграции с CRM'
			   , 'Служебный пользователь для интеграции с UMB'
			   , 'Служебный пользователь для интеграции с WD'
			   , 'ms crm cc'
			   )
			) AND

		/* Массовый инцидент НЕТ */
		IsMassIncident = 0 AND

		/* Статус маркера не заполнено */
		StatusMarkerId IS NULL

	) AS "Returned",





	/* Новые */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* Состояние инцидента */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 'Назначена на группу'
			   , 'В работе ???'
			   )
			) AND

		/* Сервис равно */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      'Администрирование B2C'
				, 'Проблемы с платежами'
				, 'Выгодно вместе'
				, 'Бонусная программа'
				, 'Умный ноль'
				, 'Тарификация'
				, 'Услуги Upsale'
				, 'USSD'
				, 'ТП Игровой'
				)
			) AND

		/* Краткое описание проблемы */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (		
			     'Запрос на возврат денежных средств. Мошенничество.'
			   , 'Запрос компенсации'
			   , 'Разовое начисление компенсации'
			   , 'Самсунг 1 ТБ'
			   , 'Терабайт'
			   )
			) AND

		/* Группа назначения равно OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* Макрорегион не равно Москва*/
		MacroregionId = ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			) AND

		/* Срок решения */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* Изменил РАВНО */ 
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     'Служебный пользователь для интеграции с CRM'
			   , 'Служебный пользователь для интеграции с UMB'
			   , 'Служебный пользователь для интеграции с WD'
			   , 'ms crm cc'
			   )
			)

		/* Массовый инцидент НЕТ 
		IsMassIncident = 0 AND */

		/* Статус маркера не заполнено 
		StatusMarkerId IS NULL */

	) AS "New",





	/* USSD */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* Состояние инцидента */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 'Назначена на группу'
			   , 'В работе'
			   )
			) AND

		/* Сервис равно */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      'Администрирование B2C'
				, 'USSD'
				)
			) AND

		/* Краткое описание проблемы */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value = 'Запрос на возврат денежных средств. Мошенничество.'
			) AND

		/* Группа назначения равно OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* Макрорегион не равно Москва*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			) AND

		/* Срок решения */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* Изменил РАВНО */ 
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     'Служебный пользователь для интеграции с CRM'
			   , 'Служебный пользователь для интеграции с UMB'
			   , 'Служебный пользователь для интеграции с WD'
			   , 'ms crm cc'
			   )
			)

		/* Массовый инцидент НЕТ 
		IsMassIncident = 0 AND */

		/* Статус маркера не заполнено 
		StatusMarkerId IS NULL */

	) AS "USSD",





	/* Бонусная программа ВСЁ ГОТОВО */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* Состояние инцидента */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 'Назначена на группу'
			   , 'В работе'
			   )
			) AND

		/* Сервис равно */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      'Администрирование B2C'
				, 'Бонусная программа'
				)
			) AND

		/* Краткое описание проблемы */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value = 'Запрос на возврат денежных средств. Мошенничество.'
			) AND

		/* Группа назначения равно OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* Макрорегион не равно Москва*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			)

		/* Срок решения */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* Изменил РАВНО  
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     'Служебный пользователь для интеграции с CRM'
			   , 'Служебный пользователь для интеграции с UMB'
			   , 'Служебный пользователь для интеграции с WD'
			   , 'ms crm cc'
			   )
			) */

		/* Массовый инцидент НЕТ 
		IsMassIncident = 0 AND */

		/* Статус маркера не заполнено 
		StatusMarkerId IS NULL */

	) AS "BonusProgramm",





	/* Выгодно вместе */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* Состояние инцидента */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 'Назначена на группу'
			   , 'В работе'
			   )
			) AND

		/* Сервис равно */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      'Администрирование B2C'
				, 'Выгодно вместе'
				)
			) AND

		/* Краткое описание проблемы */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value = 'Запрос на возврат денежных средств. Мошенничество.'
			) AND

		/* Группа назначения равно OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* Макрорегион не равно Москва*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			)

		/* Срок решения */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* Изменил РАВНО  
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     'Служебный пользователь для интеграции с CRM'
			   , 'Служебный пользователь для интеграции с UMB'
			   , 'Служебный пользователь для интеграции с WD'
			   , 'ms crm cc'
			   )
			) */

		/* Массовый инцидент НЕТ 
		IsMassIncident = 0 AND */

		/* Статус маркера не заполнено 
		StatusMarkerId IS NULL */

	) AS "ProfitTogether",





	/* Жалобы на обслуживание клиентов */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* Состояние инцидента */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 'Назначена на группу'
			   , 'В работе'
			   )
			) AND

		/* Сервис равно */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      'Администрирование B2C'
				, 'Запрос компенсации'
				)
			) AND

		/* Краткое описание проблемы */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (		
			     'Запрос на возврат денежных средств. Мошенничество.'
			   , 'Запрос компенсации'
			   , 'Самсунг 1 ТБ'
			   , 'Запрос компенсации - контент'
			   , 'Терабайт'
			   , 'Разовое начисление компенсации'			   
			   )
			) AND

		/* Группа назначения равно OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* Макрорегион не равно Москва*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			)

		/* Срок решения */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* Изменил РАВНО  
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     'Служебный пользователь для интеграции с CRM'
			   , 'Служебный пользователь для интеграции с UMB'
			   , 'Служебный пользователь для интеграции с WD'
			   , 'ms crm cc'
			   )
			) */

		/* Массовый инцидент НЕТ 
		IsMassIncident = 0 AND */

		/* Статус маркера не заполнено 
		StatusMarkerId IS NULL */

	) AS "CustomerServiceComplaints",






	/* Проблемы с платежами */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* Состояние инцидента */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 'Назначена на группу'
			   , 'В работе'
			   )
			) AND

		/* Сервис равно */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      'Администрирование B2C'
				, 'Проблемы с платежами'
				)
			) AND

		/* Краткое описание проблемы */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value = 'Запрос на возврат денежных средств. Мошенничество.'
			) AND

		/* Группа назначения равно OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* Макрорегион не равно Москва*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			)

		/* Срок решения */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* Изменил РАВНО  
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     'Служебный пользователь для интеграции с CRM'
			   , 'Служебный пользователь для интеграции с UMB'
			   , 'Служебный пользователь для интеграции с WD'
			   , 'ms crm cc'
			   )
			) */

		/* Массовый инцидент НЕТ 
		IsMassIncident = 0 AND */

		/* Статус маркера не заполнено 
		StatusMarkerId IS NULL */

	) AS "PaymentProblems",









	/* Тарификация, Услуги Upsale */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* Состояние инцидента */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 'Назначена на группу'
			   , 'В работе'
			   )
			) AND

		/* Сервис равно */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      'Администрирование B2C'
				, 'Услуги Upsale'
				, 'Тарификация'
				, 'Умный ноль'
				)
			) AND

		/* Краткое описание проблемы */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value = 'Запрос на возврат денежных средств. Мошенничество.'
			) AND

		/* Группа назначения равно OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* Макрорегион не равно Москва*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			)

		/* Срок решения */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* Изменил РАВНО  */ 
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     'Служебный пользователь для интеграции с CRM'
			   , 'Служебный пользователь для интеграции с UMB'
			   , 'Служебный пользователь для интеграции с WD'
			   , 'ms crm cc'
			   )
			)

		/* Массовый инцидент НЕТ 
		IsMassIncident = 0 AND */

		/* Статус маркера не заполнено 
		StatusMarkerId IS NULL */

	) AS "TarificationUpsale",









	/* ТП Игровой */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* Состояние инцидента */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 'Назначена на группу'
			   , 'В работе'
			   )
			) AND

		/* Сервис равно */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      'Администрирование B2C'
				, 'ТП Игровой'
				)
			) AND

		/* Краткое описание проблемы */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value = 'Запрос на возврат денежных средств. Мошенничество.'
			) AND

		/* Группа назначения равно OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* Макрорегион не равно Москва*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			)

		/* Срок решения */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* Изменил РАВНО
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     'Служебный пользователь для интеграции с CRM'
			   , 'Служебный пользователь для интеграции с UMB'
			   , 'Служебный пользователь для интеграции с WD'
			   , 'ms crm cc'
			   )
			)  */

		/* Массовый инцидент НЕТ 
		IsMassIncident = 0 AND */

		/* Статус маркера не заполнено 
		StatusMarkerId IS NULL */

	) AS "Gaming",








	/* Умный ноль */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* Состояние инцидента */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 'Назначена на группу'
			   , 'В работе'
			   )
			) AND

		/* Сервис равно */
		ServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			      'Администрирование B2C'
				, 'Умный ноль'
				)
			) AND

		/* Краткое описание проблемы */
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value = 'Запрос на возврат денежных средств. Мошенничество.'
			) AND

		/* Группа назначения равно OBO */ 
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND

		/* Макрорегион не равно Москва*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			)

		/* Срок решения */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* Изменил РАВНО
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     'Служебный пользователь для интеграции с CRM'
			   , 'Служебный пользователь для интеграции с UMB'
			   , 'Служебный пользователь для интеграции с WD'
			   , 'ms crm cc'
			   )
			)  */

		/* Массовый инцидент НЕТ 
		IsMassIncident = 0 AND */

		/* Статус маркера не заполнено 
		StatusMarkerId IS NULL */

	) AS "SmartNull",







	/* Внешние запросы */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* Состояние инцидента */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 'Назначена на группу'
			   , 'В работе'
			   , 'Внешний запрос'
			   , 'Внутренний запрос'
			   )
			) AND

		/* Сервис равно */
		ServiceId IN (
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
			) AND

		/* Краткое описание проблемы */ 
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (
			     'Запрос на возврат денежных средств. Мошенничество.'
			   , 'Запрос компенсации'
			   , 'Разовое начисление компенсации'
			   )
			) AND

		/* Группа назначения равно OBO  
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND */

		/* Макрорегион не равно Москва*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			)

		/* Срок решения */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* Изменил РАВНО
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     'Служебный пользователь для интеграции с CRM'
			   , 'Служебный пользователь для интеграции с UMB'
			   , 'Служебный пользователь для интеграции с WD'
			   , 'ms crm cc'
			   )
			)  */

		/* Массовый инцидент НЕТ 
		IsMassIncident = 0 AND */

		/* Статус маркера не заполнено 
		StatusMarkerId IS NULL */

	) AS "ExternalRequests",








	/* Позвонить */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* Состояние инцидента */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 'Назначена на группу'
			   , 'Позвонить'
			   , 'Позвонить еще'
			   , 'Позвонить на время'
			   , 'Тестирование'
			   )
			) AND

		/* Сервис равно */
		ServiceId IN (
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
			) AND

		/* Краткое описание проблемы */ 
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (
			     'Запрос на возврат денежных средств. Мошенничество.'
			   , 'Запрос компенсации'
			   , 'Разовое начисление компенсации'
			   )
			) AND

		/* Группа назначения равно OBO  
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND */

		/* Макрорегион не равно Москва*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			)

		/* Срок решения */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* Изменил РАВНО
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     'Служебный пользователь для интеграции с CRM'
			   , 'Служебный пользователь для интеграции с UMB'
			   , 'Служебный пользователь для интеграции с WD'
			   , 'ms crm cc'
			   )
			)  */

		/* Массовый инцидент НЕТ 
		IsMassIncident = 0 AND */

		/* Статус маркера не заполнено 
		StatusMarkerId IS NULL */

	) AS "CallUp",










	/* Решенные */
	(   
		/*USE BPMonline_80*/
		SELECT COUNT (SR.Id)
		FROM ServiceRequest AS SR
		WHERE
		/* Состояние инцидента */
		StatusOfIncidentId IN (
			SELECT id
			FROM StatusOfIncident
			WHERE name IN (
				 'Назначена на группу'
			   , 'Решена'
			   )
			) AND

		/* Сервис равно */
		ServiceId IN (
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
			) AND

		/* Краткое описание проблемы */ 
		SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (
			     'Запрос на возврат денежных средств. Мошенничество.'
			   , 'Запрос компенсации'
			   , 'Разовое начисление компенсации'
			   )
			) AND

		/* Группа назначения равно OBO  
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND */

		/* Макрорегион не равно Москва*/
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name <> 'Москва'
			)

		/* Срок решения */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* Изменил РАВНО
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     'Служебный пользователь для интеграции с CRM'
			   , 'Служебный пользователь для интеграции с UMB'
			   , 'Служебный пользователь для интеграции с WD'
			   , 'ms crm cc'
			   )
			)  */

		/* Массовый инцидент НЕТ 
		IsMassIncident = 0 AND */

		/* Статус маркера не заполнено 
		StatusMarkerId IS NULL */

	) AS "Resolved",







	/* 2я база */
	(   
		/*USE BPMonline_80*/
		SELECT * /* COUNT (SR.Id)*/
		FROM ServiceRequest AS SR
		WHERE
		/* Состояние инцидента
		StatusOfIncidentId = (
			SELECT id
			FROM StatusOfIncident
			WHERE name = 'Назначена на группу'
			) AND */

		/* Сервис равно */
		/*ServiceId*/ TechServiceId IN (
			SELECT id, ServiceName, ServiceParentId
			FROM Service
			/*WHERE ServiceName = 'Переоформление номера с физ.лица на физ.лицо'*/
			WHERE ServiceName = 'Запрос на возврат денежных средств. Мошенничество'
			/*WHERE ServiceName = 'Администрирование B2C'*/
			/*WHERE id = 'B5AD8E37-ECD5-4EA8-8E68-23ABBE942016'*/
			/*WHERE id = '524A3A8E-FB29-E411-80BC-00155DFC1F77'*/
			) AND

		/* Краткое описание проблемы */ 
		/*SR.Id IN (
			SELECT ServiceRequestId
			FROM DescriptionInIncident
			WHERE Value IN (
			     'Запрос на возврат денежных средств. Мошенничество'
			   , 'Переоформление по смерти абонента'
			   , 'Переоформление номера с физ.лица на физ.лицо'
			   , 'Смена владельца'
			   )
			) AND*/
		TechServiceId IN (
			SELECT id
			FROM Service
			WHERE ServiceName IN (
			     'Запрос на возврат денежных средств. Мошенничество'
			   , 'Переоформление по смерти абонента'
			   , 'Переоформление номера с физ.лица на физ.лицо'
			   , 'Смена владельца'
			   )
			) AND

		/* Группа назначения равно OBO  
		DestionationGroupId = (
			SELECT Id
			FROM SysAdminUnit
			WHERE Name = 'OBO'
			) AND */
	
		(
		/* Макрорегион равно */
		MacroregionId IN ( 
			SELECT id
			FROM Macroregion
			WHERE name IN (
				'Байкал и Дальний Восток'
			  , 'Сибирь'
			  , 'Урал'
			) OR
		/* Регион равно */
		RegionCodeId IN ( 
			SELECT id
			FROM RegionCode
			WHERE name IN (
				'IZH'
			  , 'IZH-CDMA'
			)
		) AND

		/* Регион НЕ равно */
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

		/* Срок решения */
		/*DATEDIFF (hh, SolutionDate, current_timestamp) <= 36*/
		/*DATEADD(hh, 36, current_timestamp) <= SolutionDate*/
		/*DATEDIFF (hh, SolutionDate, CURRENT_TIME) <= 36*/
		/*SolutionDate between current_timestamp AND DATEADD(dd, 1, current_timestamp) AND*/
		
		/* Изменил РАВНО
		UmbChangingSystem ???
		IN (
			SELECT ???
			FROM ???
			WHERE Name IN (		
			     'Служебный пользователь для интеграции с CRM'
			   , 'Служебный пользователь для интеграции с UMB'
			   , 'Служебный пользователь для интеграции с WD'
			   , 'ms crm cc'
			   )
			)  */

		/* Массовый инцидент НЕТ 
		IsMassIncident = 0 AND */

		/* Статус маркера не заполнено 
		StatusMarkerId IS NULL */

	) AS "2base",









FROM
	ServiceRequest




		
-- Query the view  
SELECT 
	  CritAdmin AS 'Критичные админ'
	, CritProd AS 'Критичные Prod'
	, Returned AS 'Возвращённые'
	, New AS 'Новые'
	, USSD
	, BonusProgramm AS 'Бонусная программа'
	, ProfitTogether AS 'Выгодно вместе'
	, CustomerServiceComplaints AS 'Жалобы на обслуживание клиентов'
	, PaymentProblems AS 'Проблемы с платежами'
	, TarificationUpsale AS 'Тарификация, Услуги Upsale'
	, Gaming AS 'ТП Игровой'
	, SmartNull AS 'Умный ноль'
	, ExternalRequests AS 'Внешние запросы'
	, CallUp AS 'Позонить'
	, Resolved AS 'Решённые'
	, 2base AS '2я база'
	, AS ''
	, AS ''


FROM VwBPM5_RPA_OBO_COPS_Product_TT_Stats 










/* Различные тесты
USE BPMonline_80
SELECT id
FROM ServiceRequest;

SELECT SA
FROM ServiceRequest;
*/


/*Найти связанные таблицы
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
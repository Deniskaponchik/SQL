/*  */

USE BPMonline7_8888;

/*DECLARE @CountTG INTEGER*/

WITH
/* Выборка нужных для задачи параметров из различных таблиц */
NewCase (sr, begin_time, UsrParametersSet, CircuitFULL, circuit_id, switch_id, traffic, operator, DestTrunkGroup, BunchText, bunch_type, region_id) AS (
SELECT
	/* sr - кликабельный номер обращения (синий, подчеркнутый) */
	Number,
	/* begin_time - дата регистрации обращения (МСК) */
	RegisteredOn,
	UsrParametersSet,

	/* circuit_id - Из параметров. <Наименование транковых групп>. 
	Если наименований в данном поле несколько - то строк в отчете будет несколько по данному обращению. 
	все значения полей дублируются кроме данного. 
	В каждой строчке по обращению - уникальное значение (см выше секцию "Уникальность строки") */
	(
	   REPLACE(
	      REPLACE(
		     (
		         SELECT VALUE
	             FROM STRING_SPLIT (UsrParametersSet, char(10))
	             WHERE value LIKE '5.Наименование транковых групп:%' OR value LIKE '60.Наименование транковых групп%'
	          ), '5.Наименование транковых групп: ' , ''
		  ), '60.Наименование транковых групп: ', ''
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
	                                      WHERE value LIKE '60.Наименование транковых групп%' OR value LIKE '5.Наименование транковых групп:%'
						               ), '60.Наименование транковых групп: ', ''
							       ), '5.Наименование транковых групп: ', ''
							    ), '\' , ','	
						     ), ';' , ','
						  ), '-' , ','
						), ' ' , ','
	                 ), ':' , ','
				), '/', ','
			 ), '.', ','
		  ), '|', ','
		  /*), '[А-Яа-я]', ''*/
	   )
	) circuit_id,
	/* Также можно добавить:	= + @ #    	*/


	
	(   /* switch_id - Из параметров. <Номер коммутатора> */
	   REPLACE(
	      REPLACE(
		     (
		         SELECT VALUE
	             FROM STRING_SPLIT (UsrParametersSet, char(10))
	             WHERE value LIKE '3.Номер коммутатора:%' OR value LIKE '40.Номер коммутатора:%'
	          ), '3.Номер коммутатора: ' , ''
		  ), '40.Номер коммутатора: ', ''
	   )
	) switch_id,


	/* description - Все из параметров (в том числе Регион - тоже из доп. параметров). Есть особенность для поля "Регион". В одной услуге это уникальный выбор, в другой множественный. в поле отчета, если значений несколько - вывести все через ','. Следующая конструкция для заполнения поля:
       <Регион/ы>, <Тип трафика>,  <Оператор связи>, <Протокол соединения>, <Назначение транковых групп> */
	/* Пока что выведу все необходимые поля, а потом в итоговом селекте объеденю STRING_AGG */
	( /* Тип трафика */
	   REPLACE(
	      REPLACE(
		     (
		         SELECT VALUE
	             FROM STRING_SPLIT (UsrParametersSet, char(10))
	             WHERE value LIKE '2.Тип трафика:%' OR value LIKE '45.Тип трафика:%'
	          ), '2.Тип трафика: ' , ''
		  ), '45.Тип трафика: ', ''
	   )
	) traffic,
	( /* Оператор связи */
	 /*  REPLACE(*/
	      REPLACE(
		     (
		         SELECT VALUE
	             FROM STRING_SPLIT (UsrParametersSet, char(10))
	             WHERE value LIKE '51.Оператор связи:%' /*OR value LIKE '45.Тип трафика:%'*/
	          ), '51.Оператор связи: ' , ''
		 /* ), '45.Тип трафика: ', ''*/
	   )
	) operator,
	/* ??? Протокол соединения ???
	( 
	   REPLACE(
	      REPLACE(
		     (
		         SELECT VALUE
	             FROM STRING_SPLIT (UsrParametersSet, char(10))
	             WHERE value LIKE '2.Протокол соединения:%' OR value LIKE '45.Тип трафика:%'
	          ), '2.Протокол соединения: ' , ''
		  ), '45.Тип трафика: ', ''
	   )
	) protocol, */
	( /* Назначение транковых групп */
	   REPLACE(
	      REPLACE(
		     (
		         SELECT VALUE
	             FROM STRING_SPLIT (UsrParametersSet, char(10))
	             WHERE value LIKE '90.Назначение транковых групп:%' OR value LIKE '7.Назначение транковых групп:%'
	          ), '90.Назначение транковых групп: ' , ''
		  ), '7.Назначение транковых групп: ', ''
	   )
	) DestTrunkGroup,



	/* bunch_type - Из параметров. Вычисляемое значение. Все выбранные из справочника параметры в числовом представлении, где:
		0 – входящий		1 – исходящий			3 – двунаправленные
	    Например, если выбрано "входящий;двуноправленные" в поле выводить "0,3" */
	(
	   SELECT right(rtrim(VALUE),charindex(' ',reverse(rtrim(VALUE))+' ')-1)
	   from (
		     SELECT VALUE
	         FROM STRING_SPLIT (UsrParametersSet, char(10))
	         WHERE value LIKE '6.Характеристики%' OR value LIKE '80.Характеристики%'
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
	                       WHERE value LIKE '6.Характеристики%' OR value LIKE '80.Характеристики%'
					    ) Bun
	                 ), ';' , ','
				), 'двунаправленные', '3'
			 ), 'исходящий', '1'
		  ), 'входящий', '0'
	   )
	) bunch_type,




	/* РЕГИОН */
	/* region_id - Регион (Поле из доп параметров. Если выбрано несколько значений - через ,) */
	/* с Регионом работает и в таком виде нормально. Только с Центральными функциями проблема
	(
	   REPLACE(
	      (
	      SELECT right(rtrim(VALUE),charindex(' ',reverse(rtrim(VALUE))+' ')-1)
	      from (
		        SELECT VALUE
	            FROM STRING_SPLIT (UsrParametersSet, char(10))
	            WHERE value LIKE '10.Регион%' OR value LIKE '1.Регион%'
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
	                       WHERE value LIKE '10.Регион:%' OR value LIKE '1.Регион:%'
	                 ), ';' , ','
				), '10.Регион: ', ''
			 ), '1.Регион: ', ''
	   )
	) region_id

FROM [BPMonline7_8888].[dbo].[Case] AS с
WHERE 
	/* Услуга РАВНО ("New Trgroup" ИЛИ "New TRGroup INT" */
	ServiceItemId IN (
		SELECT id
		FROM ServiceItem
		WHERE Name IN (
			'New Trgroup'
		  , 'New TRGroup INT'
		  )
	) AND 
	/* Состояние РАВНО (Решено ИЛИ Закрыто */
	StatusId IN (
		SELECT id
		FROM CaseStatus
		WHERE Name IN (
			'Решено'
		  , 'Закрыто'
		  )
	)

	/* Фактическое разрешение РАВНО "Предыдущий месяц" 
	/*MONTH(SolutionProvidedOn) = MONTH(DATEADD(NOW(), INTERVAL -1 MONTH)) AND YEAR(SolutionProvidedOn) = YEAR(NOW())*/
	/*MONTH(SolutionProvidedOn) = MONTH(DATEADD(NOW(), INTERVAL -1 MONTH)) and
	YEAR(SolutionProvidedOn) = YEAR(DATEADD(NOW(), INTERVAL -1 MONTH))*/
	(
		SolutionProvidedOn < datefromparts(year(getdate()), month(getdate()), 1) and
		SolutionProvidedOn >= dateadd(month, 1, datefromparts(year(getdate()), month(getdate()), 1))
	) */

)
	  

SELECT
	/* id - пустое поле */
	Null AS id,
	/* id_type - выводить "0" */
	0 AS id_type,
	/* bunch_id - пустое поле */
	Null AS id,
	/* circuit_id - Из параметров. <Наименование транковых групп>. 
	Если наименований в данном поле несколько - то строк в отчете будет несколько по данному обращению. 
	все значения полей дублируются кроме данного. 
	В каждой строчке по обращению - уникальное значение (см выше секцию "Уникальность строки") */
	CircuitFULL,
	value circuit_id,
    /* equipment_type - пустое поле */
	Null AS equipment_type,
    /* mac - пустое поле */
	Null AS mac,
    /* vpi - пустое поле */
	Null AS vpi,
    /* vci - пустое поле */
	Null AS vci,
    /* switch_id - Из параметров. <Номер коммутатора> */
	switch_id,
	/* bunch_type - Из параметров. Вычисляемое значение. Все выбранные из справочника параметры в числовом представлении, где:
		0 – входящий		1 – исходящий			3 – двунаправленные
	    Например, если выбрано "входящий;двуноправленные" в поле выводить "0,3" */
	bunch_type,
	/* description - Все из параметров (в том числе Регион - тоже из доп. параметров). Есть особенность для поля "Регион". В одной услуге это уникальный выбор, в другой множественный. в поле отчета, если значений несколько - вывести все через ','. Следующая конструкция для заполнения поля:
      <Регион/ы>, <Тип трафика>,  <Оператор связи>, <Протокол соединения>, <Назначение транковых групп> */

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

	/* begin_time - дата регистрации обращения (МСК) */
	begin_time,
	/* end_time - пустое поле */
	Null AS end_time,
	/* region_id - Регион (Поле из доп параметров. Если выбрано несколько значений - через ,) */
	region_id ,
	/* upload_time - пустое поле */ 
	Null AS upload_time,
    /* file_id - пустое поле */
	Null AS file_id,
	/* sr - кликабельный номер обращения (синий, подчеркнутый) */
	sr


FROM NewCase
cross apply
STRING_SPLIT (circuit_id, ',')

WHERE circuit_id NOT LIKE '%[А-Яа-я]%' /*AND circuit_id NOT LIKE ' '*/


ORDER BY begin_time DESC








/* Иван
USE BPMonline7_8888
select 
		 syst.name AS Система
       , serv.name AS Услуга
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
ORDER BY Система*/


/* ВСЯКИЕ ТЕСТЫ */
/* ServiceItem.Id = Cases.ServiceItemId = TRUE 
SELECT ServiceItem.Id, ServiceItem.Name, Cases.ServiceItemId
FROM [BPMonline7_8888].[dbo].[ServiceItem] AS ServiceItem
JOIN [BPMonline7_8888].[dbo].[Case] AS Cases
ON ServiceItem.Id = Cases.ServiceItemId */



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
        WHERE OBJECT_NAME(f.parent_object_id)='SysAdminUnit'    /* указать таблицу, по которой хотим связи*/
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
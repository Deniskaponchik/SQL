USE BPMonline7_14880;

WITH
/* Выборка нужных для задачи параметров из различных таблиц */
NewCase (sr, srid, begin_time, UsrParametersSet, CircuitFULL, circuit_id, switch_id, traffic, operator, protocol, DestTrunkGroup, BunchText, bunch_type, region_id) AS (
SELECT
	/* sr - кликабельный номер обращения (синий, подчеркнутый) */
	Number,
	id,
	/* begin_time - дата регистрации обращения (МСК) */
	RegisteredOn,
	UsrParametersSet,
	/*
	(SELECT stringvalue FROM UsrSpecificationInCase where usrcase.id = c.id and SpecificationID = ''),
	sic.*, ss.*
	*/


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
									replace(
				   		               (
											  SELECT VALUE
											  FROM STRING_SPLIT (UsrParametersSet, char(10))
											  WHERE value LIKE '60.Наименование транковых групп%' OR value LIKE '5.Наименование транковых групп:%'
										   ), '60.Наименование транковых групп: ', ''
									   ), '5.Наименование транковых групп: ', ''
								   ), ', ',','
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
	/* Протокол соединения */
	( 
	   REPLACE(
	      REPLACE(
		     (
		         SELECT VALUE
	             FROM STRING_SPLIT (UsrParametersSet, char(10))
	             WHERE value LIKE '91.Протокол соединения:%' OR value LIKE '92.Протокол соединения:%'
	          ), '91.Протокол соединения: ' , ''
		  ), '92.Протокол соединения: ', ''
	   )
	) protocol,
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

	/*,SolutionDate*/

FROM [Case] AS c

/*
LEFT JOIN UsrSpecificationInCase sis on sic.UsrCaseId = c.id
LEFT JOIN UsrSpecification ss on ss.id = sic.SpecificationId
*/

WHERE 
	/* Услуга РАВНО ("New Trgroup" ИЛИ "New TRGroup INT" 
	ServiceItemId IN (
		SELECT id
		FROM ServiceItem
		WHERE Name IN (
			'New Trgroup'
		  , 'New TRGroup INT'
		  )

	) AND  */

	/* Состояние РАВНО (Решено ИЛИ Закрыто 
	StatusId IN (
		SELECT id
		FROM CaseStatus
		WHERE Name IN (
			'Решено'
		  , 'Закрыто'
		  )
	) */

	
	/*ORDER BY SolutionDate DESC*/
	/*ORDER BY RegisteredOn DESC*/
	Number = 'SR04826173'

	/* Фактическое разрешение РАВНО "Предыдущий месяц" */
	/*(  Иван 
		SolutionProvidedOn > datefromparts(year(getdate()), month(getdate()), 1) and
		SolutionProvidedOn <= dateadd(month, 1, datefromparts(year(getdate()), month(getdate()), 1))
	) */
	/* StackOverflow */
	/*(   
		SolutionProvidedOn < datefromparts(year(getdate()), month(getdate()), 1) and
		SolutionProvidedOn >= dateadd(month, 1, datefromparts(year(getdate()), month(getdate()), 1))
	) */
	/*(SolutionProvidedOn between cast('01-01-2022' as datetime2) and cast('02-01-2022' as datetime2))*/
	/* Константин
	(
	SolutionProvidedOn between dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))
	and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))
	)*/

)
	  

SELECT
	/* id - пустое поле */
	Null AS id,
	/* id_type - выводить "0" */
	0 AS id_type,
	/* bunch_id - пустое поле */
	Null AS bunch_id,
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
	sr,
	'https://bpm.tele2.ru/0/Nui/ViewModule.aspx#CardModuleV2/CasePage/edit/'+cast(srid as nvarchar(64))


FROM NewCase
cross apply
STRING_SPLIT (circuit_id, ',')

/*WHERE circuit_id NOT LIKE '%[А-Яа-я]%' AND circuit_id NOT LIKE ' '*/

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
and cs.Name in ('Решено','Закрыто')
/*
and c.SolutionProvidedOn between dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2)))) 
and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))
*/
and c.Number IN ('SR04377502','SR04223621')











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



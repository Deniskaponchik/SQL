--USE BPMonline7_8888;

select
--c.Subject [Описание]
replace(replace(replace(replace(c.Subject, char(10), ' '), char(13), ' '), ';', ' '), '^', ' ') [Описание]
,cscl.Name [Состояние обращения]
,s.Name [Система]
,u.Name [Услуга]
,con.name [Автор]
,chan.name [Изменил]
--,format((dateadd(hh, +3, cl.StartDate)),'dd-MM-yyyy HH:mm:ss') [Дата изменения]
--,format((dateadd(hh, +3, c.RegisteredOn)),'dd-MM-yyyy HH:mm:ss') [Дата регистрации]
--,format((dateadd(hh, +3, c.RespondedOn)),'dd-MM-yyyy HH:mm:ss') [Фактическая реакция]
--,format((dateadd(hh, +3, c.SolutionProvidedOn)),'dd-MM-yyyy HH:mm:ss') [Фактическое решение]
,cast((dateadd(hh,+3,cl.StartDate)) as smalldatetime) [Дата изменения]
,cast((dateadd(hh,+3,c.RegisteredON)) as smalldatetime) [Дата регистрации] 
,cast((dateadd(hh,+3,c.RespondedOn)) as smalldatetime) [Фактическая реакция]
,cast((dateadd(hh,+3,c.SolutionProvidedOn)) as smalldatetime) [Фактическое решение]
,res.Name [Решил]
,reg.Name [Регион]
,c.Number [Номер]
,cc.Name [Код закрытия]
--,c.Solution [Решение]
,replace(replace(replace(replace(c.Solution, char(10), ' '), char(13), ' '), ';', ' '), '^', ' ') [Решение]
--,c.UsrParametersSet [Перечень параметров]
,replace(replace(replace(replace(c.UsrParametersSet, char(10), ' '), char(13), ' '), ';', ' '), '^', ' ') [Перечень параметров]
,otv.Name [Ответсвенный]

from 
CaseLifecycle cl 
left join [case] c on c.id = cl.CaseId
left join CaseStatus cs on cs.id = c.StatusId
left join ServiceItem s on s.id = c.UsrSystemId
left join ServiceItem u on u.id = c.ServiceItemId
left join Contact con on con.id = c.UsrAuthorId
left join Contact chan on chan.id = cl.OwnerId
left join Contact res on res.id = c.UsrResolvedContactId
left join UsrRegionCode reg on reg.id = c.UsrRegionId
left join ClosureCode cc on cc.Id = c.ClosureCodeId
left join Contact otv on otv.id = c.OwnerId
left join CaseStatus cscl on cscl.id = cl.StatusId
where 
--format (dateadd (hh, +3, cl.StartDate),'dd-MM-yyyy') = format (dateadd(day,-1,GETDATE()),'dd-MM-yyyy')
  cast (dateadd (hh, +3, cl.StartDate) as date) = cast (dateadd(day,-1,GETDATE()) as date)  --MAIN
--cast (dateadd (hh, +3, cl.StartDate) as date) = '2021-07-26'
--select cast (dateadd(day,-1,GETDATE()) as date)
--CONVERT(date,dateadd (hh, +3, cl.StartDate),101) = '2021-07-25'


and cl.StatusID NOT IN (
	 '3E7F420C-F46B-1410-FC9A-0050BA5D6C38'
	,'AE5F2F10-F46B-1410-FD9A-0050BA5D6C38'
	)
and (   /* Система + Услуга */
		c.ServiceItemId IN (
			 '4AC419E8-90A0-4A27-BA33-EA405499CA38' /* Система: "Сотовая связь" Услуги:"Пополнение баланса" */
			,'850FBD0D-571D-4F0A-9E28-98BF9B4721C9' /* Система: "Сотовая связь" Услуги:"Отключение лимита" */
			,'DD906579-3AD1-4114-887D-3B855FABFA05' /* Система: "Калибровки TT" Услуги:"Калибровка 1-го уровня.Розница" */
			,'1DD39028-135E-4160-AC16-201A2F89602E' /* Система: "Калибровки TT" Услуги:"Калибровка 2-го уровня.Розница" */
			,'4FF2199F-BA1B-42FD-B6CD-8B9C69DDB55B' /* Система: "Калибровки TT" Услуги:"Калибровка 1-го уровня" */
			,'EA4E3AE7-FBC6-4FF5-9C39-E7C7B337D8DA' /* Система: "Калибровки TT" Услуги:"Калибровка 2-го уровня" */
			,'08ED7BA6-B120-468E-AA21-62D9B94D92A8' /* Система: "Калибровки TT" Услуги:"Калибровка. Доработанные ТТ" */
			,'6C6AD89F-35AA-4D24-AFA2-E8C3CB1CF56B' /* Система: "Токсичные подписки" Услуги:"Довозвраты" */
			,'B26D4F47-8F7B-4CAF-AB4E-C7A93547FBBD' /* Система: "Общие папки предоставление доступа" Услуги:"Ростов-на-Дону (КЦ)" */
		)
	OR  /* все Услуги из Системы */
		c.UsrSystemId IN (
			 '2262F226-B4DD-45AD-8FE7-0598804152AA' /* Система: "OBO"							   Услуги:ВСЕ */
			,'C9EAF329-8EDF-4FCC-9E15-271D033022F2' /* Система: "Отчетность КЦ"					   Услуги:ВСЕ */
			,'4E8EFF9B-BA7F-4E45-BC0C-07052B067E81' /* Система: "Прогнозирование КЦ"	           Услуги:ВСЕ */
			,'D15C721D-8D59-45DB-AB3B-84CC52E2718A' /* Система: "Кадровое администрирование"       Услуги:ВСЕ */
			,'1B29C659-13F1-488F-A7BE-C4FCD90D63D8' /* Система: "Поддержка дистанционного сервиса" Услуги:ВСЕ */
			,'0CD0C891-D1E7-4558-AF39-678923DFB2C3' /* Система: "Контроллинг ОБО"                  Услуги:ВСЕ */
			,'BAFBF911-C1B5-4B43-820A-5BCA13C62122' /* Система: "Служебная сотовая связь"          Услуги:ВСЕ */
			,'04156b2c-c78d-45cd-9cfe-3739a5687e7f' /* Система: "Реактивное удержание"             Услуги:ВСЕ */
		)
)
order by c.Number, cl.StartDate






 
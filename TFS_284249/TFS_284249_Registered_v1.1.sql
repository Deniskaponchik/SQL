--Registered ON LAST DAY
USE BPMonline_80;

Declare @SR Table(
Id	uniqueidentifier,
Number	nvarchar(250),
RegisteredOn	datetime2(3),
ServiceRequestTypeId	uniqueidentifier,
ServiceId	uniqueidentifier,
TechServiceId	uniqueidentifier,
StatusOfIncidentId	uniqueidentifier,
SolutionDate	datetime2(3),
SolutionOverdue	bit,
ClosureDate	datetime2(3)
);

Declare @CII Table(
OldGroupId	uniqueidentifier,
NewGroupId	uniqueidentifier,
NewStatusOfIncidentId	uniqueidentifier,
RightChangeDate	datetime2(3),
RightNotChangingTime	int,
ServiceRequestId	uniqueidentifier
);

Declare @GroupTimeCii0 Table(
ServiceRequestId	uniqueidentifier,
OldGroupId	uniqueidentifier,
MaxChangeDate	datetime2(3)
);


Declare @GroupTimeCii2 Table(
ServiceRequestId	uniqueidentifier,
OldGroupId	uniqueidentifier,
MaxNotChangingTime int,
MinNotChangingTime int,
SumNotChangingTime int
);

--Таблица с необходимыми заявками, на которую в последствие ссылаются все остальные
INSERT INTO @SR (id, Number, RegisteredOn, ServiceRequestTypeId, ServiceId, TechServiceId, StatusOfIncidentId, SolutionDate, SolutionOverdue, ClosureDate)
	SELECT id, Number
	, dateadd(hh, +3, RegisteredOn) RegisteredOn
	, ServiceRequestTypeId, ServiceId, TechServiceId, StatusOfIncidentId
	, dateadd(hh, +3, SolutionProvidedOn) SolutionProvidedOn
	, SolutionOverdue
	, dateadd(hh, +3, ClosureDate) ClosureDate
	FROM ServiceRequest
    WHERE ServiceRequestTypeId <> 'E8A1B4D7-9BA5-4BEF-8ED0-E7DB10E451BF' /* Тип обращения не NOC */
	and RegisteredOn >= dateadd(day,-1,getdate())
	--and ClosureDate >= dateadd(day,-1,getdate())


--Выборка из CounterInIncident с нужными заявками. CounterInIncident скрещивается с самой собой с полями -1
INSERT INTO @CII (OldGroupId,NewGroupId,NewStatusOfIncidentId,RightChangeDate,RightNotChangingTime,ServiceRequestId)
SELECT cii1.OldGroupId,cii1.NewGroupId,NewStatusOfIncidentId
  ,case
	   when cii1.OldGroupId = cii1.NewGroupId then cii2.CreatedOn
	   else cii1.CreatedOn
  END RightChangeDate
--	,cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int)
  ,case
	   when cii1.OldGroupId <> cii1.NewGroupId AND cii2.OldGroupId <> cii2.NewGroupId then cii1.NotChangingTime
	   when cii1.OldGroupId <> cii1.NewGroupId AND cii2.OldGroupId = cii2.NewGroupId then NULL
	   when cii1.OldGroupId = cii1.NewGroupId then cii1.NotChangingTime + cii2.NotChangingTime
  END RightNotChangingTime
  ,ServiceRequestId
FROM (
	SELECT row_number() OVER(ORDER BY ServiceRequestId, CreatedOn) RowNumber
	,OldGroupId,NewGroupId,NewStatusOfIncidentId,CreatedOn
	,cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int) AS NotChangingTime
	,ServiceRequestId
	FROM CounterInIncident
	WHERE
		ServiceRequestId IN ( SELECT id FROM @SR )
	  --ServiceRequestId = '21B4DAB5-5E14-424A-B012-75B7034BF64E'
		AND NotChangingTime != ''
) cii1
left join (
	SELECT -1+row_number() OVER(ORDER BY ServiceRequestId, CreatedOn) RowNumber
		,OldGroupId,NewGroupId,CreatedOn
		,cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int) AS NotChangingTime
	FROM CounterInIncident
	WHERE
		ServiceRequestId IN ( SELECT id FROM @SR )
	  --ServiceRequestId = '21B4DAB5-5E14-424A-B012-75B7034BF64E'
		AND NotChangingTime != ''
) cii2 ON cii1.RowNumber = cii2.RowNumber


--Выборка 'Дата перевода на группу'
INSERT INTO @GroupTimeCii0 (ServiceRequestId,OldGroupId,MaxChangeDate)
	SELECT ServiceRequestId, OldGroupID, MAX(RightChangeDate)
	FROM @CII
	WHERE OldGroupID IS NOT NULL
	GROUP BY ServiceRequestId, OldGroupID

--В полях Общее время обработки (мин.), Максимальное время обработки группой (мин.), Минимальное время обработки группой (мин.), Время обработки группой (мин.) 
--не должны участвовать значения, у которых "Новое значение статуса" во вкладке счетчики равно “Внешний запрос”, “Внутренний запрос” или “Возвращена на доработку
INSERT INTO @GroupTimeCii2 (ServiceRequestId,OldGroupId,MaxNotChangingTime,MinNotChangingTime,SumNotChangingTime)
	SELECT    ServiceRequestId
			, OldGroupId
			, MAX(RightNotChangingTime)
			, MIN(RightNotChangingTime)
			, SUM(RightNotChangingTime)
	from @CII
	/* В полях Общее время обработки (мин.), Максимальное время обработки группой (мин.), Минимальное время обработки группой (мин.), Время обработки группой (мин.) 
	не должны участвовать значения, у которых "Новое значение статуса" во вкладке счетчики равно “Внешний запрос”, “Внутренний запрос” или “Возвращена на доработку */
	WHERE NewStatusOfIncidentId NOT IN (
			 'F0B04982-4C74-4FD4-ACD8-05FE186C36FF' /*Внешний запрос*/
			,'6B0131D0-CF34-4ECA-BDBB-00DA49445B77' /*Внутренний запрос*/
			,'D103AB39-7628-4447-8FE8-02C9F1490DD6' /*Возвращена на доработку*/
			)
	GROUP BY ServiceRequestId, OldGroupID


SELECT
SR.Number AS 'Номер заявки'
,SOI.Name AS 'Статус'
,SR.RegisteredOn AS 'Дата регистрации'
,SRT.Name 'Тип обращения'
,S.ServiceName 'Сервис'
,Sc.ServiceName 'Краткое описание проблемы'
,SR.SolutionDate 'Срок решения'
,REPLACE(REPLACE(SR.SolutionOverdue, '0','нет'),'1','да') AS 'Просрочен'
,SumFullCII.SumFullNotChangingTime 'Общее время обработки (мин.)'
,GroupTimeCii.MaxNotChangingTime 'Максимальное время обработки группой (мин.)'
,GroupTimeCii.MinNotChangingTime 'Минимальное время обработки группой (мин.)'
,GroupTimeCii.OldGroupID 'Группа'
,GroupTimeCII.MaxChangeDate 'Дата перевода на группу'
,GroupTimeCii.SumNotChangingTime 'Время обработки группой (мин.)'

FROM @sr sr
LEFT JOIN ServiceRequestType SRT WITH(NOLOCK) ON SRT.Id = SR.ServiceRequestTypeId
LEFT JOIN Service S WITH(NOLOCK) ON S.Id = SR.ServiceId
LEFT JOIN Service Sc WITH(NOLOCK) ON Sc.Id = SR.TechServiceId
LEFT JOIN StatusOfIncident SOI WITH(NOLOCK) ON SOI.Id = SR.StatusOfIncidentId
LEFT JOIN ( --'Общее время обработки (мин.)'
	SELECT ServiceRequestId, SUM(SumNotChangingTime) SumFullNotChangingTime
	FROM @GroupTimeCii2
	GROUP BY ServiceRequestId
	) SumFullCII ON sr.id = SumFullCII.ServiceRequestId

OUTER APPLY (
	SELECT
	  SAU.Name AS OldGroupID
	, MaxNotChangingTime
	, MinNotChangingTime
	, SumNotChangingTime
	, MaxChangeDate
	FROM
	@GroupTimeCii0 GroupTimeCii0
	LEFT JOIN @GroupTimeCii2 GroupTimeCii2 ON GroupTimeCii2.ServiceRequestId = GroupTimeCii0.ServiceRequestId
											    AND GroupTimeCII0.OldGroupId = GroupTimeCII2.OldGroupId
	LEFT JOIN SysAdminUnit SAU WITH(NOLOCK) ON SAU.Id = GroupTimeCII0.OldGroupId
	WHERE SR.id = GroupTimeCii0.ServiceRequestId
) GroupTimeCII

















/*
--Попробую потом подсчитать сумму из GroupTimeCii2
Declare @SumFullCII Table(
ServiceRequestId	uniqueidentifier,
SumFullNotChangingTime int
);*/



/*
--Попробую потом подсчитать сумму из GroupTimeCii2
--Общее время обработки (мин.) (вкладка счетчики. В минутах суммирует все значения из поля "время") 
INSERT INTO @SumFullCII (ServiceRequestId, SumFullNotChangingTime)
	SELECT ServiceRequestId, SUM(cast(
		SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + 
		SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 +  
		SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3)) 
		as int)
	) SumFullNotChangingTime
	FROM CounterInIncident AS CII1
	WHERE NewStatusOfIncidentId NOT IN (
		 'F0B04982-4C74-4FD4-ACD8-05FE186C36FF' /*Внешний запрос*/
		,'6B0131D0-CF34-4ECA-BDBB-00DA49445B77' /*Внутренний запрос*/
		,'D103AB39-7628-4447-8FE8-02C9F1490DD6' /*Возвращена на доработку*/
		)
	AND NotChangingTime != ''
	AND ServiceRequestId IN ( SELECT id FROM @SR )
	GROUP BY ServiceRequestId*/




	/*
/* CLOSED ON LAST DAY */
USE BPMonline_80;
SELECT 
 SR.Number AS 'Номер заявки'
,SOI.Name AS 'Статус'
,SR.RegisteredOn AS 'Дата регистрации'
,SRT.Name 'Тип обращения'
,S.ServiceName 'Сервис'
,Sc.ServiceName 'Краткое описание проблемы'
,SR.SolutionDate 'Срок решения'
/*,SR.ClosureDate 'Дата закрытия'*/
/*,SR.SolutionOverdue*/
/*,IF(SR.SolutionOverdue = 0,  ) AS 'Просрочен'*/
,REPLACE(REPLACE(SR.SolutionOverdue, '0','нет'),'1','да') AS 'Просрочен'
,SumFullCII.SumFullNotChangingTime 'Общее время обработки (мин.)'
,GroupTimeCII.MaxNotChangingTime 'Максимальное время обработки группой (мин.)'
,GroupTimeCII.MinNotChangingTime 'Минимальное время обработки группой (мин.)'
,GroupTimeCII.OldGroupID 'Группа' /*NewGroupId*/
/*,GroupTimeCII.NewGroupID 'Новая' /*NewGroupId*/*/
,GroupTimeCII.MaxChangeDate 'Дата перевода на группу'
,GroupTimeCII.SumNotChangingTime 'Время обработки группой (мин.)'
/*,vIOGT.DefferedSolution DefferedSolution
,vIOGT.DefferedTime DefferedTime */


 FROM
 /*ServiceRequest SR WITH(NOLOCK)*/
 (SELECT id, Number, RegisteredOn, ServiceRequestTypeId, ServiceId, TechServiceId, StatusOfIncidentId, SolutionDate, SolutionOverdue, ClosureDate
    FROM ServiceRequest
    WHERE TypeId <> 'E8A1B4D7-9BA5-4BEF-8ED0-E7DB10E451BF' /* Тип обращения не NOC */
   /*AND SAU.Name IS NOT NULL*/
	and ClosureDate >= dateadd(day,-1,getdate())
	/*ORDER BY Number*/
) SR
/*LEFT JOIN VwIncidentOnGroupTime vIOGT WITH(NOLOCK) ON vIOGT.ServiceRequestId = SR.Id */
--SELECT TOP (100) * FROM VwIncidentOnGroupTime
LEFT JOIN ServiceRequestType SRT WITH(NOLOCK) ON SRT.Id = SR.ServiceRequestTypeId
LEFT JOIN Service S WITH(NOLOCK) ON S.Id = SR.ServiceId
LEFT JOIN Service Sc WITH(NOLOCK) ON Sc.Id = SR.TechServiceId
/*LEFT JOIN SysAdminUnit SAU WITH(NOLOCK) ON SAU.Id = vIOGT.GroupId*/
LEFT JOIN StatusOfIncident SOI WITH(NOLOCK) ON SOI.Id = SR.StatusOfIncidentId

/* Общее время обработки (мин.) (вкладка счетчики. В минутах суммирует все значения из поля "время") */
LEFT JOIN ( 
	SELECT ServiceRequestId, SUM(cast(
		SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + 
		SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 +  
		SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3)) 
		as int)
	) SumFullNotChangingTime
	FROM CounterInIncident AS CII1
	WHERE NewStatusOfIncidentId NOT IN (
		 'F0B04982-4C74-4FD4-ACD8-05FE186C36FF' /*Внешний запрос*/
		,'6B0131D0-CF34-4ECA-BDBB-00DA49445B77' /*Внутренний запрос*/
		,'D103AB39-7628-4447-8FE8-02C9F1490DD6' /*Возвращена на доработку*/
		)
	AND NotChangingTime != ''
	AND ServiceRequestId IN (
		SELECT id
		FROM ServiceRequest
		WHERE TypeId <> 'E8A1B4D7-9BA5-4BEF-8ED0-E7DB10E451BF' /* Тип обращения не NOC */
		and ClosureDate >= dateadd(day,-1,getdate())
		)
	GROUP BY ServiceRequestId
) SumFullCII ON SumFullCII.ServiceRequestId = SR.Id


/* Группа (владка счетчики. Должно попадать каждое уникальное значение из "Старое значение группы". 
   По аналогии с примером будет 2 строки: группа A, группа B). */
OUTER APPLY (
SELECT 
  SAU.Name AS OldGroupID
, MaxNotChangingTime
, MinNotChangingTime
, SumNotChangingTime
/* Дата перевода на группу (вкладка счетчики. Поле пустое, если "Старое значение группы" = "Новое значение группы" во всех случаях. 
Если группа менялась, то поле будет равно последней дате перевода на группу из предыдущего столбца). */
, case
	when EXISTS (
		SELECT ServiceRequestId, NewGroupId, ChangeDate
		FROM CounterInIncident cii3
		WHERE CII3.ServiceRequestId = GroupTimeCII3.ServiceRequestId
		  AND cii3.ChangeDate = GroupTimeCII3.MAXChangeDate
		  and cii3.NewGroupid = GroupTimeCII3.OldGroupID
		) then NULL
	else MaxChangeDate
end MaxChangeDate
FROM (
	select 
	  GroupTimeCII1.ServiceRequestId AS ServiceRequestId
	, GroupTimeCII1.OldGroupId AS OldGroupID
	, MaxNotChangingTime
	, MinNotChangingTime
	, SumNotChangingTime
	, MaxChangeDate
	FROM ( /* Таблица получает MaxChangeDate в тех строках, где OldGroupID не ноль. Исключений по NewStatusOfIncidentId нет */
		SELECT 
			ServiceRequestId
		  , OldGroupID
		  , MAX(ChangeDate) MaxChangeDate
		FROM CounterInIncident cii0
		WHERE SR.Id = cii0.ServiceRequestId AND CII0.OldGroupID IS NOT NULL
		GROUP BY CII0.ServiceRequestId, CII0.OldGroupID
		) GroupTimeCII1
	LEFT JOIN (
		SELECT
			  ServiceRequestId
			, CII2.OldGroupId
			, MAX(cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int)
			) MaxNotChangingTime 
			, MIN(cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int)
			) MinNotChangingTime
			, SUM(cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int)
			) SumNotChangingTime
		from CounterInIncident AS CII2
		/* В полях Общее время обработки (мин.), Максимальное время обработки группой (мин.), Минимальное время обработки группой (мин.), Время обработки группой (мин.) 
		не должны участвовать значения, у которых "Новое значение статуса" во вкладке счетчики равно “Внешний запрос”, “Внутренний запрос” или “Возвращена на доработку */
		WHERE NewStatusOfIncidentId NOT IN (
				 'F0B04982-4C74-4FD4-ACD8-05FE186C36FF' /*Внешний запрос*/
				,'6B0131D0-CF34-4ECA-BDBB-00DA49445B77' /*Внутренний запрос*/
				,'D103AB39-7628-4447-8FE8-02C9F1490DD6' /*Возвращена на доработку*/
				)
				AND NotChangingTime != ''
				AND SR.Id = CII2.ServiceRequestId
		GROUP BY CII2.ServiceRequestId, CII2.OldGroupID 
		)GroupTimeCII2 ON GroupTimeCII1.ServiceRequestId = GroupTimeCII2.ServiceRequestId
					        AND GroupTimeCII1.OldGroupId = GroupTimeCII2.OldGroupId
	)GroupTimeCII3
	LEFT JOIN SysAdminUnit SAU WITH(NOLOCK) ON SAU.Id = OldGroupId
) GroupTimeCII





/*
WHERE 
SR.TypeId <> 'E8A1B4D7-9BA5-4BEF-8ED0-E7DB10E451BF' /* Тип обращения не NOC */
/*AND SAU.Name IS NOT NULL*/
and SR.ClosureDate between dateadd(hour,3,(dateadd(DAY,-1,cast(format(GETDATE(), 'yyyy-MM-dd') as datetime2))))
                        and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-dd') as datetime2))))
*/

/*ORDER BY SR.ClosureDate DESC*/
/*ORDER BY SR.RegisteredOn DESC*/
ORDER BY SR.Number
*/





/* ORIGINAL SCRIPT Наталья
SELECT SR.Number
,SR.RegisteredOn
,COALESCE(SRT.Name, '') ReasonName
,COALESCE(S.ServiceName, '') ServiceName
,COALESCE(Sc.ServiceName, '') ShortDescription
,SR.SolutionDate,SR.SolutionOverdue
,COALESCE(vwIOGT.SumOnGroupTime, 0)
,COALESCE(vwIOGT.MaxOnGroupTime, 0)
,COALESCE(vwIOGT.MinOnGroupTime, 0)
,COALESCE(SAU.Name, '') GroupName
,vIOGT.ChangeDate
, COALESCE(vIOGT.OnGroupTime, 0) OnGroupTime
,COALESCE(vIOGT.DefferedSolution, 0) DefferedSolution
,COALESCE(vIOGT.DefferedTime, 0) DefferedTime
,COALESCE(SOI.Name, '') Status 

FROM ServiceRequest SR WITH(NOLOCK)
LEFT JOIN VwIncidentOnGroupTime vIOGT WITH(NOLOCK) ON vIOGT.ServiceRequestId = SR.Id
LEFT JOIN ServiceRequestType SRT WITH(NOLOCK) ON SRT.Id = SR.ServiceRequestTypeId
LEFT JOIN Service S WITH(NOLOCK) ON S.Id = SR.ServiceId
LEFT JOIN Service Sc WITH(NOLOCK) ON Sc.Id = SR.TechServiceId
LEFT JOIN SysAdminUnit SAU WITH(NOLOCK) ON SAU.Id = vIOGT.GroupId
LEFT JOIN StatusOfIncident SOI WITH(NOLOCK) ON SOI.Id = SR.StatusOfIncidentId
LEFT JOIN (
	SELECT SUM(OnGroupTime) as SumOnGroupTime,MAX(OnGroupTime) as MaxOnGroupTime,MIN(OnGroupTime) as MinOnGroupTime,ServiceRequestId
	FROM VwIncidentOnGroupTime WITH(NOLOCK)
	GROUP BY ServiceRequestId
	) vwIOGT ON  vwIOGT.ServiceRequestId = SR.Id
WHERE SR.TypeId = '1B0BC159-150A-E111-A31B-00155D04C01D' AND
SAU.Name IS NOT NULL 


;if (Page.SolutionProvidedOnButton.Checked) {
	selectQuery += string.Format(@\" 
	AND vIOGT.ClosedOn >= '{0}' 
	AND vIOGT.ClosedOn <= '{1}' \", fromDate, toDate);
	}

else {selectQuery += string.Format(@\" 
AND SR.RegisteredOn >= '{0}' 
AND SR.RegisteredOn <= '{1}' \", fromDate, toDate);}



///////////// Предположительно, тебе вот эти фильтры не нужны, потому что по умолчанию они не стоят в отчете
if (Page.OnlyOverdueCheckBox.Checked) {selectQuery += \" 
AND SR.SolutionOverdue = 1\"
;}

var selectedIncidentCategories = (List<Guid>)SelectedIncidentCategories;if (selectedIncidentCategories.Count > 0) 
{var selectedIncidentCategoriesString = selectedIncidentCategories.Select(x => \"'\" + x.ToString() + \"'\").ToList().Aggregate((current, next) => current + \",\" + next);
selectQuery += string.Format(\"
AND SR.ServiceRequestTypeId IN ({0})\", selectedIncidentCategoriesString);}
 
var selectedIncidentStatuses = (List<Guid>)SelectedIncidentStatuses;if (selectedIncidentStatuses.Count > 0) {var selectedIncidentStatusesString = selectedIncidentStatuses.Select(x => \"'\" + x.ToString() + \"'\").ToList().Aggregate((current, next) => current + \",\" + next);
selectQuery += string.Format(\" 
AND SR.StatusOfIncidentId IN ({0})\", selectedIncidentStatusesString);}
*/




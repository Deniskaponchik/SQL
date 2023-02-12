/* CREATED ON LAST DAY */
USE BPMonline_80;
SELECT 
SR.Number AS 'Номер заявки'
,SOI.Name AS 'Статус'
,dateadd(hh, +3, SR.RegisteredOn) AS 'Дата регистрации'
,SRT.Name 'Тип обращения'
,S.ServiceName 'Сервис'
,Sc.ServiceName 'Краткое описание проблемы'
,dateadd(hh, +3, SR.SolutionDate) 'Срок решения'
,REPLACE(REPLACE(SR.SolutionOverdue, '0','нет'),'1','да') AS 'Просрочен'
,SumFullCII.SumFullNotChangingTime 'Общее время обработки (мин.)'
,GroupTimeCII.MaxNotChangingTime 'Максимальное время обработки группой (мин.)'
,GroupTimeCII.MinNotChangingTime 'Минимальное время обработки группой (мин.)'
,GroupTimeCII.OldGroupID 'Группа' /*NewGroupId*/
,GroupTimeCII.MaxChangeDate 'Дата перевода на группу'
,GroupTimeCII.SumNotChangingTime 'Время обработки группой (мин.)'

 FROM 
 /*ServiceRequest SR WITH(NOLOCK)*/
  (SELECT id, Number, RegisteredOn, ServiceRequestTypeId, ServiceId, TechServiceId, StatusOfIncidentId, SolutionDate, SolutionOverdue
    FROM ServiceRequest
    WHERE ServiceRequestTypeId <> 'E8A1B4D7-9BA5-4BEF-8ED0-E7DB10E451BF' /* Тип обращения не NOC */
   	--and RegisteredOn >= dateadd(day,-1,getdate())
	and RegisteredOn > '2021-09-24 00:00:00' and RegisteredOn < '2021-09-24 23:59:59'
	--and ClosureDate >= dateadd(day,-1,getdate())
) SR
LEFT JOIN ServiceRequestType SRT WITH(NOLOCK) ON SRT.Id = SR.ServiceRequestTypeId
LEFT JOIN Service S WITH(NOLOCK) ON S.Id = SR.ServiceId
LEFT JOIN Service Sc WITH(NOLOCK) ON Sc.Id = SR.TechServiceId
LEFT JOIN StatusOfIncident SOI WITH(NOLOCK) ON SOI.Id = SR.StatusOfIncidentId


--Урезанная под определённые условия CounterInIncident
outer apply (
	SELECT OldGroupId,NewGroupId,NewStatusOfIncidentId,CreatedOn
	,cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int) AS NotChangingTime
	,ServiceRequestId
	FROM CounterInIncident
	WHERE
		ServiceRequestId = SR.id
	    --ServiceRequestId = 'A4D05827-F5AC-416C-9BD5-DF21C8750ACD'
		AND NotChangingTime != ''
		/* В полях Общее время обработки (мин.), Максимальное время обработки группой (мин.), Минимальное время обработки группой (мин.), Время обработки группой (мин.) 
	    не должны участвовать значения, у которых "Новое значение статуса" во вкладке счетчики равно “Внешний запрос”, “Внутренний запрос” или “Возвращена на доработку */
		AND NewStatusOfIncidentId NOT IN (
			 'F0B04982-4C74-4FD4-ACD8-05FE186C36FF' /*Внешний запрос*/
			,'6B0131D0-CF34-4ECA-BDBB-00DA49445B77' /*Внутренний запрос*/
			,'D103AB39-7628-4447-8FE8-02C9F1490DD6' /*Возвращена на доработку*/
			)
) cii0


	
/* Группа (владка счетчики. Должно попадать каждое уникальное значение из "Старое значение группы". 
   По аналогии с примером будет 2 строки: группа A, группа B). */
OUTER APPLY (
	select 
	  --GroupTimeCII1.ServiceRequestId AS ServiceRequestId
	  SAU.Name AS OldGroupID
	, MaxNotChangingTime
	, MinNotChangingTime
	, SumNotChangingTime
	, MaxChangeDate

/* Подзапрос получает MaxChangeDate (Дата перевода на группу) и зануляет его при условии OldGroupId = NewGroupId */
	FROM ( 
		SELECT DISTINCT cii3.ServiceRequestId ServiceRequestId, cii3.OldGroupId OldGroupId
			, case
				  when GroupTimeCII0.OldGroupId = cii3.NewGroupId then NULL
				  else GroupTimeCII0.MaxChangeDate
			  END MaxChangeDate
		FROM CounterInIncident cii3
		LEFT JOIN (
				SELECT cii0.ServiceRequestId ServiceRequestId, cii0.OldGroupID OldGroupID, MAX(ChangeDate) MaxChangeDate
				FROM CounterInIncident cii0
				WHERE 
					SR.Id = cii0.ServiceRequestId
					--cii0.ServiceRequestId = '4E3A8310-9EFB-4FFF-B78E-5DBC474A2863'
					AND CII0.OldGroupID IS NOT NULL
				GROUP BY ServiceRequestId, OldGroupID
				) GroupTimeCII0 ON cii3.ServiceRequestId = GroupTimeCII0.ServiceRequestId AND cii3.OldGroupID = GroupTimeCII0.OldGroupID
		WHERE 
			--cii3.ServiceRequestId = '4E3A8310-9EFB-4FFF-B78E-5DBC474A2863'
		    SR.id = cii3.ServiceRequestId 
			AND CII3.OldGroupID IS NOT NULL
			AND cii3.OldGroupId = GroupTimeCII0.OldGroupID
			AND cii3.ChangeDate = GroupTimeCII0.MaxChangeDate
		--GROUP BY CII3.ServiceRequestId
	) GroupTimeCII1

--Здесь получаем всё оставшееся: Максимальное, Минимальное и Время обработки группой (за вычетом строк по условию)
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

	--Подбиваем имена групп
	LEFT JOIN SysAdminUnit SAU WITH(NOLOCK) ON SAU.Id = GroupTimeCII1.OldGroupId
) GroupTimeCII


/* Общее время обработки (мин.) (вкладка счетчики. В минутах суммирует все значения из поля "время") 
--Попробую в конце прилепить джойном к outer apply
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
		and RegisteredOn >= dateadd(day,-1,getdate())
		)
	GROUP BY ServiceRequestId
	) SumFullCII ON SumFullCII.ServiceRequestId = SR.Id */


/*WHERE SR.TypeId = '1B0BC159-150A-E111-A31B-00155D04C01D' AND
WHERE SR.TypeId <> 'E8A1B4D7-9BA5-4BEF-8ED0-E7DB10E451BF' /* Тип обращения не NOC */
and SR.RegisteredOn between dateadd(hour,3,(dateadd(DAY,-1,cast(format(GETDATE(), 'yyyy-MM-dd') as datetime2))))
                        and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-dd') as datetime2))))
*/


/*ORDER BY SR.RegisteredOn DESC*/
ORDER BY SR.Number







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
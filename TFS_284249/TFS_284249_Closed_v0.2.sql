/* CLOSED ON LAST DAY */
USE BPMonline_80;
SELECT 
SR.Number AS 'Номер заявки'
,COALESCE(SOI.Name, '') AS 'Статус'
,SR.RegisteredOn AS 'Дата регистрации'
,COALESCE(SRT.Name, '') 'Тип обращения'
,COALESCE(S.ServiceName, '') 'Сервис'
,COALESCE(Sc.ServiceName, '') 'Краткое описание проблемы'
,SR.SolutionDate 'Срок решения'
/*,SR.SolutionOverdue*/
/*,IF(SR.SolutionOverdue = 0,  ) AS 'Просрочен'*/
,REPLACE(REPLACE(SR.SolutionOverdue, '0','нет'),'1','да') AS 'Просрочен'
,SumFullCII.SumFullNotChangingTime 'Общее время обработки (мин.)'
,GroupTimeCII.MaxNotChangingTime 'Максимальное время обработки группой (мин.)'
,GroupTimeCII.MinNotChangingTime 'Минимальное время обработки группой (мин.)'
,GroupTimeCII.NewGroupId 'Группа'
,GroupTimeCII.MaxChangeDate 'Дата перевода на группу'
,GroupTimeCII.SumNotChangingTime 'Время обработки группой (мин.)'
/*,COALESCE(vIOGT.DefferedSolution, 0) DefferedSolution
,COALESCE(vIOGT.DefferedTime, 0) DefferedTime */


 FROM
 /*ServiceRequest SR WITH(NOLOCK)*/
 (SELECT id, Number, RegisteredOn, ServiceRequestTypeId, ServiceId, TechServiceId, StatusOfIncidentId, SolutionDate, SolutionOverdue
 FROM ServiceRequest
 WHERE TypeId <> 'E8A1B4D7-9BA5-4BEF-8ED0-E7DB10E451BF' /* Тип обращения не NOC */
and ClosureDate between dateadd(hour,3,(dateadd(DAY,-1,cast(format(GETDATE(), 'yyyy-MM-dd') as datetime2))))
                        and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-dd') as datetime2))))
) SR

/*LEFT JOIN VwIncidentOnGroupTime vIOGT WITH(NOLOCK) ON vIOGT.ServiceRequestId = SR.Id */
LEFT JOIN ServiceRequestType SRT WITH(NOLOCK) ON SRT.Id = SR.ServiceRequestTypeId
LEFT JOIN Service S WITH(NOLOCK) ON S.Id = SR.ServiceId
LEFT JOIN Service Sc WITH(NOLOCK) ON Sc.Id = SR.TechServiceId
/*LEFT JOIN SysAdminUnit SAU WITH(NOLOCK) ON SAU.Id = vIOGT.GroupId*/
LEFT JOIN StatusOfIncident SOI WITH(NOLOCK) ON SOI.Id = SR.StatusOfIncidentId

/* Общее время обработки (мин.) (вкладка счетчики. В минутах суммирует все значения из поля "время") */
/*LEFT JOIN ( 
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
	GROUP BY ServiceRequestId
	) SumFullCII ON SumFullCII.ServiceRequestId = SR.Id */

CROSS APPLY ( 
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
	AND SR.Id = CII1.ServiceRequestId
	GROUP BY ServiceRequestId
	) SumFullCII

CROSS APPLY (
	select 
	SAU.Name AS NewGroupId /* 'Группа' NewGroupId, ServiceRequestId, OldGroupID*/
	/*, cast(
	SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + 
	SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 +  
	SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3)) 
	as int) */
	, MAX(cast(
		SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + 
		SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 +  
		SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3)) 
		as int)
	) MaxNotChangingTime /* MaxNotChangingTime  'Максимальное время обработки группой (мин.)'*/
	, MIN(cast(
		SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + 
		SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 +  
		SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3)) 
		as int)
	) MinNotChangingTime /* MinNotChangingTime 'Минимальное время обработки группой (мин.)' */
	, SUM(cast(
		SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + 
		SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 +  
		SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3)) 
		as int)
	) SumNotChangingTime /* SumNotChangingTime 'Время обработки группой (мин.)' */
	, MAX(ChangeDate) MaxChangeDate /* 'Дата перевода на группу' */
	from CounterInIncident AS CII2
	LEFT JOIN SysAdminUnit SAU WITH(NOLOCK) ON SAU.Id = CII2.NewGroupId
	WHERE NewStatusOfIncidentId NOT IN (
		 'F0B04982-4C74-4FD4-ACD8-05FE186C36FF' /*Внешний запрос*/
		,'6B0131D0-CF34-4ECA-BDBB-00DA49445B77' /*Внутренний запрос*/
		,'D103AB39-7628-4447-8FE8-02C9F1490DD6' /*Возвращена на доработку*/
		)
		AND NotChangingTime != ''
		AND SR.Id = CII2.ServiceRequestId
		/*AND ServiceRequestId = '7747E97B-CAB5-4E4C-BD2F-AB7BB32B541E'*/
	GROUP BY CII2.ServiceRequestId, SAU.Name /* NewGroupId OldGroupID */
) GroupTimeCII /*ON GroupTimeCII.ServiceRequestId = SR.Id*/

/*
WHERE 
SR.TypeId <> 'E8A1B4D7-9BA5-4BEF-8ED0-E7DB10E451BF' /* Тип обращения не NOC */
/*AND SAU.Name IS NOT NULL*/
and SR.ClosureDate between dateadd(hour,3,(dateadd(DAY,-1,cast(format(GETDATE(), 'yyyy-MM-dd') as datetime2))))
                        and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-dd') as datetime2))))
*/


/*
SELECT dateadd(hour,3,(dateadd(DAY,-1,cast(format(GETDATE(), 'yyyy-MM-dd') as datetime2))))
SELECT dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-dd') as datetime2))))
*/ /*
else {selectQuery += string.Format(@\" 
AND SR.RegisteredOn >= '{0}' 
AND SR.RegisteredOn <= '{1}' \", fromDate, toDate);}
and c.SolutionProvidedOn between dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2)))) 
and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))
SELECT dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2)))) */










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
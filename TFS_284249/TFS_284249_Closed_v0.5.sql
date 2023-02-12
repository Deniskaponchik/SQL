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
	/* 5 minutes
	LEFT JOIN (
		SELECT id
		FROM ServiceRequest
		WHERE TypeId <> 'E8A1B4D7-9BA5-4BEF-8ED0-E7DB10E451BF' /* Тип обращения не NOC */
		and ClosureDate >= dateadd(day,-1,getdate())
		) SR1 ON SR1.id = CII1.ServiceRequestId */
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
/* Скорость выполнения 7 минут
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
	) SumFullCII */



/* Группа (владка счетчики. Должно попадать каждое уникальное значение из "Старое значение группы". 
   По аналогии с примером будет 2 строки: группа A, группа B). */
OUTER APPLY (
	select 
	SAU.Name AS OldGroupID /* 'Группа' NewGroupId, OldGroupID*/
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

/*ORDER BY SR.ClosureDate DESC*/
/*ORDER BY SR.RegisteredOn DESC*/
ORDER BY SR.Number








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



/*
Declare @SR Table(
Id	uniqueidentifier	Unchecked
CreatedOn	datetime2(3)	Checked
CreatedById	uniqueidentifier	Checked
ModifiedOn	datetime2(3)	Checked
ModifiedById	uniqueidentifier	Checked
Number	nvarchar(250)	Unchecked
AuthorId	uniqueidentifier	Checked
RegisteredOn	datetime2(3)	Checked
OriginId	uniqueidentifier	Checked
Symptoms	nvarchar(MAX)	Unchecked
AccountId	uniqueidentifier	Checked
ContactId	uniqueidentifier	Checked
ServiceAgreementId	uniqueidentifier	Checked
ServiceId	uniqueidentifier	Checked
TypeId	uniqueidentifier	Unchecked
UrgencyId	uniqueidentifier	Checked
ImpactId	uniqueidentifier	Checked
PriorityId	uniqueidentifier	Checked
SupportLineId	uniqueidentifier	Checked
StatusOfIncidentId	uniqueidentifier	Checked
StatusOfServiceCallId	uniqueidentifier	Checked
OwnerId	uniqueidentifier	Checked
GroupId	uniqueidentifier	Checked
ResponseDate	datetime2(3)	Checked
SolutionDate	datetime2(3)	Checked
ResponseOverdue	bit	Unchecked
SolutionOverdue	bit	Unchecked
RespondedOn	datetime2(3)	Checked
SolutionProvidedOn	datetime2(3)	Checked
PlannedWorkingTime	int	Unchecked
ActualWorkingTime	int	Unchecked
ClosureCodeId	uniqueidentifier	Checked
ConfigurationItemId	uniqueidentifier	Checked
ReleaseId	uniqueidentifier	Checked
ProblemId	uniqueidentifier	Checked
ParentIncidentId	uniqueidentifier	Checked
ChangeRequestId	uniqueidentifier	Checked
IncidentId	uniqueidentifier	Checked
SolvedBySupportLineId	uniqueidentifier	Checked
Solution	nvarchar(MAX)	Unchecked
SatisfactionLevelId	uniqueidentifier	Checked
CommentaryOnEstimate	nvarchar(MAX)	Unchecked
DisplayStatus	nvarchar(250)	Unchecked
ProcessListeners	int	Unchecked
Notes	nvarchar(MAX)	Unchecked
FacilityId	uniqueidentifier	Checked
ResponseRemains	decimal(18, 1)	Unchecked
SolutionRemains	decimal(18, 1)	Unchecked
SerialNumber	nvarchar(50)	Unchecked
MonitoringSystemAlertHistoryId	uniqueidentifier	Checked
TechServiceId	uniqueidentifier	Checked
Files	nvarchar(MAX)	Unchecked
DescriptionParameters	nvarchar(MAX)	Unchecked
StatusMarkerId	uniqueidentifier	Checked
SA	bit	Unchecked
ServiceRequestTypeId	uniqueidentifier	Checked
ClientCategoryId	uniqueidentifier	Checked
SitePriority	int	Unchecked
AccidentPrority	int	Unchecked
EquipmentType	nvarchar(500)	Unchecked
NetworkTypeId	uniqueidentifier	Checked
VendorId	uniqueidentifier	Checked
Object	nvarchar(500)	Unchecked
AccidentDescription	nvarchar(500)	Unchecked
AdditionAccidentDescription	nvarchar(MAX)	Unchecked
AccidentsStartTime	datetime2(3)	Checked
EquipmentInAccidentReasonId	uniqueidentifier	Checked
AdditionalInformation1	nvarchar(500)	Unchecked
AdditionalInformation2	nvarchar(500)	Unchecked
AdditionalInformation3	nvarchar(500)	Unchecked
AdditionalInformation4	nvarchar(500)	Unchecked
EquipmentAddress	nvarchar(250)	Unchecked
AccidentReasonForEquipmentId	uniqueidentifier	Checked
ClientTypeId	uniqueidentifier	Checked
PointOfSale	nvarchar(500)	Unchecked
PointOfSaleAddress	nvarchar(500)	Unchecked
PersonalAccountNumber	nvarchar(250)	Unchecked
CompanyName	nvarchar(250)	Unchecked
ClientFullName	nvarchar(250)	Unchecked
ClientAdress	nvarchar(500)	Unchecked
FeedbackModeId	uniqueidentifier	Checked
Inform	bit	Unchecked
ContactPerson	nvarchar(250)	Unchecked
AbonentNumber	nvarchar(50)	Unchecked
ContactNumber	nvarchar(50)	Unchecked
City	nvarchar(500)	Unchecked
ClientEmail	nvarchar(50)	Unchecked
Description	nvarchar(MAX)	Unchecked
DestionationGroupId	uniqueidentifier	Checked
ClosureDate	datetime2(3)	Checked
GroupLimitDate	datetime2(3)	Checked
DeferredDecision	bit	Unchecked
DeferredTo	datetime2(3)	Checked
ServiceRequestQualityId	uniqueidentifier	Checked
Decision	nvarchar(MAX)	Unchecked
IsMassIncident	bit	Unchecked
CreatedByGroupId	uniqueidentifier	Checked
ModifiedByGroupId	uniqueidentifier	Checked
SolvedByGroupId	uniqueidentifier	Checked
ClosedByGroupId	uniqueidentifier	Checked
ClosedById	uniqueidentifier	Checked
SolvedById	uniqueidentifier	Checked
Login	nvarchar(250)	Unchecked
MacroregionId	uniqueidentifier	Checked
RegionCodeId	uniqueidentifier	Checked
ServicePriorityId	uniqueidentifier	Checked
IncidentReasonId	uniqueidentifier	Checked
Site	nvarchar(500)	Unchecked
IsEditPageCutMode	bit	Unchecked
HasAttachments	bit	Unchecked
UmbCreatedBySid	nvarchar(250)	Unchecked
UmbCreatedByName	nvarchar(250)	Unchecked
UmbOwnerSid	nvarchar(250)	Unchecked
UmbOwnerName	nvarchar(250)	Unchecked
UmbModifiedBySid	nvarchar(250)	Unchecked
UmbModifiedByName	nvarchar(250)	Unchecked
UmbClosedBySid	nvarchar(250)	Unchecked
UmbClosedByName	nvarchar(250)	Unchecked
UmbInVoiceInstanceID	int	Unchecked
UmbInVoiceClientID	int	Unchecked
UmbInVoiceSubId	int	Unchecked
UmbIsAllSub	bit	Unchecked
UmbServiceRequestID	int	Unchecked
UmbSystem	nvarchar(50)	Unchecked
UmbServiceRequestReason	nvarchar(500)	Unchecked
UmbCategoryReason	nvarchar(250)	Unchecked
UmbFeedBackDateTime	datetime2(3)	Checked
IsSendGroupLimitNotification	bit	Unchecked
AuthorizationId	uniqueidentifier	Checked
IsDeferredToSendMessage	bit	Unchecked
IsSendAbonentNotification	bit	Unchecked
IsFromNetCool	bit	Unchecked
UmbCreatedByLogin	nvarchar(250)	Unchecked
UmbOwnerLogin	nvarchar(250)	Unchecked
UmbModifiedByLogin	nvarchar(250)	Unchecked
UmbClosedByLogin	nvarchar(250)	Unchecked
VersionNumber	int	Unchecked
OperationNumber	int	Unchecked
IsArchive	bit	Unchecked
StatusOfChangeRequestId	uniqueidentifier	Checked
InternalSD	bit	Unchecked
Confidential	bit	Unchecked
InternalSDMacroregionId	uniqueidentifier	Checked
InternalSDRegionId	uniqueidentifier	Checked
InternalSDServiceRequestTypeId	uniqueidentifier	Checked
AccountDirectionId	uniqueidentifier	Checked
InternalSDCompanyId	uniqueidentifier	Checked
Project	bit	Unchecked
ProjectCode	nvarchar(50)	Unchecked
ProjectManagerId	uniqueidentifier	Checked
Name	nvarchar(MAX)	Unchecked
InternalSDTypeApproved	bit	Unchecked
DeferredComment	nvarchar(500)	Unchecked
IntNumber	int	Unchecked
WorksStartDate	datetime2(3)	Checked
UmbChangingSystem	nvarchar(50)	Unchecked
NeedFillParamsForApproval	bit	Unchecked
ArchivedOn	datetime2(3)	Checked
PriorityOfSolution	int	Unchecked
PriorityOfTimeZone	int	Unchecked
PriorityOfFeedbackMode	int	Unchecked
DynamicPriority	int	Unchecked
IsSetManually	bit	Unchecked
UmbServiceType	nvarchar(250)	Unchecked
MVNOSubGroupId	uniqueidentifier	Checked
UsrBadMarkReasonRegionId	uniqueidentifier	Checked
UsrSourceReasonRegionId	uniqueidentifier	Checked
UsrRealWayOsRegionId	uniqueidentifier	Checked
UsrBadMarkReasonOBOId	uniqueidentifier	Checked
UsrRegionComment	nvarchar(MAX)	Unchecked
UsrOBOComment	nvarchar(MAX)	Unchecked
UsrQuestion1Id	uniqueidentifier	Checked
UsrAnswer1	nvarchar(MAX)	Unchecked
UsrQuestion2Id	uniqueidentifier	Checked
UsrAnswer2	nvarchar(MAX)	Unchecked
UsrQuestion3Id	uniqueidentifier	Checked
UsrAnswer3	nvarchar(MAX)	Unchecked
UsrQuestion4Id	uniqueidentifier	Checked
UsrAnswer4	nvarchar(MAX)	Unchecked
Location	nvarchar(500)	Unchecked
Coordinates	nvarchar(500)	Unchecked
ShortDescription	nvarchar(250)	Unchecked
DisplaySubject	bit	Unchecked
SolutionForAbonent	nvarchar(MAX)	Unchecked
IsDuplicate	bit	Unchecked
DeferredTypeId	uniqueidentifier	Checked
DeferredReasonComment	nvarchar(MAX)	Unchecked
TestDriveReasonTypeId	uniqueidentifier	Checked
IsRepeated	bit	Unchecked
);
*/



/*
Declare @SR Table(
Id	uniqueidentifier,
Number	nvarchar(250),
RegisteredOn	datetime2(3),
OriginId	uniqueidentifier	Checked
Symptoms	nvarchar(MAX)	Unchecked
AccountId	uniqueidentifier	Checked
ContactId	uniqueidentifier	Checked
ServiceAgreementId	uniqueidentifier	Checked
ServiceId	uniqueidentifier	Checked
TypeId	uniqueidentifier	Unchecked
UrgencyId	uniqueidentifier	Checked
ImpactId	uniqueidentifier	Checked
PriorityId	uniqueidentifier	Checked
SupportLineId	uniqueidentifier	Checked
StatusOfIncidentId	uniqueidentifier	Checked
StatusOfServiceCallId	uniqueidentifier	Checked
OwnerId	uniqueidentifier	Checked
GroupId	uniqueidentifier	Checked
ResponseDate	datetime2(3)	Checked
SolutionDate	datetime2(3),
ResponseOverdue	bit	Unchecked
SolutionOverdue	bit,
RespondedOn	datetime2(3)	Checked
SolutionProvidedOn	datetime2(3),
ClosureCodeId	uniqueidentifier,
ConfigurationItemId	uniqueidentifier	Checked
ReleaseId	uniqueidentifier	Checked
ProblemId	uniqueidentifier	Checked
ParentIncidentId	uniqueidentifier	Checked
ChangeRequestId	uniqueidentifier	Checked
IncidentId	uniqueidentifier	Checked
SolvedBySupportLineId	uniqueidentifier	Checked
Solution	nvarchar(MAX)	Unchecked
SatisfactionLevelId	uniqueidentifier	Checked
CommentaryOnEstimate	nvarchar(MAX)	Unchecked
DisplayStatus	nvarchar(250)	Unchecked
ProcessListeners	int	Unchecked
Notes	nvarchar(MAX)	Unchecked
FacilityId	uniqueidentifier	Checked
ResponseRemains	decimal(18, 1)	Unchecked
SolutionRemains	decimal(18, 1)	Unchecked
SerialNumber	nvarchar(50)	Unchecked
MonitoringSystemAlertHistoryId	uniqueidentifier	Checked
TechServiceId	uniqueidentifier	Checked
Files	nvarchar(MAX)	Unchecked
DescriptionParameters	nvarchar(MAX)	Unchecked
StatusMarkerId	uniqueidentifier	Checked
SA	bit	Unchecked
ServiceRequestTypeId	uniqueidentifier	Checked
ClientCategoryId	uniqueidentifier	Checked
SitePriority	int	Unchecked
AccidentPrority	int	Unchecked
EquipmentType	nvarchar(500)	Unchecked
NetworkTypeId	uniqueidentifier	Checked
VendorId	uniqueidentifier	Checked
Object	nvarchar(500)	Unchecked
AccidentDescription	nvarchar(500)	Unchecked
AdditionAccidentDescription	nvarchar(MAX)	Unchecked
AccidentsStartTime	datetime2(3)	Checked
EquipmentInAccidentReasonId	uniqueidentifier	Checked
AdditionalInformation1	nvarchar(500)	Unchecked
AdditionalInformation2	nvarchar(500)	Unchecked
AdditionalInformation3	nvarchar(500)	Unchecked
AdditionalInformation4	nvarchar(500)	Unchecked
EquipmentAddress	nvarchar(250)	Unchecked
AccidentReasonForEquipmentId	uniqueidentifier	Checked
ClientTypeId	uniqueidentifier	Checked
PointOfSale	nvarchar(500)	Unchecked
PointOfSaleAddress	nvarchar(500)	Unchecked
PersonalAccountNumber	nvarchar(250)	Unchecked
CompanyName	nvarchar(250)	Unchecked
ClientFullName	nvarchar(250)	Unchecked
ClientAdress	nvarchar(500)	Unchecked
FeedbackModeId	uniqueidentifier	Checked
Inform	bit	Unchecked
ContactPerson	nvarchar(250)	Unchecked
AbonentNumber	nvarchar(50)	Unchecked
ContactNumber	nvarchar(50)	Unchecked
City	nvarchar(500)	Unchecked
ClientEmail	nvarchar(50)	Unchecked
Description	nvarchar(MAX)	Unchecked
DestionationGroupId	uniqueidentifier	Checked
ClosureDate	datetime2(3)	Checked
GroupLimitDate	datetime2(3)	Checked
DeferredDecision	bit	Unchecked
DeferredTo	datetime2(3)	Checked
ServiceRequestQualityId	uniqueidentifier	Checked
Decision	nvarchar(MAX)	Unchecked
IsMassIncident	bit	Unchecked
CreatedByGroupId	uniqueidentifier	Checked
ModifiedByGroupId	uniqueidentifier	Checked
SolvedByGroupId	uniqueidentifier	Checked
ClosedByGroupId	uniqueidentifier	Checked
ClosedById	uniqueidentifier	Checked
SolvedById	uniqueidentifier	Checked
Login	nvarchar(250)	Unchecked
MacroregionId	uniqueidentifier	Checked
RegionCodeId	uniqueidentifier	Checked
ServicePriorityId	uniqueidentifier	Checked
IncidentReasonId	uniqueidentifier	Checked
Site	nvarchar(500)	Unchecked
IsEditPageCutMode	bit	Unchecked
HasAttachments	bit	Unchecked
UmbCreatedBySid	nvarchar(250)	Unchecked
UmbCreatedByName	nvarchar(250)	Unchecked
UmbOwnerSid	nvarchar(250)	Unchecked
UmbOwnerName	nvarchar(250)	Unchecked
UmbModifiedBySid	nvarchar(250)	Unchecked
UmbModifiedByName	nvarchar(250)	Unchecked
UmbClosedBySid	nvarchar(250)	Unchecked
UmbClosedByName	nvarchar(250)	Unchecked
UmbInVoiceInstanceID	int	Unchecked
UmbInVoiceClientID	int	Unchecked
UmbInVoiceSubId	int	Unchecked
UmbIsAllSub	bit	Unchecked
UmbServiceRequestID	int	Unchecked
UmbSystem	nvarchar(50)	Unchecked
UmbServiceRequestReason	nvarchar(500)	Unchecked
UmbCategoryReason	nvarchar(250)	Unchecked
UmbFeedBackDateTime	datetime2(3)	Checked
IsSendGroupLimitNotification	bit	Unchecked
AuthorizationId	uniqueidentifier	Checked
IsDeferredToSendMessage	bit	Unchecked
IsSendAbonentNotification	bit	Unchecked
IsFromNetCool	bit	Unchecked
UmbCreatedByLogin	nvarchar(250)	Unchecked
UmbOwnerLogin	nvarchar(250)	Unchecked
UmbModifiedByLogin	nvarchar(250)	Unchecked
UmbClosedByLogin	nvarchar(250)	Unchecked
VersionNumber	int	Unchecked
OperationNumber	int	Unchecked
IsArchive	bit	Unchecked
StatusOfChangeRequestId	uniqueidentifier	Checked
InternalSD	bit	Unchecked
Confidential	bit	Unchecked
InternalSDMacroregionId	uniqueidentifier	Checked
InternalSDRegionId	uniqueidentifier	Checked
InternalSDServiceRequestTypeId	uniqueidentifier	Checked
AccountDirectionId	uniqueidentifier	Checked
InternalSDCompanyId	uniqueidentifier	Checked
Project	bit	Unchecked
ProjectCode	nvarchar(50)	Unchecked
ProjectManagerId	uniqueidentifier	Checked
Name	nvarchar(MAX)	Unchecked
InternalSDTypeApproved	bit	Unchecked
DeferredComment	nvarchar(500)	Unchecked
IntNumber	int	Unchecked
WorksStartDate	datetime2(3)	Checked
UmbChangingSystem	nvarchar(50)	Unchecked
NeedFillParamsForApproval	bit	Unchecked
ArchivedOn	datetime2(3)	Checked
PriorityOfSolution	int	Unchecked
PriorityOfTimeZone	int	Unchecked
PriorityOfFeedbackMode	int	Unchecked
DynamicPriority	int	Unchecked
IsSetManually	bit	Unchecked
UmbServiceType	nvarchar(250)	Unchecked
MVNOSubGroupId	uniqueidentifier	Checked
UsrBadMarkReasonRegionId	uniqueidentifier	Checked
UsrSourceReasonRegionId	uniqueidentifier	Checked
UsrRealWayOsRegionId	uniqueidentifier	Checked
UsrBadMarkReasonOBOId	uniqueidentifier	Checked
UsrRegionComment	nvarchar(MAX)	Unchecked
UsrOBOComment	nvarchar(MAX)	Unchecked
UsrQuestion1Id	uniqueidentifier	Checked
UsrAnswer1	nvarchar(MAX)	Unchecked
UsrQuestion2Id	uniqueidentifier	Checked
UsrAnswer2	nvarchar(MAX)	Unchecked
UsrQuestion3Id	uniqueidentifier	Checked
UsrAnswer3	nvarchar(MAX)	Unchecked
UsrQuestion4Id	uniqueidentifier	Checked
UsrAnswer4	nvarchar(MAX)	Unchecked
Location	nvarchar(500)	Unchecked
Coordinates	nvarchar(500)	Unchecked
ShortDescription	nvarchar(250)	Unchecked
);
*/



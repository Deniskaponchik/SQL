--v3.2
--СТАТУС: НЕ ДОДЕЛАНО
--РЕАЛИЗАЦИЯ: Курсор + Временные таблицы + Убраны Макс, Мин, Дата перевода
--ПРОБЛЕМЫ: из таблицы CounterInIncident убираются строки во время фильтрации, где OldStatusOfIncidentId = NULL. 
--Но они нужны для корректного подсчёта Дата перевода на группу


USE BPMonline_80;
--GO

/*CREATE NONCLUSTERED INDEX [IX_SRtable] ON #SR ([id] ASC)*/
drop table IF EXISTS #sr
/*CREATE NONCLUSTERED INDEX [IX_GroupTimeCii0table] ON #GroupTimeCii0([ServiceRequestid] ASC)*/
drop table IF EXISTS #GroupTimeCii0
/*CREATE NONCLUSTERED INDEX [IX_GroupTimeCii1table] ON #GroupTimeCii1([ServiceRequestid] ASC)*/
drop table IF EXISTS #GroupTimeCii1
/*CREATE NONCLUSTERED INDEX [IX_GroupTimeCii2table] ON #GroupTimeCii2([ServiceRequestid] ASC)*/
drop table IF EXISTS #GroupTimeCii2
/*CREATE NONCLUSTERED INDEX [IX_Cii0table] ON #Cii0([ServiceRequestid] ASC)*/
drop table IF EXISTS #CII0
drop table IF EXISTS #CII00
/*CREATE NONCLUSTERED INDEX [IX_Ciitable] ON #Cii([ServiceRequestid] ASC)*/
drop table IF EXISTS #CII


--Таблица с необходимыми заявками, на которую в последствие ссылаются все остальные
--INSERT INTO #SR (id, Number, RegisteredOn, ServiceRequestTypeId, ServiceId, TechServiceId, StatusOfIncidentId, SolutionDate, SolutionOverdue, ClosureDate)
	SELECT id, Number
	, dateadd(hh, +3, RegisteredOn) RegisteredOn
	, ServiceRequestTypeId, ServiceId, TechServiceId, StatusOfIncidentId
	, dateadd(hh, +3, SolutionDate) SolutionDate
	, SolutionOverdue
	, dateadd(hh, +3, ClosureDate) ClosureDate
	into #sr
	FROM ServiceRequest
    WHERE 
	--RegisteredOn >= dateadd(day,-1,getdate())
	--RegisteredOn > '2021-09-24 00:00:00' and RegisteredOn < '2021-09-24 23:59:59'
	--RegisteredOn BETWEEN '2021-09-24 00:00:00' and '2021-09-24 23:59:59'
	--RegisteredOn BETWEEN cast('2021-09-24' as datetime2) and cast('2021-09-25' as datetime2)

	--ClosureDate >= dateadd(day,-1,getdate())  --MAIN
	--ClosureDate > '2021-09-24 00:00:00' and ClosureDate < '2021-09-24 23:59:59' --FASTER
	   ClosureDate BETWEEN '2021-09-24 00:00:00' and '2021-09-24 23:59:59'
	--ClosureDate BETWEEN cast('2021-09-24' as datetime2) and cast('2021-09-25' as datetime2)
	--CONVERT(date,ClosureDate,101) = '2021-09-24'
	  and ServiceRequestTypeId <> 'E8A1B4D7-9BA5-4BEF-8ED0-E7DB10E451BF' --Тип обращения не NOC
	--ORDER BY id


--Урезанная под определённые условия CounterInIncident
--INSERT INTO #CII0 (OldGroupId,NewGroupId,NewStatusOfIncidentId,CreatedOn,NotChangingTime,ServiceRequestId)
	SELECT 
	row_number() OVER(ORDER BY ServiceRequestId, CreatedOn) RowNumber
	,ServiceRequestId,CreatedOn,OldGroupId,NewGroupId
    ,cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int) AS NotChangingTime
	--, case
	--	when NotChangingTime = ''  then 0
	--	when NotChangingTime != '' then cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int)
	--  end AS NotChangingTime
	,NewStatusOfIncidentId --,RightNotChangingTime = NULL
	into #cii0
	FROM CounterInIncident
	WHERE
		ServiceRequestId IN ( SELECT id FROM #SR )
	    --ServiceRequestId = '8117CE9C-CA8A-467E-8B10-5832FE8F9373'
		AND NotChangingTime != ''
		--AND OldGroupId IS NOT NULL
		/* В полях Общее время обработки (мин.), Время обработки группой (мин.) не должны участвовать значения, 
		у которых "Старое значение статуса" во вкладке счетчики равно “Внешний запрос”, “Внутренний запрос” или “Возвращена на доработку */
		AND OldStatusOfIncidentId NOT IN (
			 'F0B04982-4C74-4FD4-ACD8-05FE186C36FF' /*Внешний запрос*/
			,'6B0131D0-CF34-4ECA-BDBB-00DA49445B77' /*Внутренний запрос*/
			,'D103AB39-7628-4447-8FE8-02C9F1490DD6' /*Возвращена на доработку*/
			)
		/*AND OldStatusOfIncidentId IN (
			 'F4BF3FB2-F36B-1410-109B-0050BA5D6C38' --В работе
			,'F6BE11BE-F36B-1410-109B-0050BA5D6C38' --Закрыта
			,'F5BF3FC4-F36B-1410-119B-0050BA5D6C38' --Новый
			,'B4BF30C8-F36B-1410-119B-0050BA5D6C38' --Отложенное решение
			,'F49E3FD2-F36B-1410-119B-0050BA5D6C38' --Решена
			,'92FE5FFE-60C4-4CCE-A0CC-8F6F2B3E3AB0' --Назначена на группу
			,'147213F8-47FB-40D3-8719-CBCAD5B7284A' --Назначена на сотрудника
			,'2D42FB9E-7F58-4DFC-954C-4EFDFFA51536' --Назначена на вендора
			,'1960D51E-40E5-4C3B-A9D6-843D2CA6BF68' --Отменена
			,'9D9C4CE1-2FE3-4DC7-A2E6-5DB6749B1076' --Позвонить
			,'92C1112E-FCCD-4C6F-9FC0-0BAE07FF8B87' --Позвонить на время
			,'DD7F55D2-7ACF-40E8-B9E7-25D630476838' --Тестирование
			,'2625827C-89FA-4D3A-93BB-3D1B01E324F3' --Ожидание информации
			,'2625827C-89FA-4D3A-93BB-3D1B01E324F4' --Позвонить еще
			, NULL
			)*/
	--order by CreatedOn


--Выборка из Cii0 с текущей + будущей строкой
--INSERT INTO #CII (OldGroupId,NewGroupId,NewStatusOfIncidentId,CreatedOn,RightNotChangingTime,ServiceRequestId)
SELECT 
    cii1.RowNumber RowNumber
   ,cii1.ServiceRequestId ServiceRequestId, cii2.ServiceRequestId cii2_ServiceRequestId 
   ,cii1.CreatedOn CreatedOn
   ,cii1.OldGroupId OldGroupId,cii2.OldGroupId cii2_OldGroupId --,cii0.OldGroupId cii0_OldGroupId,
   ,cii1.NewGroupId NewGroupId,cii2.NewGroupId cii2_NewGroupId --,cii0.NewGroupId cii0_NewGroupId
   ,cii1.NotChangingTime NotChangingTime,cii2.NotChangingTime cii2_NotChangingTime --,cii0.NotChangingTime cii0_NotChangingTime
  --,RightNotChangingTime = NULL,PlusNotChangingTime = NULL
  into #cii
FROM ( 
	SELECT -1+row_number() OVER(ORDER BY ServiceRequestId, CreatedOn) RowNumber
	,OldGroupId,NewGroupId,NewStatusOfIncidentId,CreatedOn,NotChangingTime,ServiceRequestId
	FROM #Cii0
) cii1 --ТЕКУЩАЯ строка
left join ( 
	SELECT -2+row_number() OVER(ORDER BY ServiceRequestId, CreatedOn) RowNumber
	,OldGroupId,NewGroupId,NewStatusOfIncidentId,CreatedOn,NotChangingTime,ServiceRequestId
	FROM #Cii0
) cii2 ON cii1.RowNumber = cii2.RowNumber AND cii1.ServiceRequestId = cii2.ServiceRequestId --БУДУЩАЯ строка
/*left join ( 
	SELECT row_number() OVER(ORDER BY ServiceRequestId, CreatedOn) RowNumber
	,OldGroupId,NewGroupId,NewStatusOfIncidentId,CreatedOn,NotChangingTime,ServiceRequestId
	FROM #Cii0
) cii0 ON cii1.RowNumber = cii0.RowNumber AND cii1.ServiceRequestId = cii0.ServiceRequestId --ПРОШЛАЯ строка*/



BEGIN --start cursor part
DECLARE cii_cur cursor for 
SELECT RowNumber,ServiceRequestId,cii2_ServiceRequestId,CreatedOn,OldGroupId,cii2_OldGroupId,NewGroupId,cii2_NewGroupId,NotChangingTime
FROM #cii
ORDER BY RowNumber
--FOR UPDATE OF RowNumber,ServiceRequestId,cii2_ServiceRequestId,CreatedOn,OldGroupId,cii2_OldGroupId,NewGroupId,cii2_NewGroupId,NotChangingTime

-- курсоровские переменные
DECLARE 
	--@Countcii INT, 
	  @RowNumber INT
	, @ServiceRequestId uniqueidentifier, @cii2_ServiceRequestId uniqueidentifier --, @cii_ServiceRequestId uniqueidentifier, @cii_ServiceRequestId uniqueidentifier
	, @CreatedOn datetime2(3) --, @cii2_CreatedOn datetime2(3)
	, @OldGroupId uniqueidentifier, @cii2_OldGroupId uniqueidentifier --, @cii_OldGroupId uniqueidentifier, @cii_OldGroupId uniqueidentifier
	, @NewGroupId uniqueidentifier, @cii2_NewGroupId uniqueidentifier --, @cii_NewGroupId uniqueidentifier, @cii_NewGroupId uniqueidentifier
	, @NotChangingTime INT

-- не курсоровские переменные
DECLARE 
	  @Countcii INT = (SELECT COUNT(*) FROM #cii), --
	  @OldServiceRequestId uniqueidentifier = NULL --, @cii_ServiceRequestId uniqueidentifier, @cii_ServiceRequestId uniqueidentifier, @cii2_ServiceRequestId uniqueidentifier
	, @OldNotChangingTime INT = 0


open cii_cur
fetch NEXT FROM cii_cur into @RowNumber,@ServiceRequestId,@cii2_ServiceRequestId,@CreatedOn,@OldGroupId,@cii2_OldGroupId,@NewGroupId,@cii2_NewGroupId,@NotChangingTime

WHILE @Countcii > 0 --@Countcii <> @RowNumber -- -- @@FETCH_STATUS = 0 -- 
BEGIN
	UPDATE #cii SET 
	CreatedOn = (case 
		when @ServiceRequestId = @cii2_ServiceRequestId AND @OldGroupId = @NewGroupId AND @OldGroupId = @cii2_OldGroupId  then NULL
		else CreatedOn
		end),
	NotChangingTime = (case 
		when @ServiceRequestID = @cii2_ServiceRequestId AND @OldGroupId = @NewGroupId AND @OldGroupId = @cii2_OldGroupId   then NULL --
		when @ServiceRequestID = @cii2_ServiceRequestId AND @OldGroupId = @NewGroupId AND @OldGroupId <> @cii2_OldGroupId  then @NotChangingTime
		when @OldGroupId <> @NewGroupId then @OldNotChangingTime + @NotChangingTime
		when @cii2_ServiceRequestId IS NULL then @OldNotChangingTime + @NotChangingTime
		end)

	--@Countcii = @Countcii - 1 --	--@OldRowNumber = @RowNumber + 1	--INTO #cii FROM #cii
	WHERE RowNumber = @RowNumber

	SET @OldNotChangingTime = (case 
		--when @OldNotChangingTime = 0 AND @OldGroupId = @NewGroupId AND @OldGroupId = @cii2_OldGroupId then @NotChangingTime
		when /*@OldNotChangingTime <> 0 AND*/ @OldGroupId = @NewGroupId AND @OldGroupId = @cii2_OldGroupId then @OldNotChangingTime + @NotChangingTime
		when                                  @OldGroupId = @NewGroupId AND @OldGroupId <> @cii2_OldGroupId then 0
		when @OldServiceRequestId <> @ServiceRequestId then @NotChangingTime
		when @OldGroupID <> @NewGroupId then 0
		when @cii2_ServiceRequestId IS NULL then 0
		end)
	SET @Countcii = @Countcii - 1

	/*
	if (@ServiceRequestID = @cii2_ServiceRequestId AND @OldGroupId = @NewGroupId AND @OldGroupId = @cii2_OldGroupId)
	begin
		delete from #cii where current of cii_cur
	end */

	fetch next from cii_cur into @RowNumber,@ServiceRequestId,@cii2_ServiceRequestId,@CreatedOn,@OldGroupId,@cii2_OldGroupId,@NewGroupId,@cii2_NewGroupId,@NotChangingTime
end
close cii_cur
deallocate cii_cur
END



--INSERT INTO #GroupTimeCii2 (ServiceRequestId,OldGroupId,MaxNotChangingTime,MinNotChangingTime,SumNotChangingTime)
SELECT    ServiceRequestId, OldGroupId, SUM(NotChangingTime) SumNotChangingTime, COUNT(OldGroupID) as CountAssignGroup
	--, Max(CreatedOn) MaxCreatedOn, MAX(NotChangingTime) MaxNotChangingTime, MIN(NotChangingTime) MinNotChangingTime, SUM(NotChangingTime) SumNotChangingTime
into #GroupTimeCii2
from #CII
where CreatedOn is not NULL and OldGroupId IS NOT NULL    -- этого условия не было до изменений
GROUP BY ServiceRequestId, OldGroupID                     -- это условие было до изменений
--ORDER BY ServiceRequestId




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
--,GroupTimeCii.MaxNotChangingTime 'Максимальное время обработки группой (мин.)'
--,GroupTimeCii.MinNotChangingTime 'Минимальное время обработки группой (мин.)'
,GroupTimeCii.OldGroupID 'Группа'
--,GroupTimeCII.CreatedOn /*MaxCreatedOn*/ 'Дата перевода на группу'
,GroupTimeCii.SumNotChangingTime 'Время обработки группой (мин.)'
,GroupTimeCii.CountAssignGroup 'Кол-во назначений на группу'

FROM #sr sr
LEFT JOIN ServiceRequestType SRT WITH(NOLOCK) ON SRT.Id = SR.ServiceRequestTypeId
LEFT JOIN Service S WITH(NOLOCK) ON S.Id = SR.ServiceId
LEFT JOIN Service Sc WITH(NOLOCK) ON Sc.Id = SR.TechServiceId
LEFT JOIN StatusOfIncident SOI WITH(NOLOCK) ON SOI.Id = SR.StatusOfIncidentId
LEFT JOIN ( --'Общее время обработки (мин.)'
	SELECT ServiceRequestId, SUM(SumNotChangingTime) SumFullNotChangingTime
	FROM #GroupTimeCii2
	GROUP BY ServiceRequestId
	) SumFullCII ON sr.id = SumFullCII.ServiceRequestId

OUTER APPLY (
	SELECT
	  SAU.Name AS OldGroupID
	, SumNotChangingTime  --, MaxNotChangingTime, MinNotChangingTime
	--, GroupTimeCii2.CreatedOn  CreatedOn --MaxCreatedOn
	, GroupTimeCii2.CountAssignGroup
	FROM
	#GroupTimeCii2 GroupTimeCii2
	LEFT JOIN SysAdminUnit SAU WITH(NOLOCK) ON SAU.Id = GroupTimeCii2.OldGroupId
	WHERE SR.id = GroupTimeCii2.ServiceRequestId

) GroupTimeCII

--WHERE SumFullCII.SumFullNotChangingTime <> GroupTimeCii.MaxNotChangingTime
ORDER BY SR.Number




--Джойним текущий + будущий CounterInIncident. использую CURSOR

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
    WHERE ServiceRequestTypeId <> 'E8A1B4D7-9BA5-4BEF-8ED0-E7DB10E451BF' --Тип обращения не NOC
	--and RegisteredOn >= dateadd(day,-1,getdate())
	and RegisteredOn > '2021-09-24 00:00:00' and RegisteredOn < '2021-09-24 23:59:59'
	--and ClosureDate >= dateadd(day,-1,getdate())
	--and ClosureDate > '2021-09-24 00:00:00' and ClosureDate< '2021-09-24 23:59:59'
	--ORDER BY id


--Урезанная под определённые условия CounterInIncident
--INSERT INTO #CII0 (OldGroupId,NewGroupId,NewStatusOfIncidentId,CreatedOn,NotChangingTime,ServiceRequestId)
	SELECT 
	row_number() OVER(ORDER BY ServiceRequestId, CreatedOn) RowNumber
	,ServiceRequestId,CreatedOn,OldGroupId,NewGroupId
	,cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int) AS NotChangingTime
	,NewStatusOfIncidentId --,RightNotChangingTime = NULL
	into #cii0
	FROM CounterInIncident
	WHERE
		ServiceRequestId IN ( SELECT id FROM #SR )
	    --ServiceRequestId = '28CBE84D-BF78-4803-8315-067C6AB3A194'
		AND NotChangingTime != ''
		AND OldGroupId IS NOT NULL
		/* В полях Общее время обработки (мин.), Максимальное время обработки группой (мин.), Минимальное время обработки группой (мин.), Время обработки группой (мин.) 
	    не должны участвовать значения, у которых "Новое значение статуса" во вкладке счетчики равно “Внешний запрос”, “Внутренний запрос” или “Возвращена на доработку */
		AND NewStatusOfIncidentId NOT IN (
			 'F0B04982-4C74-4FD4-ACD8-05FE186C36FF' /*Внешний запрос*/
			,'6B0131D0-CF34-4ECA-BDBB-00DA49445B77' /*Внутренний запрос*/
			,'D103AB39-7628-4447-8FE8-02C9F1490DD6' /*Возвращена на доработку*/
			)


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
DECLARE cii_cur cursor local static for
SELECT RowNumber,ServiceRequestId,cii2_ServiceRequestId,CreatedOn,OldGroupId,cii2_OldGroupId,NewGroupId,cii2_NewGroupId,NotChangingTime
FROM #cii
ORDER BY RowNumber

-- курсоровские переменные
DECLARE --@Countcii INT, 
	  @RowNumber INT
	, @ServiceRequestId uniqueidentifier, @cii2_ServiceRequestId uniqueidentifier --, @cii_ServiceRequestId uniqueidentifier, @cii_ServiceRequestId uniqueidentifier
	, @CreatedOn datetime2(3) --, @cii2_CreatedOn datetime2(3)
	, @OldGroupId uniqueidentifier, @cii2_OldGroupId uniqueidentifier --, @cii_OldGroupId uniqueidentifier, @cii_OldGroupId uniqueidentifier
	, @NewGroupId uniqueidentifier, @cii2_NewGroupId uniqueidentifier --, @cii_NewGroupId uniqueidentifier, @cii_NewGroupId uniqueidentifier
	, @NotChangingTime INT

-- не курсоровские переменные
DECLARE @Countcii INT = (SELECT COUNT(*) FROM #cii) --
	, @OldRowNumber INT = 0
	--, @OldCreatedOn datetime2(3)
	, @OldServiceRequestId uniqueidentifier = NULL--, @cii_ServiceRequestId uniqueidentifier, @cii_ServiceRequestId uniqueidentifier, @cii2_ServiceRequestId uniqueidentifier
	, @OldOldGroupId uniqueidentifier = NULL --, @cii_OldGroupId uniqueidentifier, @cii_OldGroupId uniqueidentifier, @cii2_OldGroupId uniqueidentifier
	, @OldNewGroupId uniqueidentifier = NULL --, @cii_NewGroupId uniqueidentifier, @cii_NewGroupId uniqueidentifier, @cii2_NewGroupId uniqueidentifier
	, @OldNotChangingTime INT = NULL


open cii_cur
fetch NEXT FROM cii_cur into @RowNumber,@ServiceRequestId,@cii2_ServiceRequestId,@CreatedOn,@OldGroupId,@cii2_OldGroupId,@NewGroupId,@cii2_NewGroupId,@NotChangingTime

WHILE @@FETCH_STATUS = 0 -- @Countcii > 0 -- 
BEGIN
	--SET @OldServiceRequestId = @ServiceRequestId
	--IF (@OldServiceRequestId = @ServiceRequestId, @ServiceRequestId, @ServiceRequestId) @OldServiceRequestId
	UPDATE #cii SET 

	CreatedOn = (case 
		when @ServiceRequestId = @cii2_ServiceRequestId /*AND @OldCreatedOn IS NULL*/ AND @OldGroupId = @NewGroupId AND @OldGroupId = @cii2_OldGroupId  then NULL --
		else CreatedOn
		end),
	NotChangingTime = (case 
		when @ServiceRequestID = @cii2_ServiceRequestId AND @OldGroupId = @NewGroupId AND @OldGroupId = @cii2_OldGroupId  then NULL --
		when @OldGroupId <> @NewGroupId then @OldNotChangingTime + @NotChangingTime
		--when @ServiceRequestId <> @cii2_ServiceRequestId then @OldNotChangingTime + @NotChangingTime
		when @cii2_ServiceRequestId IS NULL then @OldNotChangingTime + @NotChangingTime
		end)
	/*@OldNotChangingTime = (case 
		when @OldNotChangingTime IS NULL AND @OldGroupId = @NewGroupId AND @OldGroupId = @cii2_OldGroupId then @NotChangingTime
		when @OldServiceRequestId <> @ServiceRequestId then @NotChangingTime
		end),*/

	--@Countcii = @Countcii - 1 --
	--@OldRowNumber = @RowNumber + 1
	--INTO #cii FROM #cii
	WHERE RowNumber = @RowNumber

	  SET @OldNotChangingTime = (case 
		when @OldNotChangingTime = 0 AND @OldGroupId = @NewGroupId AND @OldGroupId = @cii2_OldGroupId then @NotChangingTime
		when @OldNotChangingTime <> 0 AND @OldGroupId = @NewGroupId AND @OldGroupId = @cii2_OldGroupId then @OldNotChangingTime + @NotChangingTime
		when @OldServiceRequestId <> @ServiceRequestId then @NotChangingTime
		when @OldGroupID <> @NewGroupId then 0
		when @cii2_ServiceRequestId IS NULL then 0
		end)

	fetch next from cii_cur into @RowNumber,@ServiceRequestId,@cii2_ServiceRequestId,@CreatedOn,@OldGroupId,@cii2_OldGroupId,@NewGroupId,@cii2_NewGroupId,@NotChangingTime
	--IF @@FETCH_STATUS <> 0 break
end

close cii_cur
deallocate cii_cur
END


SELECT * FROM #cii
ORDER BY RowNumber



/*
DECLARE @PlusNotChangingTime INT
SET @PlusNotChangingTime = NULL
UPDATE #cii SET RightNotChangingTime =
 case --джойним ПРОШЛУЮ, НАСТОЯЩУЮ и БУДУЩУЮ строки
when cii0_OldGroupId IS NULL AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId IS NULL then cii1_NotChangingTime --
when cii0_OldGroupId IS NULL AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId <> cii2_NewGroupId then NULL --
when cii0_OldGroupId IS NULL AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId AND cii1_NewGroupId = cii2_OldGroupId then NULL
when cii0_OldGroupId IS NULL AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId AND cii1_NewGroupId <> cii2_OldGroupId then cii1_NotChangingTime
when cii0_OldGroupId IS NULL AND cii1_OldGroupId <> cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId then cii1_NotChangingTime
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId <> cii1_NewGroupId AND cii2_OldGroupId <> cii2_NewGroupId then cii0_NotChangingTime + cii1_NotChangingTime --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId <> cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId AND @PlusNotChangingTime IS NOT NULL then @PlusNotChangingTime + cii1_NotChangingTime --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId <> cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId AND @PlusNotChangingTime IS NULL then cii0_NotChangingTime + cii1_NotChangingTime --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId IS NULL AND @PlusNotChangingTime IS NULL then cii0_NotChangingTime + cii1_NotChangingTime --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId IS NULL AND @PlusNotChangingTime IS NOT NULL then @PlusNotChangingTime + cii1_NotChangingTime --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId = cii2_OldGroupId AND @PlusNotChangingTime IS NULL then NULL --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId IS NULL AND @PlusNotChangingTime IS NOT NULL then @PlusNotChangingTime + cii1_NotChangingTime --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId <> cii2_OldGroupId AND @PlusNotChangingTime IS NOT NULL then NULL --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId <> cii2_OldGroupId AND @PlusNotChangingTime IS NULL then NULL --
when cii0_OldGroupId <> cii0_NewGroupId AND cii1_OldGroupId <> cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId then cii1_NotChangingTime --
when cii0_OldGroupId <> cii0_NewGroupId AND cii1_OldGroupId <> cii1_NewGroupId AND cii2_OldGroupId <> cii2_NewGroupId then cii1_NotChangingTime --
when cii0_OldGroupId <> cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId AND cii1_OldGroupId = cii2_OldGroupId then NULL --
when cii0_OldGroupId <> cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId AND cii1_OldGroupId <> cii2_OldGroupId then cii1_NotChangingTime --
when cii0_OldGroupId <> cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId <> cii2_NewGroupId then NULL --
when cii0_OldGroupId <> cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId IS NULL then cii1_NotChangingTime --
END

  ,@PlusNotChangingTime = case --джойним ПРОШЛУЮ, НАСТОЯЩУЮ и БУДУЩУЮ строки
when cii0_OldGroupId IS NULL AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId IS NULL then NULL --
when cii0_OldGroupId IS NULL AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId <> cii2_NewGroupId then NULL --
when cii0_OldGroupId IS NULL AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId AND cii1_NewGroupId = cii2_OldGroupId then cii1_NotChangingTime
when cii0_OldGroupId IS NULL AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId AND cii1_NewGroupId <> cii2_OldGroupId then NULL
when cii0_OldGroupId IS NULL AND cii1_OldGroupId <> cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId then NULL --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId <> cii1_NewGroupId AND cii2_OldGroupId <> cii2_NewGroupId then NULL --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId <> cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId AND @PlusNotChangingTime IS NOT NULL then NULL --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId <> cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId AND @PlusNotChangingTime IS NULL then NULL --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId IS NULL AND @PlusNotChangingTime IS NULL then NULL --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId IS NULL AND @PlusNotChangingTime IS NOT NULL then NULL --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId = cii2_OldGroupId then cii1_NotChangingTime+@PlusNotChangingTime --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId <> cii2_OldGroupId AND @PlusNotChangingTime IS NOT NULL then cii1_NotChangingTime+@PlusNotChangingTime --
when cii0_OldGroupId = cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId <> cii2_OldGroupId AND @PlusNotChangingTime IS NULL then NULL --
when cii0_OldGroupId <> cii0_NewGroupId AND cii1_OldGroupId <> cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId then NULL --
when cii0_OldGroupId <> cii0_NewGroupId AND cii1_OldGroupId <> cii1_NewGroupId AND cii2_OldGroupId <> cii2_NewGroupId then NULL --
when cii0_OldGroupId <> cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId AND cii1_OldGroupId = cii2_OldGroupId then cii1_NotChangingTime --
when cii0_OldGroupId <> cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId = cii2_NewGroupId AND cii1_OldGroupId <> cii2_OldGroupId then NULL --
when cii0_OldGroupId <> cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId <> cii2_NewGroupId then NULL --
when cii0_OldGroupId <> cii0_NewGroupId AND cii1_OldGroupId = cii1_NewGroupId AND cii2_OldGroupId IS NULL then NULL --
END 
*/



/* -- УБРАТЬ ПОТОМ !!!



--INSERT INTO #GroupTimeCii2 (ServiceRequestId,OldGroupId,MaxNotChangingTime,MinNotChangingTime,SumNotChangingTime)
	SELECT    ServiceRequestId,cii1_OldGroupId OldGroupId
			, MAX(RightNotChangingTime) MaxNotChangingTime
			, MIN(RightNotChangingTime) MinNotChangingTime
			, SUM(RightNotChangingTime) SumNotChangingTime
	into #GroupTimeCii2
	from #CII
	GROUP BY ServiceRequestId, cii1_OldGroupID


--Выборка 'Дата перевода на группу'
--INSERT INTO #GroupTimeCii0 (ServiceRequestId,OldGroupId,MaxCreatedOn)
	SELECT ServiceRequestId, OldGroupID, MAX(CreatedOn) MaxCreatedOn
	into #GroupTimeCii0
	FROM CounterInIncident
	WHERE ServiceRequestId IN ( SELECT id FROM #SR ) AND OldGroupID IS NOT NULL
	GROUP BY ServiceRequestId, OldGroupID

--оставляет MaxChangeDate в тех местах, где OldGroupId не равен NewGroupId
--INSERT INTO #GroupTimeCii1 (ServiceRequestId,OldGroupId,MaxCreatedOn)
	SELECT DISTINCT 
		  cii3.ServiceRequestId ServiceRequestId
		, cii3.OldGroupId OldGroupId
		, case
			 when GroupTimeCII0.OldGroupId = cii3.NewGroupId then NULL
			 else GroupTimeCII0.MaxCreatedOn
		--END MaxChangeDate
		END MaxCreatedOn
	into #GroupTimeCii1
	FROM (
		SELECT ServiceRequestId, OldGroupId, NewGroupId, CreatedOn
		FROM CounterInIncident
		WHERE ServiceRequestId IN ( SELECT id FROM #SR )
		) cii3
	LEFT JOIN #GroupTimeCII0 GroupTimeCII0 ON cii3.ServiceRequestId = GroupTimeCII0.ServiceRequestId 
	      AND cii3.OldGroupID = GroupTimeCII0.OldGroupID
	WHERE cii3.CreatedOn = GroupTimeCII0.MaxCreatedOn --останется только одна строка






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
,GroupTimeCII.MaxCreatedOn 'Дата перевода на группу'
,GroupTimeCii.SumNotChangingTime 'Время обработки группой (мин.)'

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
	, MaxNotChangingTime
	, MinNotChangingTime
	, SumNotChangingTime
	, MaxCreatedOn
	FROM
	#GroupTimeCii1 GroupTimeCii1
	LEFT JOIN #GroupTimeCii2 GroupTimeCii2 ON GroupTimeCii2.ServiceRequestId = GroupTimeCii1.ServiceRequestId
											    AND GroupTimeCII1.OldGroupId = GroupTimeCII2.OldGroupId
	LEFT JOIN SysAdminUnit SAU WITH(NOLOCK) ON SAU.Id = GroupTimeCII1.OldGroupId
	WHERE SR.id = GroupTimeCii1.ServiceRequestId
) GroupTimeCII







/*
SELECT  f.name AS ForeignKey ,
        SCHEMA_NAME(f.SCHEMA_ID) AS SchemaName ,
        OBJECT_NAME(f.parent_object_id) AS TableName ,
        COL_NAME(fc.parent_object_id, fc.parent_column_id) AS ColumnName ,
        SCHEMA_NAME(o.SCHEMA_ID) ReferenceSchemaName ,
        OBJECT_NAME(f.referenced_object_id) AS ReferenceTableName ,
        COL_NAME(fc.referenced_object_id, fc.referenced_column_id)
                                              AS ReferenceColumnName
FROM    sys.foreign_keys AS f
        INNER JOIN sys.foreign_key_columns AS fc
               ON f.OBJECT_ID = fc.constraint_object_id
        INNER JOIN sys.objects AS o ON o.OBJECT_ID = fc.referenced_object_id
        WHERE OBJECT_NAME(f.parent_object_id)='CounterInIncident' /* указать таблицу, по которой хотим связи*/
ORDER BY TableName ,
        ReferenceTableName;
		*/



*/
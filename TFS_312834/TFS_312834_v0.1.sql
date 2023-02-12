USE BPMonline_SSC

Select 
	sc.id,
	SC.Number [Номер обращения],
	UsrCaseSCRoute.Name [Направление],
	UsrBranchSC.Name [Компания],
	Accounting.name [Участок учёта],
	ServiceCategory.Name [Категория темы],
	ServiceItem.Name [Тема],
	CaseStatus.Name [Статус],
	Contact.Name[Исполнитель],
	--dateadd(HOUR,3,SC.ModifiedOn) [Дата изменения],
	cch.OldestStatus [Дата изменения Статуса],
	cmh.OldestComment [Дата комментария]

from UsrCaseSC sc
left join UsrCaseSCRoute on SC.RouteSCId = UsrCaseSCRoute.Id
left join UsrBranchSC on SC.UsrCompanyId = UsrBranchSC.ID
left join Accounting on SC.AccountingSCid = Accounting.Id                --Участок учёта
left join ServiceCategory on ServiceCategory.Id = SC.ServiceCategoryId   --Система
left join ServiceItem on ServiceItem.Id = SC.ServiceItemId               --Услуга
left join CaseStatus on SC.StatusId = CaseStatus.Id
left join Contact on Contact.Id = SC.ResponsibleSCId
outer apply (
	select UsrCaseSCId
	  , dateadd(HOUR,3,MAX(UsrChangedStatusDate)) OldestStatus
	from UsrCaseChangesHistory h1
	where h1.UsrCaseSCId = SC.id
	group by UsrCaseSCId
	) cch
outer apply (
	select UsrCaseSCId
	  , dateadd(HOUR,3,MAX(CreatedOn)) OldestComment
	from UsrCaseSCMessageHistory h2
	where h2.UsrCaseSCId = SC.id
	group by UsrCaseSCId
	) cmh

where SC.RouteSCId IN (
	  '020453A3-E21C-497F-9F50-3C4813B63B60'   -- В ОЦО
	, '018A5135-1743-4762-9F5B-04DA23613B73'   -- В Регион
	)
--В обращении присутствует комментарий, после которого не было изменения статуса.
--Дата комментария >= Даты последнего изменения поля "статус" (История - последняя запись "Статус - StartDate" < на 5 минут чем дата последнего комментария)
--AND cmh.OldestComment >= dateadd(HOUR,3,SC.ModifiedOn)
  AND cmh.OldestComment > cch.OldestStatus
--AND sc.Number = 'SSC00326586'

--GROUP BY UsrCaseSC.Id
ORDER BY cmh.OldestComment










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
        WHERE OBJECT_NAME(f.parent_object_id)='UsrCaseSC' /* указать таблицу, по которой хотим связи*/
ORDER BY TableName ,
        ReferenceTableName;
*/



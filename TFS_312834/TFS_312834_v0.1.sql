USE BPMonline_SSC

Select 
	sc.id,
	SC.Number [����� ���������],
	UsrCaseSCRoute.Name [�����������],
	UsrBranchSC.Name [��������],
	Accounting.name [������� �����],
	ServiceCategory.Name [��������� ����],
	ServiceItem.Name [����],
	CaseStatus.Name [������],
	Contact.Name[�����������],
	--dateadd(HOUR,3,SC.ModifiedOn) [���� ���������],
	cch.OldestStatus [���� ��������� �������],
	cmh.OldestComment [���� �����������]

from UsrCaseSC sc
left join UsrCaseSCRoute on SC.RouteSCId = UsrCaseSCRoute.Id
left join UsrBranchSC on SC.UsrCompanyId = UsrBranchSC.ID
left join Accounting on SC.AccountingSCid = Accounting.Id                --������� �����
left join ServiceCategory on ServiceCategory.Id = SC.ServiceCategoryId   --�������
left join ServiceItem on ServiceItem.Id = SC.ServiceItemId               --������
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
	  '020453A3-E21C-497F-9F50-3C4813B63B60'   -- � ���
	, '018A5135-1743-4762-9F5B-04DA23613B73'   -- � ������
	)
--� ��������� ������������ �����������, ����� �������� �� ���� ��������� �������.
--���� ����������� >= ���� ���������� ��������� ���� "������" (������� - ��������� ������ "������ - StartDate" < �� 5 ����� ��� ���� ���������� �����������)
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
        WHERE OBJECT_NAME(f.parent_object_id)='UsrCaseSC' /* ������� �������, �� ������� ����� �����*/
ORDER BY TableName ,
        ReferenceTableName;
*/



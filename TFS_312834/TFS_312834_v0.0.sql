USE BPMonline_SSC

Select 
	UsrCaseSC.Number [����� ���������],
	UsrCaseSCRoute.Name [�����������],
	UsrBranchSC.Name [��������],
	Accounting.name [������� �����],
	ServiceCategory.Name [��������� ����],
	ServiceItem.Name [����],
	CaseStatus.Name [������],
	Contact.Name[�����������],
	cmh.OldestComment [���� �����������]

from UsrCaseSC
left join UsrCaseSCRoute on UsrCaseSC.RouteSCId = UsrCaseSCRoute.Id
left join UsrBranchSC on UsrCaseSC.UsrCompanyId = UsrBranchSC.ID
left join Accounting on UsrCaseSC.AccountingSCid = Accounting.Id                --������� �����
left join ServiceCategory on ServiceCategory.Id = UsrCaseSC.ServiceCategoryId   --�������
left join ServiceItem on ServiceItem.Id = UsrCaseSC.ServiceItemId               --������
left join CaseStatus on UsrCaseSC.StatusId = CaseStatus.Id
left join Contact on Contact.Id = UsrCaseSC.ResponsibleSCId
outer apply (
	select UsrCaseSCId
	  , dateadd(HOUR,3,MAX(CreatedOn)) OldestComment
	from UsrCaseSCMessageHistory h
	where h.UsrCaseSCId = UsrCaseSC.id
	group by UsrCaseSCId
	) cmh
--left join (
--	select UsrCaseSCId
--	--, MAX(CreatedOn) OldestComment
--	  , dateadd(HOUR,3,MAX(CreatedOn)) OldestComment
--	--, format((dateadd(hh, +3, MAX(CreatedOn))), 'dd-MM-yyyy HH:mm:ss') OldestComment
--	from UsrCaseSCMessageHistory
--	group by UsrCaseSCId
--	) cmh
--	on cmh.UsrCaseSCId = UsrCaseSC.Id

where UsrCaseSC.RouteSCId IN (
	  '020453A3-E21C-497F-9F50-3C4813B63B60'   -- � ���
	, '018A5135-1743-4762-9F5B-04DA23613B73'   -- � ������
	)
--� ��������� ������������ �����������, ����� �������� �� ���� ��������� �������.
--���� ����������� >= ���� ���������� ��������� ���� "������" (������� - ��������� ������ "������ - StartDate" < �� 5 ����� ��� ���� ���������� �����������)
AND cmh.OldestComment >= dateadd(HOUR,3,UsrCaseSC.ModifiedOn)

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



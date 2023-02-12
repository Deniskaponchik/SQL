--v0.0
--��������: ������� ��������� ������� �� ���������
--������: 
--����������: 
--��������: 


--t2ru-tr-tst-02
--USE BPMonline7_14880;

select
--  umr.name '�����������'
--, urc.name '������'
    MacReg.umrn '�����������'
  , MacReg.urcn '������'
  , c.Number as sr
--, cs.Name '������'
  , si.Name '�������'
  , sii.Name '������'
  , c.UsrParametersSet AS "�������� ����������"
  , c.RegisteredOn '���� �����������'
--, usic1.StringValue '����������� ���� ������'
  , c.ClosureDate '���� ��������'
--, usic2.StringValue '����������� ���� ����������'
  , c.ResponseOverdue '������� ����������'
  , c.SolutionOverdue '������� ����������'
--, ucch.NewStatusId '������ � ������� ����'
  , case
		when ucch.NewStatusId = 'F063EBBE-FDC6-4982-8431-D8CFA52FEDCF' then 0
		when ucch.NewStatusId is NULL then 1
	end '������ � ������� ����'
  , sau1.name '������ ������������� 1'
--, sau2.name '������ ������������� 2'
  , co.name '��� �����������'

  , 'https://bpm.tele2.ru/0/Nui/ViewModule.aspx#CardModuleV2/CasePage/edit/'+cast(c.Id as nvarchar(64)) as link


from [case] c
left join ServiceItem si on si.Id=c.UsrSystemId
left join ServiceItem sii on sii.Id=c.ServiceItemId
left join CaseStatus cs on cs.Id=c.StatusId
--left join UsrRegionCode urc on urc.id = c.UsrRegionId
--left join UsrMacroRegion umr on umr.id = c.UsrMacroregionId
left join (
	SELECT UsrRegionCode.Id urci, UsrRegionCode.Name urcn, UsrMacroRegion.Name umrn
	FROM  UsrRegionCode
	Left JOIN UsrMacroRegion
	ON UsrRegionCode.[UsrMacroRegionId] = UsrMacroRegion.[Id]
	) MacReg on MacReg.urci = c.UsrRegionId
left join Contact co on c.UsrResolvedContactId = co.Id
left join SysAdminUnit sau1 on sau1.id = c.UsrSolvedGroupId 
left join SysAdminUnit sau2 on sau2.id = c.UsrResolvedGroupId 
left join (
	select UsrCaseid, NewStatusId
	from UsrCaseChangeHistory
	where NewStatusId = 'F063EBBE-FDC6-4982-8431-D8CFA52FEDCF'  --�����������
	) ucch on ucch.UsrCaseId = c.id
--left join (
--	select UsrCaseid, StringValue
--	from UsrSpecificationInCase
--	where SpecificationId = '558B3F8B-FA19-4D62-915B-4326B7C087AC'  --����������� ���� ������
--	) usic1 on usic1.UsrCaseId = c.id
--left join (
--	select UsrCaseid, StringValue
--	from UsrSpecificationInCase
--	where SpecificationId = '10057311-E073-4347-9B21-1B8DC032FA73'  --����������� ���� ����������
--	) usic2 on usic2.UsrCaseId = c.id

where 
	--si.Name in ('Helpdesk IT', '������ � ������������')
      c.UsrSystemId in (
	      '5594B877-3BB7-46DB-99F5-3C75B3E46556'  --Helpdesk IT
	    , 'A79FAB13-7E2B-4D45-B809-2E7E0079547C'  --������ � ������������
		)

--and cs.Name in ('������','�������')
  and c.StatusId in (
		  'AE7F411E-F46B-1410-009B-0050BA5D6C38'  --������
		, '3E7F420C-F46B-1410-FC9A-0050BA5D6C38'  --�������
		)

--and c.SolutionProvidedOn between dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2)))) 
--and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))
  and c.SolutionProvidedOn BETWEEN '2021-12-01 00:00:00' and '2021-12-31 23:59:59'

--and c.UsrSolvedGroupId IN (
--  	'BF6253E9-58F3-495C-9D31-953FDEEDF5FB'  --IT Support
--    , '30888234-00B9-4951-9EB8-A879CE27CFF6'  --IBS
--    , 'D9FDDA97-F790-4E97-8A57-B33121380F81'  --Servionica
--    , 'A082D3D9-2F1E-4C1C-9348-904BDC58870B'  --LantaService Print
--    , '32A1A6C8-6219-4A27-AF9B-5C7A0AE4AF63'  --ITsupp_2line
--    , 'B81C3306-C243-4965-A0D0-3262096AF659'  --IT MFE
--    , '5678A742-DA46-469B-B30F-083EFF71CB68'  --IT MSB
--    , 'CE6B8AEF-B576-4860-83A4-3C6291493094'  --IT MUR
--    , '487EE4C1-148E-48EF-8AE4-B6BE9E307E77'  --IT MCB
--    , 'BED0A116-F81B-4A71-8C4F-C6D8F337961A'  --IT MNW
--    , 'A5A35941-B5F1-4879-B853-AF94AAA4E109'  --IT MST
--    , '91D34E64-F1FC-4EB0-9651-9D2D3E98A6DB'  --IT MVU
--    , '0CA2A90A-5D1A-4F46-9B61-2E89A71E1681'  --IT MCN
--    , ''  --Zoom_Supp_Regions
--    , ''  --Zoom_Supp_Moscow
--    , ''  --Zoom_Supp_MoscowMR
--    , ''  --
--    , ''  --
--    , ''  --
--    , ''  --
--    , ''  --
--    , ''  --
--    , ''  --
--    , ''  --
--    , ''  --
--    , ''  --
--    , ''  --
--	)

--and c.Number = 'SR04883583'
--and c.Number IN ('SR04377502','SR04223621')

--ORDER BY c.RegisteredOn DESC


--v0.2
--https://tfs.tele2.ru/tfs/Main/Tele2/_workitems/edit/420947
--��������: ������� ��������� ������� �� ��������� � ������ ����, ������� ����������
--������: �������
--����������: ��������� �������.
--��������: ��� ���������� UsrSolvedGroupId and UsrResolvedGroupId ?

CREATE View VwBPM7_CaseHelpdeskIT_SLA_TFS418475_4NSIT

select
--  MacReg.umrn '�����������'
--, MacReg.urcn '������'
    umr.name '�����������'
  , urc.name '������'

  , usic4.StringValue '�������'
--, usic5.StringValue '�����'
  , NULL '�����'
  , c.Number as sr
--, cs.Name '������'
  , si.Name '�������'
  , sii.Name '������'
  , c.UsrParametersSet AS "�������� ����������"
  , c.RegisteredOn '���� �����������'
  , NULL '����������� ���� ������'
--, usic1.StringValue '����������� ���� ������'
  , c.ClosureDate '���� ��������'
  , NULL '����������� ���� ����������'
--, usic2.StringValue '����������� ���� ����������'
  , c.ResponseOverdue '������� ����������'
  , c.SolutionOverdue '������� ����������'

--, ucch.NewStatusId '������ � ������� ����'
  , case
	  when ucch1.NewStatusId = 'F063EBBE-FDC6-4982-8431-D8CFA52FEDCF' then 0
	  when ucch1.NewStatusId is NULL then 1
	end '������ � ������� ����'

  , case
		when ucch2.NewGroupId is not null then 1
		when ucch2.NewGroupId is null then 0
	end '��������������'

   , sau1.name '������ ������������� 1'
 --, sau2.name '������ ������������� 2'
  , co.name '��� �����������'
  , NULL '����������� �������'
--, usic3.StringValue '����������� �������'
  , 'https://bpm.tele2.ru/0/Nui/ViewModule.aspx#CardModuleV2/CasePage/edit/'+cast(c.Id as nvarchar(64)) as link


     from [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[case] c
left join [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[ServiceItem] si on si.Id=c.UsrSystemId
left join [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[ServiceItem] sii on sii.Id=c.ServiceItemId
left join [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[CaseStatus] cs on cs.Id=c.StatusId

left join [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[UsrRegionCode] urc on urc.id = c.UsrRegionId
left join [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[UsrMacroRegion] umr on umr.id = urc.UsrMacroRegionId

left join [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[Contact] co on c.UsrResolvedContactId = co.Id
left join [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[SysAdminUnit] sau1 on sau1.id = c.UsrSolvedGroupId  --������ �������������
--left join SysAdminUnit sau2 on sau2.id = c.UsrResolvedGroupId --��� �����-�� ������ �������������

left join [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[UsrCaseChangeHistory] ucch1 
  on ucch1.UsrCaseId = c.Id and ucch1.NewStatusId = 'F063EBBE-FDC6-4982-8431-D8CFA52FEDCF' --�����������

--����� ������, ����������� ������������� (���� �����: https://wiki.tele2.ru/pages/viewpage.action?pageId=38538972)
left join [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[UsrCaseChangeHistory] ucch2 
   on ucch2.UsrCaseId = c.Id 
  and ucch2.NewStatusId = 'AE7F411E-F46B-1410-009B-0050BA5D6C38'  --������
  and ucch2.OldStatusId = '49284152-9CA5-4006-B97C-A6D4382D7FAD'  --���������
  and ucch2.NewGroupId = c.UsrSolvedGroupId

--��� ������� ��� ����������. ���� �����������, ����� ��������.
--left join [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[UsrSpecificationInCase] usic1
--on usic1.UsrCaseId = c.id and usic1.SpecificationId = '558B3F8B-FA19-4D62-915B-4326B7C087AC'  --����������� ���� ������
--left join [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[UsrSpecificationInCase] usic2 
--on usic2.UsrCaseId = c.id and usic2.SpecificationId = '10057311-E073-4347-9B21-1B8DC032FA73'  --����������� ���� ����������
--left join [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[UsrSpecificationInCase] usic3 
--on usic3.UsrCaseId = c.id and usic3.SpecificationId = '7E0F18B6-3857-463C-8ABF-A38486FCB2CF'  --����������� �������
  left join [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[UsrSpecificationInCase] usic4 
  on usic4.UsrCaseId = c.id and usic4.SpecificationId = '9957AB2C-A353-49BF-A6EB-9968966C4BE8'  --������ �� ������� ����������
--left join [T2RU-BPMDB-05\BPMONLINE].[BPMonline7].[dbo].[UsrSpecificationInCase] usic5 
--on usic5.UsrCaseId = c.id and usic5.SpecificationId = '4E96E7C5-60FC-4D0C-845E-7FD9D3D5200E'  --����� �����

where 
(	  c.UsrSolvedGroupId IN (
		  '30888234-00B9-4951-9EB8-A879CE27CFF6'  --IBS
		, 'D9FDDA97-F790-4E97-8A57-B33121380F81'  --Servionica
		, 'A082D3D9-2F1E-4C1C-9348-904BDC58870B'  --LantaService Print
		, '32A1A6C8-6219-4A27-AF9B-5C7A0AE4AF63'  --ITsupp_2line

		, 'A5A35941-B5F1-4879-B853-AF94AAA4E109'  --IT MST
		, 'BED0A116-F81B-4A71-8C4F-C6D8F337961A'  --IT MNW
		, '0CA2A90A-5D1A-4F46-9B61-2E89A71E1681'  --IT MCN
		, '91D34E64-F1FC-4EB0-9651-9D2D3E98A6DB'  --IT MVU
		, '487EE4C1-148E-48EF-8AE4-B6BE9E307E77'  --IT MCB
		, 'CE6B8AEF-B576-4860-83A4-3C6291493094'  --IT MUR
		, '5678A742-DA46-469B-B30F-083EFF71CB68'  --IT MSB
		, 'B81C3306-C243-4965-A0D0-3262096AF659'  --IT MFE

		, '925FAA43-EE56-4BDA-A17C-EF38E5118D69'  --IT MO
		, '9673B516-B17B-42DA-888E-9A7F585B9BD6'  --IT VO
		, 'E6E52838-697C-4048-836A-1DC5032157D3'  --IT EK
		, 'A8720F53-A17F-4690-9033-5E1586EE9E82'  --IT IR
		, '9646F8E8-704A-425E-A163-6D554AB50DD6'  --IT KZ
		, 'DF7486F9-FD17-4004-B9D0-FE251FA2C8E8'  --IT KY
		, 'AEA163F7-A75C-46CA-9DEC-238C48EF55DF'  --IT KR
		, '6E299220-C336-4622-B2F3-223E4B65FC72'  --IT NN
		, '4DB94524-B36E-4DE9-895E-C3BF4F1CB271'  --IT NS
		, 'BDED556C-15C2-47FC-AB8E-CF147885F55D'  --IT OM
		, '541C608A-550A-496A-BA08-1CB527F0B0BC'  --IT PR
		, '94AB6F19-33FB-4088-815F-C4994C149D53'  --IT RO
		, '4024904F-02FD-40FD-9633-AB8678C92B70'  --IT SP
		, '6F13DC98-CA6B-4966-93E2-2FE098A9D420'  --IT TL
		, '6416C93A-BA03-49D3-A6DB-6972569973F8'  --IT TM
		, 'F509C5ED-3519-403B-AEB8-97E9C48F413E'  --IT CH
		, '51A79398-8D53-45C6-835A-E05C7789B81B'  --IT RU
		)

    OR c.UsrSystemId in (
	      '5594B877-3BB7-46DB-99F5-3C75B3E46556'  --Helpdesk IT
	    , 'A79FAB13-7E2B-4D45-B809-2E7E0079547C'  --������ � ������������
		)
)

  and c.StatusId in ( 
		  '3E7F420C-F46B-1410-FC9A-0050BA5D6C38'  --�������
		)

--select GetDate()
--and c.SolutionProvidedOn between dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2)))) 
--and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))
--and c.SolutionProvidedOn BETWEEN '2021-12-01 00:00:00' and '2021-12-31 23:59:59'
--and c.ClosureDate BETWEEN '2021-12-01 00:00:00' and '2021-12-31 23:59:59'
  and c.ClosureDate BETWEEN '2022-01-01 00:00:00.000' and GetDate()
--and ClosureDate >= dateadd(day,-1,getdate()) 

--ORDER BY c.RegisteredOn DESC


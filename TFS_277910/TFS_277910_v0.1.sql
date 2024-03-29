USE BPMonline7_8888;
select
c.Subject [��������]
,cscl.Name [��������� ���������]
,s.Name [�������]
,u.Name [������]
,con.name [�����]
,chan.name [�������]
--,format((dateadd(hh, +3, cl.StartDate)),'dd-MM-yyyy HH:mm:ss') [���� ���������]
--,format((dateadd(hh, +3, c.RegisteredOn)),'dd-MM-yyyy HH:mm:ss') [���� �����������]
--,format((dateadd(hh, +3, c.RespondedOn)),'dd-MM-yyyy HH:mm:ss') [����������� �������]
--,format((dateadd(hh, +3, c.SolutionProvidedOn)),'dd-MM-yyyy HH:mm:ss') [����������� �������]
,cast((dateadd(hh,+3,cl.StartDate)) as smalldatetime) [���� ���������]
,cast((dateadd(hh,+3,c.RegisteredON)) as smalldatetime) [���� �����������] 
,cast((dateadd(hh,+3,c.RespondedOn)) as smalldatetime) [����������� �������]
,cast((dateadd(hh,+3,c.SolutionProvidedOn)) as smalldatetime) [����������� �������]
,res.Name [�����]
,reg.Name [������]
,c.Number [�����]
,cc.Name [��� ��������]
,c.Solution [�������]
,c.UsrParametersSet [�������� ����������]
,otv.Name [������������]

from 
CaseLifecycle cl 
left join [case] c on c.id = cl.CaseId
left join CaseStatus cs on cs.id = c.StatusId
left join ServiceItem s on s.id = c.UsrSystemId
left join ServiceItem u on u.id = c.ServiceItemId
left join Contact con on con.id = c.UsrAuthorId
left join Contact chan on chan.id = cl.OwnerId
left join Contact res on res.id = c.UsrResolvedContactId
left join UsrRegionCode reg on reg.id = c.UsrRegionId
left join ClosureCode cc on cc.Id = c.ClosureCodeId
left join Contact otv on otv.id = c.OwnerId
left join CaseStatus cscl on cscl.id = cl.StatusId
where 
--format (dateadd (hh, +3, cl.StartDate),'dd-MM-yyyy') = format (dateadd(day,-1,GETDATE()),'dd-MM-yyyy')
  cast (dateadd (hh, +3, cl.StartDate) as date) = cast (dateadd(day,-1,GETDATE()) as date)
and cl.StatusId != '3E7F420C-F46B-1410-FC9A-0050BA5D6C38'
and cl.StatusId != 'AE5F2F10-F46B-1410-FD9A-0050BA5D6C38'
and (   /* ������� + ������ */
		c.ServiceItemId IN (
			 '4AC419E8-90A0-4A27-BA33-EA405499CA38' /* �������: "������� �����" ������:"���������� �������" */
			,'850FBD0D-571D-4F0A-9E28-98BF9B4721C9' /* �������: "������� �����" ������:"���������� ������" */
			,'DD906579-3AD1-4114-887D-3B855FABFA05' /* �������: "���������� TT" ������:"���������� 1-�� ������.�������" */
			,'1DD39028-135E-4160-AC16-201A2F89602E' /* �������: "���������� TT" ������:"���������� 2-�� ������.�������" */
			,'4FF2199F-BA1B-42FD-B6CD-8B9C69DDB55B' /* �������: "���������� TT" ������:"���������� 1-�� ������" */
			,'EA4E3AE7-FBC6-4FF5-9C39-E7C7B337D8DA' /* �������: "���������� TT" ������:"���������� 2-�� ������" */
			,'08ED7BA6-B120-468E-AA21-62D9B94D92A8' /* �������: "���������� TT" ������:"����������. ������������ ��" */
			,'6C6AD89F-35AA-4D24-AFA2-E8C3CB1CF56B' /* �������: "��������� ��������" ������:"����������" */
			,'B26D4F47-8F7B-4CAF-AB4E-C7A93547FBBD' /* �������: "����� ����� �������������� �������" ������:"������-��-���� (��)" */
		)
	OR  /* ��� ������ �� ������� */
		c.UsrSystemId IN (
			 '2262F226-B4DD-45AD-8FE7-0598804152AA' /* �������: "OBO"							   ������:��� */
			,'C9EAF329-8EDF-4FCC-9E15-271D033022F2' /* �������: "���������� ��"					   ������:��� */
			,'4E8EFF9B-BA7F-4E45-BC0C-07052B067E81' /* �������: "��������������� ��"	           ������:��� */
			,'D15C721D-8D59-45DB-AB3B-84CC52E2718A' /* �������: "�������� �����������������"       ������:��� */
			,'1B29C659-13F1-488F-A7BE-C4FCD90D63D8' /* �������: "��������� �������������� �������" ������:��� */
			,'0CD0C891-D1E7-4558-AF39-678923DFB2C3' /* �������: "����������� ���"                  ������:��� */
			,'BAFBF911-C1B5-4B43-820A-5BCA13C62122' /* �������: "��������� ������� �����"          ������:��� */
		)
)
order by c.Number, cl.StartDate







/* ������� 
select
c.Subject [��������]
,cscl.Name [��������� ���������]
,s.Name [�������]
,u.Name [������]
,con.name [�����]
,chan.name [�������]
,format((dateadd(hh, +3, cl.StartDate)),'dd-MM-yyyy HH:mm:ss') [���� ���������]
,format((dateadd(hh, +3, c.RegisteredOn)),'dd-MM-yyyy HH:mm:ss') [���� �����������]
,format((dateadd(hh, +3, c.RespondedOn)),'dd-MM-yyyy HH:mm:ss') [����������� �������]
,format((dateadd(hh, +3, c.SolutionProvidedOn)),'dd-MM-yyyy HH:mm:ss') [����������� �������]
,res.Name [�����]
,reg.Name [������]
,c.Number [�����]
,cc.Name [��� ��������]
,c.Solution [�������]
,c.UsrParametersSet [�������� ����������]
,otv.Name [������������]
from CaseLifecycle cl 
left join [case] c on c.id = cl.CaseId
left join CaseStatus cs on cs.id = c.StatusId
left join ServiceItem s on s.id = c.UsrSystemId
left join ServiceItem u on u.id = c.ServiceItemId
left join Contact con on con.id = c.UsrAuthorId
left join Contact chan on chan.id = cl.OwnerId
left join Contact res on res.id = c.UsrResolvedContactId
left join UsrRegionCode reg on reg.id = c.UsrRegionId
left join ClosureCode cc on cc.Id = c.ClosureCodeId
left join Contact otv on otv.id = c.OwnerId
left join CaseStatus cscl on cscl.id = cl.StatusId
where format (dateadd (hh, +3, cl.StartDate),'dd-MM-yyyy') = format (dateadd(day,-1,GETDATE()),'dd-MM-yyyy')
and cl.StatusId != '3E7F420C-F46B-1410-FC9A-0050BA5D6C38'
and cl.StatusId != 'AE5F2F10-F46B-1410-FD9A-0050BA5D6C38'
and c.UsrSystemId = 'bafbf911-c1b5-4b43-820a-5bca13c62122'
order by c.Number, cl.StartDate
*/


/* ����������
select 
	c.Number
	, usic.StringValue
from [case] c
left join ServiceItem si on si.Id=c.UsrSystemId
left join ServiceItem sii on sii.Id=c.ServiceItemId
left join CaseStatus cs on cs.Id=c.StatusId
left join UsrSpecificationInCase usic on usic.UsrCaseId = c.id

where si.Name in ('IC')
and sii.Name in ('New Trgroup', 'New TRGroup INT')
and cs.Name in ('������','�������')
and c.SolutionProvidedOn between dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2)))) 
and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))
*/





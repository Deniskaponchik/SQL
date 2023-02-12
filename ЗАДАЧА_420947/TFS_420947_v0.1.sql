--v0.0
--https://tfs.tele2.ru/tfs/Main/Tele2/_workitems/edit/420947
--ОПИСАНИЕ: Решёные обращения группой ИТ поддержки с начала года, включая Сервионику
--СТАТУС: РАБОЧЕЕ
--РЕАЛИЗАЦИЯ: Связанные серверы. Без параметра Регион в Перечне параметров
--ПРОБЛЕМЫ: В каком виде необходимо указывать БД прода ?

--USE BPMonline7_14880;

CREATE View VwBPM7_CaseHelpdeskIT_SLA_TFS418475_4NSIT

select
--    umr.name 'МакроРегион'
--  , urc.name 'Регион'
	  MacReg.umrn 'МакроРегион'
	, MacReg.urcn 'Регион'
	, usic4.StringValue 'РегионП'
	, c.Number as sr
    --, cs.Name 'Статус'
	, si.Name 'Система'
	, sii.Name 'Услуга'
	, c.UsrParametersSet AS "Перечень параметров"
	, c.RegisteredOn 'Дата регистрации'
	, NULL 'Фактическая дата начала'
	--, usic1.StringValue 'Фактическая дата начала'
	, c.ClosureDate 'Дата закрытия'
	, NULL 'Фактическая дата завершения'
	--, usic2.StringValue 'Фактическая дата завершения'
	, c.ResponseOverdue 'Реакция просрочена'
	, c.SolutionOverdue 'Решение просрочено'

    --, ucch.NewStatusId 'Решено с первого раза'
	, case
		when ucch.NewStatusId = 'F063EBBE-FDC6-4982-8431-D8CFA52FEDCF' then 0
		when ucch.NewStatusId is NULL then 1
	  end 'Решено с первого раза'

	--, auto.NewGroupId 'АвтоВыполнение'
	, case
		when auto.NewGroupId is not null then 1
		when auto.NewGroupId is null then 0
	end 'АвтоВыполнение'


	, sau1.name 'Группа ответственных 1'
    --, sau2.name 'Группа ответственных 2'
	, co.name 'ФИО исполнителя'
	, NULL 'Назначенный инженер'
	--, usic3.StringValue 'Назначенный инженер'
	, 'https://bpm.tele2.ru/0/Nui/ViewModule.aspx#CardModuleV2/CasePage/edit/'+cast(c.Id as nvarchar(64)) as link


from [t2ru-bpmdb-read\bpmonline].[BPMonline7].[dbo.case] c
left join ServiceItem si on si.Id=c.UsrSystemId
left join ServiceItem sii on sii.Id=c.ServiceItemId
left join CaseStatus cs on cs.Id=c.StatusId
--left join UsrRegionCode urc on urc.id = c.UsrRegionId
--left join UsrMacroRegion umr on umr.id = c.UsrMacroregionId
left join (
	SELECT UsrRegionCode.Id urci, UsrRegionCode.Name urcn, UsrMacroRegion.Name umrn
	FROM  [t2ru-bpmdb-read\bpmonline].[BPMonline7].[dbo.UsrRegionCode] UsrRegionCode
	Left JOIN [t2ru-bpmdb-read\bpmonline].[BPMonline7].[dbo.UsrMacroRegion] UsrMacroRegion
	ON UsrRegionCode.[UsrMacroRegionId] = UsrMacroRegion.[Id]
	) MacReg on MacReg.urci = c.UsrRegionId
left join [t2ru-bpmdb-read\bpmonline].[BPMonline7].[dbo.Contact] co on c.UsrResolvedContactId = co.Id
left join [t2ru-bpmdb-read\bpmonline].[BPMonline7].[dbo.SysAdminUnit] sau1 on sau1.id = c.UsrSolvedGroupId 
--left join SysAdminUnit sau2 on sau2.id = c.UsrResolvedGroupId 
left join (
	select UsrCaseid, NewStatusId
	from [t2ru-bpmdb-read\bpmonline].[BPMonline7].[dbo.UsrCaseChangeHistory]
	where NewStatusId = 'F063EBBE-FDC6-4982-8431-D8CFA52FEDCF'  --переоткрыто
	) ucch on ucch.UsrCaseId = c.id

/* Это рабочее для Сервионики. Если понадобится, можно включить. Но пока отключаю для ускорения кода
left join (
	select UsrCaseid, StringValue
	from UsrSpecificationInCase
	where SpecificationId = '558B3F8B-FA19-4D62-915B-4326B7C087AC'  --Фактическая дата начала
	) usic1 on usic1.UsrCaseId = c.id
left join (
	select UsrCaseid, StringValue
	from UsrSpecificationInCase
	where SpecificationId = '10057311-E073-4347-9B21-1B8DC032FA73'  --Фактическая дата Завершения
	) usic2 on usic2.UsrCaseId = c.id
left join (
	select UsrCaseid, StringValue
	from UsrSpecificationInCase
	where SpecificationId = '7E0F18B6-3857-463C-8ABF-A38486FCB2CF'  --Назначенный инженер
	) usic3 on usic3.UsrCaseId = c.id
*/

left join (
	select UsrCaseid, StringValue
	from [t2ru-bpmdb-read\bpmonline].[BPMonline7].[dbo.UsrSpecificationInCase]
	where SpecificationId = '9957AB2C-A353-49BF-A6EB-9968966C4BE8'  --Регион из перечня Параметров
	) usic4 on usic4.UsrCaseId = c.id

outer apply (
	select NewGroupId
	from [t2ru-bpmdb-read\bpmonline].[BPMonline7].[dbo.UsrCaseChangeHistory] ucch
	where ucch.NewGroupId = c.UsrSolvedGroupId	
	and ucch.UsrCaseId = c.id
	and ucch.NewStatusId = 'AE7F411E-F46B-1410-009B-0050BA5D6C38'  --Решено
	and ucch.OldStatusId = '49284152-9CA5-4006-B97C-A6D4382D7FAD'  --Назначено
	) Auto

where 
(
    --sau1.name in ('IBS', 'Servionica')
	  c.UsrSolvedGroupId IN (
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

--and si.Name in ('Helpdesk IT')
    OR c.UsrSystemId in (
	      '5594B877-3BB7-46DB-99F5-3C75B3E46556'  --Helpdesk IT
	    , 'A79FAB13-7E2B-4D45-B809-2E7E0079547C'  --Печать и сканирование
		)
)
--and cs.Name in ('Решено','Закрыто')
  and c.StatusId in ( 
		  '3E7F420C-F46B-1410-FC9A-0050BA5D6C38'  --Закрыто
	  --, 'AE7F411E-F46B-1410-009B-0050BA5D6C38'  --Решено
		)

--Если Выполнено скриптом, но Не с первого раза:
--and CAST(c.UsrIsScriptExecuted AS INT) > CAST(ucch.NewStatusId AS INT)

--select GetDate()
--and c.SolutionProvidedOn between dateadd(hour,3,(dateadd(MONTH,-1,cast(format(GETDATE(), 'yyyy-MM-01') as datetime2)))) 
--and dateadd(hour,3,((cast(format(GETDATE(), 'yyyy-MM-01') as datetime2))))
--and c.SolutionProvidedOn BETWEEN '2021-12-01 00:00:00' and '2021-12-31 23:59:59'
--and c.ClosureDate BETWEEN '2021-12-01 00:00:00' and '2021-12-31 23:59:59'
  and c.ClosureDate BETWEEN '2021-01-01 00:00:00.000' and GetDate()
--and ClosureDate >= dateadd(day,-1,getdate()) 

--and usic1.StringValue IS NOT NULL

--ORDER BY c.RegisteredOn DESC


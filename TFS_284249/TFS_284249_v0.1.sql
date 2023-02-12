/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) 
row_number() OVER(ORDER BY ServiceRequestId, CreatedOn)RowNumber,
--@x:=@x+1,
--[Id],
[ServiceRequestId]
      ,[CreatedOn]
	  ,[ChangeDate]
--      ,[ParameterForCounterId]
      ,[OldGroupId]
      ,[NewGroupId]
      ,[OldStatusOfIncidentId]
      ,[NewStatusOfIncidentId]
      ,[ChangedById]
      ,[ChangedGroupId]

      ,[NotChangingTime]
      
      ,[OldStatusOfServiceCallId]
      ,[NewStatusOfServiceCallId]
  FROM [BPMonline_80].[dbo].[CounterInIncident] --cii0
  --, (SELECT @x:=0) x
  /*cross apply (
	SELECT row_number() OVER(ORDER BY ServiceRequestId, CreatedOn)RowNumber1,[CreatedOn]
	FROM CounterInIncident cii1
	ORDER BY ServiceRequestId, CreatedOn
	WHERE cii1.RowNumber1 = Cii0.(RowNumber-1)*/

  --GROUP BY ServiceRequestId
  ORDER BY ServiceRequestId, CreatedOn




  	SELECT row_number() OVER(ORDER BY ServiceRequestId, CreatedOn) RowNumber
	,OldGroupId,NewGroupId,NewStatusOfIncidentId,CreatedOn
	,cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int) AS NotChangingTime
	,ServiceRequestId
	FROM (
	SELECT CounterInIncident --cii1
	WHERE
		--ServiceRequestId IN ( SELECT id FROM @SR )
	    ServiceRequestId = '87B3A9FD-9D85-452B-AA04-11E7DC7EFADC'
		AND NotChangingTime != ''
		/* В полях Общее время обработки (мин.), Максимальное время обработки группой (мин.), Минимальное время обработки группой (мин.), Время обработки группой (мин.) 
	    не должны участвовать значения, у которых "Новое значение статуса" во вкладке счетчики равно “Внешний запрос”, “Внутренний запрос” или “Возвращена на доработку */
		AND NewStatusOfIncidentId NOT IN (
			 'F0B04982-4C74-4FD4-ACD8-05FE186C36FF' /*Внешний запрос*/
			,'6B0131D0-CF34-4ECA-BDBB-00DA49445B77' /*Внутренний запрос*/
			,'D103AB39-7628-4447-8FE8-02C9F1490DD6' /*Возвращена на доработку*/
			)
) cii1
left join (
	SELECT 1+row_number() OVER(ORDER BY ServiceRequestId, CreatedOn) RowNumber
		,OldGroupId,NewGroupId
		,cast(SUBSTRING(NotChangingTime, 1, charindex('д.', NotChangingTime)-1) * 24 * 60 + SUBSTRING(NotChangingTime , charindex('д.', NotChangingTime) + 3 , (charindex('ч.', NotChangingTime) - 1) - (charindex('д.', NotChangingTime) + 3)) * 60 + SUBSTRING(NotChangingTime , charindex('ч.', NotChangingTime) + 3 , (charindex('мин.', NotChangingTime) - 1) - (charindex('ч.', NotChangingTime) + 3))as int) AS NotChangingTime
	FROM CounterInIncident
	WHERE
		--ServiceRequestId IN ( SELECT id FROM @SR )
	    ServiceRequestId = '21B4DAB5-5E14-424A-B012-75B7034BF64E'
		AND NotChangingTime != ''
		/* В полях Общее время обработки (мин.), Максимальное время обработки группой (мин.), Минимальное время обработки группой (мин.), Время обработки группой (мин.) 
	    не должны участвовать значения, у которых "Новое значение статуса" во вкладке счетчики равно “Внешний запрос”, “Внутренний запрос” или “Возвращена на доработку */
		AND NewStatusOfIncidentId NOT IN (
			 'F0B04982-4C74-4FD4-ACD8-05FE186C36FF' /*Внешний запрос*/
			,'6B0131D0-CF34-4ECA-BDBB-00DA49445B77' /*Внутренний запрос*/
			,'D103AB39-7628-4447-8FE8-02C9F1490DD6' /*Возвращена на доработку*/
			)
) cii2 ON cii1.RowNumber = cii2.RowNumber
--v0.0
--ОПИСАНИЕ: Подключение к серверу: t2ru-bpmanl-01
--СТАТУС: Должен работать 
--РЕАЛИЗАЦИЯ: 
--ПРОБЛЕМЫ: 

USE ANALYTICSS;

SELECT
 TT 'номер TT'
,Service 'Сервис'
,KOP 'Краткое описание'
,Priority 'Приоритет'
,SLA_Time_minutes 'Время нахождения заявки на  линии ЦК ПиР на основании приоритета'
,First_Assign 'Дата и время первого назначения заявки на группу ЦК ПиР'
,Last_reAssign 'Дата и время последнего изменения заявки группой ЦК ПиР на любую другую'
,Fact_work_time_minutes 'Фактическое время нахождение на линии ЦК ПиР'
,SLA_delta_minutes 'SLA'

FROM BPM5_SLA_TFS360841_4PiR

where Close_Date between (@start) and dateadd(day,1,(@end)


ORDER BY TT




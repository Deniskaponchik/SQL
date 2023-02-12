--v0.0
--ОПИСАНИЕ: Создание таблицы в БД Analyticss для Закрытые ЦК ПиР за вчера
--СТАТУС: Должно работать
--РЕАЛИЗАЦИЯ: 
--ПРОБЛЕМЫ: Нужно ли и какой указать Primary Key? На RS будет поиск по Дате закрытия заявки.

USE ANALYTICSS;

CREATE TABLE BPM5_SLA_TFS360841_4PiR (
	 TT nvarchar(250)
	,Close_Date datetime2(3)
	,Service nvarchar(250)
	,KOP nvarchar(250)
	,Priority nvarchar(250)
	,SLA_Time_minutes int
	,First_Assign datetime2(3)
	,Last_reAssign datetime2(3)
	,Fact_work_time_minutes int
	,SLA_delta_minutes int
	--PRIMARY KEY (TT) ???
	);



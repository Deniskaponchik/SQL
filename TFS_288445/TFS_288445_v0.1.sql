
UPDATE ServiceRequest
SET DeferredTo = NULL
/*USE BPMonline_80; SELECT * FROM ServiceRequest*/
WHERE
	    ServiceId = 'C6ED3C46-525F-43DB-BB6B-E5CF832F4B34'          /* Сервис = Претензии к дилеру */
	AND StatusOfIncidentId = 'F49E3FD2-F36B-1410-119B-0050BA5D6C38' /* Состояние = Решена */
	AND DeferredTo IS NOT NULL                                      /* Отложен до НЕ ПУСТОЕ */
  /*and RegisteredOn >= dateadd(day,-1,getdate())*/


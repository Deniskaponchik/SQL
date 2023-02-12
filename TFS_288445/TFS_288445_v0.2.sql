
UPDATE ServiceRequest
SET DeferredTo = NULL
WHERE
ServiceId IN (
	  '524A3A8E-FB29-E411-80BC-00155DFC1F77'  -- Администрирование b2c
	, '796FA067-376B-40CB-A2E5-EBFC607AF55B'  -- Документация B2C
)
AND StatusOfIncidentId = 'F49E3FD2-F36B-1410-119B-0050BA5D6C38' /* Состояние = Решена */
AND DeferredTo IS NOT NULL                                      /* Отложен до НЕ ПУСТОЕ */




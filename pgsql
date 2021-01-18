Saps3评分
SELECT
	saps3wbcscore.patientunitstayid,
	(
		saps3agescore.agescore + saps3beforicuscore.beforicuscore + saps3bilirubinscore.saps3bilirubinscore + saps3complicationscore.saps3complicationscore + saps3crscore.saps3crscore + saps3gcsscore.saps3gcsscore + saps3heartratecore.saps3heartratecore + saps3icusourcescore.icusourcescore + saps3infectsocre.saps3infectsocre + saps3pao2fio2score.saps3pao2fio2score + saps3phscore.saps3phcore + saps3pltscore.saps3pltcore + saps3sbpscore.saps3sbpscore + saps3srugeryscore.srugeryscore + saps3tempscore.saps3tempscore + saps3vasopressinscore.vasopressinscore + saps3wbcscore.saps3wbcscore+16 
	) AS saps3score 
FROM
	saps3agescore,
	saps3beforicuscore,
	saps3bilirubinscore,
	saps3complicationscore,
	saps3crscore,
	saps3gcsscore,
	saps3heartratecore,
	saps3icusourcescore,
	saps3infectsocre,
	saps3pao2fio2score,
	saps3phscore,
	saps3pltscore,
	saps3sbpscore,
	saps3srugeryscore,
	saps3tempscore,
	saps3vasopressinscore,
	saps3wbcscore
WHERE
	saps3agescore.patientunitstayid = saps3beforicuscore.patientunitstayid 
	AND saps3agescore.patientunitstayid = saps3bilirubinscore.patientunitstayid 
	AND saps3complicationscore.patientunitstayid = saps3agescore.patientunitstayid
	AND saps3crscore.patientunitstayid=saps3agescore.patientunitstayid
	AND saps3gcsscore.patientunitstayid =saps3agescore.patientunitstayid
	AND saps3heartratecore.patientunitstayid =saps3agescore.patientunitstayid
	AND saps3icusourcescore.patientunitstayid =saps3agescore.patientunitstayid
	AND saps3infectsocre.patientunitstayid = saps3agescore.patientunitstayid
	AND saps3pao2fio2score.patientunitstayid = saps3agescore.patientunitstayid
	AND saps3phscore.patientunitstayid = saps3agescore.patientunitstayid
	AND saps3pltscore.patientunitstayid = saps3agescore.patientunitstayid
	AND saps3sbpscore.patientunitstayid = saps3agescore.patientunitstayid
	AND saps3srugeryscore.patientunitstayid = saps3agescore.patientunitstayid
	AND saps3tempscore.patientunitstayid = saps3agescore.patientunitstayid
	AND saps3vasopressinscore.patientunitstayid = saps3agescore.patientunitstayid
	AND saps3wbcscore.patientunitstayid=saps3agescore.patientunitstayid



诊断代码：
SELECT DISTINCT
	diagnosis.patientunitstayid,
	split_part( diagnosis.diagnosisstring, '|', 3 ) 
FROM
	diagnosis,
	ressaps3 
WHERE
	diagnosis.diagnosispriority IN ( 'Primary' ) 
	AND diagnosis.patientunitstayid = ressaps3.patientunitstayid 
	AND diagnosis.diagnosisstring LIKE'pulmonary|%' 
ORDER BY
	diagnosis.patientunitstayid


获取评分代码
SELECT *,CASE
WHEN apachepatientresult.actualiculos<7 and apachepatientresult.actualicumortality like 'EXPIRED' then 'EXPIRED'
ELSE 'ALLIVE' end as icumortalityday7,
CASE
WHEN apachepatientresult.actualiculos<14 and apachepatientresult.actualicumortality like 'EXPIRED' then 'EXPIRED'
ELSE 'ALLIVE' end as icumortalityday14,
CASE
WHEN apachepatientresult.actualiculos<28 and apachepatientresult.actualicumortality like 'EXPIRED' then 'EXPIRED'
ELSE 'ALLIVE' end as icumortalityday28,
CASE
WHEN apachepatientresult.actualhospitallos<7 and apachepatientresult.actualhospitalmortality like 'EXPIRED' then 'EXPIRED'
ELSE 'ALLIVE' end as hospmortalityday7,
CASE
WHEN apachepatientresult.actualhospitallos<14 and apachepatientresult.actualhospitalmortality like 'EXPIRED' then 'EXPIRED'
ELSE 'ALLIVE' end as hospmortalityday14,
CASE
WHEN apachepatientresult.actualhospitallos<28 and apachepatientresult.actualhospitalmortality like 'EXPIRED' then 'EXPIRED'
ELSE 'ALLIVE' end as hospmortalityday28,exp(-32.6659+ln(saps3.saps3score+20.5958)*7.3068)/(1+exp(-32.6659+ln(saps3.saps3score+20.5958)*7.3068)) as predictexpried
FROM apache2,apache4,saps3,resid as idd,apachepredvar,apachepatientresult
WHERE idd.patientunitstayid=apache2.patientunitstayid and idd.patientunitstayid=apache4.patientunitstayid and idd.patientunitstayid=saps3.patientunitstayid and idd.patientunitstayid= apachepredvar.patientunitstayid and apachepredvar.electivesurgery is null and saps3.saps3score is not null and apachepatientresult.patientunitstayid=idd.patientunitstayid and apachepatientresult.apacheversion like 'IV' and apache4.actualicumortality ilike 'alive'
ORDER BY idd.patientunitstayid


亚组分析代码
WITH idd AS (
	SELECT DISTINCT
		resdatascore.* 
	FROM
		diagnosis,
		resdatascore 
	WHERE
		diagnosis.diagnosispriority IN ( 'Primary' ) 
		AND diagnosis.patientunitstayid = resdatascore.patientunitstayid 
		AND split_part( diagnosis.diagnosisstring, '|', 3 ) ILIKE'pneumonia' 
	),
	iddd AS (
	SELECT
		idd.patientunitstayid,
		MIN ( ph ) AS ph,
		MIN ( pao2 / fio2 ) AS po2fio2,
		MAX ( paco2 ) AS paco2 
	FROM
		idd
		LEFT JOIN pivoted_bg ON pivoted_bg.patientunitstayid = idd.patientunitstayid 
	GROUP BY
		idd.patientunitstayid 
	ORDER BY
		idd.patientunitstayid 
	) 
	SELECT
	resdatascore.* ,iddd.ph,iddd.po2fio2,iddd.paco2
FROM
	iddd,
	resdatascore 
WHERE
	iddd.patientunitstayid = resdatascore.patientunitstayid 
ORDER BY
	iddd.patientunitstayid

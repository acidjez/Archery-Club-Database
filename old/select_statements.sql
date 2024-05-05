--find definition of rounds--
    --what are the ranges that are shot in this round? --
SELECT Round_.round_name, Range_.num_ends, Range_.distance, Range_.face_size
FROM RoundRange
JOIN Range_ ON RoundRange.range_id = Range_.range_id
JOIN Round_ ON RoundRange.round_id = Round_.round_id
WHERE Round_.round_name = 'Townsville';


-- find equivalent round of a base round for a chosen category --
    -- What is WA70/1440s equivalent round for X category (equipment + division)?  --
SELECT RBR.round_name AS "Base Round", RER.round_name AS "Equivalent Round", er.division_name, er.bow_type
FROM EquivalentRound er
JOIN Round_ RBR ON er.base_round_id = RBR.round_id
JOIN Round_ RER ON er.equiv_round_id = RER.round_id
WHERE RBR.round_name = 'WA90/1440' AND er.division_name = '50+ Male' AND er.bow_type = 'Recurve';


    -- What is Wa90/1440s equivalent rounds for X equipment? --
SELECT RBR.round_name AS "Base Round", RER.round_name AS "Equivalent Round", er.division_name, er.bow_type
FROM EquivalentRound er
JOIN Round_ RBR ON er.base_round_id = RBR.round_id
JOIN Round_ RER ON er.equiv_round_id = RER.round_id
WHERE RBR.round_name = 'WA90/1440' AND er.bow_type = 'Recurve';


-- find an archers score for a given event --
SELECT A.first_name, A.last_name, E.event_date, R.round_name, SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS total_score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
JOIN Round_ R ON E.round_id = R.round_id
WHERE AE.event_id = 1 AND AE.archer_id = 153 
GROUP BY A.first_name, A.last_name, E.event_date, R.round_name;


-- find all round scores shot by an archer, sort by date and/or score
    -- filter by date
SELECT E.event_id, E.event_name, R.round_name AS 'Base Round Name', E.event_date, SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS total_score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN Round_ R ON E.round_id = R.round_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
WHERE A.archer_id = 153 AND E.event_date BETWEEN '2005-5-11' AND '2023-5-13'
GROUP BY E.event_id, E.event_name, E.event_date
ORDER BY total_score DESC;


    -- filter by range
SELECT E.event_id, E.event_name, R.round_name AS 'Base Round Name', E.event_date, SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS total_score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN Round_ R ON E.round_id = R.round_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
JOIN RoundRange RR ON R.round_id = RR.round_id
WHERE A.archer_id = 111 AND RR.range_id = 1
GROUP BY E.event_id, E.event_name, R.round_name, E.event_date
ORDER By total_score;


    -- filter by round
SELECT E.event_name, R.round_name AS 'Base Round', RER.round_name AS 'Equiv Round', E.event_date, SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS total_score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN Round_ R ON E.round_id = R.round_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
JOIN EquivalentRound ER ON ER.equiv_round_pk = AE.equiv_round_pk
JOIN Round_ RER ON ER.equiv_round_id = RER.round_id
WHERE A.archer_id = 111 AND RER.round_name = 'Townsville'
GROUP BY E.event_id, E.event_name;
    

-- find archers PB score from all their scores
SELECT MAX(total_score) AS highest_score
FROM (
SELECT SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS total_score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
WHERE A.archer_id = 111
GROUP BY E.event_id
) AS scores;


-- find archers PB end from all their ends
SELECT CASE 
        WHEN En.arrow1 > 10 THEN 'X'
        ELSE En.arrow1
    END AS arrow1,
    CASE 
        WHEN En.arrow2 > 10 THEN 'X'
        ELSE En.arrow2
    END AS arrow2,
    CASE 
        WHEN En.arrow3 > 10 THEN 'X'
        ELSE En.arrow3
    END AS arrow3,
    CASE 
        WHEN En.arrow4 > 10 THEN 'X'
        ELSE En.arrow4
    END AS arrow4,
    CASE 
        WHEN En.arrow5 > 10 THEN 'X'
        ELSE En.arrow5
    END AS arrow5,
    CASE 
        WHEN En.arrow6 > 10 THEN 'X'
        ELSE En.arrow6
    END AS arrow6
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
WHERE A.archer_id = 112
ORDER BY 
	(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10))
	DESC
LIMIT 1;


-- find archers PB score for a given round
SELECT MAX(total_score) AS highest_score
FROM (
    SELECT SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS total_score
    FROM Archer A
    JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
    JOIN Event_ E ON AE.event_id = E.event_id
    JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
    JOIN End_ En ON S.score_id = En.score_id
    JOIN EquivalentRound ER ON ER.equiv_round_pk = AE.equiv_round_pk
    JOIN Round_ R ON ER.equiv_round_id = R.round_id
    WHERE A.archer_id = 112 AND R.round_id = 19
    GROUP BY E.event_id, E.event_name
) AS scores;


-- find the clubs best score
    -- include data like date, what event, who shot it
SELECT A.first_name, A.last_name, E.event_name, E.event_date, MAX(event_score.total_score) AS highest_score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN (
    SELECT S.event_id, S.archer_id, SUM(En.arrow1 + En.arrow2 + En.arrow3 + En.arrow4 + En.arrow5 + En.arrow6) AS total_score
    FROM Score S
    JOIN End_ En ON S.score_id = En.score_id
    GROUP BY S.event_id, S.archer_id
) AS event_score ON AE.event_id = event_score.event_id AND AE.archer_id = event_score.archer_id
GROUP BY A.first_name, A.last_name, E.event_name, E.event_date
ORDER BY highest_score DESC
LIMIT 1;

    
-- find the clubs best score for a particular round
SELECT A.first_name, A.last_name, E.event_name, E.event_date, MAX(event_score.total_score) AS highest_score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN (
    SELECT S.event_id, S.archer_id, SUM(En.arrow1 + En.arrow2 + En.arrow3 + En.arrow4 + En.arrow5 + En.arrow6) AS total_score
    FROM Score S
    JOIN End_ En ON S.score_id = En.score_id
    GROUP BY S.event_id, S.archer_id
) AS event_score ON AE.event_id = event_score.event_id AND AE.archer_id = event_score.archer_id
JOIN Round_ R ON E.round_id = R.round_id
JOIN EquivalentRound ER ON ER.equiv_round_pk = AE.equiv_round_pk
JOIN Round_ RER ON ER.equiv_round_id = RER.round_id
WHERE RER.round_name = 'Melbourne'
GROUP BY A.first_name, A.last_name, E.event_name, E.event_date
ORDER BY highest_score DESC
LIMIT 1;

-- find competition results --
    -- find all archers who competed in a given  competition --

    -- find all scores shot, and who shot them --
SELECT A.archer_id, A.first_name, A.last_name, SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS Total_Score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
WHERE AE.event_id = 1
GROUP BY A.archer_id, A.first_name, A.last_name
ORDER BY Total_Score DESC;


    -- find best score
SELECT A.archer_id, A.first_name, A.last_name, SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS Total_Score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
WHERE AE.event_id = 1
GROUP BY A.archer_id, A.first_name, A.last_name
ORDER BY Total_Score DESC
LIMIT 1;


    -- find best end
SELECT A.first_name, A.last_name, MAX(En.arrow1 + En.arrow2 + En.arrow3 + En.arrow4 + En.arrow5 + En.arrow6) AS highest_score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
WHERE E.event_id = 1
GROUP BY A.first_name, A.last_name
ORDER BY highest_score DESC
LIMIT 1;


    -- find winner(s) of X category(s)
SELECT A.archer_id, A.first_name, A.last_name, ER.division_name, SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS Total_Score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN EquivalentRound ER ON ER.equiv_round_pk = AE.equiv_round_pk
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
WHERE AE.event_id = 6 AND ER.division_name = 'Female Open' AND ER.bow_type = 'Recurve' 
GROUP BY A.archer_id, A.first_name, A.last_name
ORDER BY Total_Score DESC
Limit 1;


-- find club championship results
    -- find participating competitions
SELECT E.event_name, R.round_name, E.event_date, E.event_location
FROM Event_ E
JOIN Round_ R ON E.round_id = R.round_id
WHERE E.champ_id IS NOT NULL
ORDER BY event_date DESC;


    -- find participating archers
SELECT A.archer_id, A.first_name, A.last_name, SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS Total_Score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN EquivalentRound ER ON ER.equiv_round_pk = AE.equiv_round_pk
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
WHERE E.champ_id = 1
GROUP BY A.archer_id, A.first_name, A.last_name
ORDER BY Total_Score DESC;

    -- find winner(s) of competitions in X category(s)
SELECT A.archer_id, A.first_name, A.last_name, ER.division_name, ER.bow_type, SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS Total_Score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN EquivalentRound ER ON ER.equiv_round_pk = AE.equiv_round_pk
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
WHERE E.champ_id = 1 AND ER.division_name = 'Female Open' AND ER.bow_type = 'Compound'
GROUP BY A.archer_id, A.first_name, A.last_name
ORDER BY Total_Score DESC;
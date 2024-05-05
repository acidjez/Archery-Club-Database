-- For a lot of the lookup use-cases, the WHERE clauses will either use IDs or names to 
-- refer to desired values to look up.
-- In practice, WHERE clauses in lookup use-cases should always look for IDs, 
-- but for the purpose of this demonstration file some will be 
-- looking for names instead, for readability.

-- **********************************************
-- **           Archer's Use Cases             **
-- **********************************************

-- *********** General Archer Lookup ***********

-- Look up an archer's scores, restricted by a date range and the type of round.
--  - 1. Return the total scores of each round they've shot
SELECT E.event_id, E.event_name, R.round_name AS 'Base Round Name', E.event_date, SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS total_score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN Round_ R ON E.round_id = R.round_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
WHERE A.archer_id = 108 AND E.event_date BETWEEN '2005-5-11' AND '2023-5-13'
GROUP BY E.event_id, E.event_name, E.event_date;

--  - 2. Return the total scores of each range they've shot
SELECT E.event_id, E.event_name, E.event_date, R.round_name, S.range_num, 
    SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS range_total
FROM End_ En 
JOIN Score S ON En.score_id = S.score_id 
JOIN ArcherEvent AE ON S.event_id = AE.event_id AND S.archer_id = AE.archer_id
JOIN Archer A ON AE.archer_id = A.archer_id
JOIN EquivalentRound ER ON AE.equiv_round_pk = ER.equiv_round_pk 
JOIN Round_ R ON ER.equiv_round_id = R.round_id 
JOIN Event_ E ON E.event_id = AE.event_id
WHERE A.archer_id = 108 AND E.event_date BETWEEN '2005-5-11' AND '2023-5-13'
GROUP BY S.score_id;

-- Look up definitions of rounds, i.e. what ranges make up the round.
SELECT Round_.round_name, RoundRange.range_num, Range_.distance, Range_.face_size, Range_.num_ends
FROM RoundRange
JOIN Range_ ON RoundRange.range_id = Range_.range_id
JOIN Round_ ON RoundRange.round_id = Round_.round_id
WHERE Round_.round_name = 'Townsville';

-- Look up equivalent rounds, i.e. if I shoot in an event of round X, in Y division with Z bow, what is the equivalent round that I will be shooting? 
SELECT rr_base.round_name AS "Base Round", rr_equiv.round_name AS "Equivalent Round", er.division_name, er.bow_type
FROM EquivalentRound er
JOIN Round_ rr_base ON er.base_round_id = rr_base.round_id
JOIN Round_ rr_equiv ON er.equiv_round_id = rr_equiv.round_id
WHERE rr_base.round_name = 'WA90/1440' AND er.division_name = '50+ Male' AND er.bow_type = 'Recurve';

-- Look up an archer's best score of any round
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

-- Look up an archer's best end score
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
    END AS arrow6,
	(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS total_score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
WHERE A.archer_id = 113
ORDER BY total_score DESC
LIMIT 1;

-- Look up an archer's best round score for a particular round.
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
    WHERE A.archer_id = 112 AND R.round_name = 'Townsville'
    GROUP BY E.event_id, E.event_name
) AS scores;

-- *********** Competition Lookup ***********

-- Look up competition results and see all the score totals for each archer in the competition, i.e the total of each archer's En.arrows in the round
SELECT R2.round_name AS base_round, A.archer_id, A.first_name, A.last_name, AE.division_name, AE.bow_type, R.round_name, 
    SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS Total_Score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
JOIN EquivalentRound ER ON AE.equiv_round_pk = ER.equiv_round_pk 
JOIN Round_ R ON ER.equiv_round_id = R.round_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN Round_ R2 ON E.round_id = R2.round_id
WHERE AE.event_id = 1
GROUP BY A.archer_id, A.first_name, A.last_name
ORDER BY Total_Score DESC;

-- Find the best score in a competition in a particular category
SELECT A.archer_id, A.first_name, A.last_name, AE.division_name, AE.bow_type, SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS Total_Score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
WHERE AE.event_id = 6 AND AE.division_name = 'Female Open' AND AE.bow_type = 'Recurve' 
GROUP BY A.archer_id, A.first_name, A.last_name
ORDER BY Total_Score DESC
Limit 1;

-- Look up the best end shot in a competition, and who shot it
SELECT A.first_name, A.last_name, 
	CASE 
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
    END AS arrow6,
    (LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS total_score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
WHERE E.event_id = 1
ORDER BY total_score DESC
LIMIT 1;

-- *********** Club Lookup ***********

-- Find all participating competitions in a particular championship
SELECT E.event_name, R.round_name, E.event_date, E.event_location
FROM Event_ E
JOIN Round_ R ON E.round_id = R.round_id
WHERE E.champ_id IS NOT NULL
ORDER BY event_date DESC;

-- Look up club championship results, i.e the total of the round scores of every archer in every competition in a given championship.
SELECT A.archer_id, A.first_name, A.last_name, 
    SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS Total_Score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
JOIN EquivalentRound ER ON AE.equiv_round_pk = ER.equiv_round_pk 
JOIN Round_ R ON ER.equiv_round_id = R.round_id
JOIN Event_ E ON AE.event_id = E.event_id 
JOIN Championship C ON E.champ_id = C.champ_id
WHERE C.champ_id = 1
GROUP BY A.archer_id, A.first_name, A.last_name
ORDER BY Total_Score DESC;

-- find the highest scoring archers in a championship in X category(s)
SELECT A.archer_id, A.first_name, A.last_name, AE.division_name, AE.bow_type, SUM(LEAST(En.arrow1, 10) + LEAST(En.arrow2, 10) + LEAST(En.arrow3, 10) + LEAST(En.arrow4, 10) + LEAST(En.arrow5, 10) + LEAST(En.arrow6, 10)) AS Total_Score
FROM Archer A
JOIN ArcherEvent AE ON A.archer_id = AE.archer_id
JOIN Event_ E ON AE.event_id = E.event_id
JOIN Score S ON AE.event_id = S.event_id AND AE.archer_id = S.archer_id
JOIN End_ En ON S.score_id = En.score_id
WHERE E.champ_id = 1 AND AE.division_name = 'Female Open' AND AE.bow_type = 'Compound'
GROUP BY A.archer_id, A.first_name, A.last_name
ORDER BY Total_Score DESC;

-- Look up the club's best score of any round
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

-- Look up the club's best score for a particular round.
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

-- *********** Archer Inserts ************

-- ---- Let an archer enter into an uncompleted event ----

-- - The archer identifies themselves in the interface.
-- - (NOTE: We can assume that there would be a good method of uniquely idetifying archers such as 
--    emails and passwords, but for now we'll say that the archer knows their id.)
SET @i_archer_id = 2; -- simulating user selecting themselves

SET @archer_id = @i_archer_id;

-- return a list of available events to the user, that they haven't already entered
SELECT Ev.event_id, Ev.event_name, Ev.event_date, Ro.round_id, Ro.round_name FROM Event_ AS Ev 
    JOIN Round_ AS Ro ON Ev.round_id = Ro.round_id 
    JOIN ArcherEvent AS AE ON Ev.event_id = AE.event_id 
    WHERE ev.is_completed = false AND AE.archer_id != @archer_id;

-- simulate user selecting an event 
SELECT event_id FROM Event_ WHERE is_completed = false ORDER BY event_id DESC LIMIT 1 INTO @i_event_id;

SET @event_id = @i_event_id;

-- Return a list of divisions the archer can participate in...
CALL GetArcherDivisions(@archer_id, (SELECT event_date FROM Event_ WHERE event_id = @event_id));

-- and a list of equipment the archer can use (should be all bows)
SELECT * FROM Equipment;

-- simulate archer selects their desired division and equipment
SET @arch_bow = 'Recurve';
SET @arch_div = 'Male Open';

-- Create the archer's event entry based on their choices
CALL InsertArcherEntry(@archer_id, @event_id, @arch_div, @arch_bow);

-- Return data for a confirmation message to the archer, showing them the details of their entry
SELECT Ev.event_name, B_Ro.round_name, AE.bow_type, AE.division_name, E_Ro.round_name
    FROM ArcherEvent AE
    JOIN Event_ Ev ON AE.event_id = Ev.event_id
    JOIN Round_ B_Ro ON Ev.round_id = B_Ro.round_id
    JOIN EquivalentRound ER ON AE.equiv_round_pk = ER.equiv_round_pk
    JOIN Round_ E_Ro ON ER.equiv_round_id = E_Ro.round_id
    WHERE AE.archer_id = @archer_id AND AE.event_id = @event_id;

-- ---- Enter an archer's new scores into a staging table for a round they are shooting at the club. ----

-- - The archer identifies themselves in the interface.
-- - (NOTE: We can assume that there would be a good method of uniquely idetifying archers such as 
--    accounts using emails and passwords, but for now we'll say that the archer knows their id.)
SET @i_archer_id = 2; -- simulating user selecting themselves

SET @archer_id = @i_archer_id; -- Store archer's id in a session variable
-- Return any incomplete events the archer is signed up for back to the interface.
-- The archer is shown event_name(s) but the interface uses event_id and archer_id as the value to send back to the database.
SELECT ev.event_name, ev.event_id, ae.archer_id FROM Event_ AS ev 
    JOIN ArcherEvent AS ae ON ev.event_id = ae.event_id 
    JOIN Archer AS ar ON ae.archer_id = ar.archer_id 
    WHERE ar.archer_id = @archer_id
		AND ev.is_completed = false;

-- Archer selects the event they are participating in.
-- For this demonstration, we'll just simulate selecting the first event listed in the above select statement
SELECT ev.event_id FROM Event_ AS ev 
    JOIN ArcherEvent AS ae ON ev.event_id = ae.event_id 
    JOIN Archer AS ar ON ae.archer_id = ar.archer_id 
    WHERE ar.archer_id = @archer_id
		AND ev.is_completed = false 
    LIMIT 1 
    INTO @i_event_id;

SET @event_id = @i_event_id; -- Store event id in a session variable

-- Create a temporary table for the session, to get a bunch of info from
DROP TEMPORARY TABLE IF EXISTS ArcherScoresInfo_temp;
CREATE TEMPORARY TABLE ArcherScoresInfo_temp 
SELECT DISTINCT ro.round_name, sc.score_id, sc.range_num, ra.num_ends, ra.distance, ra.face_size
    FROM Score AS sc 
    JOIN ArcherEvent AS ae ON (sc.archer_id = ae.archer_id AND sc.event_id = ae.event_id) 
    JOIN EquivalentRound AS er ON ae.equiv_round_pk = er.equiv_round_pk 
    JOIN Round_ AS ro ON er.equiv_round_id = ro.round_id 
    JOIN RoundRange AS rr ON ro.round_id = rr.round_id 
    JOIN Range_ AS ra ON rr.range_id = ra.range_id 
    WHERE ae.event_id = @eventID
        AND ae.archer_id = @archerID
        AND sc.range_num = rr.range_num;


-- Called by archer's interface after they select their event entry
-- This sends all the info about the archer's round to the archer,
-- and is used specifically for this use case. It requires the ArcherScoresInfo_temp table.
CALL GetArcherEventInfo();

-- Now the archer can select ends, fill them with values in the interface and run the following:
SET @i_range_num = 2; -- simulate an archer choosing the range 
SET @i_end_num = 3;  -- and the end they just shot
SELECT 2, 7, 11, 10, 8, 4 INTO -- and the points each arrow scored
	@arrow1,
	@arrow2,
	@arrow3,
	@arrow4,
	@arrow5,
	@arrow6;

-- ... and submit them
INSERT INTO StagedEnd (end_num, score_id, arrow1, arrow2, arrow3, arrow4, arrow5, arrow6) 
  VALUES (@i_end_num, @i_range_num, @arrow1, @arrow2, @arrow3, @arrow4, @arrow5, @arrow6);

-- Then the archer gets their round info again, now updated with their just-entered range
-- and the process can repeat, the archer selecting another end to record.
CALL GetArcherEventInfo();
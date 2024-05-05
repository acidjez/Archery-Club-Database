-- *****************************************************************
-- ** Procedures and Functions that can be used by our use cases! **
-- *****************************************************************

-- Create an Archer's entry into an event, 
-- inserting their ArcherEvent entry and a Score entry for each range they will shoot.
-- This function finds the equivalent round the archer is going to shoot,
-- based on their chosen equipment, division, and the event's base round.
DROP PROCEDURE IF EXISTS InsertArcherEntry;
DELIMITER //
CREATE PROCEDURE InsertArcherEntry(IN p_archerID INT, IN p_eventID INT, IN p_division VARCHAR(20), IN p_equipment VARCHAR(20)) 
MODIFIES SQL DATA 
BEGIN

    DECLARE i INT DEFAULT 1;
    DECLARE V_roundID INT;
	DECLARE num_ranges INT DEFAULT 0;
    DECLARE v_equivPK INT DEFAULT NULL;
	
    SELECT Er.equiv_round_pk
	FROM EquivalentRound AS Er 
    JOIN Event_  AS Ev ON Er.base_round_id = Ev.round_id 
    WHERE Ev.event_id = p_eventID AND Er.bow_type = p_equipment AND Er.division_name = p_division
    INTO v_equivPK;
        
	IF (v_equivPK IS NULL) THEN
		SELECT Er.equiv_round_pk
		FROM EquivalentRound AS Er 
		JOIN Event_  AS Ev ON Er.base_round_id = Ev.round_id 
		WHERE Ev.event_id = p_eventID AND Er.bow_type IS NULL AND Er.division_name IS NULL
		INTO v_equivPK;
	END IF;

    -- Get the round id for this archer
    SELECT equiv_round_id FROM EquivalentRound WHERE equiv_round_pk = v_equivPK INTO v_roundID;
     -- Get the number of ranges of the round that the Archer will be shooting
	SELECT MAX(rr.range_num) FROM RoundRange AS rr 
        WHERE rr.round_id = v_roundID
        INTO num_ranges;

    START TRANSACTION;
    -- Insert the ArcherEvent
    INSERT INTO ArcherEvent (event_id, archer_id, equiv_round_pk, division_name, bow_type) VALUES (p_eventID, p_archerID, v_equivPK, p_division, p_equipment);

    -- Insert each score 
    WHILE i <= num_ranges do
        INSERT INTO Score (archer_id, event_id, range_num) VALUES (p_archerID, p_eventID, i);
        SET i = i + 1;
    END WHILE;
    COMMIT;
END //
DELIMITER ;

-- ********* GetArcherEventInfo() *********
-- This function should only be run for the archer_enter_ends use case, due to it's reliance on the temp table that use case creates.
-- It runs 3 select statments to be used as results:
--  1. The round name (the derived round that the archer is shooting)
--  2. A table of the archer's ranges in the event, consisting of:
--         score ID, 
--         range number in the round, 
--         number of ends in each range, 
--         distance of each range, 
--         face size of each range
--  3. A table for each range, describing each end within the range (end number and arrow scores)
DROP PROCEDURE IF EXISTS GetArcherEventInfo;
DELIMITER //
CREATE PROCEDURE GetArcherEventInfo()
READS SQL DATA 
proc_label:BEGIN

    DECLARE temp_exists VARCHAR(20);
    DECLARE v_range_counter INT DEFAULT 1;
    DECLARE v_num_ranges INT DEFAULT NULL;

    -- 1. return the round name for display
    SELECT DISTINCT round_name FROM ArcherScoresInfo_temp;

    -- 2. return a table of the archer's ranges to shoot
    SELECT score_id, range_num, num_ends, distance, face_size FROM ArcherScoresInfo_temp;

    -- 3. return a table of ends for each of the ranges 
    SELECT COUNT(score_id) FROM ArcherScoresInfo_temp INTO v_num_ranges;
    WHILE v_range_counter <= v_num_ranges do 
        SELECT end_num, arrow1, arrow2, arrow3, arrow4, arrow5, arrow6 FROM StagedEnd AS st
            JOIN ArcherScoresInfo_temp AS sc ON st.score_id = sc.score_id 
            WHERE sc.range_num = v_range_counter;
        SET v_range_counter = v_range_counter + 1;
    END WHILE;


END //
DELIMITER ;

-- ********* GetArcherDivisions() *********
-- Runs a select statement returning a table of each division_name an
-- archer can participate in, based on their age and gender.
DROP PROCEDURE IF EXISTS GetArcherDivisions;
DELIMITER //
CREATE PROCEDURE GetArcherDivisions(IN p_archerID INT, in p_eventDate DATE) 
READS SQL DATA
BEGIN

    DECLARE v_age INT;
    DECLARE v_gen ENUM('M', 'F');

    SELECT TIMESTAMPDIFF(YEAR, (SELECT dob FROM Archer WHERE archer_id = p_archerID), 
        p_eventDate) INTO v_age;

    SELECT gender FROM Archer WHERE archer_id = p_archerID INTO v_gen;

    SELECT division_name FROM Division 
        WHERE gender = v_gen AND age_min <= v_age AND age_max >= v_age;

END //
DELIMITER ;
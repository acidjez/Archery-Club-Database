
-- **********************************************
-- **           Recorder's Use Cases           **
-- **********************************************

-- ---- Enter new archers ----
INSERT INTO Archer (first_name, last_name, gender, dob, default_bow, phone) VALUES 
(
    'Agatha',
    'Archery',
    'F',
    '1990-10-24',
    'Compound',
    '0458649782'
);

-- ---- Enter new rounds ----

-- User is presented with a UI to choose a round name and define its ranges and equivalent rounds.
-- This requires sending:
-- 1. A table of each range, so they can select ranges for the new round.
-- 2. A table of all the current rounds and their ranges,
--    so they can be informed about equivalent rounds that they may want to use.
-- 3. A list of each division (for creating equivalent rounds)
-- 4. A list of each equipment (for creating equivalent rounds)
SELECT * FROM Range_;
SELECT Ro.round_id, Ro.round_name, RR.range_num, Ra.distance, Ra.face_size, Ra.num_ends
    FROM Round_ Ro
    JOIN RoundRange RR ON Ro.round_id = RR.round_id
    JOIN Range_ Ra ON RR.range_id = Ra.range_id;
SELECT bow_type FROM Equipment;
SELECT division_name FROM Division;

-- simulate user selecting their round name, ranges and equivalent rounds
SET @round_name = 'Mansfield';
SET @range_1 = 1;
SET @range_2 = 5;
SET @range_3 = 12;

SET @equiv_4_id = 7;            -- imagine they set a bunch more of these, this is all just  
SET @equiv_4_div = '50+ Male';  -- in UI and sent to SQL so we won't simulate
SET @equiv_4_bow = 'Recurve';   -- everything a user selects here
SET @equiv_4_date = '2023-05-30';

SET @equiv_5_id = 8;            
SET @equiv_5_div = '50+ Male';  
SET @equiv_5_bow = 'Recurve Barebow';   
SET @equiv_5_date = '2023-05-30';

INSERT INTO Round_ (round_name) VALUES (@round_name); -- chooses a round name
SELECT last_insert_id() INTO @round_id; -- get the round id of our new round

INSERT INTO RoundRange (round_id, range_num, range_id) VALUES 
(@round_id, 1, @range_1), -- This is generated in the front end app,
(@round_id, 2, @range_2), -- adding an entry for each range in the round
(@round_id, 3, @range_3);

INSERT INTO EquivalentRound (equiv_round_id, division_name, bow_type, base_round_id, effective_date) VALUES
(@round_id, NULL, NULL, @round_id, NULL); -- Enter the self-ref EquivalentRound entry

INSERT INTO EquivalentRound (equiv_round_id, division_name, bow_type, base_round_id, effective_date) VALUES
(@equiv_4_id, @equiv_4_div, @equiv_4_bow, @round_id, @equiv_4_date), -- this is generated in the front end app,
(@equiv_5_id, @equiv_5_div, @equiv_5_bow, @round_id, @equiv_5_date); -- adding an entry for each equivalent round

-- ---- Enter new competitions ----

-- The user presses a 'new event' button and the app grabs a list of rounds
SELECT round_id, round_name FROM Round_;

-- simlate the user inputting the event information:
SET @i_round_id = 5;
SET @i_champ_id = null;
SET @i_is_competition = false;
SET @i_is_completed = false;
SET @i_event_name = 'Arrows for Anmials Charity Event';
SET @i_event_date = '2023-05-30';
SET @i_event_location = 'Moorabin Archery Club';

-- insert the event
INSERT INTO Event_(round_id, champ_id, is_competition, is_completed, event_name, event_date, event_location) VALUES (
    @i_round_id, 
    @i_champ_id, 
    @i_is_competition, 
    @i_is_completed,
    @i_event_name, 
    @i_event_date, 
    @i_event_location
);

-- ---- 'Validate' new scores that archers have staged ----

-- return a list of current events to the user
SELECT Ev.event_id, Ev.event_name FROM Event_ AS Ev 
    WHERE ev.is_completed = false;

-- simulate user selecting an event 
SELECT event_id FROM Event_ WHERE is_completed = false ORDER BY event_id DESC LIMIT 1 INTO @i_event_id;
SET @event_id = @i_event_id;

-- Get all staged ends in the event
SELECT A.first_name, A.last_name, S.range_num, SE.end_num, SE.score_id, SE.is_validated, 
    CASE 
        WHEN SE.arrow1 > 10 THEN 'X'
        ELSE SE.arrow1
    END AS arrow1,
    CASE 
        WHEN SE.arrow2 > 10 THEN 'X'
        ELSE SE.arrow2
    END AS arrow2,
    CASE 
        WHEN SE.arrow3 > 10 THEN 'X'
        ELSE SE.arrow3
    END AS arrow3,
    CASE 
        WHEN SE.arrow4 > 10 THEN 'X'
        ELSE SE.arrow4
    END AS arrow4,
    CASE 
        WHEN SE.arrow5 > 10 THEN 'X'
        ELSE SE.arrow5
    END AS arrow5,
    CASE 
        WHEN SE.arrow6 > 10 THEN 'X'
        ELSE SE.arrow6
    END AS arrow6
    FROM StagedEnd SE
    JOIN Score S ON SE.score_id = S.score_id
    JOIN ArcherEvent AE ON S.event_id = AE.event_id AND S.archer_id = AE.archer_id
    JOIN Archer A ON AE.archer_id = A.archer_id
    WHERE S.event_id = @event_id;

-- Change is_validated to 'true' on a number of ends the user has selected
-- this would be looped in the app for each end, @i_score_id and @i_end_num would change with every loop.
SELECT SE.end_num, SE.score_id
    FROM StagedEnd SE
    JOIN Score S ON SE.score_id = S.score_id
    JOIN ArcherEvent AE ON S.event_id = AE.event_id AND S.archer_id = AE.archer_id
    WHERE S.event_id = @event_id
    LIMIT 1
    INTO @i_end_num, @i_score_id;

UPDATE StagedEnd 
    SET is_validated = true
    WHERE score_id = @i_score_id AND end_num = @i_end_num;

-- Then return the event's ends to the user again, now with updated is_validated values so they know what they've checked already
SELECT A.first_name, A.last_name, S.range_num, SE.end_num, SE.score_id, SE.is_validated, 
    CASE 
        WHEN SE.arrow1 > 10 THEN 'X'
        ELSE SE.arrow1
    END AS arrow1,
    CASE 
        WHEN SE.arrow2 > 10 THEN 'X'
        ELSE SE.arrow2
    END AS arrow2,
    CASE 
        WHEN SE.arrow3 > 10 THEN 'X'
        ELSE SE.arrow3
    END AS arrow3,
    CASE 
        WHEN SE.arrow4 > 10 THEN 'X'
        ELSE SE.arrow4
    END AS arrow4,
    CASE 
        WHEN SE.arrow5 > 10 THEN 'X'
        ELSE SE.arrow5
    END AS arrow5,
    CASE 
        WHEN SE.arrow6 > 10 THEN 'X'
        ELSE SE.arrow6
    END AS arrow6
    FROM StagedEnd SE
    JOIN Score S ON SE.score_id = S.score_id
    JOIN ArcherEvent AE ON S.event_id = AE.event_id AND S.archer_id = AE.archer_id
    JOIN Archer A ON AE.archer_id = A.archer_id
    WHERE S.event_id = @event_id;    

-- Now user can move all validated ends from the event to the End_ table, 'commiting' them. This would perhaps be best used after an event's ranges have all been shot.
START TRANSACTION;
    INSERT INTO End_ 
        SELECT SE.score_id, SE.end_num, SE.arrow1, SE.arrow2, SE.arrow3, SE.arrow4, SE.arrow6, SE.arrow6
        FROM StagedEnd SE
        JOIN Score S ON SE.score_id = S.score_id
        WHERE S.event_id = @event_id;

    DELETE FROM StagedEnd 
        USING StagedEnd JOIN End_ ON (StagedEnd.score_id = End_.score_id)
        WHERE StagedEnd.score_id <> 0 AND StagedEnd.end_num <> 0;
COMMIT;
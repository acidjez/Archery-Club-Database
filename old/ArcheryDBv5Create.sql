
DROP TABLE IF EXISTS Ends;
DROP TABLE IF EXISTS StagedEnds;
DROP TABLE IF EXISTS Scores;
DROP TABLE IF EXISTS RoundRanges;
DROP TABLE IF EXISTS Ranges;
DROP TABLE IF EXISTS ArchersEvents;
DROP TABLE IF EXISTS EquivalentRounds;
DROP TABLE IF EXISTS Archers;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Championships;
DROP TABLE IF EXISTS Rounds;
DROP TABLE IF EXISTS Equipment;
DROP TABLE IF EXISTS Divisions;

CREATE TABLE Equipment (
	bow_type VARCHAR(20) NOT NULL,
	PRIMARY KEY (bow_type)
);

CREATE TABLE Divisions (
	division_name VARCHAR(20) NOT NULL,
	gender ENUM('Male', 'Female') NOT NULL,
	age_min INT NOT NULL,
	age_max INT NOT NULL,
	PRIMARY KEY (division_name)
);

CREATE TABLE Rounds (
	round_id INT NOT NULL AUTO_INCREMENT,
	round_name VARCHAR(30) NOT NULL,
	PRIMARY KEY (round_id)
);

CREATE TABLE Archers (
	archer_id INT NOT NULL AUTO_INCREMENT,
	first_name VARCHAR(20) NOT NULL,
	last_name VARCHAR(20) NOT NULL,
	dob DATE NOT NULL,
	gender ENUM('M', 'F') NOT NULL,
	phone CHAR(10),
	PRIMARY KEY (archer_id)
);

CREATE TABLE Championships (
	champ_id INT NOT NULL AUTO_INCREMENT,
	champ_name VARCHAR(30) NOT NULL,
	date_begin DATE NOT NULL,
	date_end DATE NOT NULL,
	PRIMARY KEY (champ_id)
);

CREATE TABLE EquivalentRound (
	equivalent_round_id INT NOT NULL,
	division_name VARCHAR(20) NOT NULL,
	bow_type VARCHAR(20) NOT NULL,
	round_id INT NOT NULL,
	effective_date DATE NOT NULL,
	PRIMARY KEY (equivalent_round_id, division_name, bow_type),
	FOREIGN KEY (round_id) 
		REFERENCES Rounds (round_id) 
		ON DELETE CASCADE, -- These cascades could be good, or bad? idk
	FOREIGN KEY (equiv_round_id) 
		REFERENCES Rounds (round_id)
		ON DELETE CASCADE,
	FOREIGN KEY (division_name) 
		REFERENCES Divisions (division_name) 
		ON DELETE CASCADE,
	FOREIGN KEY (bow_type) 
		REFERENCES Equipment (bow_type) 
		ON DELETE CASCADE
);

CREATE TABLE Events (
	event_id INT NOT NULL AUTO_INCREMENT,
	round_id INT NOT NULL,
	championship_id INT,
	is_competition BOOL NOT NULL,
	is_completed BOOL NOT NULL,
	event_name VARCHAR(40) NOT NULL,
	event_date DATE NOT NULL,
	event_location VARCHAR(40) NOT NULL,
	PRIMARY KEY (event_id),
	FOREIGN KEY (round_id) REFERENCES Rounds (round_id),
	FOREIGN KEY (championship_id)REFERENCES Championships (championship_id)
);

CREATE TABLE ArchersEvents ( -- AKA Event Entries
	event_id INT NOT NULL,
	archer_id INT NOT NULL,
	PRIMARY KEY (event_id, archer_id),
	FOREIGN KEY (event_id) 
		REFERENCES Events (event_id)
		ON DELETE CASCADE,
	FOREIGN KEY (archer_id) 
		REFERENCES Archers (archer_id)
);

CREATE TABLE Ranges (
	range_id INT NOT NULL AUTO_INCREMENT,
	num_ends INT NOT NULL,
	distance INT NOT NULL,
	face_size ENUM('80cm', '144cm') NOT NULL,
	PRIMARY KEY (range_id)
);

CREATE TABLE RoundRanges (
	round_id INT NOT NULL,
	range_num INT NOT NULL,
	range_id INT NOT NULL,
	PRIMARY KEY (round_id, range_num),
	FOREIGN KEY (range_id) REFERENCES Ranges (range_id),
	FOREIGN KEY (round_id) REFERENCES Rounds (round_id)
);

CREATE TABLE Scores (
	score_id INT NOT NULL AUTO_INCREMENT,
	event_id INT NOT NULL,
	archer_id INT NOT NULL,
	range_id INT NOT NULL,
	range_num INT NOT NULL
	PRIMARY KEY (score_id),
	FOREIGN KEY (event_id, archer_id) 
		REFERENCES ArchersEvents (event_id, archer_id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE,
	FOREIGN KEY (range_id) REFERENCES Ranges (range_id)
);

-- Storing arrow scores:
-- Desired values can be 0-10 or X. 
-- An idea for this: 2 characters, which can be 00, 01 ... 09, 10, 1X
-- X only matters in ties, so a quick function could be:
-- for each arrow string if arrow[0] = '1' and arrow[1] = 'X' then increment Xs for that end. else, convert to int and add to score tally
-- I can't think of a way to implement 'X's into tallying scores that doesn't involve iteration (check each arrow, if it's an X add 10)
-- there's probably a more elegent way to do that hey
CREATE TABLE Ends (
	score_id INT NOT NULL,
	end_num INT NOT NULL,
	arrow1 CHAR(2) NOT NULL,
	arrow2 CHAR(2) NOT NULL,
	arrow3 CHAR(2) NOT NULL,
	arrow4 CHAR(2) NOT NULL,
	arrow5 CHAR(2) NOT NULL,
	arrow6 CHAR(2) NOT NULL,
	PRIMARY KEY (score_id, end_num),
	FOREIGN KEY (score_id) 
		REFERENCES Scores (score_id) 
		ON DELETE CASCADE
);

CREATE TABLE StagedEnds (
	score_id INT NOT NULL,
	end_num INT NOT NULL,
	arrow1 CHAR(2) NOT NULL,
	arrow2 CHAR(2) NOT NULL,
	arrow3 CHAR(2) NOT NULL,
	arrow4 CHAR(2) NOT NULL,
	arrow5 CHAR(2) NOT NULL,
	arrow6 CHAR(2) NOT NULL,
	PRIMARY KEY (score_id, end_num),
	FOREIGN KEY (score_id) 
		REFERENCES Scores (score_id) 
		ON DELETE CASCADE
);

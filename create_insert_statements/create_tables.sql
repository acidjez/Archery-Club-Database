DROP TABLE IF EXISTS End_;
DROP TABLE IF EXISTS StagedEnd;
DROP TABLE IF EXISTS Score;
DROP TABLE IF EXISTS RoundRange;
DROP TABLE IF EXISTS Range_;
DROP TABLE IF EXISTS ArcherEvent;
DROP TABLE IF EXISTS EquivalentRound;
DROP TABLE IF EXISTS Archer;
DROP TABLE IF EXISTS Event_;
DROP TABLE IF EXISTS Championship;
DROP TABLE IF EXISTS Round_;
DROP TABLE IF EXISTS Equipment;
DROP TABLE IF EXISTS Division;

CREATE TABLE Equipment (
	bow_type VARCHAR(20) NOT NULL,
	PRIMARY KEY (bow_type)
);

CREATE TABLE Division (
	division_name VARCHAR(20) NOT NULL,
	gender ENUM('M', 'F') NOT NULL,
	age_min INT NOT NULL,
	age_max INT NOT NULL,
	PRIMARY KEY (division_name)
);

CREATE TABLE Round_ (
	round_id INT NOT NULL AUTO_INCREMENT,
	round_name VARCHAR(30) NOT NULL,
	PRIMARY KEY (round_id)
);

CREATE TABLE Archer (
	archer_id INT NOT NULL AUTO_INCREMENT,
	first_name VARCHAR(30) NOT NULL,
	last_name VARCHAR(30) NOT NULL,
	gender ENUM('M', 'F') NOT NULL,
	dob DATE NOT NULL,
	default_bow VARCHAR(20) NOT NULL DEFAULT 'Recurve',
	phone CHAR(10),
	PRIMARY KEY (archer_id),
	FOREIGN KEY (default_bow) REFERENCES Equipment(bow_type)
);

CREATE TABLE Championship (
	champ_id INT NOT NULL AUTO_INCREMENT,
	champ_name VARCHAR(30) NOT NULL,
	date_begin DATE NOT NULL,
	date_end DATE NOT NULL,
	PRIMARY KEY (champ_id)
);

CREATE TABLE EquivalentRound (
	equiv_round_pk INT NOT NULL AUTO_INCREMENT,
	equiv_round_id INT NOT NULL,
	division_name VARCHAR(20),
	bow_type VARCHAR(20),
	base_round_id INT NOT NULL,
	effective_date DATE,
	PRIMARY KEY (equiv_round_pk),
	FOREIGN KEY (base_round_id) 
		REFERENCES Round_ (round_id) 
		ON DELETE CASCADE, -- These cascades could be good, or bad? idk
	FOREIGN KEY (equiv_round_id) 
		REFERENCES Round_ (round_id)
		ON DELETE CASCADE,
	FOREIGN KEY (division_name) 
		REFERENCES Division (division_name) 
		ON DELETE CASCADE,
	FOREIGN KEY (bow_type) 
		REFERENCES Equipment (bow_type) 
		ON DELETE CASCADE
);

CREATE TABLE Event_ (
	event_id INT NOT NULL AUTO_INCREMENT,
	round_id INT NOT NULL,
	is_competition BOOL NOT NULL,
	champ_id INT,
	is_completed BOOL NOT NULL DEFAULT false,
	event_name VARCHAR(40) NOT NULL,
	event_date DATE NOT NULL,
	event_location VARCHAR(40) NOT NULL,
	PRIMARY KEY (event_id),
	FOREIGN KEY (round_id) 
		REFERENCES Round_ (round_id), 
	FOREIGN KEY (champ_id) 
		REFERENCES Championship (champ_id)
);

CREATE TABLE ArcherEvent (
	event_id INT NOT NULL,
	archer_id INT NOT NULL,
	equiv_round_pk INT NOT NULL,
	division_name VARCHAR(20) NOT NULL,
	bow_type VARCHAR(20) NOT NULL,
	PRIMARY KEY (event_id, archer_id),
	FOREIGN KEY (event_id) 
		REFERENCES Event_ (event_id)
		ON DELETE CASCADE,
	FOREIGN KEY (archer_id) 
		REFERENCES Archer (archer_id),
	FOREIGN KEY (equiv_round_pk)
		REFERENCES EquivalentRound (equiv_round_pk),
	FOREIGN KEY (division_name)
		REFERENCES Division (division_name),
	FOREIGN KEY (bow_type)
		REFERENCES Equipment (bow_type)
);

CREATE TABLE Range_ (
	range_id INT NOT NULL AUTO_INCREMENT,
	num_ends INT NOT NULL,
	distance INT NOT NULL,
	face_size ENUM('80cm', '122cm') NOT NULL,
	PRIMARY KEY (range_id)
);

CREATE TABLE RoundRange (
	round_id INT NOT NULL,
	range_num INT NOT NULL,
	range_id INT NOT NULL,
	PRIMARY KEY (round_id, range_num),
	FOREIGN KEY (range_id) REFERENCES Range_ (range_id),
	FOREIGN KEY (round_id) REFERENCES Round_ (round_id)
);

CREATE TABLE Score (
	score_id INT NOT NULL AUTO_INCREMENT,
	event_id INT NOT NULL,
	archer_id INT NOT NULL,
	range_num INT NOT NULL,
	PRIMARY KEY (score_id),
	FOREIGN KEY (event_id, archer_id) 
		REFERENCES ArcherEvent (event_id, archer_id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE
);

-- Storing arrow scores:
-- Desired values can be 0-10 or X. 
-- Possible input values are 0-11
-- When tallying scores, use MIN(arrow, 10)
-- To find bullseyes, you can increment a variable num_bullseye for each arrow value > 10
CREATE TABLE End_ (
	score_id INT NOT NULL,
	end_num INT NOT NULL,
	arrow1 INT NOT NULL,
	arrow2 INT NOT NULL,
	arrow3 INT NOT NULL,
	arrow4 INT NOT NULL,
	arrow5 INT NOT NULL,
	arrow6 INT NOT NULL,
	PRIMARY KEY (score_id, end_num),
	FOREIGN KEY (score_id) 
		REFERENCES Score (score_id) 
		ON DELETE CASCADE
);

CREATE TABLE StagedEnd (
	score_id INT NOT NULL,
	end_num INT NOT NULL,
	arrow1 INT NOT NULL,
	arrow2 INT NOT NULL,
	arrow3 INT NOT NULL,
	arrow4 INT NOT NULL,
	arrow5 INT NOT NULL,
	arrow6 INT NOT NULL,
	is_validated BOOL NOT NULL DEFAULT false,
	PRIMARY KEY (score_id, end_num),
	FOREIGN KEY (score_id) 
		REFERENCES Score (score_id) 
		ON DELETE CASCADE
);

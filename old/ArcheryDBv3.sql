DROP TABLE IF EXISTS END;
DROP TABLE IF EXISTS SCORE;
DROP TABLE IF EXISTS RANGEE;
DROP TABLE IF EXISTS EQUIPMENTROUND;
DROP TABLE IF EXISTS EQUIPMENT;
DROP TABLE IF EXISTS DIVISIONROUND;
DROP TABLE IF EXISTS DIVISION;
DROP TABLE IF EXISTS ARCHERPRACTICEROUND;
DROP TABLE IF EXISTS ARCHERCOMPETITION;
DROP TABLE IF EXISTS COMPETITION;
DROP TABLE IF EXISTS ROUND;
DROP TABLE IF EXISTS ARCHER; 



CREATE TABLE ARCHER (
    ArcherID INT AUTO_INCREMENT,
    FirstName VARCHAR(20) NOT NULL,
    LastName VARCHAR(30) NOT NULL,
    DOB DATE NOT NULL,
    Gender ENUM('M','F') NOT NULL,
    PhoneNo INT (10),
    PRIMARY KEY (ArcherID)
    );

CREATE TABLE ROUND (
    RoundID VARCHAR(10) NOT NULL,
    RoundName VARCHAR(20) NOT NULL,
    PRIMARY KEY (RoundID)
);

CREATE TABLE COMPETITION (
    CompetitionID INT AUTO_INCREMENT,
    RoundID VARCHAR(10) NOT NULL,
    ISChampionchip ENUM ('Y', 'N') NOT NULL DEFAULT 'N',
    CompName VARCHAR (20) NOT NULL,
    CompDate DATE NOT NULL,
    PRIMARY KEY (CompetitionID),
    FOREIGN KEY (RoundID) REFERENCES ROUND (RoundID)
);

CREATE TABLE ARCHERCOMPETITION (
    CompetitionID INT NOT NULL,
    ArcherID INT NOT NULL,
    PRIMARY KEY (CompetitionID, ArcherID),
    FOREIGN KEY (CompetitionID) REFERENCES COMPETITION(CompetitionID),
    FOREIGN KEY (ArcherID) REFERENCES ARCHER(ArcherID)
);

CREATE TABLE ARCHERPRACTICEROUND (
    RoundID VARCHAR(10) NOT NULL,
    ArcherID INT NOT NULL,
    PRIMARY KEY (RoundID, ArcherID),
    FOREIGN KEY (RoundID) REFERENCES ROUND (RoundID),
    FOREIGN KEY (ArcherID) REFERENCES ARCHER(ArcherID)
);

CREATE TABLE DIVISION (
    DivisionName VARCHAR(20) NOT NULL,
    Gender ENUM('M','F') NOT NULL,
    PRIMARY KEY (DivisionName)
);

CREATE TABLE DIVISIONROUND (
    DivisionName VARCHAR(20) NOT NULL,
    RoundID VARCHAR(10) NOT NULL,
    EquivelantRound VARCHAR(10),
    EffectiveDate DATE,
    PRIMARY KEY (DivisionName, RoundID),
    FOREIGN KEY (DivisionName) REFERENCES DIVISION (DivisionName),
    FOREIGN KEY (RoundID) REFERENCES ROUND (RoundID),
    FOREIGN KEY (EquivelantRound) REFERENCES ROUND (RoundID)
);

CREATE TABLE EQUIPMENT (
    BowType VARCHAR(20) NOT NULL,
    PRIMARY KEY (BowType)
);

CREATE TABLE EQUIPMENTROUND (
    BowType VARCHAR(20) NOT NULL,
    RoundID VARCHAR(10) NOT NULL,
    PRIMARY KEY(BowType, RoundID),
    FOREIGN KEY (BowType) REFERENCES EQUIPMENT (BowType),
    FOREIGN KEY (RoundID) REFERENCES ROUND (RoundID)
);

CREATE TABLE RANGEE (
    Distance INT NOT NULL,
    RangeNo INT NOT NULL,
    RoundID VARCHAR(10) NOT NULL,
    NoOfEnds INT NOT NULL,
    PRIMARY KEY(Distance, RangeNo, RoundID),
    FOREIGN KEY (RoundID) REFERENCES ROUND (RoundID)
);

CREATE TABLE SCORE (
    ScoreID INT AUTO_INCREMENT,
    ArcherID INT NOT NULL,
    CompetitionID INT,
    TotScore INT(),
    PRIMARY KEY (ScoreID, ArcherID, CompetitionID),
    FOREIGN KEY (ArcherID) REFERENCES ARCHERCOMPETITION(ArcherID),
    FOREIGN KEY (CompetitionID) REFERENCES ARCHERCOMPETITION(CompetitionID)
);

CREATE TABLE END (
    EndNumber INT NOT NULL,
    Distance INT NOT NULL,
    RangeNo INT NOT NULL,
    RoundID VARCHAR(10) NOT NULL,
    ScoreID INT,
    FaceSize ENUM ('80', '120') NOT NULL,
    ArrowScore1 INT NOT NULL,
    ArrowScore2 INT NOT NULL,
    ArrowScore3 INT NOT NULL,
    ArrowScore4 INT NOT NULL,
    ArrowScore5 INT NOT NULL,
    ArrowScore6 INT NOT NULL,
    PRIMARY KEY (EndNumber, Distance, RangeNo, RoundID),
    FOREIGN KEY (Distance, RangeNo, RoundID) REFERENCES RANGEE (Distance, RangeNo, RoundID),
    FOREIGN KEY (ScoreID) REFERENCES SCORE (ScoreID)
);
/*
CREATE TRIGGER update_score_trigger
AFTER INSERT ON END
FOR EACH ROW
BEGIN
    -- Update the SCORE table with the aggregate score for the inserted end
    UPDATE SCORE
    SET TotScore = (SELECT SUM(ArrowScore1 + ArrowScore2 + ArrowScore3 + ArrowScore4 + ArrowScore5 + ArrowScore6)
                    FROM END
                    WHERE EndNumber = NEW.EndNumber
                    AND Distance = NEW.Distance
                    AND RangeNo = NEW.RangeNo
                    AND RoundID = NEW.RoundID)
    WHERE ArcherID = NEW.ScoreID;
END;

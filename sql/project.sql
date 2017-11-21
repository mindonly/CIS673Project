SPOOL project.out
SET ECHO ON
/*
CIS 673 - Database Design Project
Ron Foreman
Rob Sanchez
Victor Sun
Justin Wickenheiser
*/
--
-- CREATE TABLES
-- 
-- Create Uniform Table
CREATE TABLE uniform (
	uniformId NUMBER (15),
	purchaseDate DATE,
	--
	-- uniform_IC1:
	-- uniformId is the primary key
	CONSTRAINT uniform_IC1 PRIMARY KEY (uniformId)
);
--
-- Create Marcher Table
CREATE TABLE marcher (
	studentId NUMBER(15),
	firstName VARCHAR2(255),
	lastName VARCHAR2(255),
	major VARCHAR2(255),
	uniformId NUMBER(15),
	--
	-- marcher_IC1:
	-- studentId is the primary key
	CONSTRAINT marcher_IC1 PRIMARY KEY (studentId),
	-- marcher_IC2:
	-- Every marcher has one uniform checked out
	CONSTRAINT marcher_IC2 FOREIGN KEY (uniformId)
		REFERENCES uniform (uniformId)
);
--
-- Create Drum Major Table
CREATE TABLE drumMajor (
	studentId NUMBER(15),
	firstName VARCHAR2(255),
	lastName VARCHAR2(255),
	major VARCHAR2(255),
	uniformId NUMBER(15),
	--
	-- drumMajor_IC1:
	-- studentId is the primary key
	CONSTRAINT drumMajor_IC1 PRIMARY KEY (studentId),
	-- drumMajor_IC2:
	-- Every marcher has one uniform checked out
	CONSTRAINT drumMajor_IC2 FOREIGN KEY (uniformId)
		REFERENCES uniform (uniformId)
);
--
-- Create Season Table
CREATE TABLE season (
	termCode NUMBER(6),
	description VARCHAR2(255),
	--
	-- season_IC1:
	-- termCode is the primary key
	CONSTRAINT season_IC1 PRIMARY KEY (termCode)
);
--
-- Create Show Table
CREATE TABLE show (
	termCode NUMBER(6),
	title VARCHAR2(255),
	performDate DATE,
	--
	-- show_IC1:
	-- termCode and title are the composite primary key
	CONSTRAINT show_IC1 PRIMARY KEY (termCode,title),
	-- show_IC2:
	-- termCode must be an existing season's termCode
	-- If a season is deleted, then show also gets deleted.
	CONSTRAINT show_IC2 FOREIGN KEY (termCode)
		REFERENCES season (termCode)
		ON DELETE CASCADE
);
--
-- Create Song Table
CREATE TABLE song (
	songId NUMBER(15),
	title VARCHAR2(255),
	tempo NUMBER(3),
	measureCount NUMBER(3),
	--
	-- song_IC1:
	-- songId is the primary key
	CONSTRAINT song_IC1 PRIMARY KEY (songId),
	-- song_IC2:
	-- If the song has >=200 measures then the tempo must be >= 120
	CONSTRAINT song_IC2 CHECK (NOT (measureCount >= 200 AND tempo < 120))
);
--
-- Create Composer Table
CREATE TABLE composer (
	songId NUMBER(15),
	composer VARCHAR2(255),
	--
	-- composer_IC1:
	-- songId and composer are the composite primary key
	CONSTRAINT composer_IC1 PRIMARY KEY (songId,composer),
	-- composer_IC2:
	-- The songId must be an existing song.
	-- If a song gets deleted, delete the composer for that song.
	CONSTRAINT composer_IC2 FOREIGN KEY (songId)
		REFERENCES song (songId)
		ON DELETE CASCADE
);
--
-- Create Participation Table
CREATE TABLE participation (
	marcherId NUMBER(15),
	termCode NUMBER(6),
	showTitle VARCHAR2(255),
	instrument VARCHAR2(255),
	--
	-- participation_IC1:
	-- marcherId, termCode, and showTitle are the composite primary key
	CONSTRAINT participation_IC1 PRIMARY KEY (marcherId,termCode,showTitle),
	-- participation_IC2:
	-- The marcherId must be an existing marcher.
	-- If a marcher is deleted, then their participation in shows are deleted.
	CONSTRAINT participation_IC2 FOREIGN KEY (marcherId)
		REFERENCES marcher (studentId)
		ON DELETE CASCADE,
	-- participation_IC3:
	-- The instrument that a marcher can play must be one of the following:
	-- Piccolo, Clarinet, Alto Sax, Tenor Sax, Mellophone,
	-- Trumpet, Trombone, Baritone, Sousaphone, Percussion, Flag, or Twirler.
	CONSTRAINT participation_IC3 CHECK (instrument IN ('piccolo','clarinet','alto sax','tenor sax','mellophone','trumpet','trombone','baritone','sousaphone','percussion','flag','twirler'))
	-- participation_IC4:
	-- The combination of termCode and showTitle must be an existing show.
	-- This will need to be done via a trigger.
	--
	-- participation_IC5:
	-- A marcher must play the same instrument for every show they participate in for a given season.
	-- This will need to be done via a trigger.
);
--
-- Create pariticiaption_IC4 Trigger
-- The combination of termCode and showTitle must be an existing show.
CREATE TRIGGER participation_IC4_tr
BEFORE INSERT OR UPDATE ON
	participation
FOR EACH ROW
DECLARE
	counter INTEGER; /* counter variable */
BEGIN
	SELECT
		COUNT(1)
	INTO
		counter
	FROM
		show
	WHERE
		termCode = :new.termCode
		AND title = :new.showTitle;

	IF counter = 0
	THEN
		RAISE_APPLICATION_ERROR(-20001,'The show/termCode combination does not exist. ' || :new.showTitle || ' does not exist in term ' || :new.termCode);
	END IF;
END;
/
--
-- Create pariticiaption_IC5 Trigger
-- A marcher must play the same instrument for every show they participate in for a given season.
CREATE TRIGGER participation_IC5_tr
BEFORE INSERT OR UPDATE ON
	participation
FOR EACH ROW
DECLARE
	PRAGMA AUTONOMOUS_TRANSACTION;
	instrument VARCHAR2(30);
	counter INTEGER;
BEGIN
	-- Get the instrument that :new.marcherId used when participating in shows for the given season :new.termCode
	SELECT DISTINCT
		instrument,
		COUNT(1) AS counter
	INTO
		instrument,
		counter
	FROM
		participation
	WHERE
		termCode = :new.termCode
		AND marcherId = :new.marcherId
	GROUP BY
		instrument;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	counter := 0;

	IF counter > 0 AND LOWER(instrument) != LOWER(:new.instrument)
	THEN
		RAISE_APPLICATION_ERROR(-20001,'Invalid instrument. The marcher has been using ' || instrument || ' all of the ' || :new.termCode || ' term. You are trying to switch the instrument to ' || :new.instrument || '.');
	END IF;
END;
/
--
-- Create Lead Conductor Table
CREATE TABLE leadConductor (
	termCode NUMBER(6),
	showTitle VARCHAR2(255),
	songId NUMBER(15),
	drumMajorId NUMBER(15),
	--
	-- leadConductor_IC1:
	-- termCode, showTitle, and songId are the composite primary key
	CONSTRAINT leadConductor_IC1 PRIMARY KEY (termCode,showTitle,songId),
	-- leadConductor_IC2:
	-- The songId must be of an existing song.
	-- If the song is deleted, then the leadConductor gets deleted.
	CONSTRAINT leadConductor_IC2 FOREIGN KEY (songId)
		REFERENCES song (songId)
		ON DELETE CASCADE,
	-- leadConductor_IC3:
	-- The drumMajorId must be an existing drum major.
	-- If the drum major gets deleted, then the leadConductor gets deleted.
	CONSTRAINT leadConductor_IC3 FOREIGN KEY (drumMajorId)
		REFERENCES drumMajor (studentId)
		ON DELETE CASCADE
	-- leadConductor_IC4:
	-- The combination of termCode and showTitle must be an existing show.
	-- This will need to be done via a trigger.
);
--
-- Create leadConductor_IC4 Trigger
-- The combination of termCode and showTitle must be an existing show.
CREATE TRIGGER leadConductor_IC4_tr
BEFORE INSERT OR UPDATE ON
	leadConductor
FOR EACH ROW
DECLARE
	counter INTEGER; /* counter variable */
BEGIN
	SELECT
		COUNT(1)
	INTO
		counter
	FROM
		show
	WHERE
		termCode = :new.termCode
		AND title = :new.showTitle;

	IF counter = 0
	THEN
		RAISE_APPLICATION_ERROR(-20001,'The show/termCode combination does not exist. ' || :new.showTitle || ' does not exist in term ' || :new.termCode);
	END IF;
END;
/
--
-- Create Show Line Up Table
CREATE TABLE showLineup (
	termCode NUMBER(6),
	showTitle VARCHAR2(255),
	songId NUMBER(15),
	orderBy INTEGER,
	--
	-- showLineup_IC1:
	-- termCode, showTitle, and songId are the composite primary key
	CONSTRAINT showLineup_IC1 PRIMARY KEY (termCode,showTitle,songId),
	-- showLineup_IC2:
	-- The songId must be of an existing song.
	-- If the song is deleted, then it is removed from the line up.
	CONSTRAINT showLineup_IC2 FOREIGN KEY (songId)
		REFERENCES song (songId)
		ON DELETE CASCADE
	-- showLineup_IC3:
	-- The combination of termCode and showTitle must be an existing show.
	-- This will need to be done via a trigger.
);
--
-- Create showLineup_IC3 Trigger
-- The combination of termCode and showTitle must be an existing show.
CREATE TRIGGER showLineup_IC3_tr
BEFORE INSERT OR UPDATE ON
	showLineup
FOR EACH ROW
DECLARE
	counter INTEGER; /* counter variable */
BEGIN
	SELECT
		COUNT(1)
	INTO
		counter
	FROM
		show
	WHERE
		termCode = :new.termCode
		AND title = :new.showTitle;

	IF counter = 0
	THEN
		RAISE_APPLICATION_ERROR(-20001,'The show/termCode combination does not exist. ' || :new.showTitle || ' does not exist in term ' || :new.termCode);
	END IF;
END;
/
--
-- Populate the tables with simple test data
SET FEEDBACK OFF
-- Insert uniforms
INSERT INTO uniform (uniformId,purchaseDate) VALUES (1,TO_DATE('05/17/2013','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (2,TO_DATE('05/17/2013','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (3,TO_DATE('05/17/2013','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (4,TO_DATE('05/17/2013','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (5,TO_DATE('05/17/2013','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (6,TO_DATE('05/17/2013','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (7,TO_DATE('05/17/2013','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (8,TO_DATE('05/17/2013','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (9,TO_DATE('05/17/2013','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (10,TO_DATE('05/17/2013','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (11,TO_DATE('10/03/2015','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (12,TO_DATE('10/03/2015','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (13,TO_DATE('10/03/2015','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (14,TO_DATE('10/03/2015','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (15,TO_DATE('10/03/2015','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (16,TO_DATE('10/03/2015','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (17,TO_DATE('10/03/2015','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (18,TO_DATE('12/09/2016','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (19,TO_DATE('12/09/2016','mm/dd/yyyy'));
INSERT INTO uniform (uniformId,purchaseDate) VALUES (20,TO_DATE('12/09/2016','mm/dd/yyyy'));
-- Insert marchers
INSERT INTO marcher (studentId,firstName,lastName,major,uniformId) VALUES (1000,'James','Singleton','Accounting',1);
INSERT INTO marcher (studentId,firstName,lastName,major,uniformId) VALUES (1011,'Emily','Reed','Music Education',2);
INSERT INTO marcher (studentId,firstName,lastName,major,uniformId) VALUES (1012,'Cody','Dalm','Music Education',3);
INSERT INTO marcher (studentId,firstName,lastName,major,uniformId) VALUES (2104,'Kalie','Twilling','Ad PR',4);
INSERT INTO marcher (studentId,firstName,lastName,major,uniformId) VALUES (2194,'Katie','Salinas','Accounting',5);
INSERT INTO marcher (studentId,firstName,lastName,major,uniformId) VALUES (2202,'John','Stickroe','Psychology',6);
INSERT INTO marcher (studentId,firstName,lastName,major,uniformId) VALUES (3963,'Abbigail','Fox','Nursing',7);
-- Insert drum majors
INSERT INTO drumMajor (studentId,firstName,lastName,major,uniformId) VALUES (2945,'Zach','Lehman','Music Education',13);
INSERT INTO drumMajor (studentId,firstName,lastName,major,uniformId) VALUES (1855,'Tim','Grieme','Music Education',14);
INSERT INTO drumMajor (studentId,firstName,lastName,major,uniformId) VALUES (2264,'Brianne','Krom','Nursing',15);
-- Insert seasons
INSERT INTO season (termCode,description) VALUES (201710,'Fall 2017');
INSERT INTO season (termCode,description) VALUES (201810,'Fall 2018');
INSERT INTO season (termCode,description) VALUES (201910,'Fall 2019');
-- Insert shows
INSERT INTO show (termCode,title,performDate) VALUES (201710,'Show 1',TO_DATE('08/26/2017','mm/dd/yyyy'));
INSERT INTO show (termCode,title,performDate) VALUES (201710,'Show 2',TO_DATE('09/2/2017','mm/dd/yyyy'));
INSERT INTO show (termCode,title,performDate) VALUES (201810,'Show 1',TO_DATE('08/25/2018','mm/dd/yyyy'));
-- Insert songs
INSERT INTO song (songId,title,tempo,measureCount) VALUES (1,'Queen Opener',120,50);
INSERT INTO song (songId,title,tempo,measureCount) VALUES (2,'All I Do is Win',100,45);
INSERT INTO song (songId,title,tempo,measureCount) VALUES (3,'Applause',120,70);
INSERT INTO song (songId,title,tempo,measureCount) VALUES (4,'Victorious',140,63);
INSERT INTO song (songId,title,tempo,measureCount) VALUES (5,'Come Fly with Me',104,87);
INSERT INTO song (songId,title,tempo,measureCount) VALUES (6,'Night Train',124,33);
INSERT INTO song (songId,title,tempo,measureCount) VALUES (7,'Daft Punk Medley',116,112);
-- Insert composer
INSERT INTO composer (songId,composer) VALUES (1,'Tom Wallace');
INSERT INTO composer (songId,composer) VALUES (1,'Tony McCutchen');
INSERT INTO composer (songId,composer) VALUES (2,'Tom Wallace');
INSERT INTO composer (songId,composer) VALUES (3,'Michael Brown');
INSERT INTO composer (songId,composer) VALUES (3,'Will Rapp');
INSERT INTO composer (songId,composer) VALUES (4,'Matt Conaway');
INSERT INTO composer (songId,composer) VALUES (4,'Jack Holt');
INSERT INTO composer (songId,composer) VALUES (5,'Paul Murtha');
INSERT INTO composer (songId,composer) VALUES (5,'Will Rapp');
INSERT INTO composer (songId,composer) VALUES (6,'Tom Wallace');
INSERT INTO composer (songId,composer) VALUES (7,'Tom Wallace');
INSERT INTO composer (songId,composer) VALUES (7,'Tony McCutchen');
-- Insert participation
--	--	--	201710 Show 1	--	--	--
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (1000,201710,'Show 1','clarinet');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (1011,201710,'Show 1','piccolo');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (1012,201710,'Show 1','alto sax');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (2104,201710,'Show 1','tenor sax');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (2194,201710,'Show 1','tenor sax');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (2202,201710,'Show 1','mellophone');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (3963,201710,'Show 1','percussion');
--	--	--	201710 Show 2	--	--	--
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (1000,201710,'Show 2','clarinet');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (1011,201710,'Show 2','piccolo');
-- marcherId 1012 did not participate in 201710 Show 2
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (2104,201710,'Show 2','tenor sax');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (2194,201710,'Show 2','tenor sax');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (2202,201710,'Show 2','mellophone');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (3963,201710,'Show 2','percussion');
--	--	--	201810 Show 1	--	--	--
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (1000,201810,'Show 1','clarinet');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (1011,201810,'Show 1','piccolo');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (1012,201810,'Show 1','alto sax');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (2104,201810,'Show 1','sousaphone');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (2194,201810,'Show 1','tenor sax');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (2202,201810,'Show 1','mellophone');
INSERT INTO participation (marcherId,termCode,showTitle,instrument) VALUES (3963,201810,'Show 1','percussion');
-- Insert showLineup
--	--	--	201710 Show 1	--	--	--
INSERT INTO showLineUp (termCode,showTitle,songId,orderBy) VALUES (201710,'Show 1',1,1);
INSERT INTO showLineUp (termCode,showTitle,songId,orderBy) VALUES (201710,'Show 1',3,2);
INSERT INTO showLineUp (termCode,showTitle,songId,orderBy) VALUES (201710,'Show 1',2,3);
INSERT INTO showLineUp (termCode,showTitle,songId,orderBy) VALUES (201710,'Show 1',4,4);
--	--	--	201710 Show 2	--	--	--
INSERT INTO showLineUp (termCode,showTitle,songId,orderBy) VALUES (201710,'Show 2',7,1);
INSERT INTO showLineUp (termCode,showTitle,songId,orderBy) VALUES (201710,'Show 2',5,2);
-- Insert leadConductor
--	--	--	201710 Show 1	--	--	--
INSERT INTO leadConductor (termCode,showTitle,songId,drumMajorId) VALUES (201710,'Show 1',1,2945);
INSERT INTO leadConductor (termCode,showTitle,songId,drumMajorId) VALUES (201710,'Show 1',2,1855);
INSERT INTO leadConductor (termCode,showTitle,songId,drumMajorId) VALUES (201710,'Show 1',3,2264);
INSERT INTO leadConductor (termCode,showTitle,songId,drumMajorId) VALUES (201710,'Show 1',4,2945);
--	--	--	201710 Show 2	--	--	--
INSERT INTO leadConductor (termCode,showTitle,songId,drumMajorId) VALUES (201710,'Show 2',7,1855);
INSERT INTO leadConductor (termCode,showTitle,songId,drumMajorId) VALUES (201710,'Show 2',5,2264);
--
SET FEEDBACK ON
COMMIT;
--
-- Display the tables
SELECT * FROM uniform;
SELECT * FROM marcher;
SELECT * FROM drumMajor;
SELECT * FROM song;
SELECT * FROM composer;
SELECT * FROM season;
SELECT * FROM show;
SELECT * FROM showLineup;
SELECT * FROM participation;
SELECT * FROM leadConductor;
--
-- Queries
--
SPOOL OFF
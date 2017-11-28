SPOOL project.out
SET ECHO ON
/*
CIS 673 - Database Design Project
Ron Foreman
Rob Sanchez
Victor Sun
Justin Wickenheiser
*/
-- Set the linesize (only to help keep things clean)
SET LINESIZE 300;
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
	firstName VARCHAR2(30),
	lastName VARCHAR2(30),
	major VARCHAR2(30),
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
	firstName VARCHAR2(30),
	lastName VARCHAR2(30),
	major VARCHAR2(30),
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
	description VARCHAR2(30),
	--
	-- season_IC1:
	-- termCode is the primary key
	CONSTRAINT season_IC1 PRIMARY KEY (termCode)
);
--
-- Create Show Table
CREATE TABLE show (
	termCode NUMBER(6),
	title VARCHAR2(30),
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
	title VARCHAR2(30),
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
	composer VARCHAR2(30),
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
	showTitle VARCHAR2(30),
	instrument VARCHAR2(30),
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
	numInstruments INTEGER;
BEGIN
	-- Get the instrument that :new.marcherId used when participating in shows for the given season :new.termCode
	SELECT
		COUNT(DISTINCT instrument) AS numInstruments
	INTO
		numInstruments
	FROM
		participation
	WHERE
		termCode = :new.termCode
		AND marcherId = :new.marcherId
	;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	numInstruments := 0;

	IF numInstruments > 0 AND LOWER(:old.instrument) != LOWER(:new.instrument)
	THEN
		RAISE_APPLICATION_ERROR(-20001,'Invalid instrument. The marcher has been using ' || instrument || ' all of the ' || :new.termCode || ' term. You are trying to switch the instrument to ' || :new.instrument || '.');
	END IF;
END;
/
--
-- Create Lead Conductor Table
CREATE TABLE leadConductor (
	termCode NUMBER(6),
	showTitle VARCHAR2(30),
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
	showTitle VARCHAR2(30),
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
INSERT INTO marcher (studentId,firstName,lastName,major,uniformId) VALUES (3004,'Mason','Riley','Music Education',8);
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
-- 1. Join involving at least four relations.
-- Find the instrument, show title, and season description for each show that Kalie Twilling particiapted in. Order the results by the season and then by show title.
SELECT
	m.firstName,
	m.lastName,
	s.description AS Season,
	sh.title AS Show,
	p.instrument
FROM
	season s,
	show sh,
	participation p,
	marcher m
WHERE
	s.termCode = sh.termCode
	AND sh.termCode = p.termCode
	AND sh.title = p.showTitle
	AND p.marcherId = m.studentId
	AND LOWER(m.firstName) = 'kalie'
	AND LOWER(m.lastName) = 'twilling'
ORDER BY
	s.description,
	sh.title
;
--
-- 2. Self join
-- Find pairs of marchers that share the same major.
SELECT
	m1.firstName || ' ' || m1.lastName AS Marcher_1,
	m2.firstName || ' ' || m2.lastName AS Marcher_2,
	m1.major
FROM
	marcher m1,
	marcher m2
WHERE
	m1.major = m2.major
	AND m1.studentId < m2.studentId
ORDER BY
	m1.major
;
--
-- 3. Union
-- Select the firstName and lastName of marchers and drum majors that are majoring in Music Education. Order by the lastName.
SELECT
	firstName,
	lastName
FROM
	marcher
WHERE
	LOWER(major) = 'music education'
UNION
SELECT
	firstName,
	lastName
FROM
	drumMajor
WHERE
	LOWER(major) = 'music education'
ORDER BY
	lastName
;
--
-- 4. SUM, AVG, MAX, and MIN
-- Find the total number of measures, the average number of measures, max and min number of measures across all songs.
SELECT
	SUM(measureCount),
	AVG(measureCount),
	MAX(measureCount),
	MIN(measureCount)
FROM
	song
;
--
-- 5. GROUP BY, HAVING, and ORDER BY
-- Find the marchers that particiapted in only 1 show for each season. For each marcher, get their name and the season's description.
SELECT
	m.firstName,
	m.lastName,
	s.description,
	COUNT(p.showTitle) AS showsMarched
FROM
	marcher m,
	season s,
	participation p
WHERE
	m.studentId = p.marcherId
	AND p.termCode = s.termCode
GROUP BY
	m.firstName,
	m.lastName,
	s.description
HAVING
	COUNT(p.showTitle) = 1
ORDER BY
	s.description,
	m.lastName,
	m.firstName
;
--
-- 6. Correlated Subquery
-- Find the name of the marcher(s) who have not particiapted in any shows.
SELECT
	m.firstName,
	m.lastName
FROM
	marcher m
WHERE
	NOT EXISTS (
		SELECT
			*
		FROM
			participation
		WHERE
			marcherId = m.studentId
	)
;
--
-- 7. Non-Correlated Subquery
-- Find the song(s) that are not a part of any show line up.
SELECT
	title
FROM
	song
WHERE
	songId NOT IN (
		SELECT
			songId
		FROM
			showLineUp
	)
;
--
-- 8. Relational DIVISION
-- Find the studentId and name of every drum major who has conducted every song composed by Will Rapp
SELECT
	dm.studentId,
	dm.firstName,
	dm.lastName
FROM 
	drumMajor dm
WHERE
	NOT EXISTS (
		(
			SELECT
				c.songId
			FROM
				composer c
			WHERE
				LOWER(c.composer) = 'will rapp'
		) MINUS (
			SELECT
				l.songId
			FROM
				leadConductor l, composer c
			WHERE
				l.drumMajorId = dm.studentId
				AND l.songId = c.songId
				AND LOWER(c.composer) = 'will rapp'
		)
	)
;
--
-- 9. Outer Join
-- Find the uniformId and purchase date of every uniform. Also show the students name for those who have them.
SELECT
	u.uniformId,
	u.purchaseDate,
	m.firstName || ' ' || m.lastName AS marcher,
	d.firstName || ' ' || d.lastName AS drumMajor
FROM
	uniform u
LEFT OUTER JOIN
	marcher m ON u.uniformId = m.uniformId
LEFT OUTER JOIN
	drumMajor d ON u.uniformId = d.uniformId
ORDER BY
	u.uniformId
;
--
-- 10. RANK Query
-- Find the RANK and DENSE RANK of the uniform purchase date of '09-DEC-16' among all purchase dates
SELECT
	RANK('09-DEC-16') WITHIN GROUP (ORDER BY purchaseDate) AS "Rank of 09-DEC-16",
	DENSE_RANK('09-DEC-16') WITHIN GROUP (ORDER BY purchaseDate) AS "Dense Rank of 09-DEC-16"
FROM
	uniform
;
--
-- 11. Top-N Query
-- Find the title and tempo of the four fastest songs.
SELECT
	title,
	tempo
FROM
	(
		SELECT
			title,
			tempo
		FROM
			song
		ORDER BY
			tempo DESC
	)
WHERE
	ROWNUM <= 4
;
--
-- TESTING ICs
-- 
-- Testing: marcher_IC1 (key)
INSERT INTO marcher (studentId,firstName,lastName,major,uniformId) VALUES (3004,'Emily','Ketchum','Accounting',9);
COMMIT;
--
-- Testing: drumMajor_IC2 (foreign key)
UPDATE
	drumMajor
SET
	uniformId = 99
WHERE
	studentId = 2945
;
COMMIT;
--
-- Testing: participation_IC3 (1-attribute)
UPDATE
	participation
SET
	instrument = 'flute'
WHERE
	marcherId = 3963
;
COMMIT;
--
-- Testing: song_IC2 (2-attribute, 1 row)
INSERT INTO song (songId,title,tempo,measureCount) VALUES (8,'Wabash Cannonball',116,245);
COMMIT;
--
-- Testing: participation_IC5_tr (2-row)
UPDATE
	participation
SET
	instrument = 'piccolo'
WHERE
	marcherId = 1000
	AND termCode = 201710
	AND showTitle = 'Show 2'
;
COMMIT;
--
SPOOL OFF
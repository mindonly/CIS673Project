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
	CONSTRAINT song_IC1 PRIMARY KEY (songId)
);
--
-- Create Composer Table
CREATE TABLE composer (
	songId NUMBER(15),
	composer VARCHAR2(255)
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
-- <<<<<	INSERT CODE HERE	>>>>>
--
-- Create pariticiaption_IC5 Trigger
-- <<<<<	INSERT CODE HERE	>>>>>
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
	--
	-- leadConductor_IC5:
	-- Every song within a show must have a lead conductor.
	-- This will need to be done via a trigger.
);
--
-- Create leadConductor_IC4 Trigger
-- <<<<<	INSERT CODE HERE	>>>>>
--
-- Create leadConductor_IC5 Trigger
-- <<<<<	INSERT CODE HERE	>>>>>
--
-- Create Show Line Up Table
CREATE TABLE showLineup (
	termCode NUMBER(6),
	showTitle VARCHAR2(255),
	songId NUMBER(15),
	order INTEGER,
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
-- <<<<<	INSERT CODE HERE	>>>>>
--
-- Populate the tables with simple test data
SET FEEDBACK OFF
--
SET FEEDBACK ON
COMMIT;
--
--
--
SPOOL OFF
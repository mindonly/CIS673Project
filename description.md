# Marching Band Database Description

## Student
* The system tracks Students that are in the school marching band.
* Students have a unique Student ID, in addition to name and major attributes.
* Every Student in the system is either a Marcher or a Drum Major.

## Season
* The system tracks the different marching Seasons. 
* Seasons have a unique term code as well as a description. 

## Show
* The system will track marching Shows. 
* Shows have a title and a performance date.
* A Show belongs to a specific Season and a Season can be composed of many Shows.
* Not all Seasons have Shows planned for them yet.

## Song
* There are also Songs that the system must track. 
* Songs have a unique song ID, a title, tempo, measure count, one or more composers.
* The system will also track the Song's tempo and number of measures in the Song.
* For any given Show in a given Season, there are Songs that make up the Show. 
* A Show can have many Songs and a Song can be in multiple Shows.
* A Show must have at least 1 Song in it, but not every Song has to be in a Show.
* The system must also track the order of the Songs in each Show.
* Songs must have a minimum tempo of 96 BPM.
* Songs must have a minimum of 50 measures.

## Marcher
* Marchers participate in Shows. 
* Not every Marcher participates in a given Show. 
* Not every Show has Marchers participating in it.
* A Marcher can participate in several Shows, and a Show has one or more Marchers. 
* The system needs to track what instrument a Marcher plays for a given Show.
* A Marcher only plays one instrument per Show.
* The instrument that a Marcher can play must be one of the following: Piccolo, Clarinet, Alto Sax, Tenor Sax, Mellophone, Trumpet, Trombone, Baritone, Sousaphone, Percussion, Flag, or Twirler.
* A Marcher must play the same instrument for every Show in a Season.

## Lead Conductor
* Drum Majors "become" Lead Conductors for specific Songs of any given Show.
* "Lead Conducting" is an event that occurs during a Show, and the duration of that event could be one or many Songs.
* A Drum Major can be Lead Conductor for several Songs in a Show.
* A Song only has one Lead Conductor per Show
* Not every Drum Major has to be a Lead Conductor within a Show.
* Every Song within a Show must have a Lead Conductor; however, not every Show needs Lead Conductors. 

## Uniform
* The system will track Uniforms. 
* Uniforms are uniquely identified by their uniform ID. 
* They also have a purchase date. 
* Each Student checks out only one Uniform and a Uniform can only be checked out by one Student.
* Not every Uniform in the band's inventory is necessarily checked out.


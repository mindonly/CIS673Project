# Marching Band Database Description

## Student
* The system tracks Students that are in the school marching band.
* Students have a unique G#, name, and major.
* Every Student in the system is either a Marcher or a Drum Major.

## Season
* The system tracks the different marching Seasons. 
* Seasons have a unique term code and a description. 

## Show
* The system will track marching Shows. 
* Shows have a title and a performance date.
    - (If we use Date as the Show then Show doesn't have to be Weak ?? Then Lead Conductor key doesn't need to include Season TermCode ?? -RS)
* A Show belongs to a specific Season and a Season can have many shows.
* Not all Seasons have Shows planned for them yet.

## Song
* There are also Songs that the system must track. 
* Songs have a unique songID, a title, and one or more composers.
* The system will also track the song's tempo and number of measures in the song.
* For any given Show in a given Season, there are Songs that make up the Show. 
* A Show can have many songs and a song can be in multiple shows.
    - (I added this statement to clarify the show/song relationship is M:N -JW)
* A Show has to have at least 1 Song in it, but not every Song has to be in a Show.
* The system must also track the order of the Songs in each Show.
* Songs must have a minimum tempo of 96 BPM.
* Songs must have a minimum of 50 measures.

## Song Instance
* All Song Instances are instances of a Song.
* Shows are composed of Song Instances, but not all Shows necessarily have Song Instances assigned.
* The system will keep track of the order of a Song Instance within a Show.
* Every Song Instance in a Show must have a lead conductor. 

## Marcher
* Marchers participate in shows. 
* Not every Marcher participates in a given show. 
* Not every show has Marchers participating in it.
* A Marcher can participate in several shows, and a show has one or more Marchers. 
* The system needs to track what instrument a Marcher plays for a given show.
* A Marcher only plays one instrument per show.
* The instrument that a marcher can play must be one of the following: Piccolo, Clarinet, Alto Sax, Tenor Sax, Mellophone, Trumpet, Trombone, Baritone, Sousaphone, Percussion, Flag, or Twirler.
* A marcher must play the same instrument for every show in a season.

## Drum Major
* Drum Majors lead specific songs of any given show. 
* A Drum Major can be lead several songs in a show. 
* A song only has one lead conductor per show.
* Not every Drum Major has to be a lead conductor within a show.

## Uniform
* The system will track Uniforms. 
* Uniforms are uniquely identified by their UniformID. 
* They also have a purchaseDate. 
* Each Student checks out only one Uniform and a Uniform can only be checked out by one student.
* Not every Uniform in the band's inventory is necessarily checked out.


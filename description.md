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

## Marcher
* Marchers participate in shows. 
* Not every Marcher participates in a given show. 
* Not every show has Marchers participating in it.
* A Marcher can participate in several shows, and a show has one or more Marchers. 
* The system needs to track what instrument a Marcher plays for a given show.
* A Marcher only plays one instrument per show.
* The instrument that a marcher can play must be one of the following: Piccolo, Clarinet, Alto Sax, Tenor Sax, Mellophone, Trumpet, Trombone, Baritone, Sousaphone, Percussion, Flag, or Twirler.
* A marcher must play the same instrument for every show in a season.

## Drum Major/Lead Conductor
* Drum Majors are Lead Conductors for specific songs of any given show. 
* A Drum Major can be Lead Conductor for several songs in a show. 
* A song only has one Lead Conductor per show 
    - (I think this means that the relationship going from Lead Conductor to show needs to be identifying. That makes the drawing incorrect. -JW)
* Not every Drum Major has to be a Lead Conductor within a show.
* Every song within a show must have a Lead Conductor; however, not every show needs Lead Conductors. 
    - (This I think will need to be implemented via trigger. Simply put: You can plan a show with 4 songs to be a in future season. Since you don't know what Drum Majors you will have that season, you cannot yet assign them as Lead Conductors for songs in that show. BUT, if you start to assign Drum Majors as Lead Conductors of songs in a given show, then all songs in that show must have a Lead Conductor. It is all or nothing. -JW)

## Uniform
* The system will track Uniforms. 
* Uniforms are uniquely identified by their UniformID. 
* They also have a purchaseDate. 
* Each Student checks out only one Uniform and a Uniform can only be checked out by one student.
* Not every Uniform in the band's inventory is necessarily checked out.


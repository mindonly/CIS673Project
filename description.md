# Marching Band Database Description

1. The system tracks students that are in the school marching band. Students have a unique G#, name, and major.  Every student in the system is either a marcher or a drum major.

2. The system tracks the different marching seasons. Seasons have a unique term code and a description. The system will track marching shows. Shows have a title and a performance date.

3. A Show belongs to a specific season and a season can have many shows. Not all seasons have shows planned for them yet.

4. There are also Songs that the system must track. Songs have a unique songId, a title, and one or more composers.

5. For any given show in a given season, there are songs that make up the show. A show has to have at least 1 song in it, but not every song has to be in a show. The system must also track the order of the songs in each show. Each show is identified by a show number.

6. Marchers participate in shows. Not every marcher participates in a given show, and not every show has marchers participating in it. A marcher can participate in several shows, and a show has several marchers. The system needs to track what instrument a marcher plays for a given show.

7. Drum majors are lead conductors for specific songs of any given show. A drum major can be lead conductor for several songs in a show. 

8. A song only has one lead conductor per show (I think this means that the relationship going from lead conductor to show needs to be identifying. That makes the drawing incorrect.).

9. Not every drum major has to be a lead conductor within a show.
Every song within a show must have a lead conductor; however, not every show needs lead conductors. (This I think will need to be implemented via trigger. Simply put: You can plan a show with 4 songs to be a in future season. Since you don't know what drum majors you will have that season, you cannot yet assign them as lead conductors for songs in that show. BUT, if you start to assign drum majors as lead conductors of songs in a given show, then all songs in that show must have a lead conductor. It is all or nothing.)

10. Finally the system will track uniforms. Uniforms are uniquely identified by their uniformId. They also have a purchaseDate. Each Student checks out only one uniform and a uniform can only be checked out by one student.


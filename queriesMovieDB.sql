USE `movieDB`;

#1.a)List all the actors who acted in at least one film in 2nd half of the 19th century and in at least one film in 
#the 1st half of the 20th century
SELECT fName, lName
FROM Actor AS a, Movie AS m1, Movie AS m2, Cast AS c1, Cast AS c2
WHERE c1. mID = m1.id
AND c1.pID = a.id
AND m1.releaseyear BETWEEN 1850 AND 1900
AND c2. mID = m2.id
AND c2.pID = a.id
AND m2.releaseyear BETWEEN 1901 AND 1950;

#b).List all the directors who directed a film in a leap year.
SELECT m.id, d.fName, d.lName 
FROM Movie m, Director d, MovieDirector md
WHERE md.dID = d.ID
AND md.movieID = m.ID
AND ((m.releaseyear % 4 AND m.releaseyear % 100 <> 0)
OR m.releaseyear % 400 = 0);

#2.List all the movies that have the same year as the movie 'Shrek (2001)', but a better rank. 
#(Note: bigger value of rank implies a better rank).
SELECT *
FROM Movie AS m1
INNER JOIN (SELECT movierank, releaseyear
FROM Movie
WHERE moviename = 'Shrek (2001)'
) AS m2
ON m1.movierank > m2.movierank
AND m1.releaseyear = m2.releaseyear;

#3.List first name and last name of all the actors who played in the movie 'Officer 444 (1926)'.
SELECT fName, lName
FROM Actor AS a, Movie AS m, Cast AS c
WHERE c.mID = m.ID
AND a.id = c.mID
AND moviename = 'Officer 444 (1926)';

#4.List all directors in descending order of the number of films they directed.
SELECT d.fName, d.lName, COUNT(md.movieID) AS no_movies
FROM Director AS d, MovieDirector AS md
WHERE d.id = md.dID
GROUP BY fName, lName
ORDER BY no_movies DESC;

#5.a)Find the film(s) with the largest cast.
#Varianta 1:
SELECT m.moviename, COUNT(*) AS cast_size
FROM Movie AS m 
INNER JOIN Cast AS c ON m.ID = c.mID
GROUP BY m.ID, m.moviename
HAVING COUNT(*) >= ALL (SELECT COUNT(*) 
FROM Cast
GROUP BY mID);

#Varianta 2:
SELECT m.moviename, COUNT(*) AS cast_size
FROM Movie AS m 
INNER JOIN Cast AS c ON m.ID = c.mID
GROUP BY m.ID, m.moviename
HAVING COUNT(*) = (SELECT MAX(nbActors) 
FROM (SELECT COUNT(*) AS nbActors
FROM Cast
GROUP BY mID) AS largestCast);

#b)Find the film(s) with the smallest cast.
#Varianta 1:
SELECT m.moviename, COUNT(*) AS cast_size
FROM Movie m 
INNER JOIN Cast c ON m.ID = c.mID
GROUP BY m.ID, m.moviename
HAVING COUNT(*) <= ALL (SELECT COUNT(*) 
FROM Cast
GROUP BY mID);

#Varianta 2:
SELECT m.moviename, COUNT(*) AS cast_size
FROM Movie AS m 
INNER JOIN Cast AS c ON m.ID = c.mID
GROUP BY m.ID, m.moviename
HAVING COUNT(*) = (SELECT MIN(nbActors) 
FROM (SELECT COUNT(*) AS nbActors
FROM Cast
GROUP BY mID) AS smallestCast);

#6.Find all the actors who acted in films by at least 10 distinct directors.
#Varianta 1:
SELECT DISTINCT a.id, CONCAT(a.fName, ', ' , a.lName) AS Actor, CONCAT(d.fName, ', ', d.lName) AS Director
FROM Actor AS a
INNER JOIN Cast AS c ON a.ID = c.pID
INNER JOIN MovieDirector AS md ON md.movieID = c.mID
INNER JOIN Movie AS m ON m.ID = md.movieID 
INNER JOIN Director AS d ON d.ID = md.dID 
GROUP BY ID
HAVING COUNT(dID) >= 10;

#Varianta 2:
CREATE TEMPORARY TABLE actorCast AS (
SELECT id, fName, lName, gender, pID, mID, role
FROM Actor AS a
INNER JOIN Cast AS c
ON a.id = c.pID);

CREATE TEMPORARY TABLE actorCastDirector AS (
SELECT * FROM actorCast AS ac
INNER JOIN MovieDirector AS md ON ac.mID = md.movieID );

SELECT id, fName, lName, COUNT(dID) AS no_directors
FROM actorCastDirector
GROUP BY id, fName, lName
HAVING COUNT(dID) >= 10;

#7.Find all actors who acted only in films before 1960. 
#Varianta 1:
SELECT a.fName, a.lName, m.moviename, m.releaseyear
FROM Actor AS a, Movie AS m, Cast AS c
WHERE c.pid  = a.id 
AND c.mid = m.id
AND releaseyear <= 1960;

#Varianta 2:
SELECT a.fName, a.lName, m.moviename, m.releaseyear
FROM Actor AS a
INNER JOIN Cast c ON c.pID = a.id
INNER JOIN Movie m ON m.id = c.mID
WHERE m.releaseyear <= 1960;

#8.Find the films with more women actors than men.
SELECT m.id, m.moviename, a.lName, a.fName
FROM Movie AS m, Cast AS c1, Actor AS a
WHERE c1.mID = m.ID 
AND c1.pID = a.id 
AND a.gender = 'F'
GROUP BY m.ID
HAVING COUNT(*) > (SELECT COUNT(*)
FROM Cast AS c2, Actor AS a
WHERE c2.mID = m.ID 
AND c2.pID = a.id 
AND a.gender = 'M');

#9.For every pair of male and female actors that appear together in some film, find the total number of films in
#which they appear together. Sort the answers in decreasing order of the total number of films.
SELECT MaleActor.fName, MaleActor.lName, FemActor.fName, FemActor.lName, COUNT(MaleCast.mID) AS no_movies
FROM Actor AS MaleActor
INNER JOIN Cast AS MaleCast ON MaleActor.id = MaleCast.pID
INNER JOIN Cast AS FemCast ON MaleCast.pID = FemCast.pID
INNER JOIN Actor AS FemActor ON FemActor.id = FemCast.pID
WHERE MaleActor.gender = 'M' AND FemActor.gender = 'F'
GROUP BY MaleActor.id
HAVING no_movies > 0
ORDER BY no_movies DESC;

#10.For every actor, list the films he/she appeared in their debut year. Sort the results by last name of the actor.
#Varianta 1:
SELECT a.fName, a.lName, m1.moviename, m1.releaseyear
FROM Actor AS a, Movie AS m1, Cast AS c1
WHERE a.ID = c1.pID
AND m1.ID = c1.mID
AND m1.releaseyear = (SELECT MIN(releaseyear) 
FROM Movie AS m2, Cast AS c2
WHERE m2.ID = c2.mID
AND a.ID = c2.pID)
ORDER BY a.lName;

#Varianta 2:
SELECT a.fName, a.lName, m1.moviename, m1.releaseyear
FROM Actor AS a
INNER JOIN Cast AS c1 ON a.id = c1.pID
INNER JOIN Movie AS m1 ON m1.ID = c1.mID
WHERE m1.releaseyear = (SELECT MIN(releaseyear)
FROM Movie AS m2
INNER JOIN Cast AS c2 ON m2.ID = c2.mID
INNER JOIN Actor ON a.id = c2.pID
ORDER BY a.lName);

#Varianta 3:
CREATE TEMPORARY TABLE ActorCast AS (
SELECT id, fName, lName, gender, role, mID
FROM Actor AS a
INNER JOIN Cast AS c
ON a.id = c.pID);

CREATE TEMPORARY TABLE ActorCastMovie AS (
SELECT id, fName,  lName, moviename, releaseyear
FROM ActorCast AS ac
INNER JOIN Movie AS m
ON ac.mID = mID);

SELECT fName, lName, moviename, releaseyear
FROM ActorCastMovie
WHERE releaseyear = (SELECT MIN(releaseyear)
FROM Movie AS m1, Cast AS c1
WHERE m1.id = c1.mID 
AND a.id = c1.pID);

#12.The Bacon number of an actor is the length of the shortest path between the actor and Kevin Bacon in the 
#"co-acting" graph. That is, Kevin Bacon has Bacon number 0; all actors who acted in the same film as KB have 
#Bacon number 1; all actors who acted in the same film as some actor with Bacon number 1 have Bacon number 2, etc.
#Return all actors whose Bacon number is 2. 
#Bonus: Suppose you write a single SELECT-FROM-WHERE SQL query that returns all actors whose Bacon number is 
#infinity. How big is the query?
#Note: The above "Bonus" problem is ill-stated. The correct one should be as follows:
#Suppose you write a single SELECT-FROM-WHERE SQL query that returns all actors who have finite Bacon numbers.
#How big is the query?
SELECT COUNT(DISTINCT pID) FROM Cast 
WHERE mID IN (SELECT mID FROM Cast
WHERE pID IN (SELECT DISTINCT pID IN (
SELECT DISTINCT pID FROM Cast WHERE mID IN (SELECT mID FROM Cast INNER JOIN Actor
ON pID = Actor.id WHERE fName = 'Kevin' AND lName = 'Bacon')))
AND pID NOT IN (SELECT DISTINCT pID FROM Cast WHERE mID IN (
SELECT mID FROM Cast INNER JOIN Actor ON
pID = Actor.id WHERE fName  = 'Kevin' AND lName = 'Bacon'));

#12.A decade is a sequence of 10 consecutive years. For example 1965, 1966, ..., 1974 is a decade, and so is 1967, 
#1968, ..., 1976. Find the decade with the largest number of films.
SELECT m1.releaseyear AS decade_start, m1.releaseyear + 9 AS decade_end, COUNT(*) AS no_movies
FROM (SELECT DISTINCT releaseyear 
FROM Movie) T JOIN 
Movie AS m1
ON m1.releaseyear BETWEEN m1.releaseyear AND m1.releaseyear + 9
GROUP BY m1.releaseyear
ORDER BY m1.moviename DESC
LIMIT 1;

#13.Rank the actors based on their popularity, and compute a list of all actors in descending order of their 
#popularity ranks.  You need to come up with your own metric for computing the popularity ranking.  This may 
#include information such as the number of movies that an actor has acted in; the 'popularity' of these movies' 
#directors (where the directors' popularity is the number of movies they have directed), etc.  Be creative in 
#how you choose your criteria of computing the actors' popularity.   For this answer, in addition to the query, 
#also turn in the criteria you used to rank the actors.

SELECT actorRank
FROM 
(SELECT a.lName, a.fName 
(CASE 
WHEN COUNT(m.id) AS noMoviesActed AND COUNT(md.mID) AS noMoviesDirected BETWEEN 80 AND 100 THEN 'Very popular'
WHEN COUNT(m.id) AS noMoviesActed AND COUNT(md.mID) AS noMoviesDirected BETWEEN 50 AND 79 THEN 'Popular'
WHEN COUNT(m.id) AS noMoviesActed AND COUNT(md.mID) AS noMoviesDirected < 50 THEN 'Not popular at all'
END) actorRank
FROM Actor AS a
INNER JOIN MovieDirector AS md ON a.id = md.pID
INNER JOIN Movie AS m ON m.id = md.mID) ar
GROUP BY ar.actorRank;
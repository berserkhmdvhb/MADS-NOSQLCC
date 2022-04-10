show client_encoding;
SET CLIENT_ENCODING TO 'UTF8';


/* Question 1 & 2 */

/** The tables 'uris' and and 'keywords' are created including primary key and foreign key **/
CREATE TABLE uris(
	id int,
	link varchar(1024),
	PRIMARY KEY(id)
);
 
COPY uris
FROM '/home/hamed/Documents/datasets/wikiperdia-revision-uris.TSV'



CREATE TABLE keywords(
	id int,
	term varchar(64), 
	score float,
	FOREIGN KEY(id) REFERENCES uris(id)
);



		
COPY keywords
FROM '/home/hamed/Documents/datasets/wikipedia-keywords.TSV'







/** The tables 'uris_wk' and and 'keywords_wk' are created excluding any kind of key (without key or wk) **/
CREATE TABLE uris_wk(
	id int,
	link varchar(1024)
);
 

COPY uris_wk
FROM '/home/hamed/Documents/datasets/wikiperdia-revision-uris.TSV'
/*DELIMITER E'\t';*/


CREATE TABLE keywords_wk(
	id int,
	term varchar(64), 
	score float
);

COPY keywords_wk
FROM '/home/hamed/Documents/datasets/wikipedia-keywords.TSV'
/*DELIMITER E'\t';*/


SELECT id FROM uris WHERE id IN (SELECT id FROM keywords WHERE keywords.term = "")
/* regex and aggregate attempts */
/* ANY */
SELECT id, string_agg(term, ', ') AS reg FROM keywords GROUP BY id;
SELECT * FROM (SELECT id, regexp_matches(string_agg(term, ' '), '(rock)|(paper)|(scissors)|(game)') AS reg FROM keywords GROUP BY id) AS A WHERE A.reg IS NOT NULL;
/* ALL */
SELECT * FROM (SELECT id, regexp_matches(string_agg(term, ' '), '((rock)|(paper)|(scissors)|(game))') AS reg FROM keywords GROUP BY id) AS A;





/* Problem 2 */		
/** Boolean Retrievals **/
/*** Question 2.1:  all ***/
SELECT t1.* FROM (SELECT uris.link FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'PAPER'
INTERSECT
SELECT uris.link FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'ROCK'
INTERSECT
SELECT uris.link FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'SCISSOR'
INTERSECT
SELECT uris.link FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'GAME') AS t1;


/*** Question 2.2:  any ***/
SELECT t1.* FROM (SELECT uris.link FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'PAPER'
UNION
SELECT uris.link FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'ROCK'
UNION
SELECT uris.link FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'SCISS1ORS'
UNION
SELECT uris.link FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'GAME') AS t1;
   	   								 

/*** Question 2.3:  only rock ***/ 
SELECT t1.* AS keyword2 FROM (SELECT uris.link FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) <> 'PAPER'
INTERSECT
SELECT uris.link FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'ROCK'
INTERSECT
SELECT uris.link FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) <> 'SCISSORS'
INTERSECT
SELECT uris.link FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) <> 'GAME') AS t1;








/** Ranked Retrievals **/
/*** Question 2.4: all ***/
SELECT link, SUM(t1.score) AS sumscore FROM (SELECT uris.link, keywords.score FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'PAPER'
INTERSECT
SELECT uris.link, keywords.score FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'ROCK'
INTERSECT
SELECT uris.link, keywords.score FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'SCISSOR'
INTERSECT
SELECT uris.link, keywords.score FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'GAME') AS t1 GROUP BY link ORDER BY  sumscore DESC
/*** Question 2.5: any ***/
SELECT link, SUM(t1.score) AS sumscore FROM (SELECT uris.link, keywords.score FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'PAPER'
UNION
SELECT uris.link, keywords.score FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'ROCK'
UNION
SELECT uris.link, keywords.score FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'SCISSORS'
UNION
SELECT uris.link, keywords.score FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'GAME') AS t1 GROUP BY link ORDER BY  sumscore DESC

/*** Quesetion 2.6: only rock ***/
SELECT link, SUM(t1.score) AS sumscore FROM (SELECT uris.link, keywords.score FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) <> 'PAPER'
INTERSECT
SELECT uris.link, keywords.score FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) = 'ROCK'
INTERSECT
SELECT uris.link, keywords.score FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) <> 'SCISSOR'
INTERSECT
SELECT uris.link, keywords.score FROM uris INNER JOIN keywords ON uris.id = keywords.id WHERE UPPER(keywords.term) <> 'GAME') AS t1 GROUP BY link ORDER BY  sumscore DESC

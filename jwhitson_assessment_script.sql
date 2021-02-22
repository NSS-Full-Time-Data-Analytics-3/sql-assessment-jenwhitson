--no. 1
--a. 
SELECT grade_id,
	COUNT(id)
FROM author
GROUP BY grade_id
ORDER BY grade_id;
--Answer:
-- 1	623
-- 2	1437
-- 3	2344
-- 4	3288
-- 5	3464


--b.
SELECT grade_id,
	gender.name as gender,
	COUNT(gender_id)
FROM author INNER JOIN gender ON author.gender_id = gender.id
WHERE author.gender_id IN (1, 2)
GROUP BY grade_id, gender.name
ORDER BY grade_id, gender;
-- Answer:
-- 1	"Female"	243
-- 1	"Male"	    163
-- 2	"Female"	605
-- 2	"Male"	    412
-- 3	"Female"	948
-- 3	"Male"	    577
-- 4	"Female"	1241
-- 4	"Male"	    723
-- 5	"Female"	1294
-- 5	"Male"	    757

--c. 2 observations:
--1) Participation generally goes up by grade.
--2) Girls are a lot more likely than boys to participate.  Roughly 1.5-2x as likely. 


--no. 2
WITH love  as (SELECT 
			   	'love' as word,
			   	COUNT(text) as poem_count,
				ROUND(AVG(char_count)::numeric, 2) as avg_char_count
			    FROM poem
				WHERE text ilike '%love%'),
death as (SELECT 'death' as word,
		  	COUNT(text) as poem_count,
			ROUND(AVG(char_count)::numeric, 2) as avg_char_count
			FROM poem
			WHERE text ilike '%death%')
SELECT *
FROM love
UNION ALL
SELECT *
FROM death
ORDER BY word desc;
-- Answer:
-- word		poem_count	avg_char_count
-- "love"	4464		226.79
-- "death"	86			342.53


--no. 3
--a.
SELECT e.name as emotion,
	ROUND(AVG(pe.intensity_percent), 2) as avg_intensity,
	ROUND(AVG(p.char_count), 2) as avg_char_count
FROM poem_emotion as pe INNER JOIN emotion as e 
						ON e.id = pe.emotion_id
						INNER JOIN poem as p ON p.id = pe.poem_id
GROUP BY e.name;
-- Answer:
-- emotion		avg_intensity	avg_char_count
-- "Fear"		45.47			256.27
-- "Sadness"	39.26			247.19
-- "Joy"		47.82			220.99
-- "Anger"		43.57			261.16
-- Angry poems are longest. 
-- Joy poems are shortest.

--b. 
WITH emostats AS (SELECT e.name as emotion,
						ROUND(AVG(pe.intensity_percent), 2) as avg_intensity,
						ROUND(AVG(p.char_count), 2) as avg_char_count
					FROM poem_emotion as pe INNER JOIN emotion as e 
											ON e.id = pe.emotion_id
											INNER JOIN poem as p ON p.id = pe.poem_id
					GROUP BY e.name)
SELECT p.id as poem_id,
	p.text as poem_text,
	pe.intensity_percent as intensity_percent,
	p.char_count as char_count,
	es.avg_char_count as avg_char_count
FROM poem as p INNER JOIN poem_emotion as pe 
					ON p.id = pe.poem_id
				INNER JOIN emotion as e 
					ON e.id = pe.emotion_id
				INNER JOIN emostats as es
					ON es.emotion = e.name
WHERE e.name ilike 'joy'
ORDER BY pe.intensity_percent desc
LIMIT 5;
--Answer: please run query to see answer. it's too long, since it has poem text in it.
--Most joyful poem is about a fluffy dagwood. 
--It seems poems have been categorized as joyful for mentioning the word
--happiness, whether or not they are actually happy. One is about sad
--butterflies; another is about depression.
--Generally, it appears the more emotionally intense poems are much shorter
--than the average.


--no. 4
WITH grade1 AS (SELECT p.id as poem_id,
				p.text as poem_text,
				a.grade_id as grade,
				pe.intensity_percent as intensity_percent,
				g.name as gender
			FROM poem as p INNER JOIN poem_emotion as pe 
								ON p.id = pe.poem_id
							INNER JOIN emotion as e 
								ON e.id = pe.emotion_id
							INNER JOIN author as a
								ON a.id = p.author_id
							INNER JOIN gender as g
								ON g.id = a.gender_id
			WHERE e.name ilike 'anger'
				AND a.grade_id = 1
			ORDER BY pe.intensity_percent desc
			LIMIT 5),
grade5 AS (SELECT p.id as poem_id,
				p.text as poem_text,
				a.grade_id as grade,
				pe.intensity_percent as intensity_percent,
				g.name as gender
			FROM poem as p INNER JOIN poem_emotion as pe 
								ON p.id = pe.poem_id
							INNER JOIN emotion as e 
								ON e.id = pe.emotion_id
							INNER JOIN author as a
								ON a.id = p.author_id
							INNER JOIN gender as g
								ON g.id = a.gender_id
			WHERE e.name ilike 'anger'
				AND a.grade_id = 5
			ORDER BY pe.intensity_percent desc
			LIMIT 5)
SELECT *
FROM grade1
UNION ALL
SELECT *
FROM grade5;
--a. 5th grade is more intense
--b. Way more girls than boys.
--c. Is very difficult to choose. They are all perfect, but
--I think my favorite is #26953 re summer. It is perfectly
--expressive of my own feelings.


--no. 5
--aggregating data on count of emilys, average intensity, and count of each emotion.
WITH counte1 AS (SELECT COUNT(*) as count1, 
				 a.grade_id as grade_id
				 FROM poem_emotion as pe INNER JOIN poem as p
									ON pe.poem_id = p.id
									INNER JOIN author as a
									ON p.author_id = a.id
				WHERE a.name ilike '%emily%'
				AND pe.emotion_id = 1
				GROUP BY a.grade_id),
counte2 AS (SELECT a.grade_id as grade_id,
				COUNT(*) as count2				 
			 FROM poem_emotion as pe INNER JOIN poem as p
								ON pe.poem_id = p.id
								INNER JOIN author as a
								ON p.author_id = a.id
			WHERE a.name ilike '%emily%'
			AND pe.emotion_id = 2
			GROUP BY a.grade_id
		   UNION ALL
		   SELECT 1, 0
		   ORDER BY grade_id),
counte3 AS (SELECT COUNT(*) as count3, 
				 a.grade_id as grade_id
				 FROM poem_emotion as pe INNER JOIN poem as p
									ON pe.poem_id = p.id
									INNER JOIN author as a
									ON p.author_id = a.id
				WHERE a.name ilike '%emily%'
				AND pe.emotion_id = 3
				GROUP BY a.grade_id),
counte4 AS (SELECT COUNT(*) as count4, 
				 a.grade_id as grade_id
				 FROM poem_emotion as pe INNER JOIN poem as p
									ON pe.poem_id = p.id
									INNER JOIN author as a
									ON p.author_id = a.id
				WHERE a.name ilike '%emily%'
				AND pe.emotion_id = 4
				GROUP BY a.grade_id)
SELECT a.grade_id,
	COUNT(DISTINCT(a.id)) as count_emilys,
	COUNT(p.id) as count_emily_poems,
	ROUND(AVG(p.char_count), 2) as avg_char_count,
	ROUND(AVG(pe.intensity_percent), 2) as avg_intensity,
 	MIN(ce1.count1) as count_anger,
	MIN(ce2.count2) as count_fear,
	MIN(ce3.count3) as count_sadness,
	MIN(ce4.count4) as count_joy
FROM author as a INNER JOIN poem as p
						ON a.id = p.author_id
					INNER JOIN poem_emotion as pe
						ON p.id = pe.poem_id
					INNER JOIN emotion as e
						ON e.id = pe.emotion_id
					INNER JOIN counte1 as ce1
						ON ce1.grade_id = a.grade_id
					INNER JOIN counte2 as ce2
						ON ce2.grade_id = a.grade_id
					INNER JOIN counte3 as ce3
						ON ce3.grade_id = a.grade_id
					INNER JOIN counte4 as ce4
						ON ce4.grade_id = a.grade_id
WHERE a.name ilike '%emily%'
GROUP BY a.grade_id;


--pulled all relevant data on all emilys. way easier, can't believe i didn't think of this an hour ago.
SELECT p.id as poem_id,
	a.name as name,
	a.id as author_id,
	a.grade_id as grade_id,
	p.text as poem_text,
	p.char_count as char_count,
	pe.intensity_percent as intensity_percent,
	e.name as emotion
FROM author as a INNER JOIN poem as p
						ON a.id = p.author_id
					INNER JOIN poem_emotion as pe
						ON p.id = pe.poem_id
					INNER JOIN emotion as e
						ON e.id = pe.emotion_id
WHERE a.name ilike '%emily%';


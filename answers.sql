-- ANSWERS TO QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */


SELECT name 
FROM Facilities 
WHERE membercost > 0.0;


/* Q2: How many facilities do not charge a fee to members? */


SELECT COUNT(name) AS have_no_member_fee
FROM Facilities 
WHERE membercost = 0.0;


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */


SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost > 0.0
	AND membercost < (monthlymaintenance * 0.2);


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */


SELECT *
FROM Facilities
WHERE facid IN (1, 5);


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */


SELECT name, monthlymaintenance,
	(CASE WHEN monthlymaintenance < 100 THEN 'cheap'
     ELSE 'expensive' END) AS maintenance_category
FROM Facilities;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */


SELECT firstname, surname
FROM Members
WHERE joindate =
	(SELECT MAX(joindate)
     FROM Members);


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */


SELECT DISTINCT f.name, CONCAT(m.firstname, ' ', m.surname) AS member_name
FROM Bookings b
INNER JOIN Facilities f 
	ON b.facid = f.facid
INNER JOIN Members m
	ON b.memid = m.memid
WHERE f.name LIKE '%TENNIS COURT%'
ORDER BY 1,2;



/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name, CONCAT(m.firstname, ' ', m.surname) AS member_name,
	(CASE WHEN b.memid = 0 THEN (b.slots * f.guestcost)
     ELSE (b.slots * f.membercost) END) AS booking_cost
FROM Bookings AS b
INNER JOIN Facilities AS f
	ON b.facid = f.facid
INNER JOIN Members AS m
	ON b.memid = m.memid
WHERE b.starttime LIKE '2012-09-14%'
GROUP BY b.bookid, b.memid, b.slots, f.name, m.firstname, m.surname, f.membercost, f.guestcost
HAVING (CASE WHEN b.memid = 0 THEN (b.slots * f.guestcost)
     ELSE (b.slots * f.membercost) END) > 30.0
ORDER BY booking_cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT f.name, CONCAT(m.firstname, ' ', m.surname) AS member_name, subquery.booking_cost
FROM Bookings AS b
INNER JOIN Facilities AS f
	ON b.facid = f.facid
INNER JOIN Members AS m
	ON b.memid = m.memid
INNER JOIN (SELECT b.bookid, (CASE WHEN b.memid = 0 THEN (b.slots * f.guestcost)
     				ELSE (b.slots * f.membercost) END) AS booking_cost
     		FROM Bookings AS b
			INNER JOIN Facilities AS f
				ON b.facid = f.facid
			INNER JOIN Members AS m
				ON b.memid = m.memid
            WHERE b.starttime LIKE '2012-09-14%'
			) AS subquery
            	ON b.bookid = subquery.bookid
WHERE subquery.booking_cost > 30.0
ORDER BY booking_cost DESC;
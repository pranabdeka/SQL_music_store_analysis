---SET A---

--Q1.Who is the senior most employee based on the job title?--

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

--Q2. Which countries have the most Invoices?--

select 
	billing_country,
	count(*)
from invoice
group by billing_country order by count(*) desc
limit 1;

--Q3. What are top 3 values of total Invoices?

select
	total
from invoice
order by total desc
limit 3;

select * from Invoice;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select 
	customer.city as city,
	sum(invoice.total) as invoice_total
from customer
join invoice on customer.customer_id=invoice.customer_id
group by city
order by invoice_total desc
limit 1;

or

select
	billing_city as city,
	sum(total) total
from invoice
group by city
order by total desc
limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select
	customer.customer_id,
	customer.first_name first_name,
	customer.last_name last_name,
	sum(invoice.total) total_amt
from customer
join invoice on customer.customer_id=invoice.customer_id
group by first_name, last_name, customer.customer_id
order by total_amt desc
limit 1;

--SET B---

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

--Option1

select distinct
	customer.email,
	customer.first_name,
	customer.last_name,
	genre.name as genre_name
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on invoice_line.track_id=track.track_id
join genre on track.genre_id=genre.genre_id
where genre.name='Rock'
order by customer.email;

--Option2

select distinct
	customer.email,
	customer.first_name,
	customer.last_name
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id

where track_id in (
	select track_id from track
	join genre on track.genre_id=genre.genre_id and genre.name like 'Rock')
order by email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select
	artist.name,
	count(genre.name)
from artist
join album on artist.artist_id=album.artist_id
join track on album.album_id=track.album_id
join genre on track.genre_id=genre.genre_id and genre.name like 'Rock'
group by artist.name
order by count(genre.name) desc
limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select
	name,
	milliseconds	
from track
where milliseconds>(select avg(milliseconds) from track)
order by milliseconds desc;

--SET C--

/* Q1: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */

select
	concat(customer.first_name,customer.last_name) as customer_name,
	artist.name,
	sum(invoice_line.unit_price*invoice_line.quantity) total_spent
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on invoice_line.track_id=track.track_id
join album on track.album_id=album.album_id
join artist on album.artist_id=artist.artist_id
group by customer_name, artist.name
order by customer_name,total_spent desc;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with popular_genre as
(select
	invoice.billing_country,
	genre.name,
	sum(invoice_line.quantity) sale_unit,
	row_number() over(partition by invoice.billing_country order by count(*) desc) as row_num
from invoice
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on invoice_line.track_id=track.track_id
join genre on track.genre_id=genre.genre_id
group by invoice.billing_country, genre.name
order by invoice.billing_country, sale_unit desc
)
select 
	billing_country,
	name,
	sale_unit
from popular_genre where row_num<=1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with most_spent as
(select
	customer.country,
	customer.first_name,
	customer.last_name,
	sum(invoice.total) as total,
	row_number() over (partition by country order by sum(invoice.total) desc) as row_num
from customer
join invoice on customer.customer_id=invoice.customer_id
group by customer.first_name, customer.last_name, customer.country
order by country)
select * from most_spent where row_num=1;

	
	

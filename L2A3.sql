create database FootballTicketBooking

-- create user role
CREATE TYPE user_role AS ENUM ('Football Fan', 'Ticket Manager');
CREATE TYPE tournament AS ENUM (
  'Champions League',
  'Premier League', 
  'Serie A',
  'La Liga'
);

create type match_status as enum (
  'Available', 'Selling Fast', 'Sold Out', 'Postponed'
)
create type payment_status_enum as enum (
  'Pending', 'Confirmed', 'Cancelled', 'Refunded'
)

-- DROP TABLES IF THEY ALREADY EXIST TO PREVENT CONFLICTS
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Matches;
DROP TABLE IF EXISTS Users;

-- =========================================================================
-- 1. CREATE USERS TABLE
-- =========================================================================
CREATE TABLE Users (
    user_id serial primary key,
    full_name varchar(75),
    email varchar(255) unique,
    role user_role,
    phone_number varchar(15),
    createdAt timestamp default now()
);

-- =========================================================================
-- 2. CREATE MATCHES TABLE
-- =========================================================================
CREATE TABLE Matches (
    match_id serial primary key,
    fixture varchar(75),
    tournament_category tournament,
    base_ticket_price decimal(10,2) check (base_ticket_price >= 0),
    match_status match_status,
   createdAt timestamp default now()
);

-- =========================================================================
-- 3. CREATE BOOKINGS TABLE
-- =========================================================================
CREATE TABLE Bookings (
    booking_id serial primary key,
    user_id int references users(user_id),
    match_id int references matches(match_id),
    seat_number varchar(15),
    payment_status payment_status_enum,
    total_cost decimal(10, 2),
   createdAt timestamp default now()
);


-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO USERS
-- =========================================================================
INSERT INTO Users (user_id, full_name, email, role, phone_number) VALUES
(1, 'Tanvir Rahman', 'tanvir@mail.com', 'Football Fan', '+8801711111111'),
(2, 'Asif Haque', 'asif@mail.com', 'Football Fan', '+8801722222222'),
(3, 'Sajjad Rahman', 'sajjad@mail.com', 'Ticket Manager', '+8801733333333'),
(4, 'Jannat Ara', 'jannat@mail.com', 'Football Fan', NULL);

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO MATCHES
-- =========================================================================
INSERT INTO Matches (match_id, fixture, tournament_category, base_ticket_price, match_status) VALUES
(101, 'Real Madrid vs Barcelona', 'Champions League', 150.00, 'Available'),
(102, 'Man City vs Liverpool', 'Premier League', 120.00, 'Selling Fast'),
(103, 'Bayern Munich vs PSG', 'Champions League', 130.00, 'Available'),
(104, 'AC Milan vs Inter Milan', 'Serie A', 90.00, 'Sold Out'),
(105, 'Juventus vs Roma', 'Serie A', 80.00, 'Available');

-- =========================================================================
-- DATA SEEDING: INSERT SAMPLE DATA INTO BOOKINGS
-- =========================================================================
INSERT INTO Bookings (booking_id, user_id, match_id, seat_number, payment_status, total_cost) VALUES
(501, 1, 101, 'A-12', 'Confirmed', 150.00),
(502, 1, 102, 'B-04', 'Confirmed', 120.00),
(503, 2, 101, 'A-13', 'Confirmed', 150.00),
(504, 2, 101, NULL, NULL, 150.00),
(505, 3, 102, 'C-20', 'Pending', 120.00);

-- Query 1:
select match_id, fixture, base_ticket_price from matches where tournament_category = 'Champions League' and match_status = 'Available'

-- Query 2:
select user_id, full_name, email from users where full_name ilike 'Tanvir%' or full_name ilike '%Haque%';

-- Query 3:
select booking_id, user_id, match_id, coalesce(payment_status::varchar(10), 'Action Required') as systematic_status from bookings where payment_status is null

-- Query 4:
select b.booking_id, u.full_name , m.fixture, b.total_cost from bookings as b inner join users as u on b.user_id = u.user_id inner join matches as m on b.match_id = m.match_id

-- Query 5:
select u.user_id, u.full_name, b.booking_id from users as u left join bookings as b on b.user_id = u.user_id

-- Query 6:
select booking_id, match_id, total_cost from bookings where total_cost > (select avg(total_cost) from bookings)

-- Query 7:
select match_id, fixture, base_ticket_price from matches order by base_ticket_price desc limit 2 offset 1

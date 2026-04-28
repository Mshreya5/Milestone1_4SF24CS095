CREATE TABLE Users (
user_id INT PRIMARY KEY,
name VARCHAR(100),
email VARCHAR(100) UNIQUE
);

INSERT INTO Users VALUES
(1, 'Shreya', 'shreya@gmail.com'),
(2, 'Rahul', 'rahul@gmail.com');

CREATE TABLE Movies (
movie_id INT PRIMARY KEY,
movie_name VARCHAR(100)
);

INSERT INTO Movies VALUES
(1, 'Inception'),
(2, 'Interstellar');

CREATE TABLE Theatres (
theatre_id INT PRIMARY KEY,
theatre_name VARCHAR(100),
theatre_location VARCHAR(100)
);

INSERT INTO Theatres VALUES
(1, 'PVR Cinemas', 'Bangalore'),
(2, 'INOX', 'Mysore');

CREATE TABLE Screens (
screen_id INT PRIMARY KEY,
theatre_id INT,
screen_number INT,
FOREIGN KEY (theatre_id) REFERENCES Theatres(theatre_id)
);

INSERT INTO Screens VALUES
(1, 1, 1),
(2, 1, 2);

CREATE TABLE Seats (
seat_id INT PRIMARY KEY,
screen_id INT,
seat_number VARCHAR(10),
seat_type VARCHAR(20),
FOREIGN KEY (screen_id) REFERENCES Screens(screen_id)
);

INSERT INTO Seats VALUES
(1, 1, 'A1', 'REGULAR'),
(2, 1, 'A2', 'REGULAR'),
(3, 1, 'A3', 'VIP');

CREATE TABLE Shows (
show_id INT PRIMARY KEY,
movie_id INT,
screen_id INT,
show_datetime DATETIME,
FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
FOREIGN KEY (screen_id) REFERENCES Screens(screen_id)
);

INSERT INTO Shows VALUES
(1, 1, 1, '2026-04-28 10:00:00'),
(2, 2, 2, '2026-04-28 14:00:00');

CREATE TABLE Show_Seats (
show_id INT,
seat_id INT,
status VARCHAR(20),
PRIMARY KEY (show_id, seat_id),
FOREIGN KEY (show_id) REFERENCES Shows(show_id),
FOREIGN KEY (seat_id) REFERENCES Seats(seat_id)
);

INSERT INTO Show_Seats VALUES
(1, 1, 'AVAILABLE'),
(1, 2, 'AVAILABLE'),
(1, 3, 'BOOKED');

CREATE TABLE Bookings (
booking_id INT PRIMARY KEY,
show_id INT,
booking_time DATETIME,
payment_status VARCHAR(20),
FOREIGN KEY (show_id) REFERENCES Shows(show_id)
);

INSERT INTO Bookings VALUES
(1, 1, '2026-04-28 09:00:00', 'CONFIRMED');

CREATE TABLE Booking_Users (
booking_id INT,
user_id INT,
PRIMARY KEY (booking_id, user_id),
FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

INSERT INTO Booking_Users VALUES
(1, 1);

CREATE TABLE Booking_Seats (
booking_id INT,
seat_id INT,
user_id INT,
PRIMARY KEY (booking_id, seat_id, user_id),
FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
FOREIGN KEY (seat_id) REFERENCES Seats(seat_id),
FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

INSERT INTO Booking_Seats VALUES
(1, 3, 1);

Query 1: Retrieve bookings for a user within a date range

SELECT
b.booking_id,
u.name,
m.movie_name,
t.theatre_name,
s.show_datetime,
GROUP_CONCAT(se.seat_number) AS seats
FROM Bookings b
JOIN Booking_Users bu ON b.booking_id = bu.booking_id
JOIN Users u ON bu.user_id = u.user_id
JOIN Shows s ON b.show_id = s.show_id
JOIN Movies m ON s.movie_id = m.movie_id
JOIN Screens sc ON s.screen_id = sc.screen_id
JOIN Theatres t ON sc.theatre_id = t.theatre_id
JOIN Booking_Seats bs ON b.booking_id = bs.booking_id
JOIN Seats se ON bs.seat_id = se.seat_id
WHERE u.user_id = 1
AND b.booking_time BETWEEN '2026-04-01' AND '2026-04-30'
GROUP BY b.booking_id;

Query 2: Most frequently booked movie

SELECT
m.movie_name,
COUNT(DISTINCT b.booking_id) AS total_bookings
FROM Bookings b
JOIN Shows s ON b.show_id = s.show_id
JOIN Movies m ON s.movie_id = m.movie_id
GROUP BY m.movie_id
ORDER BY total_bookings DESC
LIMIT 1;

Query 3: Shows with booked and available seats

SELECT
s.show_id,
m.movie_name,
s.show_datetime,
SUM(CASE WHEN ss.status = 'BOOKED' THEN 1 ELSE 0 END) AS booked_seats,
SUM(CASE WHEN ss.status = 'AVAILABLE' THEN 1 ELSE 0 END) AS available_seats
FROM Shows s
JOIN Movies m ON s.movie_id = m.movie_id
JOIN Screens sc ON s.screen_id = sc.screen_id
JOIN Theatres t ON sc.theatre_id = t.theatre_id
JOIN Show_Seats ss ON s.show_id = ss.show_id
WHERE t.theatre_id = 1
AND DATE(s.show_datetime) = '2026-04-28'
GROUP BY s.show_id, m.movie_name, s.show_datetime;

Transaction for booking operation
BEGIN;
SELECT COUNT(*) AS available_count
FROM Show_Seats
WHERE show_id = 1
AND seat_id IN (1,2)
AND status = 'AVAILABLE';
If available_count is less than required seats, the transaction is rolled back.
INSERT INTO Bookings (booking_id, show_id, booking_time, payment_status)
VALUES (2, 1, CURRENT_TIMESTAMP, 'PENDING');
INSERT INTO Booking_Users (booking_id, user_id)
VALUES (2, 1);
INSERT INTO Booking_Seats (booking_id, seat_id, user_id)
VALUES (2, 1, 1),
(2, 2, 1);
UPDATE Show_Seats
SET status = 'BOOKED'
WHERE show_id = 1
AND seat_id IN (1,2);
UPDATE Bookings
SET payment_status = 'CONFIRMED'
WHERE booking_id = 2;
COMMIT;

CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100),
    user_email VARCHAR(100) UNIQUE
);

CREATE TABLE Movies (
    movie_id INT PRIMARY KEY,
    movie_name VARCHAR(100)
);

CREATE TABLE Theatres (
    theatre_id INT PRIMARY KEY,
    theatre_name VARCHAR(100),
    theatre_location VARCHAR(100)
);

CREATE TABLE Screens (
    screen_id INT PRIMARY KEY,
    theatre_id INT,
    screen_number INT,
    FOREIGN KEY (theatre_id) REFERENCES Theatres(theatre_id)
);

CREATE TABLE Seats (
    seat_id INT PRIMARY KEY,
    screen_id INT,
    seat_number VARCHAR(10),
    seat_type VARCHAR(20),
    FOREIGN KEY (screen_id) REFERENCES Screens(screen_id)
);

CREATE TABLE Shows (
    show_id INT PRIMARY KEY,
    movie_id INT,
    screen_id INT,
    show_datetime DATETIME,
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (screen_id) REFERENCES Screens(screen_id)
);

CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    user_id INT,
    show_id INT,
    booking_time DATETIME,
    total_price DECIMAL(10,2),
    payment_status VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (show_id) REFERENCES Shows(show_id)
);

CREATE TABLE Booking_Seats (
    booking_id INT,
    seat_id INT,
    PRIMARY KEY (booking_id, seat_id),
    FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id),
    FOREIGN KEY (seat_id) REFERENCES Seats(seat_id)
);

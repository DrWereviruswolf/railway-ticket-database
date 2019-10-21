CREATE TABLE Train(
    t_tid       CHAR(6)
);
--WARNING

CREATE TABLE Seat(
    seat_type CHAR(8) PRIMARY KEY
);

CREATE TABLE Station(
    s_sid       INTEGER
);

CREATE TABLE TrainSchedule(
    ts_tid             CHAR(6),
    ts_sid             integer,
    ts_seat_type       CHAR(8),
    ts_part_TIME       TIME,
    ts_arrival_TIME    TIME,
    ts_price           DECIMAL(18, 2),
    FOREIGN KEY (ts_tid) REFERENCES Train(t_tid),
    FOREIGN KEY (ts_sid) REFERENCES Station(ts_sid),
    FOREIGN KEY (ts_seat_type) REFERENCES Seat(seat_type),
    PRIMARY KEY (ts_tid, ts_sid)
);

CREATE TABLE TrainByDate(
    tbd_tid             CHAR(6),
    tbd_sid             INTEGER,
    tbd_seat_type       CHAR(8),
    tbd_part_DATE       DATE,
    tbd_seat_left       INTEGER,
    FOREIGN KEY (tbd_tid, tbd_seat_type) REFERENCES TrainSchedule(ts_tid, ts_sid, ts_seat_type),
    PRIMARY KEY (tbd_tid, tbd_sid, tbd_part_DATE)
);
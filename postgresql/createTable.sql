CREATE TYPE TrainType as enum(
    'C',
    'D',
    'G',
    'K',
    'T',
    'Y',
    'Z',
    '0'
);

CREATE TYPE Access as enum(
    'Passenger',
    'Administrator'
);

CREATE TYPE Status as enum(
    'Reserved',
    'Processing',
    'Unfinished',
    'Finished',
    'Cancelled'
);

CREATE TYPE SeatType as enum(
    'hard_seat',
    'soft_seat',
    'hard_upper', 
    'hard_medium', 
    'hard_lower', 
    'soft_upper',
    'soft_lower'
);

CREATE TABLE Train(
    tid       CHAR(6) PRIMARY KEY,
    tname     TrainType
);
--WARNING

--CREATE TABLE Seat(
  --  seat_type CHAR(8) PRIMARY KEY
--);

CREATE TABLE Station(
    s_sid       INTEGER PRIMARY KEY,
    s_sname     VARCHAR(20),
    s_cityname  VARCHAR(20)
);

--Static data
CREATE TABLE TrainSchedule(
    ts_tid             CHAR(6),
    ts_sid             INTEGER,
    ts_seat_type       SeatType,
    ts_arrival_time    TIME,
    ts_part_time       TIME,
    ts_price           DECIMAL(18, 2),
    FOREIGN KEY (ts_tid) REFERENCES Train(tid),
    FOREIGN KEY (ts_sid) REFERENCES Station(s_sid),
    PRIMARY KEY (ts_tid, ts_sid, ts_seat_type)
);

CREATE TABLE Schedule(
    sc_tid              CHAR(6),
    sc_sid              INTEGER,
    sc_arrival_time     TIME,
    sc_part_time        TIME,
    PRIMARY KEY (sc_tid, sc_sid),
    FOREIGN KEY (sc_tid) REFERENCES Train(tid),
    FOREIGN KEY (sc_sid) REFERENCES Station(s_sid)  
);

CREATE TABLE Price(
    p_tid               CHAR(6),
    p_sid               INTEGER,
    p_seat_type         SeatType,
    p_price             DECIMAL(18, 2),
    FOREIGN KEY (p_tid) REFERENCES Train(tid),
    FOREIGN KEY (p_sid) REFERENCES Station(s_sid),
    PRIMARY KEY (p_tid, p_sid, p_seat_type)
);
--Dynamic data
CREATE TABLE TrainByDate(
    tbd_tid             CHAR(6),
    tbd_sid             INTEGER,
    tbd_seat_type       SeatType,
    tbd_part_date       DATE,
    tbd_seat_left       INTEGER,
    FOREIGN KEY (tbd_tid, tbd_sid, tbd_seat_type) REFERENCES TrainSchedule(ts_tid, ts_sid, ts_seat_type),
    PRIMARY KEY (tbd_tid, tbd_sid, tbd_seat_type, tbd_part_date)
);

CREATE TABLE WebUser(
    u_uid           INTEGER PRIMARY KEY,
    u_fullname      VARCHAR(20),
    u_idcard        CHAR(18),
    u_phone         CHAR(11),
    u_credit        CHAR(16),
    u_nickname      VARCHAR(20),
    u_account       DECIMAL(18, 2),
    u_access        Access
);

CREATE TABLE Reservation (
  r_rid         INTEGER PRIMARY KEY,
  r_uid         INTEGER,
  r_tid         CHAR(6),
  r_part_sid    INTEGER,
  r_arrival_sid INTEGER,
  r_seat_type   SeatType,
  r_part_date   DATE,
  r_status      Status,
  FOREIGN KEY (r_uid)           REFERENCES WebUser(u_uid),
  FOREIGN KEY (r_tid)           REFERENCES Train(tid),
  FOREIGN KEY (r_part_sid)      REFERENCES Station(s_sid),
  FOREIGN KEY (r_arrival_sid)   REFERENCES Station(s_sid)
);

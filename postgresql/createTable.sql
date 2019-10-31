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

CREATE TYPE Privilege as enum(
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
--TODO

CREATE TABLE Train(
    tid       CHAR(6),
    tname     TrainType,
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
    ts_seat_type       VARCHAR(8),
    ts_arrival_time    TIME,
    ts_part_time       TIME,
    ts_price           DECIMAL(18, 2),
    FOREIGN KEY (ts_tid) REFERENCES Train(t_tid),
    FOREIGN KEY (ts_sid) REFERENCES Station(s_sid),
    PRIMARY KEY (ts_tid, ts_sid, ts_seat_type)
);

--Dynamic data
CREATE TABLE TrainByDate(
    tbd_tid             CHAR(6),
    tbd_sid             INTEGER,
    tbd_seat_type       VARCHAR(8),
    tbd_part_date       DATE,
    tbd_seat_left       INTEGER,
    FOREIGN KEY (tbd_tid, tbd_sid, tbd_seat_type) REFERENCES TrainSchedule(ts_tid, ts_sid, ts_seat_type),
    PRIMARY KEY (tbd_tid, tbd_sid, tbd_seat_type, tbd_part_date)
);

CREATE TABLE User (
    u_uid           INTEGER PRIMARY KEY,
    u_fullname      VARCHAR(20),
    u_idcard        CHAR(18),
    u_phone         CHAR(11),
    u_credit        CHAR(16),
    u_nickname      VARCHAR(20),
    u_account       DECIMAL(18, 2),
    u_access        Privilege
);

CREATE TABLE Reservation (
  r_rid         INTEGER PRIMARY KEY,
  r_uid         INTEGER,
  r_tid         CHAR(6),
  r_part_sid    INTEGER,
  r_arrival_sid INTEGER,
  r_seat_type   VARCHAR(8),
  r_part_date   DATE,
  r_status      Status,
  FOREIGN KEY (r_uid)           REFERENCES User(u_uid),
  FOREIGN KEY (r_tid)           REFERENCES Train(tid),
  FOREIGN KEY (r_part_sid)      REFERENCES Station(sid),
  FOREIGN KEY (r_arrival_sid)   REFERENCES Station(sid)
);

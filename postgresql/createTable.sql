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

--CREATE TABLE Train(
  --  tid       CHAR(6) PRIMARY KEY,
  --  tname     TrainType
--);
--WARNING

--CREATE TABLE Seat(
  --  seat_type CHAR(8) PRIMARY KEY
--);

CREATE TABLE Station(
    s_sid       INTEGER,
    s_sname     VARCHAR(20)  PRIMARY KEY,
    s_cityname  VARCHAR(20)
);

--Static data 7
CREATE TABLE TrainSchedule(
    ts_tid             CHAR(6),
    ts_order           INTEGER,
    ts_sname           VARCHAR(20),
    ts_arrival_time    TIME,
    ts_part_time       TIME,
    ts_price           DECIMAL(18, 2),
    ts_seat_type       SeatType,
    FOREIGN KEY (ts_sname) REFERENCES Station(s_sname),
    PRIMARY KEY (ts_tid, ts_sname, ts_seat_type)
);

--Dynamic data 6 [0:2]
CREATE TABLE TrainByDate(
    tbd_tid             CHAR(6),
    tbd_order           INTEGER,
    tbd_sname           VARCHAR(20),
    tbd_part_date       DATE,
    tbd_seat_left       INTEGER,
    tbd_seat_type       SeatType,
    FOREIGN KEY (tbd_tid, tbd_sname, tbd_seat_type) REFERENCES TrainSchedule(ts_tid, ts_sname, ts_seat_type),
    PRIMARY KEY (tbd_tid, tbd_sname, tbd_seat_type, tbd_part_date)
);

CREATE TABLE WebUser(
    u_uid           VARCHAR(32) PRIMARY KEY,
    u_fullname      VARCHAR(20),
    u_idcard        CHAR(18),
    u_phone         CHAR(11),
    u_credit        CHAR(16),
    u_nickname      VARCHAR(20),
    u_account       DECIMAL(18, 2),
    u_access        Access
);

CREATE TABLE Reservation (
  r_rid             VARCHAR(32) PRIMARY KEY,
  r_uid             INTEGER,
  r_tid             CHAR(6),
  r_part_sname      VARCHAR(20),
  r_arrival_sname   VARCHAR(20),
  r_seat_type       SeatType,
  r_part_date       DATE,
  r_status          Status,
  FOREIGN KEY (r_uid)             REFERENCES WebUser(u_uid),
  FOREIGN KEY (r_part_sname)      REFERENCES Station(s_sname),
  FOREIGN KEY (r_arrival_sname)   REFERENCES Station(s_sname)
);

SELECT P.ts_tid AS temp_tid, P.ts_seat_type AS temp_seat_type, P.ts_part_time AS temp_part_time,
A.ts_arrival_time AS temp_arrival_time, P.ts_price AS temp_part_price, A.ts_price AS temp_arrival_price,
P.ts_sname AS temp_part_sname, A.ts_sname AS temp_arrival_sname, (
  SELECT MIN(tbd_seat_left)
  FROM TrainByDate
  WHERE tbd_tid = P.ts_tid AND tbd_seat_type = P.ts_seat_type
  AND tbd_order >= P.ts_order AND tbd_order < A.ts_order
  AND tbd_part_date = DATE '2019-11-14'
) AS temp_seat_left
FROM (
  SELECT *
  FROM TrainSchedule, Station
  WHERE ts_sname = s_sname
  AND s_cityname = '南京' AND ts_part_time >= '00:00:00'
  AND ts_price > 0
) AS P,
(
  SELECT * 
  FROM TrainSchedule, Station
  WHERE ts_sname = s_sname
  AND s_cityname = '北京'
  AND ts_price > 0
) AS A
WHERE P.ts_tid = A.ts_tid AND P.ts_seat_type = A.ts_seat_type
AND P.ts_seat_type = 'hard_seat' AND P.ts_order < A.ts_order
AND (
  SELECT MIN(tbd_seat_left)
  FROM TrainByDate
  WHERE tbd_tid = P.ts_tid AND tbd_seat_type = P.ts_seat_type
  AND tbd_order >= P.ts_order AND tbd_order < A.ts_order
  AND tbd_part_date = DATE '2019-11-14'
) > 0
ORDER BY A.ts_price - P.ts_price, (A.ts_arrival_time - P.ts_part_time) + (INTERVAL '24 h' * (SELECT (
  CASE WHEN A.ts_arrival_time < P.ts_part_time THEN
    1
  ELSE
    0
  END
))), P.ts_part_time
LIMIT 10;

UPDATE TrainByDate
SET tbd_seat_left = 5
WHERE tbd_tid = 'G2' AND tbd_order = 2 AND tbd_seat_type = 'soft_seat' AND tbd_part_date = DATE '2019-11-14';

SELECT Train1.temp_tid AS temp_tid, Train2.temp_tid AS temp_tid2, 
Train1.temp_seat_type AS temp_seat_type, Train1.temp_part_time AS temp_part_time, 
Train1.temp_arrival_time AS temp_arrival_time, Train2.temp_part_time AS temp_part_time2, 
Train2.temp_arrival_time AS temp_arrival_time2, Train1.temp_part_price AS temp_part_price, 
Train1.temp_arrival_price AS temp_arrival_price, Train2.temp_part_price AS temp_part_price2, 
Train2.temp_arrival_price AS temp_arrival_price2, Train1.temp_part_sname AS temp_part_sname, 
Train1.temp_arrival_sname AS temp_arrival_sname, Train2.temp_part_sname AS temp_part_sname2, 
Train2.temp_arrival_sname AS temp_arrival_sname2, (
    SELECT MIN(tbd_seat_left)
    FROM TrainByDate
    WHERE tbd_tid = Train1.temp_tid AND tbd_seat_type = Train1.temp_seat_type
    AND tbd_order >= Train1.temp_part_order AND tbd_order < Train1.temp_arrival_order
    AND tbd_part_date = DATE '2019-11-14'
) AS temp_seat_left, (
    SELECT MIN(tbd_seat_left)
    FROM TrainByDate
    WHERE tbd_tid = Train2.temp_tid AND tbd_seat_type = Train2.temp_seat_type
    AND tbd_order >= Train2.temp_part_order AND tbd_order < Train2.temp_arrival_order
    AND (
        Train1.temp_arrival_time > Train1.temp_part_time AND tbd_part_date = DATE '2019-11-14'
        OR Train1.temp_arrival_time < Train1.temp_part_time AND tbd_part_date = DATE '2019-11-14' + 1
    )
) AS temp_seat_left2
FROM ( 
SELECT P.ts_tid AS temp_tid, P.ts_seat_type AS temp_seat_type, P.ts_part_time AS temp_part_time, 
A.ts_arrival_time AS temp_arrival_time, P.ts_price AS temp_part_price, A.ts_price AS temp_arrival_price, 
P.ts_sname AS temp_part_sname, A.ts_sname AS temp_arrival_sname, S.s_cityname AS temp_arrival_cityname,
P.ts_order AS temp_part_order, A.ts_order AS temp_arrival_order
FROM ( 
    SELECT * 
    FROM TrainSchedule, Station 
    WHERE ts_sname = s_sname 
    AND s_cityname = '南京' AND ts_part_time >= TIME '00:00:00'
    AND ts_price > 0
) AS P, 
( 
    SELECT *  
    FROM TrainSchedule, Station 
    WHERE ts_sname = s_sname AND ts_price > 0
) AS A, 
Station AS S 
WHERE A.ts_sname = S.s_sname AND P.ts_tid = A.ts_tid AND P.ts_seat_type = A.ts_seat_type 
AND P.ts_seat_type = 'soft_seat' AND P.ts_order < A.ts_order
) AS Train1, ( 
SELECT P.ts_tid AS temp_tid, P.ts_seat_type AS temp_seat_type, P.ts_part_time AS temp_part_time, 
A.ts_arrival_time AS temp_arrival_time, P.ts_price AS temp_part_price, A.ts_price AS temp_arrival_price, 
P.ts_sname AS temp_part_sname, A.ts_sname AS temp_arrival_sname,
P.ts_order AS temp_part_order, A.ts_order AS temp_arrival_order
FROM ( 
    SELECT * 
    FROM TrainSchedule, Station 
    WHERE ts_sname = s_sname AND ts_price > 0
) AS P, 
( 
    SELECT *  
    FROM TrainSchedule, Station 
    WHERE ts_sname = s_sname 
    AND s_cityname = '北京'
    AND ts_price > 0
) AS A
WHERE P.ts_tid = A.ts_tid AND P.ts_seat_type = A.ts_seat_type 
AND P.ts_seat_type = 'soft_seat' AND P.ts_order < A.ts_order
) AS Train2,
Station AS S
WHERE S.s_sname = Train2.temp_part_sname AND (( 
    Train2.temp_part_time > Train1.temp_arrival_time AND Train2.temp_part_time - Train1.temp_arrival_time <= INTERVAL '4 h' 
    AND (Train2.temp_part_sname = Train1.temp_arrival_sname AND Train2.temp_part_time - Train1.temp_arrival_time >= INTERVAL '1 h' 
    OR (Train2.temp_part_sname <> Train1.temp_arrival_sname AND S.s_cityname = Train1.temp_arrival_cityname 
    AND Train2.temp_part_time - Train1.temp_arrival_time >= INTERVAL '2 h')) 
    ) OR ( 
    Train2.temp_part_time < Train1.temp_arrival_time AND Train2.temp_part_time - Train1.temp_arrival_time + INTERVAL '24 h' <= INTERVAL '4 h' 
    AND (Train2.temp_part_sname = Train1.temp_arrival_sname AND Train2.temp_part_time - Train1.temp_arrival_time + INTERVAL '24 h' >= INTERVAL '1 h' 
    OR (Train2.temp_part_sname <> Train1.temp_arrival_sname AND S.s_cityname = Train1.temp_arrival_cityname 
    AND Train2.temp_part_time - Train1.temp_arrival_time + INTERVAL '24 h' >= INTERVAL '2 h')) 
)) AND (
    SELECT MIN(tbd_seat_left)
    FROM TrainByDate
    WHERE tbd_tid = Train1.temp_tid AND tbd_seat_type = Train1.temp_seat_type
    AND tbd_order >= Train1.temp_part_order AND tbd_order < Train1.temp_arrival_order
    AND tbd_part_date = DATE '2019-11-14'
) > 0 AND (
    SELECT MIN(tbd_seat_left)
    FROM TrainByDate
    WHERE tbd_tid = Train2.temp_tid AND tbd_seat_type = Train2.temp_seat_type
    AND tbd_order >= Train2.temp_part_order AND tbd_order < Train2.temp_arrival_order
    AND (
        Train1.temp_arrival_time > Train1.temp_part_time AND tbd_part_date = DATE '2019-11-14'
        OR Train1.temp_arrival_time < Train1.temp_part_time AND tbd_part_date = DATE '2019-11-14' + 1
    )
) > 0;

INSERT INTO WebUser
VALUES ('abcdefg', 'abc', '123456789987654321', '12345678909', '1234567887654321', 'abc', 0, 'Passenger');

SELECT ts_sname, ts_arrival_time, ts_part_time, ts_price, tbd_seat_left
FROM TrainSchedule, TrainByDate
WHERE tbd_tid = ts_tid AND tbd_sname = ts_sname AND tbd_seat_type = ts_seat_type
AND tbd_tid = 'Z338' AND tbd_part_date = DATE '2019-11-14' AND tbd_seat_type = 'hard_upper';

SELECT ts_sname, ts_arrival_time, ts_part_time, ts_price, (
    SELECT MIN(tbd_seat_left)
    FROM TrainSchedule AS TS2, TrainByDate
    WHERE TS2.ts_tid = TS1.ts_tid AND TS2.ts_seat_type = TS1.ts_seat_type
    AND tbd_part_date = DATE '2019-11-14' AND TS2.ts_order < TS1.ts_order
) AS temp_seat_left
FROM TrainSchedule AS TS1, TrainByDate
WHERE tbd_tid = ts_tid AND tbd_sname = ts_sname AND tbd_seat_type = ts_seat_type
AND tbd_tid = 'G2' AND tbd_part_date = DATE '2019-11-14' AND tbd_seat_type = 'hard_seat'
ORDER BY TS1.ts_order;
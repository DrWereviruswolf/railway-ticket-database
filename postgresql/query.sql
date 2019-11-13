SELECT ts_sname, ts_arrival_time, ts_part_time, ts_price, (
  SELECT MIN(tbd_seat_left)
  FROM TrainSchedule AS TS2, TrainByDate
  WHERE TS2.ts_tid = TS1.ts_tid AND TS2.ts_seat_type = TS1.ts_seat_type
  AND tbd_part_date = $2 AND TS2.ts_order < TS1.ts_order
) AS temp_seat_left
FROM TrainSchedule AS TS1, TrainByDate
WHERE tbd_tid = ts_tid AND tbd_sname = ts_sname AND tbd_seat_type = ts_seat_type
AND tbd_tid = $1 AND tbd_part_date = $2 AND tbd_seat_type = $3
ORDER BY TS1.ts_order;

SELECT P.ts_tid AS temp_tid, P.ts_seat_type AS temp_seat_type, P.ts_part_time AS temp_part_time,
A.ts_arrival_time AS temp_arrival_time, P.ts_price AS temp_part_price, A.ts_price AS temp_arrival_price,
P.ts_sname AS temp_part_sname, A.ts_sname AS temp_arrival_sname, (
  SELECT MIN(tbd_seat_left)
  FROM TrainByDate
  WHERE tbd_tid = P.ts_tid AND tbd_seat_type = P.ts_seat_type
  AND tbd_order >= P.ts_order AND tbd_order < A.ts_order
  AND tbd_part_date = $3
) AS temp_seat_left
FROM (
  SELECT *
  FROM TrainSchedule, Station
  WHERE ts_sname = s_sname
  AND s_cityname = $1 AND ts_part_time >= $4
  AND ts_price > 0
) AS P,
(
  SELECT *
  FROM TrainSchedule, Station
  WHERE ts_sname = s_sname
  AND s_cityname = $2
  AND ts_price > 0
) AS A
WHERE P.ts_tid = A.ts_tid AND P.ts_seat_type = A.ts_seat_type
AND P.ts_seat_type = $5 AND P.ts_order < A.ts_order
AND (
  SELECT MIN(tbd_seat_left)
  FROM TrainByDate
  WHERE tbd_tid = P.ts_tid AND tbd_seat_type = P.ts_seat_type
  AND tbd_order >= P.ts_order AND tbd_order < A.ts_order
  AND tbd_part_date = $3
) > 0
ORDER BY A.ts_price - P.ts_price, (A.ts_arrival_time - P.ts_part_time) + (INTERVAL'24 h' * (SELECT (
  CASE WHEN A.ts_arrival_time < P.ts_part_time THEN
    1
  ELSE
    0
  END
))), P.ts_part_time
LIMIT 10;

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
    AND tbd_part_date = $3
) AS temp_seat_left, (
    SELECT MIN(tbd_seat_left)
    FROM TrainByDate
    WHERE tbd_tid = Train2.temp_tid AND tbd_seat_type = Train2.temp_seat_type
    AND tbd_order >= Train2.temp_part_order AND tbd_order < Train2.temp_arrival_order
    AND (
        Train1.temp_arrival_time > Train1.temp_part_time AND tbd_part_date = $3
        OR Train1.temp_arrival_time < Train1.temp_part_time AND tbd_part_date = $3 + 1
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
    AND s_cityname = $1 AND ts_part_time >= $4
    AND ts_price > 0
) AS P,
(
    SELECT *
    FROM TrainSchedule, Station
    WHERE ts_sname = s_sname AND ts_price > 0
) AS A,
Station AS S
WHERE A.ts_sname = S.s_sname AND P.ts_tid = A.ts_tid AND P.ts_seat_type = A.ts_seat_type
AND P.ts_seat_type = $5 AND P.ts_order < A.ts_order
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
    AND s_cityname = $2
    AND ts_price > 0
) AS A
WHERE P.ts_tid = A.ts_tid AND P.ts_seat_type = A.ts_seat_type
AND P.ts_seat_type = $5 AND P.ts_order < A.ts_order
) AS Train2,
Station AS S
WHERE S.s_sname = Train2.temp_part_sname AND ((
    Train2.temp_part_time > Train1.temp_arrival_time AND Train2.temp_part_time - Train1.temp_arrival_time <= INTERVAL'4 h'
    AND (Train2.temp_part_sname = Train1.temp_arrival_sname AND Train2.temp_part_time - Train1.temp_arrival_time >= INTERVAL'1 h'
    OR (Train2.temp_part_sname <> Train1.temp_arrival_sname AND S.s_cityname = Train1.temp_arrival_cityname
    AND Train2.temp_part_time - Train1.temp_arrival_time >= INTERVAL'2 h'))
    ) OR (
    Train2.temp_part_time < Train1.temp_arrival_time AND Train2.temp_part_time - Train1.temp_arrival_time + INTERVAL'24 h' <= INTERVAL'4 h'
    AND (Train2.temp_part_sname = Train1.temp_arrival_sname AND Train2.temp_part_time - Train1.temp_arrival_time + INTERVAL'24 h' >= INTERVAL'1 h'
    OR (Train2.temp_part_sname <> Train1.temp_arrival_sname AND S.s_cityname = Train1.temp_arrival_cityname
    AND Train2.temp_part_time - Train1.temp_arrival_time + INTERVAL'24 h' >= INTERVAL'2 h'))
)) AND (
    SELECT MIN(tbd_seat_left)
    FROM TrainByDate
    WHERE tbd_tid = Train1.temp_tid AND tbd_seat_type = Train1.temp_seat_type
    AND tbd_order >= Train1.temp_part_order AND tbd_order < Train1.temp_arrival_order
    AND tbd_part_date = $3
) > 0 AND (
    SELECT MIN(tbd_seat_left)
    FROM TrainByDate
    WHERE tbd_tid = Train2.temp_tid AND tbd_seat_type = Train2.temp_seat_type
    AND tbd_order >= Train2.temp_part_order AND tbd_order < Train2.temp_arrival_order
    AND (
        Train1.temp_arrival_time > Train1.temp_part_time AND tbd_part_date = $3
        OR Train1.temp_arrival_time < Train1.temp_part_time AND tbd_part_date = $3 + 1
    )
) > 0
ORDER BY Train1.temp_arrival_price - Train1.temp_part_price + Train2.temp_arrival_price - Train2.temp_part_price,
(Train1.temp_arrival_time - Train1.temp_part_time) + (INTERVAL'24 h' * (SELECT (
  CASE WHEN Train1.temp_arrival_time < Train1.temp_part_time THEN
    1
  ELSE
    0
  END
))) + (Train2.temp_arrival_time - Train2.temp_part_time) + (INTERVAL'24 h' * (SELECT (
  CASE WHEN Train2.temp_arrival_time < Train2.temp_part_time THEN
    1
  ELSE
    0
  END
))) + (Train2.temp_part_time - Train1.temp_arrival_time) + (INTERVAL'24 h' * (SELECT (
  CASE WHEN Train2.temp_part_time < Train1.temp_arrival_time THEN
    1
  ELSE
    0
  END
))), Train1.temp_part_time
LIMIT 10;

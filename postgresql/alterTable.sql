SELECT r_rid, r_part_sname, r_arrival_sname, r_status
FROM
    (SELECT*
    FROM Reservation AS R, TrainSchedule AS TS
    WHERE R.r_tid = TS.ts_tid AND R.r_part_sname = TS.ts_sname
        AND R.r_seat_type = TS.ts_seat_type
    ) AS A,
    (SELECT*
    FROM Reservation AS R, TrainSchedule AS TS
    WHERE R.r_tid = TS.ts_tid AND R.r_arrival_sname = TS.ts_sname
        AND R.r_seat_type = TS.ts_seat_type
    ) AS B      
WHERE 
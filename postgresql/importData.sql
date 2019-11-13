copy region from '/home/dbms/Lab1/TPCH/tpch-gen/data/region.tbl' with (format csv, delimiter '|');
\copy station(s_sid, s_sname, s_cityname) from '/home/dbms/Lab2/train-2016-10/all-stations.csv' with(format csv, delimiter ',');
\copy TrainSchedule from '/media/sf_database/workspace/railway-ticket-database/data/train-2016-10/trainsched.csv' with(format csv, delimiter ',');
\copy TrainByDate from '/media/sf_database/workspace/railway-ticket-database/data/train-2016-10/tbd.csv' with(format csv, delimiter ',');

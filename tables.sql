create table Train (
  tid char(6) primary key,
  model varchar(20)
);

create table Station (
  sid integer primary key,
  sname char(20),
  city char(20)
);

create table Seat (
  seat_type char(8) primary key,
);

create table TrainSchedule (
  tid char(6),
  sid integer,
  seat_type char(8),
  part_time time,
  arrival_time time,
  price decimal(18, 2),
  foreign key (tid) references Train(tid),
  foreign key (sid) references Station(sid),
  foreign key (seat_type) references Seat(seat_type),
  primary key (tid, sid, seat_type)
);

create table TrainSeatsLeft (
  tid char(6),
  sid integer,
  seat_type char(8),
  part_date date,
  seat_left integer,
  foreign key (tid, sid, seat_type) references TrainSchedule(tid, sid, seat_type),
  primary key (tid, sid, seat_type, part_date)
);

create table User (
  uid integer primary key,
  fullname char(20),
  idcard char(18) unique,
  phone char(11) unique,
  credit char(16),
  nick varchar(32),
  account integer,
  access smallint
);

create table Reservation (
  rid integer primary key,
  uid integer,
  tid char(6),
  part_sid integer,
  arrival_sid integer,
  seat_type char(8),
  part_date date,
  foreign key (uid) references User(uid),
  foreign key (tid) references Train(tid),
  foreign key (part_sid) references Station(sid),
  foreign key (arrival_sid) references Station(sid),
  foreign key (seat_type) references Seat(seat_type)
);

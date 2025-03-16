DECLARE @studyid int;
DECLARE @runid int;
DECLARE @iteration int;
DECLARE @insertionDate smalldatetime;
DECLARE @simrunid int;

-- CHECK THIS FIRST
SET @studyid = 2; -- select carefully.  Look at what data is already in the database
SET @runid = 1; --see results window or output for most recent run_id   -- DO change this when uploading data for a new scenario
SET @iteration = 0;  -- when doing individual iterations one at a time.  Consider carefully.

set @insertionDate = CAST({fn Now()} as smalldatetime);  -- get the current timestamp to be saved as the 'InsertionDate'

-- Note, in the following queries you need to be sure that you have the TABLE NAMES and COLUMN NAMES correct.  Yours could be different from what I have here.

--Signal Changes
insert into sim_andalib.dbo.signalchanges (StudyID, RunID, Iteration, InsertionDate, SimTime, SC, SG, State)
select
	@studyid,
	@runid,
	@iteration+sc.SimRunID,
	@insertionDate,
	sc.SimTime,
	sc.Signalcontroller,
	sc.SG,
	case sc.Image
		when 'green' then 1
		when 'red' then 0
		when 'amber' then 2
		else -1
	end as state
from
	vissim_andalib.dbo.SIGNALCHANGES as sc
;

--Travel Times
insert into sim_andalib.dbo.traveltimes (StudyID, RunID, Iteration, InsertionDate, Time, No_, Veh, VehType, Trav_, Delay_)
select
	@studyid,
	@runid,
	@iteration+tt.SimRunID,
	@insertionDate,
	tt.Time,
	tt.No_,
	tt.Veh,
	tt.VehType,
	convert(float,tt.Trav_),
	convert(float,tt.Delay_)
from
	vissim_andalib.dbo.VehicleTravelTimeRawData as tt
;

--Node Data
insert into sim_andalib.dbo.Node (StudyID, RunID, Iteration, InsertionDate, VehNo, VehType, StartTime, EndTime, StartLink, StartLane, StartPos, NodeNo,
                                Movement, FromLink, ToLink, ToLane, ToPos, Layover, Stops, No_Pers)
select
	@studyid,
	@runid,
	@iteration+n.SimRunID,
	@insertionDate,
	n.VehNo,
	n.VehType,
	n.Starttime,
	n.Endat,
	n.StartLink,
	n.StartLane,
	n.StartPos,
	n.NodeNo,
	n.Movement,
	n.FromLink,
	n.ToLink,
	n.toLane,
	n.toPos,
	n.Layover,
	n.Stops,
	n.No_Pers
from
	vissim_andalib.dbo.NodeRawData as n


insert into [sim_Andalib].[dbo].[VehRecord] (StudyID, RunID, Iteration, InsertionDate, SIMSEC, No_, Link, Lane, Pos, Speed) 
select
	@studyid,
	@runid,
	@iteration+veh.SIMRUN,
	@insertionDate,
	veh.SIMSEC, 
	veh.NO, 
	veh.[LANE\LINK\NO], 
	veh.[LANE\INDEX], 
	veh.POS, 
	veh.speed
from vissim_andalib.dbo.VEHICLE as veh;

delete [vissim_Andalib].[dbo].[NodeRawData]
delete [vissim_Andalib].[dbo].[VEHICLE]
delete [vissim_Andalib].[dbo].[SIGNALCHANGES]
delete [vissim_Andalib].[dbo].[VehicleTravelTimeRawData]

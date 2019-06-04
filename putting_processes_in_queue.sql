--- THIS SCRIPT PUTS PROCESSES IN QUEUE - OFF HOLD
---
---
set echo on;
column spoolname new_value spoolname
SELECT 'C:\temp\SQLLogs\'||INSTANCE_NAME ||'_put_in_queue'
	||(select '_'||to_char(sysdate,'YYYY_MM_DD_HH24_MI_SS') from dual)||'.log' spoolname
FROM v$INSTANCE;
spool &spoolname;
---**************************************************************************
--- Count of processes on hold and in queue - 4 = "HOLD"; 5 = "QUEUED"
---**************************************************************************
---
select runstatus, count(*) from psprcsrqst
where initiatednext = 0
having runstatus in ('4', '5') 
group by runstatus;
---
---**************************************************************************
--- Which processes are on hold and in queue before running the script
---**************************************************************************
select * from psprcsrqst where runstatus in ('4', '5') and initiatednext = 0;
--- 
---**************************************************************************
--- Count of processes in a temp table
---**************************************************************************
select count(*) from ps_um_prcs_hld;
---
---**************************************************************************
--- Processes in a temp table
---**************************************************************************
---
select * from ps_um_prcs_hld;
---
---**************************************************************************
--- Putting the processes that were put on hold back to queued status
---**************************************************************************
---
Begin
for HoldRec in (select * from ps_um_prcs_hld)
loop
update psprcsque set runstatus = '5' where prcsinstance = HoldRec.Prcsinstance AND runstatus = '4';
update psprcsrqst set runstatus = '5' where prcsinstance = HoldRec.Prcsinstance AND runstatus = '4';
end loop;
end;
/

COMMIT;
---
---**************************************************************************
--- Count of processes on hold and in queue - 4 = "HOLD"; 5 = "QUEUED"
---**************************************************************************
---
select runstatus, count(*) from psprcsrqst
where initiatednext = 0
having runstatus in ('4', '5') 
group by runstatus;
---
---**************************************************************************
--- Which processes are on hold and in queue after running the script
---**************************************************************************
select * from psprcsrqst where runstatus in ('4', '5') and initiatednext = 0;

set echo off;
spool off;
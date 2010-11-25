CREATE OR REPLACE FORCE VIEW CDM.SYS_VW_0001
(JOB#, MVIEW_OWNER, MVIEW_NAME, LAST_RUN_DATE, NEXT_SCHED_RUN_DATE, 
 IS_WORKING, FAILURES, IS_RUNNING, SID)
AS 
SELECT a.job job#
			 ,schema_user mview_owner
			 ,DECODE (SUBSTR (what, INSTR (what, '.', 1, 2) + 2, INSTR (what, '”', 1, 4) - 4 - INSTR (what, '.', 1, 2) + 2)
						,NULL, SUBSTR (what, 1, 40)
						,SUBSTR (what, INSTR (what, '.', 1, 2) + 2, INSTR (what, '”', 1, 4) - 4 - INSTR (what, '.', 1, 2) + 2))
				 mview_name
			 ,last_date last_run_date
			 ,next_date next_sched_run_date
			 ,DECODE (broken,  'Y', -1,  'N', 1,  ' ') is_working
			 ,failures
			 ,running is_running
			 ,b.sid sid
	 FROM 	 dba_jobs a
			  LEFT OUTER JOIN
				 (  SELECT /*+ RULE */
							 job
							 ,'YES' running
							 ,sid
					 FROM   dba_jobs_running) b
			  ON a.job = b.job
  UNION ALL
	 SELECT NULL job#
			 ,'Time on Server' mview_owner
			 ,TO_CHAR(SYSDATE,'HH24:MI:SS') mview_name
			 ,NULL last_run_date
			 ,NULL next_sched_run_date
			 ,NULL is_working
			 ,NULL failures
			 ,NULL is_running
			 ,NULL sid
	 FROM   DUAL
	 ORDER BY mview_owner
/

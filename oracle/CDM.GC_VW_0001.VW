CREATE OR REPLACE FORCE VIEW CDM.GC_VW_0001
(DISP, RATE, CUR, MAX, AVG, 
 TTL)
AS 
SELECT name disp
			 ,'loop_rate' rate
			 ,cur_loop_rate || ' in ' || scale_loops / 100 || ' seconds' cur
			 ,max_loop_rate MAX
			 ,avg_loop_rate AVG
			 ,ttl_loops / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
  UNION ALL
	 SELECT name disp
			 ,'event_rate' rate
			 ,cur_event_rate || ' in ' || scale_loops / 100 || ' seconds' cur
			 ,max_event_rate MAX
			 ,avg_event_rate AVG
			 ,ttl_loops / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
  UNION ALL
	 SELECT name disp
			 ,'msg_rate' rate
			 ,cur_msg_rate || ' in ' || scale_msg / 100 || ' seconds' cur
			 ,max_msg_rate MAX
			 ,avg_msg_rate AVG
			 ,ttl_msg / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
  UNION ALL
	 SELECT name disp
			 ,'svr_buf_rate' rate
			 ,cur_svr_buf_rate || ' in ' || scale_svr_buf / 100 || ' seconds' cur
			 ,max_svr_buf_rate MAX
			 ,avg_svr_buf_rate AVG
			 ,ttl_svr_buf / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
  UNION ALL
	 SELECT name disp
			 ,'svr_byte_rate' rate
			 ,cur_svr_byte_rate || ' in ' || scale_svr_buf / 100 || ' seconds' cur
			 ,max_svr_byte_rate MAX
			 ,avg_svr_byte_rate AVG
			 ,ttl_svr_buf / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
  UNION ALL
	 SELECT name disp
			 ,'svr_byte_per_buf' rate
			 ,cur_svr_byte_per_buf || ' per buffer' cur
			 ,max_svr_byte_per_buf MAX
			 ,avg_svr_byte_per_buf AVG
			 ,ttl_svr_buf / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
  UNION ALL
	 SELECT name disp
			 ,'clt_buf_rate' rate
			 ,cur_clt_buf_rate || ' in ' || scale_clt_buf / 100 || ' seconds' cur
			 ,max_clt_buf_rate MAX
			 ,avg_clt_buf_rate AVG
			 ,ttl_clt_buf / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
  UNION ALL
	 SELECT name disp
			 ,'clt_byte_rate' rate
			 ,cur_clt_byte_rate || ' in ' || scale_clt_buf / 100 || ' seconds' cur
			 ,max_clt_byte_rate MAX
			 ,avg_clt_byte_rate AVG
			 ,ttl_clt_buf / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
  UNION ALL
	 SELECT name disp
			 ,'clt_byte_per_buf' rate
			 ,cur_clt_byte_per_buf || ' per buffer' cur
			 ,max_clt_byte_per_buf MAX
			 ,avg_clt_byte_per_buf AVG
			 ,ttl_clt_buf / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
  UNION ALL
	 SELECT name disp
			 ,'buf_rate' rate
			 ,cur_buf_rate || ' in ' || scale_buf / 100 || ' seconds' cur
			 ,max_buf_rate MAX
			 ,avg_buf_rate AVG
			 ,ttl_buf / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
  UNION ALL
	 SELECT name disp
			 ,'byte_rate' rate
			 ,cur_byte_rate || ' in ' || scale_buf / 100 || ' seconds' cur
			 ,max_byte_rate MAX
			 ,avg_byte_rate AVG
			 ,ttl_buf / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
  UNION ALL
	 SELECT name disp
			 ,'buf_rate' rate
			 ,cur_buf_rate || ' in ' || scale_buf / 100 || ' seconds' cur
			 ,max_buf_rate MAX
			 ,avg_buf_rate AVG
			 ,ttl_buf / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
  UNION ALL
	 SELECT name disp
			 ,'byte_per_buf' rate
			 ,cur_byte_per_buf || ' per buffer' cur
			 ,max_byte_per_buf MAX
			 ,avg_byte_per_buf AVG
			 ,ttl_buf / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
  UNION ALL
	 SELECT name disp
			 ,'in_connect_rate' rate
			 ,cur_in_connect_rate || ' in ' || scale_in_connect / 100 || ' seconds' cur
			 ,max_in_connect_rate MAX
			 ,avg_in_connect_rate AVG
			 ,ttl_in_connect / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
  UNION ALL
	 SELECT name disp
			 ,'out_connect_rate' rate
			 ,cur_out_connect_rate || ' in ' || scale_out_connect / 100 || ' seconds' cur
			 ,max_out_connect_rate MAX
			 ,avg_out_connect_rate AVG
			 ,ttl_out_connect / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
  UNION ALL
	 SELECT name disp
			 ,'reconnect_rate' rate
			 ,cur_reconnect_rate || ' in ' || scale_reconnect / 100 || ' seconds' cur
			 ,max_reconnect_rate MAX
			 ,avg_reconnect_rate AVG
			 ,ttl_reconnect / 100 || ' seconds' ttl
	 FROM   v$dispatcher_rate
     UNION ALL
     SELECT 'Time on Server' disp, to_char(sysdate,'HH24:MI:SS') rate, null, null,null,null
     from dual
/

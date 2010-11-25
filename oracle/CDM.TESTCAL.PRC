CREATE OR REPLACE PROCEDURE CDM.testcal
AS
BEGIN
   OWA_UTIL.calendarprint ('select pubdate,title,link_url from HTML_RSS_NEWS order by 1');
END;
/

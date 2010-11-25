CREATE OR REPLACE PACKAGE BODY CDM.pkg_mviews
AS
   /******************************************************************************
    NAME:    PKG_MVIEWS
    PURPOSE:

    REVISIONS:
    Ver    Date    Author    Description
    ---------  ----------  --------------- ------------------------------------
    1.0    22/09/2010    Davide   1. Created this package body.
   ******************************************************************************/
   FUNCTION myfunction (param1 IN NUMBER)
      RETURN NUMBER
   IS
   BEGIN
      RETURN param1;
   END;

   PROCEDURE prc001_refresh_all
   IS
      completed_status   CONSTANT VARCHAR2 (10) := 'SUCCEEDED';
      calendar_success   CONSTANT NUMBER (1) := 6;
      calendar_failure   CONSTANT NUMBER (1) := 4;
      v_entry                     XMLTYPE;
      v_status                    VARCHAR2 (25);
      v_result                    VARCHAR2 (1024);
   BEGIN
      FOR c1 IN (  SELECT mview_name
                     FROM user_mviews
                 ORDER BY mview_name)
      LOOP
         BEGIN
            DBMS_SNAPSHOT.refresh (c1.mview_name, 'C');
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.put_line ('Error refreshing ' || c1.mview_name);
         END;
      END LOOP;

      /* --uncomment the following lines to have google calendar updated
        SELECT XMLELEMENT (
            "entry",
            xmlattributes ('http://www.w3.org/2005/Atom' AS "xmlns",
                 'http://schemas.google.com/g/2005' AS "xmlns:gd",
                 'http://schemas.google.com/gCal/2005' AS "xmlns:gCal"),
            XMLELEMENT ("category",
                xmlattributes ('http://schemas.google.com/g/2005#kind' AS "scheme", 'http://schemas.google.com/g/2005#event' AS "term")),
            XMLELEMENT ("title", xmlattributes ('text' AS "type"), JOB_NAME || '  ' || STATUS),
            XMLELEMENT ("content", xmlattributes ('text' AS "type"), CPU_USED || ': ' || ERROR#),
            XMLELEMENT ("link",
                xmlattributes ('http://schemas.google.com/gCal/2005/webContent' AS "rel",
                     'image/gif' AS "type",
                     'https://www.google.com/googlecalendar/icons/' || DECODE (STATUS, completed_status, '9.png', 'skull.png') AS "href",
                     '' AS "title"),
                XMLELEMENT ("gCal:webContent", xmlattributes ('CHIP' AS "display")),
                NULL),
            XMLELEMENT ("gd:transparency", xmlattributes ('http://schemas.google.com/g/2005#event.opaque' AS "value")),
            XMLELEMENT ("gd:eventStatus", xmlattributes ('http://schemas.google.com/g/2005#event.confirmed' AS "value")),
            XMLELEMENT ("gd:where", xmlattributes ('FRATERNO' AS "valueString")),
            XMLELEMENT (
             "gd:when",
             xmlattributes (TO_CHAR (ACTUAL_START_DATE, 'YYYY-MM-DD"T"HH24:MI:SS') AS "startTime",
                  TO_CHAR (ACTUAL_START_DATE + RUN_DURATION, 'YYYY-MM-DD"T"HH24:MI:SS') AS "endTime"))),
           STATUS
        INTO v_entry, v_status
        FROM user_scheduler_job_run_details
         WHERE log_id = (SELECT MAX (log_id)
               FROM user_scheduler_job_run_details
              WHERE job_name = 'JOBMVIEWS_001_REFRESH_ALL');

        IF v_status = completed_status
        THEN
         v_result := SYSMAN.utl_google.add_calendar_error (v_entry, calendar_success);
        ELSE
         v_result := SYSMAN.utl_google.add_calendar_error (v_entry, calendar_failure);
        END IF;

        UPDATE log_google
         SET resultado = v_result, entry = v_entry;
      */
      COMMIT;
   END prc001_refresh_all;

   PROCEDURE prc002_refresh_news
   IS
   BEGIN
      utl_google_news.fill_html_rss_news;
   END prc002_refresh_news;
END pkg_mviews;
/

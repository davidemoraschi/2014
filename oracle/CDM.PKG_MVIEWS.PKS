CREATE OR REPLACE PACKAGE CDM.PKG_MVIEWS
AS
   /******************************************************************************
      NAME:       PKG_MVIEWS
      PURPOSE:

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        22/09/2010      Davide       1. Created this package.
   ******************************************************************************/

   FUNCTION MyFunction (Param1 IN NUMBER)
      RETURN NUMBER;

   PROCEDURE PRC001_REFRESH_ALL;
   PROCEDURE PRC002_REFRESH_NEWS;
END PKG_MVIEWS;
/

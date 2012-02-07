CREATE OR REPLACE PACKAGE BODY CDM.gdatasource
/**
 * OraGoods - Copyright 2009 www.4tm.com.ar - Jose Luis Canciani
 * Oracle PL/SQL Implementation for Google Data Source objects
 *
 * Some support to the Query Language included
 * http://code.google.com/apis/visualization/documentation/querylanguage.html#Clauses
 *
 * Copyright Notice
 *
 * This file is part of ORAGOODS, a library developed by Jose Luis Canciani
 *
 * ORAGOODS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * ORAGOODS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 *
 */
AS
   /*******************************************************************
   *
   * Private prodecures/functions start here
   *
   *******************************************************************/
   PROCEDURE DEBUG (
      p_message                  IN       VARCHAR2)
   IS
   BEGIN
      IF g_debug
      THEN
         DBMS_OUTPUT.put_line (p_message);
      END IF;
   END DEBUG;

   /**
   * Print procedures!
   */
   PROCEDURE p (
      PRINT                      IN       VARCHAR2)
   IS
   BEGIN
      IF g_debug
      THEN
         DBMS_OUTPUT.put_line (PRINT);
      ELSE
         HTP.p (PRINT);
      END IF;
   END p;

   PROCEDURE prn (
      PRINT                      IN       VARCHAR2)
   IS
   BEGIN
      IF g_debug
      THEN
         DBMS_OUTPUT.put (PRINT);
      ELSE
         HTP.prn (PRINT);
      END IF;
   END prn;

   PROCEDURE nl
   IS
   BEGIN
      IF g_debug
      THEN
         DBMS_OUTPUT.new_line;
      ELSE
         HTP.prn (CHR (10));
      END IF;
   END nl;

   /**
   * Clean package variables for running it again
   */
   PROCEDURE clean
   IS
   BEGIN
      g_google_query := NULL;
      g_datasource_select_clause := NULL;
      g_datasource_rest_of_clause := NULL;
      g_datasource_columns.DELETE;
      g_datasource_columns_full.DELETE;
      g_datasource_needed_columns.DELETE;
      g_datasource_bind_values.DELETE;
      g_datasource_bind_types.DELETE;
      g_datasource_labels.DELETE;
      g_datasource_formats.DELETE;
      g_parsed_query := NULL;
      g_opt_no_format := FALSE;
      g_opt_no_values := FALSE;
   END clean;

   FUNCTION trimme (
      p_string                   IN       VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN LTRIM (RTRIM (p_string, ' ' || CHR (9) || CHR (10) || CHR (13) || CHR (32)), ' ' || CHR (9) || CHR (10) || CHR (13) || CHR (32));
   END trimme;

   /**
   *  encodeJsonString: encode text with special characters for sending into a JSON
   *     Based on http://www.json.org/
   */
   PROCEDURE printjsonstring (
      p_string                   IN       VARCHAR2)
   IS
      v_letter                      VARCHAR2 (1 CHAR);
      v_buffer                      VARCHAR2 (2000 CHAR) := '';
      v_count                       PLS_INTEGER := 0;
   BEGIN
      IF     p_string IS NOT NULL
         AND LENGTH (p_string) > 0
      THEN
         FOR l IN 1 .. LENGTH (p_string)
         LOOP
            v_letter := SUBSTR (p_string, l, 1);
            v_count := v_count + 1;
            v_buffer :=
                  v_buffer
               || CASE v_letter
                     WHEN '\'
                        THEN '\\'
                     WHEN '"'
                        THEN '\"'
                     WHEN '/'
                        THEN '\/'
                     WHEN CHR (10)
                        THEN '\n'
                     WHEN CHR (13)
                        THEN '\r'
                     WHEN CHR (9)
                        THEN '\t'
                     ELSE v_letter
                  END;

            IF v_count = 1000
            THEN
               prn (v_buffer);
               v_count := 0;
               v_buffer := '';
            END IF;
         END LOOP;

         IF v_count > 0
         THEN
            prn (v_buffer);
         END IF;
      END IF;
   END printjsonstring;

   /**
   *  encodeJsonString: encode text with special characters for sending into a JSON
   *     Based on http://www.json.org/
   */
   PROCEDURE printjsonstring (
      p_string                   IN       CLOB)
   IS
      v_count                       BINARY_INTEGER;
      v_read                        BINARY_INTEGER;
      v_text_buffer                 VARCHAR2 (2000 CHAR);
   BEGIN
      v_count := 1;
      v_read := 2000;

      LOOP
         DBMS_LOB.READ (p_string, v_read, v_count, v_text_buffer);
         printjsonstring (v_text_buffer);
         v_count := v_count + v_read;
      END LOOP;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN;
   END printjsonstring;

   /**
   *  extractQueryClause
   *  @param string p_query The query string to extract from
   *  @param string p_clause The clause to extract: select | where | etc
   */
   PROCEDURE extractqueryclauses (
      p_query                    IN       VARCHAR2
     ,p_select                   OUT      VARCHAR2
     ,p_where                    OUT      VARCHAR2
     ,p_groupby                  OUT      VARCHAR2
     ,p_pivot                    OUT      VARCHAR2
     ,p_orderby                  OUT      VARCHAR2
     ,p_limit                    OUT      VARCHAR2
     ,p_offset                   OUT      VARCHAR2
     ,p_label                    OUT      VARCHAR2
     ,p_format                   OUT      VARCHAR2
     ,p_options                  OUT      VARCHAR2)
   IS
      v_query                       VARCHAR2 (32767) := trimme (p_query);
      v_pos_select                  PLS_INTEGER := 0;
      v_pos_where                   PLS_INTEGER := 0;
      v_pos_groupby                 PLS_INTEGER := 0;
      v_pos_pivot                   PLS_INTEGER := 0;
      v_pos_orderby                 PLS_INTEGER := 0;
      v_pos_limit                   PLS_INTEGER := 0;
      v_pos_offset                  PLS_INTEGER := 0;
      v_pos_label                   PLS_INTEGER := 0;
      v_pos_format                  PLS_INTEGER := 0;
      v_pos_options                 PLS_INTEGER := 0;
   BEGIN
      -- start getting the positions for each clause
      DECLARE
         v_current_word                VARCHAR2 (32767) := '';
         v_last_word                   VARCHAR2 (32767) := '';
         v_current_quote               VARCHAR2 (1) := NULL;
         v_letter                      VARCHAR2 (1) := '';
         v_last_letter                 VARCHAR2 (1) := '';
      BEGIN
         FOR i IN 1 .. LENGTH (v_query)
         LOOP
            v_letter := SUBSTR (v_query, i, 1);

            IF v_letter IN (' ', CHR (9), CHR (10), CHR (13), CHR (32))
            THEN
               -- when end of word

               -- if this isn't "another" space and I'm not being quoted then...
               IF     v_last_letter NOT IN (' ', CHR (9), CHR (10), CHR (13), CHR (32))
                  AND v_current_quote IS NULL
               THEN
                  -- search clause keywords
                  CASE LOWER (v_current_word)
                     WHEN 'select'
                     THEN
                        IF v_pos_select > 0
                        THEN
                           raise_application_error (-20003, 'Parse error: duplicate clause found');
                        ELSE
                           v_pos_select := i + 1;
                        END IF;
                     WHEN 'where'
                     THEN
                        IF v_pos_where > 0
                        THEN
                           raise_application_error (-20003, 'Parse error: duplicate clause found');
                        ELSE
                           v_pos_where := i + 1;
                        END IF;
                     WHEN 'by'
                     THEN
                        CASE LOWER (v_last_word)
                           WHEN 'group'
                           THEN
                              IF v_pos_groupby > 0
                              THEN
                                 raise_application_error (-20003, 'Parse error: duplicate clause found');
                              ELSE
                                 v_pos_groupby := i + 1;
                              END IF;
                           WHEN 'order'
                           THEN
                              IF v_pos_orderby > 0
                              THEN
                                 raise_application_error (-20003, 'Parse error: duplicate clause found');
                              ELSE
                                 v_pos_orderby := i + 1;
                              END IF;
                           ELSE
                              NULL;
                        END CASE;
                     WHEN 'pivot'
                     THEN
                        IF v_pos_pivot > 0
                        THEN
                           raise_application_error (-20003, 'Parse error: duplicate clause found');
                        ELSE
                           v_pos_pivot := i + 1;
                        END IF;
                     WHEN 'limit'
                     THEN
                        IF v_pos_limit > 0
                        THEN
                           raise_application_error (-20003, 'Parse error: duplicate clause found');
                        ELSE
                           v_pos_limit := i + 1;
                        END IF;
                     WHEN 'offset'
                     THEN
                        IF v_pos_offset > 0
                        THEN
                           raise_application_error (-20003, 'Parse error: duplicate clause found');
                        ELSE
                           v_pos_offset := i + 1;
                        END IF;
                     WHEN 'label'
                     THEN
                        IF v_pos_label > 0
                        THEN
                           raise_application_error (-20003, 'Parse error: duplicate clause found');
                        ELSE
                           v_pos_label := i + 1;
                        END IF;
                     WHEN 'format'
                     THEN
                        IF v_pos_format > 0
                        THEN
                           raise_application_error (-20003, 'Parse error: duplicate clause found');
                        ELSE
                           v_pos_format := i + 1;
                        END IF;
                     WHEN 'options'
                     THEN
                        IF v_pos_options > 0
                        THEN
                           raise_application_error (-20003, 'Parse error: duplicate clause found');
                        ELSE
                           v_pos_options := i + 1;
                        END IF;
                     ELSE
                        NULL;
                  END CASE;

                  -- since I finished a word, clean it
                  v_last_word := v_current_word;
                  v_current_word := '';
               ELSIF v_current_quote IS NOT NULL
               THEN
                  v_current_word := v_current_word || v_letter;
               END IF;
            ELSIF v_letter IN ('''', '"', '`')
            THEN
               -- when quote
               IF     v_current_quote IS NOT NULL
                  AND v_letter = v_current_quote
               THEN
                  -- end quote
                  v_current_quote := NULL;
               ELSIF     v_letter IS NOT NULL
                     AND v_letter <> v_current_quote
               THEN
                  -- ignore quote inside another quote
                  NULL;
               ELSE
                  v_current_quote := v_letter;
               END IF;

               v_current_word := v_current_word || v_letter;
            ELSE
               -- continue
               v_current_word := v_current_word || v_letter;
            END IF;

            v_last_letter := v_letter;
         END LOOP;

         IF v_current_quote IS NOT NULL
         THEN
            raise_application_error (-20000, 'Parsing error: quote not closed');
         END IF;
      END;

      -- check for valid order
      DECLARE
         v_pos2_select                 PLS_INTEGER := v_pos_select;
         v_pos2_where                  PLS_INTEGER := v_pos_where;
         v_pos2_groupby                PLS_INTEGER := v_pos_groupby;
         v_pos2_pivot                  PLS_INTEGER := v_pos_pivot;
         v_pos2_orderby                PLS_INTEGER := v_pos_orderby;
         v_pos2_limit                  PLS_INTEGER := v_pos_limit;
         v_pos2_offset                 PLS_INTEGER := v_pos_offset;
         v_pos2_label                  PLS_INTEGER := v_pos_label;
         v_pos2_format                 PLS_INTEGER := v_pos_format;
         v_pos2_options                PLS_INTEGER := v_pos_options;
      BEGIN
         IF v_pos2_where = 0
         THEN
            v_pos2_where := v_pos2_select;
         END IF;

         IF v_pos2_groupby = 0
         THEN
            v_pos2_groupby := v_pos2_where;
         END IF;

         IF v_pos2_pivot = 0
         THEN
            v_pos2_pivot := v_pos2_groupby;
         END IF;

         IF v_pos2_orderby = 0
         THEN
            v_pos2_orderby := v_pos2_pivot;
         END IF;

         IF v_pos2_limit = 0
         THEN
            v_pos2_limit := v_pos2_orderby;
         END IF;

         IF v_pos2_offset = 0
         THEN
            v_pos2_offset := v_pos2_limit;
         END IF;

         IF v_pos2_label = 0
         THEN
            v_pos2_label := v_pos2_offset;
         END IF;

         IF v_pos2_format = 0
         THEN
            v_pos2_format := v_pos2_label;
         END IF;

         IF v_pos2_options = 0
         THEN
            v_pos2_options := LENGTH (v_query);
         END IF;

         IF    v_pos2_select > v_pos2_where
            OR v_pos2_where > v_pos2_groupby
            OR v_pos2_groupby > v_pos2_pivot
            OR v_pos2_pivot > v_pos2_orderby
            OR v_pos2_orderby > v_pos2_limit
            OR v_pos2_limit > v_pos2_offset
            OR v_pos2_offset > v_pos2_label
            OR v_pos2_label > v_pos2_format
            OR v_pos2_format > v_pos2_options
         THEN
            raise_application_error (-20001, 'Parsing error: invalid order of the query clauses.');
         END IF;
      END;

      -- extract clauses
      DECLARE
         v_end                         PLS_INTEGER := LENGTH (v_query) + 1;
      BEGIN
         -- get options
         IF     v_pos_options > 0
            AND v_pos_options < v_end
         THEN
            p_options := trimme (SUBSTR (v_query, v_pos_options, v_end - v_pos_options));
            v_end := v_pos_options - LENGTH ('options ') - 1;
         END IF;

         -- get format
         IF     v_pos_format > 0
            AND v_pos_format < v_end
         THEN
            p_format := trimme (SUBSTR (v_query, v_pos_format, v_end - v_pos_format));
            v_end := v_pos_format - LENGTH ('format ') - 1;
         END IF;

         -- get label
         IF     v_pos_label > 0
            AND v_pos_label < v_end
         THEN
            p_label := trimme (SUBSTR (v_query, v_pos_label, v_end - v_pos_label));
            v_end := v_pos_label - LENGTH ('label ') - 1;
         END IF;

         -- get offset
         IF     v_pos_offset > 0
            AND v_pos_offset < v_end
         THEN
            p_offset := trimme (SUBSTR (v_query, v_pos_offset, v_end - v_pos_offset));
            v_end := v_pos_offset - LENGTH ('offset ') - 1;
         END IF;

         -- get limit
         IF     v_pos_limit > 0
            AND v_pos_limit < v_end
         THEN
            p_limit := trimme (SUBSTR (v_query, v_pos_limit, v_end - v_pos_limit));
            v_end := v_pos_limit - LENGTH ('limit ') - 1;
         END IF;

         -- get order by
         IF     v_pos_orderby > 0
            AND v_pos_orderby < v_end
         THEN
            p_orderby := trimme (SUBSTR (v_query, v_pos_orderby, v_end - v_pos_orderby));
            v_end := v_pos_orderby - LENGTH ('order by ') - 1;
         END IF;

         -- get pivot
         IF     v_pos_pivot > 0
            AND v_pos_pivot < v_end
         THEN
            p_pivot := trimme (SUBSTR (v_query, v_pos_pivot, v_end - v_pos_pivot));
            v_end := v_pos_pivot - LENGTH ('pivot ') - 1;
         END IF;

         -- get group by
         IF     v_pos_groupby > 0
            AND v_pos_groupby < v_end
         THEN
            p_groupby := trimme (SUBSTR (v_query, v_pos_groupby, v_end - v_pos_groupby));
            v_end := v_pos_groupby - LENGTH ('group by ') - 1;
         END IF;

         -- get group by
         IF     v_pos_where > 0
            AND v_pos_where < v_end
         THEN
            p_where := trimme (SUBSTR (v_query, v_pos_where, v_end - v_pos_where));
            v_end := v_pos_where - LENGTH ('where ') - 1;
         END IF;

         -- finally get select
         IF     v_pos_select > 0
            AND v_pos_select < v_end
         THEN
            p_select := trimme (SUBSTR (v_query, v_pos_select, v_end - v_pos_select));
         END IF;
      END;
   END extractqueryclauses;

   PROCEDURE explode (
      p_string                   IN       VARCHAR2
     ,p_separator                IN       VARCHAR2
     ,p_table                    OUT      t_varchar2
     ,p_trim                     IN       BOOLEAN DEFAULT TRUE
     ,p_ignore_empty_strings     IN       BOOLEAN DEFAULT FALSE
     ,p_exit                     IN       PLS_INTEGER DEFAULT 0
     ,p_separator_case           IN       BOOLEAN DEFAULT FALSE)
   IS
      v_current_quote               VARCHAR2 (1 CHAR) := NULL;
      v_parenthesis_count           PLS_INTEGER := 0;
      v_current_word                VARCHAR2 (32767) := '';
      v_separator_length            PLS_INTEGER := LENGTH (p_separator);
      v_letter                      VARCHAR2 (1 CHAR) := '';
   BEGIN
      IF    LENGTH (p_string) IS NOT NULL
         OR LENGTH (p_string) > 0
      THEN
         FOR i IN 1 .. LENGTH (p_string)
         LOOP
            v_letter := SUBSTR (p_string, i, 1);
            v_current_word := v_current_word || v_letter;

            IF v_letter IN ('''', '"', '`')
            THEN
               IF v_current_quote IS NULL
               THEN
                  v_current_quote := v_letter;
               ELSIF v_current_quote = v_letter
               THEN
                  v_current_quote := NULL;
               END IF;
            ELSIF     v_current_quote IS NULL
                  AND v_letter = '('
            THEN
               v_parenthesis_count := v_parenthesis_count + 1;
            ELSIF     v_current_quote IS NULL
                  AND v_letter = ')'
            THEN
               IF v_parenthesis_count = 0
               THEN
                  raise_application_error (-20016, 'Parsing error: close parenthesis was never opened');
               ELSE
                  v_parenthesis_count := v_parenthesis_count - 1;
               END IF;
            END IF;

            IF     v_current_quote IS NULL
               AND v_parenthesis_count = 0
               AND (   (    p_separator_case = TRUE
                        AND SUBSTR (v_current_word, -1 * v_separator_length) = p_separator)
                    OR (    p_separator_case = FALSE
                        AND LOWER (SUBSTR (v_current_word, -1 * v_separator_length)) = LOWER (p_separator)))
            THEN
               IF p_trim
               THEN
                  v_current_word := trimme (SUBSTR (v_current_word, 1, LENGTH (v_current_word) - v_separator_length));
               ELSE
                  v_current_word := SUBSTR (v_current_word, 1, LENGTH (v_current_word) - v_separator_length);
               END IF;

               IF     p_ignore_empty_strings = TRUE
                  AND (   v_current_word = ''
                       OR v_current_word IS NULL)
               THEN
                  -- ignore!
                  NULL;
               ELSE
                  p_table (p_table.COUNT + 1) := v_current_word;
                  v_current_word := '';

                  IF     p_exit > 0
                     AND p_exit = (p_table.COUNT)
                  THEN
                     RETURN;
                  END IF;
               END IF;
            END IF;
         END LOOP;

         IF p_trim
         THEN
            v_current_word := trimme (v_current_word);
         END IF;

         IF     p_ignore_empty_strings = TRUE
            AND (   v_current_word = ''
                 OR v_current_word IS NULL)
         THEN
            -- ignore!
            NULL;
         ELSE
            p_table (p_table.COUNT + 1) := v_current_word;
         END IF;
      END IF;

      IF v_parenthesis_count > 0
      THEN
         raise_application_error (-20017, 'Parsing error: opened parenthesis is never closed');
      END IF;
   END explode;

   /**
     * @param p_attr
     * @param tqx
     * @return VARCHAR2
     *
     * Description: receives a tqx string (see google data source) and returns the attr value requested.
     * Returns NULL if nothing is found
     *
     * Example:
     *    the call
     *      get_tqx_attr('reqId','version:0.5;reqId:1;sig:5277771;out:json;responseHandler:myQueryHandler');
     *    would return
     *      1
     *
     */
   FUNCTION get_tqx_attr (
      p_attr                     IN       VARCHAR2
     ,tqx                        IN       VARCHAR2)
      RETURN VARCHAR2
   IS
      v_attributes                  t_varchar2;
      v_attr_values                 t_varchar2;
   BEGIN
      explode (tqx, ';', v_attributes);

      FOR i IN 1 .. NVL (v_attributes.COUNT, 0)
      LOOP
         explode (v_attributes (i), ':', v_attr_values);

         FOR j IN 1 .. NVL (v_attr_values.COUNT, 0)
         LOOP
            IF     j = 1
               AND v_attr_values (1) = p_attr
            THEN
               RETURN v_attr_values (2);
            END IF;
         END LOOP;
      END LOOP;

      -- nothing found
      RETURN NULL;
   END get_tqx_attr;

   PROCEDURE checkifcolumnisindatasource (
      p_column                   IN       VARCHAR2)
   IS
   BEGIN
      FOR i IN 1 .. g_datasource_columns.COUNT
      LOOP
         IF g_datasource_columns (i) = p_column
         THEN
            -- this column is referenced by google query, so we need to include it
            g_datasource_needed_columns (i) := 'YES';
            RETURN;
         END IF;
      END LOOP;

      raise_application_error (-20026, 'Column not found in Data Source: ' || SUBSTR (p_column, 1, 30));
   END checkifcolumnisindatasource;

   PROCEDURE getcolid (
      p_string                   IN       VARCHAR2
     ,p_colid                    OUT      VARCHAR2
     ,p_rest                     OUT      VARCHAR2)
   IS
      v_letter                      VARCHAR2 (1 CHAR);
   BEGIN
      p_colid := '';
      p_rest := NULL;
      v_letter := SUBSTR (p_string, 1, 1);

      IF v_letter = '`'
      THEN
         -- find the rest of the ID
         FOR l IN 2 .. LENGTH (p_string)
         LOOP
            v_letter := SUBSTR (p_string, l, 1);

            IF v_letter = '`'
            THEN
               p_rest := trimme (SUBSTR (p_string, (l + 1), LENGTH (p_string) - (l + 1) + 1));
               RETURN;
            END IF;

            p_colid := p_colid || v_letter;
         END LOOP;

         raise_application_error (-20005, 'Parsing error: expecting ` found: ' || v_letter);
      ELSE
         raise_application_error (-20004, 'Parsing error: expecting ` found: ' || v_letter);
      END IF;
   END getcolid;

   PROCEDURE getnumber (
      p_string                   IN       VARCHAR2
     ,p_number                   OUT      VARCHAR2
     ,p_rest                     OUT      VARCHAR2)
   IS
      v_letter                      VARCHAR2 (1 CHAR);
      v_dot                         BOOLEAN := FALSE;
   BEGIN
      p_rest := NULL;
      p_number := '';

      -- get the number
      FOR l IN 1 .. LENGTH (p_string)
      LOOP
         v_letter := SUBSTR (p_string, l, 1);

         IF    v_letter IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
            OR (    v_letter = '-'
                AND l = 1)
            OR (    v_letter = '.'
                AND NVL (INSTR (p_number, '.'), 0) = 0)
         THEN
            p_number := p_number || v_letter;
         ELSIF v_letter IN (' ', CHR (9), CHR (10), CHR (13), CHR (32))
         THEN
            -- finish!
            p_rest := trimme (SUBSTR (p_string, (l + 1), LENGTH (p_string) - (l + 1) + 1));
            EXIT;
         ELSE
            raise_application_error (-20009, 'Parsing error: wrong number, found character: ' || v_letter);
         END IF;
      END LOOP;

      -- check for valid number
      DECLARE
         v_number                      NUMBER;
      BEGIN
         v_number := TO_NUMBER (p_number);
      EXCEPTION
         WHEN OTHERS
         THEN
            IF SQLCODE = -1722
            THEN
               raise_application_error (-20010, 'Parsing error: wrong number: ' || p_number);
            ELSE
               RAISE;
            END IF;
      END;
   END getnumber;

   PROCEDURE getstring (
      p_string_in                IN       VARCHAR2
     ,p_string                   OUT      VARCHAR2
     ,p_rest                     OUT      VARCHAR2)
   IS
      v_letter                      VARCHAR2 (1 CHAR);
      v_quote                       VARCHAR2 (1 CHAR);
   BEGIN
      p_string := '';
      p_rest := NULL;
      v_letter := SUBSTR (p_string_in, 1, 1);

      IF v_letter IN ('''', '"')
      THEN
         -- find the rest of the ID
         v_quote := v_letter;

         FOR l IN 2 .. LENGTH (p_string_in)
         LOOP
            v_letter := SUBSTR (p_string_in, l, 1);

            IF v_letter = v_quote
            THEN
               p_rest := trimme (SUBSTR (p_string_in, (l + 1), LENGTH (p_string_in) - (l + 1) + 1));
               RETURN;
            END IF;

            p_string := p_string || v_letter;
         END LOOP;
      END IF;

      raise_application_error (-20008, 'Parsing error: expecting '' or " and found: ' || v_letter);
   END getstring;

   PROCEDURE getlabel (
      p_string_in                IN       VARCHAR2
     ,p_string                   OUT      VARCHAR2
     ,p_rest                     OUT      VARCHAR2)
   IS
      v_letter                      VARCHAR2 (1 CHAR);
      v_quote                       VARCHAR2 (1 CHAR);
   BEGIN
      p_string := '';
      p_rest := NULL;
      v_quote := SUBSTR (p_string_in, LENGTH (p_string_in), 1);

      IF v_quote IN ('''', '"')
      THEN
         -- find the rest of the label
         FOR l IN REVERSE 1 .. (LENGTH (p_string_in) - 1)
         LOOP
            v_letter := SUBSTR (p_string_in, l, 1);

            IF v_letter = v_quote
            THEN
               -- label found, now collect the column and exit
               p_rest := trimme (SUBSTR (p_string_in, 1, l - 1));
               RETURN;
            END IF;

            p_string := v_letter || p_string;
         END LOOP;

         raise_application_error (-20042, 'Parsing error: invalid label, beggining of quote not found');
      ELSE
         raise_application_error (-20041, 'Parsing error: invalid label, end of quote not found');
      END IF;
   END getlabel;

   FUNCTION getalias (
      p_string                   IN       VARCHAR2)
      RETURN VARCHAR2
   IS
      v_letter                      VARCHAR2 (1 CHAR);
      p_rest                        VARCHAR2 (32767);
   BEGIN
      v_letter := SUBSTR (p_string, 1, 1);

      IF v_letter = '"'
      THEN
         -- find the rest of the ID
         FOR l IN 2 .. LENGTH (p_string)
         LOOP
            IF SUBSTR (p_string, l, 1) = '"'
            THEN
               p_rest := trimme (SUBSTR (p_string, (l + 1), LENGTH (p_string) - (l + 1) + 1));

               IF    LENGTH (p_rest) IS NULL
                  OR LENGTH (p_rest) = 0
               THEN
                  RETURN SUBSTR (p_string, 2, l - 2);
               ELSE
                  raise_application_error (-20024, 'Parsing error: found unexpected characters after double quote');
               END IF;
            END IF;
         END LOOP;

         raise_application_error (-20023, 'Parsing error: expecting " and found: ' || v_letter);
      ELSE
         -- only a-b 1-9 _
         IF LOWER (v_letter) IN
                  ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z')
         THEN
            FOR l IN 2 .. LENGTH (p_string)
            LOOP
               IF LOWER (SUBSTR (p_string, l, 1)) NOT IN
                     ('_', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n'
                     ,'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z')
               THEN
                  raise_application_error (-20025, 'Parsing error: invalid character in column identifier: ' || LOWER (SUBSTR (p_string, l, 1)));
               END IF;
            END LOOP;

            RETURN p_string;
         ELSE
            raise_application_error (-20025, 'Parsing error: column identifier must start with a letter. Found: ' || v_letter);
         END IF;
      END IF;
   END getalias;

   PROCEDURE getword (
      p_string                   IN       VARCHAR2
     ,p_word                     OUT      VARCHAR2
     ,p_rest                     OUT      VARCHAR2)
   IS
      v_letter                      VARCHAR2 (1 CHAR);
   BEGIN
      p_word := '';
      p_rest := NULL;
      v_letter := SUBSTR (p_string, 1, 1);

      -- find the rest of the ID
      FOR l IN 1 .. LENGTH (p_string)
      LOOP
         v_letter := SUBSTR (p_string, l, 1);

         IF    
               -- accepted letters
               (    l > 1
                AND LOWER (v_letter) NOT IN
                       ('_', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n'
                       ,'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'))
            OR (    l = 1
                AND LOWER (v_letter) NOT IN
                       ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y'
                       ,'z'))
         THEN
            IF v_letter NOT IN (' ', CHR (9), CHR (10), CHR (13), CHR (32), '+', '-', '/', '*', '(')
            THEN
               raise_application_error (-20012, 'Parsing error: invalid character on keyword: ' || v_letter);
            ELSE
               p_rest := trimme (SUBSTR (p_string, (l), LENGTH (p_string) - l + 1));
               RETURN;
            END IF;
         END IF;

         p_word := p_word || v_letter;
      END LOOP;
   END getword;

   PROCEDURE getparams (
      p_argument_string          IN       VARCHAR2
     ,p_params                   OUT      t_varchar2
     ,p_rest                     OUT      VARCHAR2
     ,p_trim                     IN       BOOLEAN DEFAULT TRUE
     ,p_ignore_empty_strings     IN       BOOLEAN DEFAULT FALSE)
   IS
   BEGIN
      p_rest := '';

      -- find first and last parenthesis
      IF SUBSTR (p_argument_string, 1, 1) <> '('
      THEN
         raise_application_error (-20013, 'Invalid arguments, expecting: (');
      END IF;

      IF SUBSTR (p_argument_string, -1) <> ')'
      THEN
         raise_application_error (-20014, 'Invalid arguments, ")" not properly closed near "' || SUBSTR (p_argument_string, 1, 6) || '..."');
      END IF;

      explode (SUBSTR (p_argument_string, 2, LENGTH (p_argument_string) - 2), ',', p_params, p_trim, p_ignore_empty_strings);
   END getparams;

   PROCEDURE findoperator (
      p_string                   IN       VARCHAR2
     ,p_operator                 OUT      VARCHAR2
     ,p_rest                     OUT      VARCHAR2
     ,p_expression_type          IN       VARCHAR2 DEFAULT 'select')
   IS
      v_string                      VARCHAR2 (32767) := trimme (p_string);
      v_letter                      VARCHAR2 (1 CHAR);
      v_letter2                     VARCHAR2 (2 CHAR);
      v_next_word                   VARCHAR2 (100) := '';
      v_next_word1                  VARCHAR2 (100) := NULL;
      v_next_word2                  VARCHAR2 (100) := NULL;
      v_next_word_pos1              PLS_INTEGER := NULL;
      v_next_word_pos2              PLS_INTEGER := NULL;
   BEGIN
      IF p_expression_type = 'where'
      THEN
         -- find next words
         v_letter := ' ';

         FOR c IN 1 .. LENGTH (v_string)
         LOOP
            v_letter2 := v_letter;
            v_letter := SUBSTR (v_string, c, 1);

            IF     v_letter IN (' ', CHR (9), CHR (10), CHR (13), CHR (32))
               AND v_letter2 NOT IN (' ', CHR (9), CHR (10), CHR (13), CHR (32))
            THEN
               -- end of word
               IF v_next_word1 IS NULL
               THEN
                  v_next_word1 := v_next_word;
                  v_next_word := '';
                  v_next_word_pos1 := c;
               ELSE
                  v_next_word2 := v_next_word;
                  v_next_word_pos2 := c;
                  EXIT;
               END IF;
            ELSIF v_letter NOT IN (' ', CHR (9), CHR (10), CHR (13), CHR (32))
            THEN
               v_next_word := v_next_word || v_letter;
            END IF;
         END LOOP;
      END IF;

      p_rest := '';
      p_operator := NULL;
      v_letter := SUBSTR (v_string, 1, 1);
      v_letter2 := SUBSTR (v_string, 1, 2);

      IF     p_expression_type = 'where'
         AND v_letter2 IN ('<=', '>=', '!=', '<>')
      THEN
         p_operator := v_letter2;
         p_rest := trimme (SUBSTR (v_string, 3, LENGTH (v_string) - 1));
      ELSIF    (    p_expression_type = 'select'
                AND (   v_letter IN ('+', '*', '/')
                     OR (    v_letter = '-'
                         AND SUBSTR (v_string, 2, 1) NOT IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9'))))
            OR (    p_expression_type = 'where'
                AND (   v_letter IN ('<', '>', '=', '+', '*', '/')
                     OR (    v_letter = '-'
                         AND SUBSTR (v_string, 2, 1) NOT IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9'))))
      THEN
         p_operator := v_letter;
         p_rest := trimme (SUBSTR (v_string, 2, LENGTH (v_string) - 1));
      ELSIF     p_expression_type = 'where'
            AND LOWER (v_next_word1) IN ('is', 'or')
      THEN
         p_operator := LOWER (v_next_word1);
         p_rest := trimme (SUBSTR (v_string, 3, LENGTH (v_string) - 1));
      ELSIF     p_expression_type = 'where'
            AND LOWER (v_next_word1) IN ('and')
      THEN
         p_operator := 'and';
         p_rest := trimme (SUBSTR (v_string, 4, LENGTH (v_string) - 1));
      ELSIF     p_expression_type = 'where'
            AND LOWER (v_next_word1) IN ('contains', 'matches', 'like')
      THEN
         p_operator := LOWER (v_next_word1);
         p_rest := trimme (SUBSTR (v_string, v_next_word_pos1, LENGTH (v_string) - 1));
      ELSIF     p_expression_type = 'where'
            AND ((    LOWER (v_next_word1) IN ('starts', 'ends')
                  AND LOWER (v_next_word2) = 'with'))
      THEN
         p_operator := LOWER (v_next_word1) || ' ' || LOWER (v_next_word2);
         p_rest := trimme (SUBSTR (v_string, v_next_word_pos2, LENGTH (v_string) - 1));
      END IF;
   END findoperator;

   PROCEDURE findexpressioninparenthesis (
      p_string                   IN       VARCHAR2
     ,p_string_out               OUT      VARCHAR2
     ,p_rest                     OUT      VARCHAR2)
   IS
      v_letter                      VARCHAR2 (1 CHAR);
      v_current_quote               VARCHAR2 (1 CHAR) := NULL;
      v_parenthesis_count           PLS_INTEGER := 0;
   BEGIN
      IF SUBSTR (p_string, 1, 1) != '('
      THEN
         raise_application_error (-20038, 'GDataSource Internal error, "(" character not found');
      END IF;

      FOR i IN 2 .. LENGTH (p_string)
      LOOP
         v_letter := SUBSTR (p_string, i, 1);

         IF v_letter IN ('''', '"', '`')
         THEN
            IF v_current_quote IS NULL
            THEN
               v_current_quote := v_letter;
            ELSIF v_current_quote = v_letter
            THEN
               v_current_quote := NULL;
            END IF;
         ELSIF     v_current_quote IS NULL
               AND v_letter = '('
         THEN
            v_parenthesis_count := v_parenthesis_count + 1;
         ELSIF     v_current_quote IS NULL
               AND v_letter = ')'
         THEN
            IF v_parenthesis_count = 0
            THEN
               -- end!
               p_string_out := SUBSTR (p_string, 2, i - 2);
               p_rest := trimme (SUBSTR (p_string, i + 1, LENGTH (p_string)));
               RETURN;
            ELSE
               v_parenthesis_count := v_parenthesis_count - 1;
            END IF;
         END IF;
      END LOOP;

      raise_application_error (-20039, 'Parsing error: opened parenthesis is never closed');
   END findexpressioninparenthesis;

   /**
   *
   *  Receives an expresion and process it recursivly
   *
   *
   */
   PROCEDURE processexpression (
      p_word                     IN       VARCHAR2
     ,p_column_text              IN OUT   VARCHAR2
     ,p_expression_type          IN       VARCHAR2 DEFAULT 'select'
     ,                                                                                                                               -- select | where
      p_process_operator         IN       BOOLEAN DEFAULT FALSE)
   IS
      v_this_word                   VARCHAR2 (32767);
      v_letter                      VARCHAR2 (1 CHAR);
      v_word                        VARCHAR2 (32767);
      v_params                      t_varchar2;
      v_buffer                      VARCHAR2 (32767);
      v_next_operator               VARCHAR2 (10) := NULL;
      v_next_expression             VARCHAR2 (32767) := NULL;
      v_rest                        VARCHAR2 (32767) := '';
      v_operator                    VARCHAR2 (20 CHAR);
      v_column_text                 VARCHAR2 (32767) := '';
   BEGIN
      IF p_process_operator = TRUE
      THEN
         v_rest := p_word;
      ELSE
         v_this_word := p_word;
         v_letter := SUBSTR (v_this_word, 1, 1);

         -- what is this?
         IF v_letter = '('
         THEN
            -- find closing parameter
            findexpressioninparenthesis (v_this_word, v_this_word, v_rest);
            v_column_text := '(';
            -- recursive call to process next expression
            processexpression (v_this_word, v_column_text, p_expression_type);
            v_column_text := v_column_text || ')';
         ELSIF v_letter = '`'
         THEN
            -- is colID
            DECLARE
               v_colid                       VARCHAR2 (100);
            BEGIN
               getcolid (v_this_word, v_colid, v_rest);
               -- is colID in the gdatasource?
               checkifcolumnisindatasource (v_colid);
               -- store translated colID
               v_column_text := '"' || v_colid || '"';
            END;
         ELSIF v_letter IN ('.', '-', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0')
         THEN
            -- is number
            DECLARE
               v_number                      VARCHAR2 (100);
            BEGIN
               getnumber (v_this_word, v_number, v_rest);
               -- store translated colID
               v_column_text := ':b' || g_datasource_bind_values.COUNT;
               g_datasource_bind_values (g_datasource_bind_values.COUNT) := v_number;
               g_datasource_bind_types (g_datasource_bind_types.COUNT) := 'number';
            END;
         ELSIF v_letter IN ('"', '''')
         THEN
            -- is string literal
            DECLARE
               v_string                      VARCHAR2 (100);
            BEGIN
               getstring (v_this_word, v_string, v_rest);
               -- store translated string
               v_column_text := ':b' || g_datasource_bind_values.COUNT;
               g_datasource_bind_values (g_datasource_bind_values.COUNT) := v_string;
               g_datasource_bind_types (g_datasource_bind_types.COUNT) := 'varchar2';
            END;
         ELSIF LOWER (v_letter) IN
                   ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z')
         THEN
            -- colName, aggr function, scalar function
            DECLARE
               v_string                      VARCHAR2 (100);
            BEGIN
               getword (v_this_word, v_string, v_rest);

               -- is an invalid keyword?
               IF LOWER (v_string) = 'null'
               THEN
                  v_column_text := 'null';
               ELSIF     p_expression_type = 'where'
                     AND LOWER (v_string) = 'not'
               THEN
                  getword (v_rest, v_string, v_rest);

                  IF LOWER (v_string) = 'null'
                  THEN
                     v_column_text := 'not null';
                  ELSE
                     raise_application_error (-20011, 'Parsing error: invalid character found after "not" keyword, expecting "null"');
                  END IF;
               ELSIF LOWER (v_string) IN
                       ('not', 'true', 'false', 'and', 'asc', 'by', 'false', 'format', 'group', 'label', 'limit', 'not', 'offset', 'options', 'desc'
                       ,'or', 'order', 'pivot', 'select', 'true', 'where')
               THEN
                  -- invalid keyword in select
                  raise_application_error (-20011, 'Parsing error: invalid keyword found in ' || p_expression_type || ' clause: ' || v_string);
               ELSIF LOWER (v_string) IN ('date', 'datetime', 'timeofday', 'timestamp')
               THEN
                  -- date-based literal
                  DECLARE
                     v_date                        VARCHAR2 (100);
                  BEGIN
                     getstring (v_rest, v_date, v_rest);

                     -- check for next expression (after string nothing is expected)
                     IF     v_rest IS NOT NULL
                        AND LENGTH (v_rest) > 0
                     THEN
                        raise_application_error (-20013, 'Parsing error: invalid expresion in date-based literal: ' || SUBSTR (v_rest, 1, 6) || '...');
                     END IF;

                     -- store translated colID
                     CASE LOWER (v_string)
                        WHEN 'date'
                        THEN
                           v_column_text := 'to_date(:b' || g_datasource_bind_values.COUNT || ',''yyyy-mm-dd'')';
                        WHEN 'timeofday'
                        THEN
                           v_column_text := 'to_date(:b' || g_datasource_bind_values.COUNT || ',''hh24:mi:ss'')';
                        WHEN 'datetime'
                        THEN
                           v_column_text := 'to_timestamp(:b' || g_datasource_bind_values.COUNT || ',''yyyy-mm-dd hh24:mi:ss.ff3'')';
                        WHEN 'timestamp'
                        THEN
                           v_column_text := 'to_timestamp(:b' || g_datasource_bind_values.COUNT || ',''yyyy-mm-dd hh24:mi:ss.ff3'')';
                     END CASE;

                     g_datasource_bind_values (g_datasource_bind_values.COUNT) := v_date;
                     g_datasource_bind_types (g_datasource_bind_types.COUNT) := 'varchar2';
                  END;
               ELSIF LOWER (v_string) IN ('avg', 'count', 'max', 'min', 'sum')
               THEN
                  -- aggregation functions
                  -- they receive a single column according to G. Query v0.7
                  -- verify there's no extra parameters
                  IF p_expression_type = 'where'
                  THEN
                     raise_application_error (-20033
                                             , 'Parsing error: invalid use of aggregation function "' || LOWER (v_string) || '" in where clause');
                  END IF;

                  getparams (v_rest, v_params, v_rest, TRUE, TRUE);

                  IF v_params.COUNT != 1
                  THEN
                     raise_application_error (-20018, 'Parsing error: wrong number of parameters in aggregation function ' || LOWER (v_string));
                  END IF;

                  v_column_text := LOWER (v_string) || '(';
                  -- recursive call to process the parameter
                  processexpression (v_params (1), v_column_text, p_expression_type);
                  v_column_text := v_column_text || ')';
               ELSIF LOWER (v_string) IN ('now')
               THEN
                  -- no-argument functions
                  CASE LOWER (v_string)
                     WHEN 'now'
                     THEN
                        -- store translated now function
                        v_column_text := 'systimestamp';
                  END CASE;

                  -- verify there's no extra parameters
                  getparams (v_rest, v_params, v_rest, TRUE, TRUE);

                  IF v_params.COUNT > 0
                  THEN
                     raise_application_error (-20012, 'Parsing error: too many parameters in now() function');
                  END IF;
               ELSIF LOWER (v_string) IN
                              ('year', 'month', 'day', 'hour', 'minute', 'second', 'millisecond', 'quarter', 'dayofweek', 'todate', 'upper', 'lower')
               THEN
                  -- one-argument functions
                  getparams (v_rest, v_params, v_rest, TRUE, FALSE);

                  IF v_params.COUNT != 1
                  THEN
                     raise_application_error (-20012, 'Parsing error: wrong parameter count in function ' || LOWER (v_string));
                  END IF;

                  -- store translated now function
                  IF LOWER (v_string) = 'todate'
                  THEN
                     -- return date
                     v_column_text := 'gdatasource.toDate(';
                     -- recursive call to process next expression
                     processexpression (v_params (1), v_column_text, p_expression_type);
                     v_column_text := v_column_text || ')';
                  ELSIF LOWER (v_string) IN ('upper', 'lower')
                  THEN
                     -- return string
                     v_column_text := LOWER (v_string) || '(';
                     -- recursive call to process next expression
                     processexpression (v_params (1), v_column_text, p_expression_type);
                     v_column_text := v_column_text || ')';
                  ELSE
                     -- return number
                     -- recursive call to process next expression
                     processexpression (v_params (1), v_buffer, p_expression_type);

                     CASE LOWER (v_string)
                        WHEN 'year'
                        THEN
                           v_column_text := 'to_number(to_char(' || v_buffer || ',''yyyy''))';
                        WHEN 'month'
                        THEN
                           v_column_text := 'to_number(to_char(' || v_buffer || ',''mm''))';
                        WHEN 'day'
                        THEN
                           v_column_text := 'to_number(to_char(' || v_buffer || ',''dd''))';
                        WHEN 'hour'
                        THEN
                           v_column_text := 'to_number(to_char(' || v_buffer || ',''hh24''))';
                        WHEN 'minute'
                        THEN
                           v_column_text := 'to_number(to_char(' || v_buffer || ',''mi''))';
                        WHEN 'second'
                        THEN
                           v_column_text := 'to_number(to_char(' || v_buffer || ',''ss''))';
                        WHEN 'millisecond'
                        THEN
                           v_column_text := 'to_number(to_char(' || v_buffer || ',''ff3''))';
                        WHEN 'quarter'
                        THEN
                           v_column_text := 'to_number(to_char(' || v_buffer || ',''q''))';
                        WHEN 'dayofweek'
                        THEN
                           v_column_text := 'to_number(to_char(' || v_buffer || ',''d''))';
                     END CASE;
                  END IF;
               ELSIF LOWER (v_string) IN ('datediff')
               THEN
                  -- two-argument functions
                  getparams (v_rest, v_params, v_rest, TRUE, FALSE);

                  IF v_params.COUNT != 2
                  THEN
                     raise_application_error (-20012, 'Parsing error: wrong parameter count in function ' || LOWER (v_string));
                  END IF;

                  -- store translated datediff function
                  -- recursive call to process next expression
                  v_column_text := '(';
                  processexpression (v_params (1), v_column_text);
                  v_column_text := v_column_text || ') - (';
                  processexpression (v_params (2), v_column_text);
                  v_column_text := v_column_text || ')';
               ELSE
                  -- not a known keyword, it should be a column name
                  checkifcolumnisindatasource (UPPER (v_string));
                  v_column_text := UPPER (v_string);
               END IF;
            END;
         ELSE
            IF    v_letter = ''
               OR v_letter IS NULL
            THEN
               raise_application_error (-20002, 'Parsing error: missing expresion in ' || p_expression_type || ' clause');
            ELSE
               raise_application_error (-20006, 'Parsing error: unexpected character in ' || p_expression_type || ' clause: ' || v_letter);
            END IF;
         END IF;
      END IF;                                                                                                                 -- if p_process_operator

      -- finally, if this is a where clause look for next operator
      v_rest := trimme (v_rest);

      IF NVL (LENGTH (v_rest), 0) > 0
      THEN
         findoperator (v_rest, v_operator, v_word, p_expression_type);

         IF v_operator IS NOT NULL
         THEN
            -- recursive call to process next expression, adding the operator_count parameter
            IF v_operator IN ('contains', 'ends with', 'starts with')
            THEN
               -- expecting string literal
               DECLARE
                  v_string                      VARCHAR2 (32767);
               BEGIN
                  getstring (v_word, v_string, v_rest);

                  CASE v_operator
                     WHEN 'contains'
                     THEN
                        v_column_text := 'contains(' || v_column_text || ',' || ':b' || g_datasource_bind_values.COUNT || ') > 0';
                        g_datasource_bind_values (g_datasource_bind_values.COUNT) := v_string;
                     WHEN 'ends with'
                     THEN
                        v_column_text := v_column_text || ' like :b' || g_datasource_bind_values.COUNT;
                        g_datasource_bind_values (g_datasource_bind_values.COUNT) := '%' || v_string;
                     WHEN 'starts with'
                     THEN
                        v_column_text := v_column_text || ' like :b' || g_datasource_bind_values.COUNT;
                        g_datasource_bind_values (g_datasource_bind_values.COUNT) := v_string || '%';
                  END CASE;

                  g_datasource_bind_types (g_datasource_bind_types.COUNT) := 'varchar2';
                  p_column_text := p_column_text || ' ' || v_column_text;
                  v_column_text := '';
                  processexpression (v_rest, v_column_text, p_expression_type, TRUE);
                  p_column_text := p_column_text || v_column_text;
               END;
            ELSE
               p_column_text := p_column_text || ' ' || v_column_text || ' ' || v_operator || ' ';
               v_column_text := '';
               processexpression (v_word, v_column_text, p_expression_type, FALSE);
               p_column_text := p_column_text || v_column_text;
            END IF;
         ELSE
            raise_application_error (-20040
                                    ,    'Parsing error: invalid operator found in '
                                      || p_expression_type
                                      || ' clause near "'
                                      || SUBSTR (v_rest, 1, 6)
                                      || '..."');
         END IF;
      ELSE
         p_column_text := p_column_text || v_column_text;
      END IF;
   END processexpression;

   /*******************************************************************
   *
   * Public functions/procedures start here
   *
   *******************************************************************/

   /**
   * Parse a server database query string
   */
   PROCEDURE setdatasource (
      p_datasource_query         IN       VARCHAR2)
   IS
      v_select_clause               VARCHAR2 (32767) := '';
      v_select_columns              t_varchar2;
      v_select_column               t_varchar2;
   BEGIN
      -- get select clause
      DECLARE
         v_letter                      VARCHAR2 (1 CHAR) := '';
         v_last_letter                 VARCHAR2 (1 CHAR) := '';
         v_current_quote               VARCHAR2 (1 CHAR) := '';
         v_current_word                VARCHAR2 (32767) := '';
         v_pos_select                  PLS_INTEGER;
         v_pos_from                    PLS_INTEGER;
      BEGIN
         FOR i IN 1 .. LENGTH (p_datasource_query)
         LOOP
            v_letter := SUBSTR (p_datasource_query, i, 1);

            IF v_letter IN (' ', CHR (9), CHR (10), CHR (13), CHR (32))
            THEN
               -- when end of word

               -- if this isn't "another" space and I'm not being quoted then...
               IF     v_last_letter NOT IN (' ', CHR (9), CHR (10), CHR (13), CHR (32))
                  AND v_current_quote IS NULL
               THEN
                  -- search clause keywords
                  CASE LOWER (v_current_word)
                     WHEN 'select'
                     THEN
                        v_pos_select := i + 1;
                     WHEN 'from'
                     THEN
                        v_pos_from := i + 1;
                     ELSE
                        NULL;
                  END CASE;

                  -- since I finished a word, clean it
                  IF LOWER (v_current_word) = 'from'
                  THEN
                     EXIT;
                  END IF;

                  v_current_word := '';
               ELSIF v_current_quote IS NOT NULL
               THEN
                  v_current_word := v_current_word || v_letter;
               END IF;
            ELSIF v_letter IN ('''', '"', '`')
            THEN
               -- when quote
               IF     v_current_quote IS NOT NULL
                  AND v_letter = v_current_quote
               THEN
                  -- end quote
                  v_current_quote := NULL;
               ELSIF     v_letter IS NOT NULL
                     AND v_letter <> v_current_quote
               THEN
                  -- ignore quote inside another quote
                  NULL;
               ELSE
                  v_current_quote := v_letter;
               END IF;

               v_current_word := v_current_word || v_letter;
            ELSE
               -- continue
               v_current_word := v_current_word || v_letter;
            END IF;

            v_last_letter := v_letter;
         END LOOP;

         IF v_current_quote IS NOT NULL
         THEN
            raise_application_error (-20020, 'Parsing error on Datasource query: quote not closed');
         END IF;

         -- finally get select
         g_datasource_select_clause := trimme (SUBSTR (p_datasource_query, v_pos_select, v_pos_from - 6 - v_pos_select));
         g_datasource_rest_of_clause := SUBSTR (p_datasource_query, v_pos_from - 5);
      END;

      explode (g_datasource_select_clause, ',', v_select_columns);

      IF v_select_columns.COUNT = 0
      THEN
         raise_application_error (-20021, 'Parsing error on Datasource query: no select columns found');
      END IF;

      FOR c IN 1 .. v_select_columns.COUNT
      LOOP
         explode (v_select_columns (c), ' as ', v_select_column);

         IF v_select_column.COUNT > 2
         THEN
            raise_application_error (-20022, 'Parsing error on Datasource query: invalid column, found to many aliases');
         END IF;

         IF v_select_column.COUNT = 2
         THEN
            -- there's an alias!
            IF SUBSTR (v_select_column (2), 1, 1) = '"'
            THEN
               g_datasource_columns (c) := getalias (v_select_column (2));
            ELSE
               g_datasource_columns (c) := UPPER (getalias (v_select_column (2)));
            END IF;
         ELSE
            -- no alias!
            IF SUBSTR (v_select_column (1), 1, 1) = '"'
            THEN
               g_datasource_columns (c) := getalias (v_select_column (1));
            ELSE
               g_datasource_columns (c) := UPPER (getalias (v_select_column (1)));
            END IF;
         END IF;

         -- mark this column as "not needed" for now. If the google query references it, we will then mark it as YES
         g_datasource_needed_columns (c) := 'NO';
         g_datasource_columns_full (c) := v_select_columns (c);
      END LOOP;
   END setdatasource;

   /**
   * parse a client's google datasource query string
   */
   PROCEDURE setquery (
      p_google_query             IN       VARCHAR2)
   IS
      -- for extracting query clauses
      v_select_clause               VARCHAR2 (32767) := '';
      v_where_clause                VARCHAR2 (32767) := '';
      v_groupby_clause              VARCHAR2 (32767) := '';
      v_pivot_clause                VARCHAR2 (32767) := '';
      v_orderby_clause              VARCHAR2 (32767) := '';
      v_limit_clause                VARCHAR2 (32767) := '';
      v_offset_clause               VARCHAR2 (32767) := '';
      v_label_clause                VARCHAR2 (32767) := '';
      v_format_clause               VARCHAR2 (32767) := '';
      v_options_clause              VARCHAR2 (32767) := '';
      -- select extract variables
      v_select_cols                 t_varchar2;
      v_groupby_cols                t_varchar2;
      v_orderby_cols                t_varchar2;
      v_label_cols                  t_varchar2;
      v_format_cols                 t_varchar2;
      v_option_cols                 t_varchar2;
      -- the new query!
      v_parsed_query                VARCHAR2 (32767);
      -- needed vars
      v_label                       VARCHAR2 (32767);
      v_rest                        VARCHAR2 (32767);
      v_datasource_labels_cols      t_varchar2;                                                                                       -- store labels
      v_datasource_labels_values    t_varchar2;                                                                                       -- store labels
      v_datasource_formats_cols     t_varchar2;                                                                                      -- store formats
      v_datasource_formats_values   t_varchar2;                                                                                      -- store formats
      v_comma                       BOOLEAN;
      v_buffer                      VARCHAR2 (32767);                                                     -- temporary store translated select clause
      v_where_buffer                VARCHAR2 (32767);                                                             -- temporary store the where clause
      v_select_count                PLS_INTEGER;
      -- limit and offset
      v_limit                       PLS_INTEGER;
      v_offset                      PLS_INTEGER;
   BEGIN
      IF g_datasource_columns.COUNT = 0
      THEN
         raise_application_error (-20024, 'No google datasource set, please run the setDataSource() method first');
      END IF;

      g_google_query := p_google_query;
      -- start parsing the query
      extractqueryclauses (p_google_query
                          ,v_select_clause
                          ,v_where_clause
                          ,v_groupby_clause
                          ,v_pivot_clause
                          ,v_orderby_clause
                          ,v_limit_clause
                          ,v_offset_clause
                          ,v_label_clause
                          ,v_format_clause
                          ,v_options_clause);
      /*
      debug('v_select_clause    : ->' || v_select_clause || '<- ' ) ;
      debug('v_where_clause     : ->' || v_where_clause  || '<- ' ) ;
      debug('v_groupby_clause   : ->' || v_groupby_clause ||'<- ' ) ;
      debug('v_pivot_clause     : ->' || v_pivot_clause  || '<- ' ) ;
      debug('v_orderby_clause   : ->' || v_orderby_clause ||'<- ' ) ;
      debug('v_limit_clause     : ->' || v_limit_clause  || '<- ' ) ;
      debug('v_offset_clause    : ->' || v_offset_clause || '<- ' ) ;
      debug('v_label_clause     : ->' || v_label_clause  || '<- ' ) ;
      debug('v_format_clause    : ->' || v_format_clause || '<- ' ) ;
      debug('v_options_clause   : ->' || v_options_clause || '<-' );
      */

      -- start building the query
      v_parsed_query := 'select ';
      -- load labels
      explode (v_label_clause, ',', v_label_cols);

      FOR i IN 1 .. NVL (v_label_cols.COUNT, 0)
      LOOP
         getlabel (v_label_cols (i), v_label, v_rest);
         v_datasource_labels_cols (i) := '';
         processexpression (v_rest, v_datasource_labels_cols (i), 'select');
         v_datasource_labels_values (i) := v_label;
      END LOOP;

      -- load formats
      explode (v_format_clause, ',', v_format_cols);

      FOR i IN 1 .. NVL (v_format_cols.COUNT, 0)
      LOOP
         getlabel (v_format_cols (i), v_label, v_rest);
         v_datasource_formats_cols (i) := '';
         processexpression (v_rest, v_datasource_formats_cols (i), 'select');
         v_datasource_formats_values (i) := v_label;
      END LOOP;

      -- select clause
      explode (v_select_clause, ',', v_select_cols);

      IF v_select_cols.COUNT = 0
      THEN
         raise_application_error (-20050, 'Parse error: select clause is required');
      END IF;

      -- * or no select clause
      IF     v_select_cols.COUNT = 1
         AND v_select_cols (1) = '*'
      THEN
         v_select_count := g_datasource_columns.COUNT;
      ELSE
         v_select_count := v_select_cols.COUNT;
      END IF;

      FOR i IN 1 .. v_select_count
      LOOP
         -- parse the google query select clause and validate and translate each column
         v_buffer := '';

         IF     v_select_cols.COUNT = 1
            AND v_select_cols (1) = '*'
         THEN
            -- get the column from the datasource
            v_buffer := g_datasource_columns (i);
            g_datasource_needed_columns (i) := 'YES';
         ELSE
            -- first process the column
            processexpression (v_select_cols (i), v_buffer, 'select');
         END IF;

         -- concat to the parsed query
         IF i > 1
         THEN
            v_parsed_query := v_parsed_query || ', ' || v_buffer;
         ELSE
            v_parsed_query := v_parsed_query || v_buffer;
         END IF;

         -- add the label if any
         g_datasource_labels (i) := NULL;

         FOR l IN 1 .. NVL (v_datasource_labels_cols.COUNT, 0)
         LOOP
            IF v_datasource_labels_cols (l) = v_buffer
            THEN
               g_datasource_labels (i) := v_datasource_labels_values (l);
               EXIT;
            END IF;
         END LOOP;

         -- add the format if any
         g_datasource_formats (i) := NULL;

         FOR l IN 1 .. NVL (v_datasource_formats_cols.COUNT, 0)
         LOOP
            IF v_datasource_formats_cols (l) = v_buffer
            THEN
               g_datasource_formats (i) := v_datasource_formats_values (l);
               EXIT;
            END IF;
         END LOOP;
      END LOOP;

      -- where clause (process now to add needed columns to the datasource)
      IF     LENGTH (v_where_clause) IS NOT NULL
         AND LENGTH (v_where_clause) > 0
      THEN
         processexpression (v_where_clause, v_where_buffer, 'where');
      END IF;

      -- limit
      IF NVL (LENGTH (v_limit_clause), 0) > 0
      THEN
         BEGIN
            v_limit := TO_NUMBER (v_limit_clause);
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error (-20042, 'Parse error: invalid limit number');
         END;
      ELSE
         v_limit := 0;
      END IF;

      -- offset
      IF NVL (LENGTH (v_offset_clause), 0) > 0
      THEN
         BEGIN
            v_offset := TO_NUMBER (v_offset_clause);
         EXCEPTION
            WHEN OTHERS
            THEN
               raise_application_error (-20044, 'Parse error: invalid offset number');
         END;
      ELSE
         v_offset := 0;
      END IF;

      -- add the DataSource query
      IF g_datasource_needed_columns.COUNT = 0
      THEN
         raise_application_error (-20050, 'Parse error: no reference to a Datasource column found on the query');
      END IF;

      v_parsed_query := v_parsed_query || ' from (' || CHR (10) || 'select ';
      v_comma := FALSE;

      FOR i IN 1 .. g_datasource_needed_columns.COUNT
      LOOP
         IF g_datasource_needed_columns (i) = 'YES'
         THEN
            -- add comma only if this is not the first needed column
            IF NOT v_comma
            THEN
               FOR j IN 1 .. (i - 1)
               LOOP
                  IF g_datasource_needed_columns (j) = 'YES'
                  THEN
                     v_comma := TRUE;
                     EXIT;
                  END IF;
               END LOOP;
            END IF;

            IF v_comma
            THEN
               v_parsed_query := v_parsed_query || ', ';
            END IF;

            v_parsed_query := v_parsed_query || g_datasource_columns_full (i);
         END IF;
      END LOOP;

      v_parsed_query := v_parsed_query || CHR (10) || g_datasource_rest_of_clause || CHR (10) || ')';

      -- where clause
      IF     LENGTH (v_where_clause) IS NOT NULL
         AND LENGTH (v_where_clause) > 0
      THEN
         v_parsed_query := v_parsed_query || CHR (10) || ' where ' || v_where_buffer;
      END IF;

      -- group by clause
      explode (v_groupby_clause, ',', v_groupby_cols);

      -- * or no select clause
      FOR i IN 1 .. NVL (v_groupby_cols.COUNT, 0)
      LOOP
         -- parse the google query group by clause and validate and translate each column
         IF i > 1
         THEN
            v_parsed_query := v_parsed_query || ', ';
         ELSE
            v_parsed_query := v_parsed_query || CHR (10) || 'group by ';
         END IF;

         -- process the column
         processexpression (v_groupby_cols (i), v_parsed_query, 'select');
      END LOOP;

      -- TODO: pivot clause!

      -- order by clause
      explode (v_orderby_clause, ',', v_orderby_cols);

      -- * or no select clause
      DECLARE
         v_order                       VARCHAR2 (5);
         v_order_by_col                VARCHAR2 (32767);
      BEGIN
         FOR i IN 1 .. NVL (v_orderby_cols.COUNT, 0)
         LOOP
            -- find asc/desc keyword
            IF LOWER (trimme (SUBSTR (v_orderby_cols (i), -4))) = 'asc'
            THEN
               v_order := ' asc';
               v_order_by_col := SUBSTR (v_orderby_cols (i), 1, LENGTH (v_orderby_cols (i)) - 4);
            ELSIF LOWER (trimme (SUBSTR (v_orderby_cols (i), -5))) = 'desc'
            THEN
               v_order := ' desc';
               v_order_by_col := SUBSTR (v_orderby_cols (i), 1, LENGTH (v_orderby_cols (i)) - 5);
            ELSE
               v_order := '';
               v_order_by_col := v_orderby_cols (i);
            END IF;

            -- parse the google query group by clause and validate and translate each column
            IF i > 1
            THEN
               v_parsed_query := v_parsed_query || ', ';
            ELSE
               v_parsed_query := v_parsed_query || CHR (10) || 'order by ';
            END IF;

            -- process the column
            processexpression (v_order_by_col, v_parsed_query, 'select');
            -- add order
            v_parsed_query := v_parsed_query || v_order;
         END LOOP;
      END;

      -- limit and offset
      IF    v_offset > 0
         OR v_limit > 0
      THEN
         IF v_offset = 0
         THEN
            v_offset := 1;
         END IF;

         v_parsed_query := 'select iv.*, rownum rnum from ( ' || CHR (10) || v_parsed_query || CHR (10) || ') ';

         IF v_limit > 0
         THEN
            v_parsed_query := v_parsed_query || 'iv where rownum < :b' || g_datasource_bind_values.COUNT || CHR (10);
            g_datasource_bind_values (g_datasource_bind_values.COUNT) := TO_CHAR (v_limit + v_offset);
            g_datasource_bind_types (g_datasource_bind_types.COUNT) := 'number';
         END IF;

         IF v_offset > 1
         THEN
            v_parsed_query := 'select * from (' || CHR (10) || v_parsed_query || CHR (10) || ') where rnum >= :b' || g_datasource_bind_values.COUNT;
            g_datasource_bind_values (g_datasource_bind_values.COUNT) := TO_CHAR (v_offset);
            g_datasource_bind_types (g_datasource_bind_types.COUNT) := 'number';
         END IF;
      END IF;

      -- load options
      explode (v_options_clause, ',', v_option_cols);

      FOR i IN 1 .. NVL (v_option_cols.COUNT, 0)
      LOOP
         CASE LOWER (v_option_cols (i))
            WHEN 'no_format'
            THEN
               g_opt_no_format := TRUE;
            WHEN 'no_values'
            THEN
               g_opt_no_values := TRUE;
            ELSE
               raise_application_error (-20050, 'Parse error: invalid Option found');
         END CASE;
      END LOOP;

      DEBUG ('Final query is: ' || v_parsed_query);
      g_parsed_query := v_parsed_query;
   END setquery;

   /**
   * build, parse and bind query based on datasource query and datasource cursor
   */
   PROCEDURE preparecursor (
      p_cursor                   IN OUT   NUMBER)
   IS
   BEGIN
      -- parse cursor
      DBMS_SQL.parse (p_cursor, g_parsed_query, DBMS_SQL.native);

      -- add the bind variables
      FOR b IN 0 .. NVL (g_datasource_bind_values.COUNT - 1, -1)
      LOOP
         CASE g_datasource_bind_types (b)
            WHEN 'number'
            THEN
               DBMS_SQL.bind_variable (p_cursor, ':b' || b, TO_NUMBER (g_datasource_bind_values (b)));
            WHEN 'varchar2'
            THEN
               DBMS_SQL.bind_variable (p_cursor, ':b' || b, g_datasource_bind_values (b));
            ELSE
               raise_application_error (-20053, 'Invalid bind type detected when parsing query.');
         END CASE;
      END LOOP;
   END preparecursor;

   PROCEDURE get_json (
      p_datasource_id            IN       gdatasources.ID%TYPE
     ,tq                         IN       VARCHAR2 DEFAULT 'select *'
     ,tqx                        IN       VARCHAR2 DEFAULT NULL)
   IS
      -- datasource query
      v_query                       gdatasources.sql_text%TYPE;
      -- dynamic cursor info
      v_cursor                      NUMBER;                                                                                              -- cursor id
      v_cursor_output               NUMBER;                                                                                  -- execute cursor output
      v_col_cnt                     PLS_INTEGER;                                                                                      -- # of columns
      record_desc_table             DBMS_SQL.desc_tab;                                                                           -- description table
      -- to store output values of the query
      v_col_char                    VARCHAR2 (32767);
      v_col_number                  NUMBER;
      v_col_date                    DATE;
      v_col_datetime                TIMESTAMP;
      v_col_clob                    CLOB;
      -- logic helper vars
      v_first                       BOOLEAN;
      -- buffer to avoid printing before testing column formats
      v_buffer                      VARCHAR2 (32767) := '';
      v_test_format                 VARCHAR2 (1000);
   BEGIN
      BEGIN
         SELECT sql_text
         INTO   v_query
         FROM   gdatasources
         WHERE  ID = p_datasource_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- treat error!
            p ('error, no datasource found');
            RETURN;
      END;

      clean;
      -- set DataSource
      setdatasource (v_query);
      -- set the google query
      setquery (tq);
      -- open cursor
      v_cursor := DBMS_SQL.open_cursor;
      -- prepare cursor (parse and bind)
      preparecursor (v_cursor);
      -- execute the cursor
      v_cursor_output := DBMS_SQL.EXECUTE (v_cursor);
      -- get columns of the cursor
      DBMS_SQL.describe_columns (v_cursor, v_col_cnt, record_desc_table);

      -- NOTE
      -- from now on, we should not have any errors!
      -- Parsing and execute was done, so we assume the rest will be ok
      -- If an error happens, then the resulting JSON will be invalid
      FOR col IN 1 .. v_col_cnt
      LOOP
         IF record_desc_table (col).col_name != 'RNUM'
         THEN
            -- create column details
            v_buffer := v_buffer || '   {' || 'id: "' || record_desc_table (col).col_name || '", ';

            IF NOT g_opt_no_values
            THEN
               IF g_datasource_labels (col) IS NOT NULL
               THEN
                  v_buffer := v_buffer || 'label: "' || g_datasource_labels (col) || '", ';
               ELSE
                  v_buffer := v_buffer || 'label: "' || record_desc_table (col).col_name || '", ';
               END IF;
            END IF;

            IF record_desc_table (col).col_type IN (1, 9, 96, 112)
            THEN
               -- varchar, varchar2, char and CLOB
               DBMS_SQL.define_column (v_cursor, col, v_col_char, 32767);
               v_buffer := v_buffer || 'type: "string"';
            ELSIF record_desc_table (col).col_type = 2
            THEN
               -- number
               DBMS_SQL.define_column (v_cursor, col, v_col_number);
               v_buffer := v_buffer || 'type: "number"';
            ELSIF record_desc_table (col).col_type = 12
            THEN
               -- date
               DBMS_SQL.define_column (v_cursor, col, v_col_date);
               v_buffer := v_buffer || 'type: "date"';
            ELSIF record_desc_table (col).col_type = 187
            THEN
               -- timestamp
               DBMS_SQL.define_column (v_cursor, col, v_col_datetime);
               v_buffer := v_buffer || 'type: "datetime"';
            ELSE
               raise_application_error (-20001, 'Not expected datatype');
            END IF;

            -- test format! Only valid for number, date and timestamp, ignore the rest
            IF     record_desc_table (col).col_type IN (2, 12, 187)
               AND g_datasource_formats (col) IS NOT NULL
               AND NOT g_opt_no_format
            THEN
               DECLARE
                  v_type                        VARCHAR2 (20);
               BEGIN
                  IF record_desc_table (col).col_type = 2
                  THEN
                     v_type := 'Number';
                     v_test_format := TO_CHAR (1, g_datasource_formats (col));
                  ELSIF record_desc_table (col).col_type = 12
                  THEN
                     v_type := 'Date';
                     v_test_format := TO_CHAR (SYSDATE, g_datasource_formats (col));
                  ELSIF record_desc_table (col).col_type = 187
                  THEN
                     v_type := 'Datetime';
                     v_test_format := TO_CHAR (SYSTIMESTAMP, g_datasource_formats (col));
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     raise_application_error (-20060
                                             ,    'Invalid format given for '
                                               || v_type
                                               || ' column: '
                                               || g_datasource_formats.COUNT
                                               || ' '
                                               || g_datasource_formats (col));
               END;
            END IF;

            IF col < v_col_cnt
            THEN
               v_buffer := v_buffer || '},';
            ELSE
               v_buffer := v_buffer || '}';
            END IF;

            v_buffer := v_buffer || CHR (10);
         END IF;
      END LOOP;

      -- return the json object with the proper response Handler given
      IF NOT g_debug
      THEN
         OWA_UTIL.mime_header ('text/x-json', FALSE, NULL);
         HTP.p ('Pragma: no-cache');
         HTP.p ('Expires: Thu, 01 Jan 1970 12:00:00 GMT');
         OWA_UTIL.http_header_close;
      END IF;

      -- start the JSON object
      p (NVL (get_tqx_attr ('responseHandler', tqx), 'google.visualization.Query.setResponse') || '(');
      p ('{');
      p (' version: "' || g_version || '",');
      p (' status: "ok",');
      p (' reqId: ' || NVL (get_tqx_attr ('reqId', tqx), 0) || ',');
      -- TODO: signature ??
      -- p(' signature: "928347923874923874",');

      -- start building the table
      p (' table: {');
      -- define cols
      p ('  cols: [');
      p (v_buffer);
      p ('  ],');
      -- rows!
      p ('  rows: [');
      v_first := TRUE;

      LOOP
         -- Fetch a row from the source table
         EXIT WHEN DBMS_SQL.fetch_rows (v_cursor) = 0;

         -- create row details

         -- Add the col and rows objects to the table json
         IF v_first
         THEN
            p ('   {c: [ ');
            v_first := FALSE;
         ELSE
            p ('   ,{c: [ ');
         END IF;

         FOR col IN 1 .. v_col_cnt
         LOOP
            IF record_desc_table (col).col_name != 'RNUM'
            THEN
               prn ('    {');

               IF record_desc_table (col).col_type IN (1, 9, 96)
               THEN
                  -- varchar, varchar2, char
                  DBMS_SQL.COLUMN_VALUE (v_cursor, col, v_col_char);

                  IF v_col_char IS NULL
                  THEN
                     prn ('v: null');
                  ELSE
                     prn ('v: "');
                     printjsonstring (v_col_char);
                     prn ('"');
                  END IF;
               ELSIF record_desc_table (col).col_type = 2
               THEN
                  -- number
                  DBMS_SQL.COLUMN_VALUE (v_cursor, col, v_col_number);

                  -- TODO: opt no_values
                  IF v_col_number IS NULL
                  THEN
                     prn ('v: null');
                  ELSE
                     prn ('v: ' || TO_CHAR (v_col_number));

                     IF     g_datasource_formats (col) IS NOT NULL
                        AND NOT g_opt_no_format
                     THEN
                        prn (', f: "' || TO_CHAR (v_col_number, g_datasource_formats (col)) || '"');
                     END IF;
                  END IF;
               ELSIF record_desc_table (col).col_type = 12
               THEN
                  DBMS_SQL.COLUMN_VALUE (v_cursor, col, v_col_date);

                  IF v_col_date IS NULL
                  THEN
                     prn ('v: null');
                  ELSE
                     prn (   'v: new Date('
                          || NVL (TRIM (LEADING '0' FROM TO_CHAR (v_col_date, 'yyyy')), '0')
                          || ','
                          || NVL (TRIM (LEADING '0' FROM TO_CHAR (v_col_date, 'mm')), '0')
                          || ','
                          || NVL (TRIM (LEADING '0' FROM TO_CHAR (v_col_date, 'dd')), '0')
                          || ','
                          || NVL (TRIM (LEADING '0' FROM TO_CHAR (v_col_date, 'hh24')), '0')
                          || ','
                          || NVL (TRIM (LEADING '0' FROM TO_CHAR (v_col_date, 'mi')), '0')
                          || ','
                          || NVL (TRIM (LEADING '0' FROM TO_CHAR (v_col_date, 'ss')), '0')
                          || ')');

                     IF     g_datasource_formats (col) IS NOT NULL
                        AND NOT g_opt_no_format
                     THEN
                        prn (', f: "' || TO_CHAR (v_col_date, g_datasource_formats (col)) || '"');
                     ELSIF NOT g_opt_no_format
                     THEN
                        prn (', f: "' || TO_CHAR (v_col_date, 'yyyy-mm-dd hh24:mi:ss') || '"');
                     END IF;
                  END IF;
               ELSIF record_desc_table (col).col_type = 187
               THEN
                  DBMS_SQL.COLUMN_VALUE (v_cursor, col, v_col_datetime);

                  IF v_col_datetime IS NULL
                  THEN
                     prn ('v: null');
                  ELSE
                     prn (   'v: new Date('
                          || NVL (TRIM (LEADING '0' FROM TO_CHAR (v_col_datetime, 'yyyy')), '0')
                          || ','
                          || NVL (TRIM (LEADING '0' FROM TO_CHAR (v_col_datetime, 'mm')), '0')
                          || ','
                          || NVL (TRIM (LEADING '0' FROM TO_CHAR (v_col_datetime, 'dd')), '0')
                          || ','
                          || NVL (TRIM (LEADING '0' FROM TO_CHAR (v_col_datetime, 'hh24')), '0')
                          || ','
                          || NVL (TRIM (LEADING '0' FROM TO_CHAR (v_col_datetime, 'mi')), '0')
                          || ','
                          || NVL (TRIM (LEADING '0' FROM TO_CHAR (v_col_datetime, 'ss')), '0')
                          || '.'
                          || NVL (TRIM (LEADING '0' FROM TO_CHAR (v_col_datetime, 'ff3')), '0')
                          || ')');

                     IF     g_datasource_formats (col) IS NOT NULL
                        AND NOT g_opt_no_format
                     THEN
                        prn (', f: "' || TO_CHAR (v_col_datetime, g_datasource_formats (col)) || '"');
                     ELSIF NOT g_opt_no_format
                     THEN
                        prn (', f: "' || TO_CHAR (v_col_datetime, 'yyyy-mm-dd hh24:mi:ss') || '"');
                     END IF;
                  END IF;
               ELSIF record_desc_table (col).col_type = 112
               THEN
                  -- CLOB
                  DBMS_SQL.COLUMN_VALUE (v_cursor, col, v_col_clob);

                  IF    NVL (DBMS_LOB.getlength (v_col_clob), 0) = 0
                     OR v_col_clob IS NULL
                  THEN
                     prn ('v: null');
                  ELSE
                     prn ('v: "');
                     printjsonstring (v_col_clob);
                     prn ('"');
                  END IF;
               END IF;

               IF col < v_col_cnt
               THEN
                  prn ('},');
               ELSE
                  prn ('}');
               END IF;

               nl;
            END IF;
         END LOOP;

         p ('   ]}');
      END LOOP;

      p ('  ]');
      p (' }');
      p ('}');
      -- finish!
      p (')');
      DBMS_SQL.close_cursor (v_cursor);
   EXCEPTION
      WHEN OTHERS
      THEN
         DECLARE
            v_errors                      t_varchar2;
            v_messages                    t_varchar2;
            v_detailed_messages           t_varchar2;
         BEGIN
            v_errors (1) := SQLCODE;
            v_messages (1) := SQLERRM;
            print_json_error (v_errors, v_messages, v_detailed_messages, tqx);
         END;
   END get_json;

   /**
    * Send errors
    *
    */
   PROCEDURE print_json_error (
      p_reasons                  IN       t_varchar2
     ,p_messages                 IN       t_varchar2
     ,p_detailed_messages        IN       t_varchar2
     ,tqx                                 VARCHAR2 DEFAULT NULL)
   IS
   BEGIN
      -- return the json object with the proper response Handler given
      IF NOT g_debug
      THEN
         OWA_UTIL.mime_header ('text/x-json', FALSE, NULL);
         p ('Pragma: no-cache');
         p ('Expires: Thu, 01 Jan 1970 12:00:00 GMT');
         OWA_UTIL.http_header_close;
      END IF;

      p (NVL (get_tqx_attr ('responseHandler', tqx), 'google.visualization.Query.setResponse') || '(');
      p ('{');
      p (' version: "' || g_version || '",');
      p (' status: "error",');
      p (' reqId: ' || NVL (get_tqx_attr ('reqId', tqx), 0) || ',');
      -- signature ??
      -- p(' signature: "928347923874923874",');
      p (' errors: [');

      IF NVL (p_reasons.COUNT, 0) = 0
      THEN
         p ('   {reason: "Undefined error in GDataSource package"}');
      ELSE
         FOR e IN 1 .. p_reasons.COUNT
         LOOP
            IF e > 1
            THEN
               p (',');
               prn ('   {');
            ELSE
               prn ('   {');
            END IF;

            prn ('reason: "');
            printjsonstring (p_reasons (e));
            prn ('"');

            IF     p_messages.EXISTS (e)
               AND NVL (LENGTH (p_messages (e)), 0) > 0
            THEN
               prn (', message: "');
               printjsonstring (p_messages (e));
               prn ('"');
            END IF;

            IF     p_detailed_messages.EXISTS (e)
               AND NVL (LENGTH (p_detailed_messages (e)), 0) > 0
            THEN
               prn (', detailed_message: "');
               printjsonstring (p_detailed_messages (e));
               prn ('"');
            END IF;

            p ('}');
         END LOOP;
      END IF;

      p (' ]');
      p ('}');
      -- finish!
      p (')');
   END print_json_error;

   /**
   *
   *  Wrapper functions needed for Google Query functions
   *
   */
   FUNCTION todate (
      p_date                     IN       TIMESTAMP)
      RETURN DATE
   IS
   BEGIN
      RETURN TO_DATE (TO_CHAR (p_date, 'yyyy-mm-dd'), 'yyyy-mm-dd');
   END todate;

   FUNCTION todate (
      p_date                     IN       NUMBER)
      RETURN DATE
   IS
   BEGIN
      RETURN TO_DATE ('1970-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss') + (p_date / 1000 / 60 / 60 / 24);
   END todate;
END gdatasource; 
/


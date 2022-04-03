-- First we create an utility table "calendar"
CREATE TABLE calendar (
	date DATE NOT NULL PRIMARY KEY COMMENT 'Date, format Y-m-d',
	year YEAR NOT NULL,
	year_days SMALLINT UNSIGNED NOT NULL COMMENT 'Year days count, eg. 365 or 366',
	month TINYINT NOT NULL COMMENT 'Month number, range 1-12',
	month_days TINYINT NOT NULL COMMENT 'Month days count, range 28-31',
	month_full TINYTEXT NOT NULL COMMENT 'Month name',
	month_short TINYTEXT NOT NULL COMMENT 'Month short name, eg. "Jan."',
	month_first_day DATE COMMENT 'First month day',
	month_last_day DATE COMMENT 'Last month day',
	week TINYINT UNSIGNED NOT NULL COMMENT 'ISO week number in year',
	day TINYINT UNSIGNED NOT NULL COMMENT 'Day of month, range 1-31',
	weekday TINYINT UNSIGNED NOT NULL COMMENT 'ISO day of week (Monday = 1, Sunday = 7), range 1-7',
	weekday_full TINYTEXT NOT NULL COMMENT 'Day name',
	weekday_short TINYTEXT NOT NULL COMMENT 'Day short name, eg. "Mon."',
	workday CHAR(1),
	weekend CHAR(1),
	yearday SMALLINT UNSIGNED NOT NULL COMMENT 'Day of year, range 1-366',
	yearsemester SMALLINT UNSIGNED NOT NULL COMMENT 'Year and semester (1-2)',
	yearquarter SMALLINT UNSIGNED NOT NULL COMMENT 'Year and quarter (1-4)',
	yearmonth MEDIUMINT UNSIGNED NOT NULL COMMENT 'Year and month (01-12)',
	yearmonth_iso CHAR(7) NOT NULL COMMENT 'Year and month, ISO format "YEAR(4)-MONTH(2)"',
	yearweek MEDIUMINT UNSIGNED NOT NULL COMMENT 'Year and ISO week',
	yearweek_iso CHAR(8) NOT NULL COMMENT 'Year and ISO week, ISO format "YEAR(4)-WWEEK(2)"',
	yearweekday MEDIUMINT UNSIGNED NOT NULL COMMENT '',
	yearweekday_iso CHAR(10) NOT NULL COMMENT 'Year and ISO week/day, ISO format "YEAR(4)-WWEEK(2)-DOW(1)"',
	seconds_0 BIGINT UNSIGNED NOT NULL COMMENT 'Nombre de secondes depuis 0000-00-00',
	seconds_unix INT UNSIGNED NOT NULL COMMENT 'Nombre de secondes depuis 1970-01-01',
	INDEX (yearmonth),
	INDEX (yearweek)
);

-- Increase recursion as needed
-- MySQL setting, check your RDBM manual if needed
SET @@cte_max_recursion_depth = 20000;

-- Init calendar with recursive CTE
INSERT INTO calendar
WITH RECURSIVE calendar_dates (date) AS (
	(SELECT ALL '2000-01-01')
	UNION ALL
	(SELECT ALL date + INTERVAL 1 DAY FROM calendar_dates WHERE date < '2039-12-31')
    -- That's beautiful :)
)
SELECT ALL
	date,
	YEAR(date),
	DAYOFYEAR(CONCAT(YEAR(date), '-12-31')),
	MONTH(date),
	DAY(LAST_DAY(date)),
	DATE_FORMAT(date, '%M'),
	DATE_FORMAT(date, '%b'),
	CONCAT(EXTRACT(YEAR_MONTH FROM date), '01'),
	LAST_DAY(date),
	WEEK(date, 3), -- First day of week	monday, with 4 or more days this year, range 1-53
	DAYOFMONTH(date),
	WEEKDAY(date) + 1,
	DATE_FORMAT(date, '%W'),
	DATE_FORMAT(date, '%a'),
	IF(DAYOFWEEK(date) BETWEEN 2 AND 6, 'Y', 'N'),
	IF(DAYOFWEEK(date) IN (1, 7), 'Y', 'N'),
	DAYOFYEAR(date),
	CONCAT(YEAR(date), ((MONTH(date) - 1) DIV 6) + 1),
	CONCAT(YEAR(date), QUARTER(date)),
	EXTRACT(YEAR_MONTH FROM date),
	CONCAT(YEAR(date), '-', LPAD(MONTH(date), 2, '0')),
	YEARWEEK(date, 3),
	CONCAT(YEAR(date), '-W', LPAD(WEEK(date, 3), 2, '0')),
	CONCAT(YEAR(date), LPAD(WEEK(date, 3), 2, '0'), DAYOFWEEK(date)),
	CONCAT(YEAR(date), '-W', LPAD(WEEK(date, 3), 2, '0'), '-', DAYOFWEEK(date)),
	TO_SECONDS(date),
	UNIX_TIMESTAMP(date)
FROM calendar_dates;

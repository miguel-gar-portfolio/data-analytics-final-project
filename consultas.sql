CREATE TABLE mreid (
	iso3_o CHAR(3),
	country_o VARCHAR(50),
	iso3_d CHAR(3),
	country_d VARCHAR(50),
	year INT(4),
	naics2 INT(2),
	naics2description VARCHAR(300),
	extensive INT,
	greenfield INT,
	mergers INT,
	OperatingrevenueTurnover FLOAT,
	OperatingrevenueTurnover_green FLOAT,
	OperatingrevenueTurnover_mergers FLOAT,
	TotalassetsthUSD FLOAT,
	TotalassetsthUSD_green FLOAT,
	TotalassetsthUSD_mergers FLOAT,
	Numberofemployees INT,
	Numberofemployees_green INT, 
	Numberofemployees_mergers INT,
	FixedassetsthUSD FLOAT,
	FixedassetsthUSD_green FLOAT,
	FixedassetsthUSD_mergers FLOAT
)

ALTER TABLE mreid 
MODIFY Numberofemployees FLOAT ; 

CREATE TABLE `currency_exchange_rates` (
  `date` timestamp NULL DEFAULT NULL,
  `usd` float DEFAULT NULL,
  `eur` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


/*�Cu�l es el top 10 pa�ses donde el ratio Facturaci�n por empleado es m�s alto?*/
SELECT 
	country_d,
	SUM(OperatingrevenueTurnover)/SUM(Numberofemployees) as revenue_per_employee
FROM mreid m 
GROUP BY country_d 
ORDER BY revenue_per_employee DESC
LIMIT 10


/*�Cu�l es el bottom 10 pa�ses donde el ratio Facturaci�n por empleado es m�s bajo?*/
SELECT 
	country_d,
	IFNULL(SUM(OperatingrevenueTurnover)/SUM(Numberofemployees),0) as revenue_per_employee
FROM mreid m 
GROUP BY country_d 
ORDER BY revenue_per_employee 
LIMIT 10

/* �Cu�les son los 5 sectores con mejor evoluci�n entre 2010 y 2021, en el n�mero de
empresas (extensive) en inversi�n (TotalassetsthUSD) dom�stica en Espa�a?
 */

SELECT
	naics2description as sector ,
	year,
	SUM(TotalassetsthUSD) as investments_total,
	SUM(extensive) as number_of_enterprises
FROM mreid m 
WHERE (country_o = country_d) AND (country_o = 'Spain')	
GROUP BY  year, naics2description



/*�Cu�les son los 5 sectores con peor evoluci�n entre 2010 y 2021, en el n�mero de
empresas (extensive) en inversi�n (TotalassetsthUSD) internacional en Espa�a?
(empresas con origen internacional y con destino Espa�a) 
*/

SELECT
	naics2description as sector ,
	year,
	SUM(TotalassetsthUSD) as investments_total,
	SUM(extensive) as number_of_enterprises
FROM mreid m 
WHERE (country_o != 'Spain') AND (country_d = 'Spain')	
GROUP BY naics2description, year


/* 5. Importe en � (EUROS), en el 2020 de la inversi�n extranjera en la Pen�nsula Ib�rica
(Espa�a, Portugal y Andorra), en el sector Finanzas y Seguros.
 */

SELECT  
 	A.sector,
 	A.quantity * B.EUR  as quantity_in_eur
FROM 
	(SELECT 
		naics2description as sector,
		SUM(TotalassetsthUSD) as quantity
	FROM mreid m 
	WHERE (country_o != country_d) 
	AND ((country_d = 'Spain') OR (country_d = 'Portugal') OR (country_d='Andorra')) 
	AND (year=2020) 
	AND (naics2description = 'Finance and Insurance ')) AS A, 
	(SELECT EUR
	FROM currency_exchange_rates cer
	WHERE date = '2020-01-01 00:00:00') AS B


/*Importe en � (EUROS), en el 2015 del ratio Facturaci�n por empleado en Italia,
para el sector de Bienes Ra�ces*/
SELECT  
 	A.sector,
 	A.quantity * B.EUR  as quantity_in_eur
FROM 
	(SELECT 
		naics2description as sector,
		SUM(TotalassetsthUSD) as quantity
	FROM mreid m 
	WHERE (country_o != country_d) 
	AND ((country_d = 'Spain') OR (country_d = 'Portugal') OR (country_d='Andorra')) 
	AND (year=2015) 
	AND (naics2description = 'Real Estate ')) AS A, 
	(SELECT EUR
	FROM currency_exchange_rates cer
	WHERE date = '2015-01-01 00:00:00') AS B




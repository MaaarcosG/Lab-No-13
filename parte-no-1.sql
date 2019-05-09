/*********************************
Universidad del Valle de Guatemala
Base de Datos
Marcos Gutierrez		17909
David Valenzuela		171001
**********************************/

-- Inciso A, la tabla se puede encontrar en la carpeta llamada database
Select * from d_date;

-- Inciso B
-- Unimos la tabla de d_date con las que se encuentran en la base de datos

Select * from Invoiceline 
	Inner Join invoice on invoice.InvoiceId = Invoiceline.InvoiceId
	Inner Join d_date on d_date.date_actual = invoice.InvoiceDate;

-- Inciso C
-- Creamos un objeto de materalizacion
Drop Materialized view ventas;
CREATE MATERIALIZED VIEW ventas AS
	SELECT invoice.BillingCity, invoice.BillingCountry, d_date.year_actual, d_date.quarter_actual, d_date.month_actual, 
		   d_date.week_of_year, genre.Name AS nameCancion, MediaType.Name AS tipoCancion, SUM(InvoiceLine.Quantity * InvoiceLine.UnitPrice) as total FROM Invoice
	INNER JOIN InvoiceLine ON invoice.InvoiceId = InvoiceLine.InvoiceId
	INNER JOIN d_date ON d_date.date_actual = invoice.InvoiceDate
	INNER JOIN Track ON Track.TrackId = InvoiceLine.TrackId
	INNER JOIN MediaType ON MediaType.MediaTypeId = Track.MediaTypeId
	INNER JOIN Genre ON Genre.GenreId = Track.GenreId
GROUP BY CUBE(
	invoice.BillingCity, invoice.BillingCountry, d_date.year_actual, d_date.quarter_actual, 
	d_date.month_actual, d_date.week_of_year, nameCancion, MediaType.Name
);

SELECT * FROM ventas;


--Insciso D
--> 1. ¿Cuál es el tipo de archivo de audio más vendido en la base de datos?
	SELECT ventas.nameCancion, ventas.tipoCancion, ventas.Total FROM ventas
		WHERE ventas.tipoCancion IS NOT NULL 
		ORDER BY ventas.Total
	DESC
	LIMIT 3;	

--> 2. ¿Cuál fue el género más vendido durante el 2013?
	SELECT ventas.nameCancion, ventas.year_actual, ventas.total FROM ventas
		WHERE (ventas.nameCancion IS NOT NULL) AND (ventas.year_actual = 2013) 
	ORDER BY ventas.total DESC
	LIMIT 3;

--> 3. ¿Cómo han evolucionado las ventas semanales durante el 2012?
	
	SELECT ventas.nameCancion, ventas.year_actual, ventas.week_of_year, ventas.total FROM ventas
		WHERE (ventas.week_of_year IS NOT NULL) AND (ventas.year_actual = 2012)  AND (ventas.billingcountry IS NULL)
		AND (ventas.billingcity IS NULL) AND (ventas.quarter_actual IS NULL) 
		AND (ventas.month_actual IS NULL) AND (ventas.nameCancion IS NULL) AND (ventas.tipoCancion IS NULL)
	ORDER by ventas.week_of_year ASC;
	
--> 4. ¿Cuál ha sido nuestro mejor trimestre de ventas?
	SELECT ventas.tipoCancion, ventas.quarter_actual, ventas.total FROM ventas
		WHERE (ventas.quarter_actual IS NOT NULL) and (ventas.tipoCancion IS NOT NULL)
	ORDER BY ventas.quarter_actual IS NOT NULL
	DESC
	LIMIT 1;
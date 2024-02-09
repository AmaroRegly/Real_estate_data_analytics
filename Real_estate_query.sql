#DATA EXPLORATION AND DATA CLEANING ---------------------------------------

#Arrumar o item "São Paulo" ---------------

UPDATE real_estate_dataset
SET city = 'Sao Paulo'
WHERE city = 'SÃ£o Paulo';

#"Arrumar a coluna floor de "-" para "0" -----------------
SET SQL_SAFE_UPDATES = 0;

UPDATE real_estate_dataset
SET floor = "-"
WHERE floor = 0;

#Padronizar o nomes das colunas -----------------------

ALTER TABLE real_estate_dataset
CHANGE `hoa (R$)` hoa INT;

ALTER TABLE real_estate_dataset
CHANGE `rent amount (R$)` rent_amount INT;

ALTER TABLE real_estate_dataset
CHANGE `property tax (R$)` property_tax INT;

ALTER TABLE real_estate_dataset
CHANGE `fire insurance (R$)` fire_insurance INT;

ALTER TABLE real_estate_dataset
CHANGE `total (R$)` total INT;

ALTER TABLE real_estate_dataset
CHANGE `parking spaces` parking_spaces INT;

#Adicionar coluna de M² ------------

ALTER TABLE real_estate_dataset
ADD COLUMN m2_price float;

UPDATE real_estate_dataset
SET m2_price = total / area;

#Identificar e duplicatas --------------

CREATE VIEW vw_real_estate_dataset AS
select distinct
	city, area, rooms, bathroom, parking_spaces, floor, animal, furniture, hoa, rent_amount, property_tax, fire_insurance, total, m2_price
from
	real_estate_dataset;

#DATA ANALYSIS ---------------------------------------------------

#Número de imóveis por cidade

SELECT
	city,
    COUNT(*) AS number_of_properties
FROM
	vw_real_estate_dataset
GROUP BY
	city
ORDER BY
	number_of_properties desc;
    
#Quantos imóveis são mobiliados em cada cidade?

SELECT
	city,
	COUNT(furniture) AS property_furnished
FROM
	vw_real_estate_dataset
WHERE
	furniture = 'furnished'
GROUP BY
	city
ORDER BY
	property_furnished desc;

#Quantos imóveis aceitam pet em cada cidade?

SELECT
	city,
	COUNT(animal) AS property_acept_pet
FROM
	vw_real_estate_dataset
WHERE
	animal = 'acept'
GROUP BY
	city
ORDER BY
	property_acept_pet desc;

#Preço médio do m² por cidade ------

SELECT
	city,
    ROUND(AVG(m2_price), 2) AS avg_m2_price
FROM
	vw_real_estate_dataset
GROUP BY
	city
ORDER BY
	avg_m2_price desc;

#Area média por cidade e total médio por cidade ----------

SELECT
	city,
    AVG(area) AS avg_area,
    AVG(total) AS avg_total_rent
FROM
	vw_real_estate_dataset
GROUP BY
	city
ORDER BY
	avg_area desc;
	
#Quais os imóveis mais baratos  em cada cidade? --------

SELECT
	*
FROM
	vw_real_estate_dataset
WHERE total IN (
	SELECT MIN(total)
    FROM vw_real_estate_dataset
    GROUP BY city
);

#Quais os imóveis com área acima da média em cada cidade?

SELECT
    city, area, rooms, bathroom, parking_spaces, floor, animal, furniture, hoa, rent_amount, property_tax, fire_insurance, total
FROM
    vw_real_estate_dataset AS main
WHERE
    area > (
        SELECT AVG(area)
        FROM vw_real_estate_dataset AS sub
        WHERE sub.city = main.city
    )
ORDER BY
    city, area;
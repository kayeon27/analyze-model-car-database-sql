/**------------------simulation de transfert de stock-----------------**/
 
/**Pour commencer, nous allons determiner les capacité d'unité restante dans 
les entrepots disponibles en prenant en compte la variable warehousePctCap 
qui est en %. cette varible n'etant pas fourni, nous chercherons a la trouver en
 ajoutant une colonne warehouseTotalCapacity a la table warehouses qui contient 
 les quantités trouvées partir d'une requete precedente.**/

/**calcul de capacité restante en unité**/
SELECT 
    w.warehouseCode,
    w.warehouseName,
    w.warehouseTotalCapacity AS total_capacity_units,
    (w.warehouseTotalCapacity * (100 - w.warehousePctCap) / 100) AS available_capacity_units
FROM
    warehouses w
WHERE
    w.warehouseCode IN ('a' , 'b', 'c')
ORDER BY available_capacity_units DESC;
 

/**redistribution dans les entrepots disponibles**/

/**Cette redistribution devra se faire en tenant compte de la capacité d'unité disponible 
afin de ne pas faire de surstockage et gerer efficacement le service client**/
SELECT 
    w.warehouseCode,
    w.warehouseName,
    (w.warehouseTotalCapacity * (100 - w.warehousePctCap) / 100) AS available_capacity_units,
    LEAST(
        ((w.warehouseTotalCapacity * (100 - w.warehousePctCap) / 100) / (SELECT 
                SUM(w2.warehouseTotalCapacity * (100 - w2.warehousePctCap) / 100)
            FROM
                warehouses w2
            WHERE
                w2.warehouseCode IN ('a' , 'b', 'c'))) * (SELECT 
                SUM(p.quantityInStock)
            FROM
                products p
            WHERE
                p.warehouseCode = 'd'),
        (w.warehouseTotalCapacity * (100 - w.warehousePctCap) / 100)
    ) AS allocated_stock
FROM
    warehouses w
WHERE
    w.warehouseCode IN ('a' , 'b', 'c')
ORDER BY available_capacity_units DESC;
/** La fonction Least permet de limiter la valeur de du stock alloué en faisant une verification 
entre les deux valeur afin de ne pas depasser la capacité de stockage disponible des entrepots.**/
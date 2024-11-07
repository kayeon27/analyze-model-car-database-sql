SELECT VERSION();
show tables;

/*** -------------analyser les tendances de ventes-----------------***/
/**La jointure presente dans les 3 requetes suivantes permettent de 
lier la table orderDetails a la table Products en fonction de productCode
 afin de recuperer les informations correspondant aux deux tables
 (associer chaque produits avec les informations de sa commande) **/
 
 
SELECT 
    p.productCode,
    p.productName,
    p.warehouseCode,
    SUM(od.quantityOrdered) AS total_quantity_sold
FROM
    products p
        JOIN
    orderdetails od ON p.productCode = od.productCode
GROUP BY productCode , productName , warehouseCode
ORDER BY total_quantity_sold DESC
LIMIT 25;


/*** impact du prix sur les ventes**/
SELECT 
    od.productCode,
    p.productName,
    AVG(od.priceEach) AS averagePrice,
    SUM(od.quantityOrdered) AS totalQuantitySold
FROM
    orderdetails od
        JOIN
    products p ON od.productCode = p.productCode
GROUP BY od.productCode
ORDER BY averagePrice DESC;


/**produit faiblement vendu et peu rentable**/

SELECT 
    p.productCode,
    p.productName,
    p.warehouseCode,
    SUM(od.quantityOrdered) AS total_sold
FROM
    products p
        JOIN
    orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode , p.warehouseCode
HAVING total_sold < 850
ORDER BY total_sold ASC;


/**Commande par client**/
/** les 3 jointures permettent de : 
relier la table order et la table custumer en fonction de custumerNumber 
afin d'associer chaque commande avec les informations du clients**/


SELECT 
    c.customerNumber,
    c.customerName,
    o.orderNumber,
    w.warehouseCode,
	COUNT(o.orderNumber) AS total_orders,
    SUM(od.quantityOrdered) AS total_items_ordered
FROM 
    customers c
JOIN 
    orders o ON c.customerNumber = o.customerNumber
JOIN 
    orderdetails od ON o.orderNumber = od.orderNumber
JOIN 
    products p ON od.productCode = p.productCode
JOIN 
    warehouses w ON p.warehouseCode = w.warehouseCode
GROUP BY 
    c.customerNumber, c.customerName, o.orderNumber, w.warehouseCode
ORDER BY 
    total_items_ordered DESC;




/**------------Inventaires----------------**/
/**les requetes suivantes permettent de calaculer le total de quantité de produits 
ainsi que le total financier dans touts les entrepots en faisant la somme de ceux ci **/

/**inventaire des quantités **/
SELECT 
    warehouseCode, SUM(quantityInStock) AS total_quantity
FROM
    products
GROUP BY warehouseCode;

/**inventaire financier***/
SELECT 
    warehouseCode,
    SUM(buyPrice * quantityInStock) AS total_inventory_value
FROM
    products
GROUP BY warehouseCode;

 

/**--------Analyse whatIf----------**/
/**c'est une analyse Hypothétique qui permet de simuler des scenarios 
et d'anticiper l'impact d'un changement spécifiquesur notre situation **/

/**total des quantitées vendu pour l'entrepot visé**/
SELECT 
    p.warehouseCode,
    productLine,
    p.productCode,
    p.productName,
    SUM(od.quantityOrdered) AS total_sold
FROM
    products p
        JOIN
    orderdetails od ON p.productCode = od.productCode
WHERE
    warehouseCode = 'd'
GROUP BY p.productCode , p.productName , productLine
ORDER BY total_sold ASC;
/**cette analyse permet de distinguer les produits les plus vendu comme prioritaires
 pour le transferts afin de maintenir la satisfaction des clients**/


/**total des des produit/categories en stock avec une reduction de 5%**/
SELECT 
    productLine,
    SUM(quantityInStock) AS total_stock,
    SUM(quantityInStock * 0.95) AS reduced_stock
FROM
    products
GROUP BY productLine;


/**total des des produit en stock avec une reduction de 5%**/
SELECT 
    productCode,
    productName,
    quantityInStock,
    ROUND(quantityInStock * 0.95) AS newQuantityInStock
FROM
    products;
/**la reduction des quantitées par categorie ou par produit en stock permet d'identifier 
les produits qui pourrait etre enrupture de stock apres la reduction**/



/**impact de la reduction des produits sur le service client**/
SELECT 
    p.productCode,
    p.productName,
    ROUND(p.quantityInStock * 0.95) AS newQuantityInStock,
    SUM(od.quantityOrdered) AS recentDemand
FROM
    products p
        JOIN
    orderdetails od ON p.productCode = od.productCode
        JOIN
    orders o ON od.orderNumber = o.orderNumber
WHERE
    o.orderDate >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY p.productCode
HAVING newQuantityInStock < recentDemand;
/**apres cette analyse on conclu que la reduction de 5% du stock n'affecte pas le service client
 pour les 3 derniers mois pris. Alors La fermeture d’un entrepôt devient ainsi plus viable,
 car les autres entrepôts devraient pouvoir supporter cette réduction de niveau sans compromettre
 la disponibilité des produits.**/
 /**Ce qui nous conduit au scenario 1**/


/**Capacité de stockage restant pour les entrepots en % **/
SELECT 
    w.warehouseCode,
    w.warehouseName,
    (100 - w.warehousePctCap) AS remaining_capacity_pct
FROM
    warehouses w;

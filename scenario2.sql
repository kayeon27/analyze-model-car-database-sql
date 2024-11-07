/**preparation du stockage de distribution**/

/**Dans ce scenario, nous allons transformer l'entrepot cible en centre
 de distribution specifique. Nous allons nous servir des produits avec les plus 
 de vente (plus demandé) afin de le remplir et ainsi optimiser les délais de
 livraison et de réduire les coûts de stockage.  **/


/*Pour ce faire nous allons ajouter une nouvelle colonne isDistributionCenter
 dans notre table warehouses. Cette colonne a pour objectif de preciser que 
 l'entreport choisi est le centre de distribution  */
alter table warehouses
add column isDistributionCenter boolean default false;


 
UPDATE warehouses 
SET 
    isDistributionCenter = TRUE
WHERE
    warehouseCode = 'd';


/**distribution des produits les plus demandées dans l'entrepot cible**/

/**La creation de la table temporaire topProduct contourner la limitation
 de MySQL qui empêche l'utilisation de LIMIT dans une sous-requête avec IN 
 et de stocker les 25 premiers produits les plus demandés**/

create temporary table topProducts as 
select p.productCode
from products p
join orderdetails od on p.productCode =  od.productCode
group by productCode
order by sum(od.quantityOrdered) desc
limit 25;

UPDATE products 
SET 
    warehouseCode = 'd'
WHERE
    productCode IN (SELECT 
            productCode
        FROM
            topProducts);
            
 
 /**Verifer que les odifications ont eté appliquées
 et supprimer la table temporaire si elle n'a pas deja été supprimé**/
 
/**Verification du stocks**/
SELECT 
    productCode, productName, quantityInStock
FROM
    products
WHERE
    warehouseCode = 'd'
ORDER BY quantityInStock ASC;


/**/
DROP TEMPORARY TABLE IF EXISTS topProducts;

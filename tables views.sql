SELECT * FROM mintclassics.products;
select * from mintclassics.orderdetails;
select * from mintclassics.warehouses;
select * from mintclassics.productlines;
alter table warehouses
add column warehouseTotalCapacity int;

UPDATE warehouses
SET warehouseTotalCapacity = 131688
WHERE warehouseCode = 'a';

UPDATE warehouses
SET warehouseTotalCapacity = 219183
WHERE warehouseCode = 'b';

UPDATE warehouses
SET warehouseTotalCapacity = 124880
WHERE warehouseCode = 'c';

UPDATE warehouses
SET warehouseTotalCapacity = 79380
WHERE warehouseCode = 'd'; 

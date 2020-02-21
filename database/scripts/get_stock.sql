USE `stock_management`;
DROP procedure IF EXISTS `get_stock`;

DELIMITER $$
USE `stock_management`$$

CREATE PROCEDURE get_stock
(
 IN in_product_ids varchar(255)
)
BEGIN
IF in_product_ids IS NOT NULL 
    THEN
        SET  @sql = concat("SELECT p.product_id, p.product_name, s.location, s.stock_level 
        FROM product as p Left JOIN stock as s ON p.product_id = s.product_id 
        WHERE p.product_id IN (" , in_product_ids , ")");
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
    ELSE
        SELECT p.product_id, p.product_name, s.location ,s.stock_level 
        FROM product as p Left JOIN stock as s ON p.product_id = s.product_id;
END IF;

END$$

DELIMITER ;


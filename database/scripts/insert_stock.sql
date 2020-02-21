USE `stock_management`;
DROP procedure IF EXISTS `insert_stock`;

DELIMITER $$
USE `stock_management`$$

CREATE PROCEDURE insert_stock
(
 IN in_product_id varchar(255), 
 IN in_product_name varchar(255), 
 IN in_stock_level int,
 IN in_location varchar(255)
)
BEGIN
DECLARE is_success INT DEFAULT 0;
DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN	
	SELECT is_success;
        ROLLBACK;
        RESIGNAL;
    END;
	
START TRANSACTION;
	  
IF (SELECT count(*) FROM stock where product_id = in_product_id AND location = in_location > 0) 
    THEN
	UPDATE stock SET stock_level = in_stock_level WHERE product_id = in_product_id AND location = in_location;
    ELSE
        INSERT IGNORE INTO product (product_id, product_name)   VALUES (in_product_id, in_product_name);
	INSERT INTO stock (product_id, location, stock_level) VALUES (in_product_id, in_location, in_stock_level);
END IF;    
    
COMMIT;

SET is_success = 1;
SELECT is_success;
END$$

DELIMITER ;



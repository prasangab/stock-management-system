USE `stock_management`;
DROP procedure IF EXISTS `change_stock`;

DELIMITER $$
USE `stock_management`$$

CREATE PROCEDURE change_stock
(
 IN in_product_id varchar(255), 
 IN in_change int, 
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

UPDATE stock SET stock_level = stock_level + in_change 
WHERE product_id = in_product_id AND location = in_location;

COMMIT;

SET is_success = 1;
SELECT is_success;
END$$

DELIMITER ;


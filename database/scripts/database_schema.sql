CREATE DATABASE IF NOT EXISTS `stock_management`;
USE stock_management;

CREATE TABLE IF NOT EXISTS product 
(
    id int auto_increment,
    product_id varchar(255) NOT NULL UNIQUE,
    product_name varchar(255) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS stock (
    id int auto_increment,
    product_id varchar(255) NOT NULL,
    location ENUM('store','storage'),
    stock_level int,
    PRIMARY KEY (id)
);



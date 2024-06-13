-- Criação de um banco de dados para gerenciamento de estoques para produtos alimenticios, incluindo controle de validade e lote

CREATE DATABASE IF NOT EXISTS food_inventory;
USE food_inventory;

-- Tabela de produtos

CREATE TABLE IF NOT EXISTS products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    category VARCHAR(30),
    unit VARCHAR(10), -- Unidade de medida, como kg, litro, unidade, etc.
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela Fornecedores

CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    contact_name VARCHAR(50),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(50),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de Lotes

CREATE TABLE IF NOT EXISTS batches (
    batch_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    supplier_id INT,
    quantity DECIMAL(10, 2) NOT NULL,
    expiration_date DATE NOT NULL,
    received_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Tabela de Entradas de Estoque

CREATE TABLE IF NOT EXISTS stock_entries (
    entry_id INT AUTO_INCREMENT PRIMARY KEY,
    batch_id INT NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    entry_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (batch_id) REFERENCES batches(batch_id)
);

-- Tabela de Saídas de Estoque

CREATE TABLE IF NOT EXISTS stock_exits (
    exit_id INT AUTO_INCREMENT PRIMARY KEY,
    batch_id INT NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    exit_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (batch_id) REFERENCES batches(batch_id)
);

-- Visualizar Estoque Atual

CREATE VIEW current_stock AS
SELECT
    p.product_id,
    p.name AS product_name,
    SUM(be.quantity) - COALESCE(SUM(se.quantity), 0) AS total_quantity
FROM
    products p
LEFT JOIN
    batches b ON p.product_id = b.product_id
LEFT JOIN
    stock_entries be ON b.batch_id = be.batch_id
LEFT JOIN
    stock_exits se ON b.batch_id = se.batch_id
GROUP BY
    p.product_id, p.name;
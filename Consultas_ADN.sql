-- consultas adicionais para gerar relatórios sobre produtos próximos da data de validade, movimentação de estoque, etc.

-- Relatório de Produtos Próximos da Data de Validade

SELECT 
    p.product_id,
    p.name AS product_name,
    b.batch_id,
    b.quantity,
    b.expiration_date,
    DATEDIFF(b.expiration_date, CURDATE()) AS days_until_expiration
FROM 
    products p
JOIN 
    batches b ON p.product_id = b.product_id
WHERE 
    b.expiration_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 30 DAY)
ORDER BY 
    b.expiration_date ASC;

-- Relatório de Movimentação de Estoque

SELECT 
    p.product_id,
    p.name AS product_name,
    b.batch_id,
    se.entry_id AS movement_id,
    se.quantity AS movement_quantity,
    'Entrada' AS movement_type,
    se.entry_date AS movement_date
FROM 
    products p
JOIN 
    batches b ON p.product_id = b.product_id
JOIN 
    stock_entries se ON b.batch_id = se.batch_id
WHERE 
    se.entry_date BETWEEN '2024-01-01' AND '2024-12-31'
UNION ALL
SELECT 
    p.product_id,
    p.name AS product_name,
    b.batch_id,
    sx.exit_id AS movement_id,
    sx.quantity AS movement_quantity,
    'Saída' AS movement_type,
    sx.exit_date AS movement_date
FROM 
    products p
JOIN 
    batches b ON p.product_id = b.product_id
JOIN 
    stock_exits sx ON b.batch_id = sx.batch_id
WHERE 
    sx.exit_date BETWEEN '2024-01-01' AND '2024-12-31'
ORDER BY 
    movement_date ASC;

-- Relatório de Estoque Atual

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(be.quantity) - COALESCE(SUM(se.quantity), 0) AS current_stock
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

-- Relatório de Lotes Recebidos por Fornecedor

SELECT 
    s.supplier_id,
    s.name AS supplier_name,
    b.batch_id,
    p.product_id,
    p.name AS product_name,
    b.quantity,
    b.received_date
FROM 
    suppliers s
JOIN 
    batches b ON s.supplier_id = b.supplier_id
JOIN 
    products p ON b.product_id = p.product_id
ORDER BY 
    s.name, b.received_date;

-- Relatório de Produtos com Baixo Estoque

SELECT 
    p.product_id,
    p.name AS product_name,
    SUM(be.quantity) - COALESCE(SUM(se.quantity), 0) AS current_stock
FROM 
    products p
LEFT JOIN 
    batches b ON p.product_id = b.product_id
LEFT JOIN 
    stock_entries be ON b.batch_id = be.batch_id
LEFT JOIN 
    stock_exits se ON b.batch_id = se.batch_id
GROUP BY 
    p.product_id, p.name
HAVING 
    current_stock < 50;

-- Relatório de Produtos com Maior Movimento de Estoque

SELECT 
    p.product_id,
    p.name AS product_name,
    COALESCE(SUM(be.quantity), 0) AS total_entries,
    COALESCE(SUM(se.quantity), 0) AS total_exits,
    (COALESCE(SUM(be.quantity), 0) + COALESCE(SUM(se.quantity), 0)) AS total_movement
FROM 
    products p
LEFT JOIN 
    batches b ON p.product_id = b.product_id
LEFT JOIN 
    stock_entries be ON b.batch_id = be.batch_id
LEFT JOIN 
    stock_exits se ON b.batch_id = se.batch_id
WHERE 
    (be.entry_date BETWEEN '2024-01-01' AND '2024-12-31' OR se.exit_date BETWEEN '2024-01-01' AND '2024-12-31')
GROUP BY 
    p.product_id, p.name
ORDER BY 
    total_movement DESC;

-- Relatório de Produtos com Maior Movimento de Estoque

SELECT 
    p.product_id,
    p.name AS product_name,
    COALESCE(SUM(be.quantity), 0) AS total_entries,
    COALESCE(SUM(se.quantity), 0) AS total_exits,
    (COALESCE(SUM(be.quantity), 0) + COALESCE(SUM(se.quantity), 0)) AS total_movement
FROM 
    products p
LEFT JOIN 
    batches b ON p.product_id = b.product_id
LEFT JOIN 
    stock_entries be ON b.batch_id = be.batch_id
LEFT JOIN 
    stock_exits se ON b.batch_id = se.batch_id
WHERE 
    (be.entry_date BETWEEN '2024-01-01' AND '2024-12-31' OR se.exit_date BETWEEN '2024-01-01' AND '2024-12-31')
GROUP BY 
    p.product_id, p.name
ORDER BY 
    total_movement DESC;
    
-- Relatório de Produtos por Categoria

SELECT 
    category,
    GROUP_CONCAT(name ORDER BY name ASC SEPARATOR ', ') AS products
FROM 
    products
GROUP BY 
    category
ORDER BY 
    category;

-- THANKS     

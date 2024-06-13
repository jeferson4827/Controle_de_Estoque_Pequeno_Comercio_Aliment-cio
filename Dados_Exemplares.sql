-- Inserção de Dados Exemplares

INSERT INTO products (name, description, category, unit) VALUES
('Maçã', 'Maçã verde fresca', 'Frutas', 'kg'),
('Leite', 'Leite integral', 'Laticínios', 'litro');

-- Inserindo Fornecedores

INSERT INTO suppliers (name, contact_name, contact_phone, contact_email, address) VALUES
('Fornecedor A', 'João Silva', '111-222-3333', 'joao@fornecedorA.com', 'Rua A, 123'),
('Fornecedor B', 'Maria Souza', '444-555-6666', 'maria@fornecedorB.com', 'Rua B, 456');

-- Inserindo Lotes

INSERT INTO batches (product_id, supplier_id, quantity, expiration_date, received_date) VALUES
(1, 1, 100, '2024-12-31', '2024-06-01'),
(2, 2, 200, '2024-07-01', '2024-06-01');

-- Inserindo Entradas de Estoque

INSERT INTO stock_entries (batch_id, quantity) VALUES
(1, 100),
(2, 200);

-- Inserindo Saídas de Estoque

INSERT INTO stock_exits (batch_id, quantity) VALUES
(1, 20),
(2, 50);

-- Consultas de Estoque

SELECT * FROM current_stock WHERE product_id = 1;
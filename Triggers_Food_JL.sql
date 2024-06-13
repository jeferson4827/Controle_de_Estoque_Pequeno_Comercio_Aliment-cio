CREATE TRIGGER before_batches_update
BEFORE UPDATE ON batches
FOR EACH ROW
BEGIN
    -- Verifica se a nova quantidade é negativa
    IF NEW.quantity < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A quantidade do lote não pode ser negativa';
    END IF;
    
    -- Verifica se a nova data de validade é anterior à data de recebimento
    IF NEW.expiration_date < NEW.received_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A data de validade não pode ser anterior à data de recebimento';
    END IF;
END$$

DELIMITER ;

-- Trigger para Deleções

DELIMITER $$

CREATE TRIGGER before_batches_delete
BEFORE DELETE ON batches
FOR EACH ROW
BEGIN
    -- Deletar entradas de estoque associadas ao lote
    DELETE FROM stock_entries WHERE batch_id = OLD.batch_id;
    
    -- Deletar saídas de estoque associadas ao lote
    DELETE FROM stock_exits WHERE batch_id = OLD.batch_id;
END$$

DELIMITER ;

-- Trigger para Atualizações de stock_entries e stock_exits

DELIMITER $$

CREATE TRIGGER before_stock_entries_update
BEFORE UPDATE ON stock_entries
FOR EACH ROW
BEGIN
    DECLARE total_stock DECIMAL(10, 2);

    -- Calcula o estoque total atual, excluindo a entrada que está sendo atualizada
    SELECT (SUM(quantity) - OLD.quantity + NEW.quantity) INTO total_stock
    FROM stock_entries
    WHERE batch_id = NEW.batch_id;

    -- Verifica se o estoque total não excede a quantidade do lote
    IF total_stock > (SELECT quantity FROM batches WHERE batch_id = NEW.batch_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A quantidade de entrada excede a quantidade do lote';
    END IF;
END$$

DELIMITER ;

-- Trigger para stock_exits

DELIMITER $$

CREATE TRIGGER before_stock_exits_delete
BEFORE DELETE ON stock_exits
FOR EACH ROW
BEGIN
    DECLARE total_entry DECIMAL(10, 2);

    -- Calcula o total de entradas associadas ao lote
    SELECT SUM(quantity) INTO total_entry
    FROM stock_entries
    WHERE batch_id = OLD.batch_id;

    -- Verifica se a quantidade de saídas após a deleção é válida
    IF total_entry - OLD.quantity < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é possível deletar a saída, pois causaria inconsistência no estoque';
    END IF;
END$$

DELIMITER ;




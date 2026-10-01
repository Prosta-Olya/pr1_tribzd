-- Запрос на заполнение таблицы уценка

DELETE FROM Уценка;
ALTER TABLE Уценка
ALTER COLUMN [коэф уценки] DECIMAL(3,1) NOT NULL;

-- 6 месяцев + 1 день
INSERT INTO Уценка (id_хранения, [дата уценки], [коэф уценки], [новая цена])
SELECT 
    s.id_хранения,
    DATEADD(day, 1, DATEADD(month, 6, s.[дата поступления])) AS [дата уценки],
    1.5 AS [коэф уценки],
    t.[начальная цена] / 1.5 AS [новая цена]
FROM Товары t
JOIN Хранение s ON t.id_товара = s.id_товара
WHERE 
    -- Проверяем, что дата уже наступила
    GETDATE() > DATEADD(day, 1, DATEADD(month, 6, s.[дата поступления]))
    -- Проверяем, чтобы не было дубля
    AND NOT EXISTS (
        SELECT 1 
        FROM Уценка u 
        WHERE u.id_хранения = s.id_хранения 
          AND u.[коэф уценки] = 1.5
    );

-- 10 месяцев + 1 день
INSERT INTO Уценка (id_хранения, [дата уценки], [коэф уценки], [новая цена])
SELECT 
    s.id_хранения,
    DATEADD(day, 1, DATEADD(month, 10, s.[дата поступления])) AS [дата уценки],
    2.0 AS [коэф уценки],
    t.[начальная цена] / 2.0 AS [новая цена]
FROM Товары t
JOIN Хранение s ON t.id_товара = s.id_товара
WHERE 
    -- Проверяем, что наступила дата второй уценки
    GETDATE() > DATEADD(day, 1, DATEADD(month, 10, s.[дата поступления]))
    -- Проверяем, чтобы не было дубля
    AND NOT EXISTS (
        SELECT 1 
        FROM Уценка u 
        WHERE u.id_хранения = s.id_хранения 
          AND u.[коэф уценки] = 2.0
    );
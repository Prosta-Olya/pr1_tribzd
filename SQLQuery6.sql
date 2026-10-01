-- Запрос на просмотр мин и макс срока хранения, мин и макс цены до/после уценки

SELECT 
    MIN(storage_months) AS [Мин. срок хранения],
    MAX(storage_months) AS [Макс. срок хранения],
    MIN(price_before) AS [Мин. цена до уценки],
    MAX(price_before) AS [Макс. цена до уценки],
    MIN(price_after) AS [Мин. цена после уценки],
    MAX(price_after) AS [Макс. цена после уценки],
    SUM(price_before) AS [Сумма цен до уценки],
    SUM(price_after) AS [Сумма цен после уценки]
FROM (
    SELECT 
        -- Срок хранения на момент уценки
        DATEDIFF(month, s.[дата поступления], u.[дата уценки]) AS storage_months,
        t.[начальная цена] AS price_before,
        u.[новая цена] AS price_after
    FROM Уценка u
    JOIN Хранение s ON u.id_хранения = s.id_хранения
    JOIN Товары t ON s.id_товара = t.id_товара
) AS SubQuery;

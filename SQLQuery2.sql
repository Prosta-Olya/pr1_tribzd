-- Запрос уценка

DECLARE @ProductName NVARCHAR(100) = N'ноутбук';
DECLARE @TargetDate  DATETIME     = N'20260903';

IF NOT EXISTS (SELECT 1 FROM Товары WHERE название = @ProductName)
BEGIN
    SELECT N'Товар не найден в справочнике' AS [Сообщение];
END
ELSE
BEGIN
    --  Поставки, которые уже на складе к дате расчета
    SELECT
        t.название                 AS [Товар],
        t.[ед измерения]           AS [Ед. изм.],
        s.id_хранения              AS [ID поставки],
        s.[кол-во]                 AS [Кол-во],
        s.[дата поступления]       AS [Дата поставки],
        @TargetDate                AS [Дата расчета],
        t.[начальная цена]         AS [Начальная цена],
        CASE WHEN u.[новая цена] IS NOT NULL
             THEN u.[новая цена]
             ELSE t.[начальная цена]
        END                        AS [Цена на указанную дату],
        N'На складе'               AS [Статус]
    FROM Товары t
    JOIN Хранение s
        ON t.id_товара = s.id_товара
       AND CAST(s.[дата поступления] AS DATE) <= CAST(@TargetDate AS DATE)
    OUTER APPLY (
        SELECT TOP 1 u.[новая цена]
        FROM Уценка u
        WHERE u.id_хранения = s.id_хранения
          AND CAST(u.[дата уценки] AS DATE) <= CAST(@TargetDate AS DATE)
        ORDER BY u.[дата уценки] DESC   -- берём самую свежую уценку на дату расчета
    ) AS u
    WHERE t.название = @ProductName

    UNION ALL

    --  Поставки, которые ещё не пришли к дате расчета
    SELECT
        t.название,
        t.[ед измерения],
        s.id_хранения,
        s.[кол-во],
        s.[дата поступления],
        @TargetDate,
        t.[начальная цена],
        NULL,
        N'Ещё не завезён на склад'
    FROM Товары t
    JOIN Хранение s
        ON t.id_товара = s.id_товара
       AND CAST(s.[дата поступления] AS DATE) > CAST(@TargetDate AS DATE)
    WHERE t.название = @ProductName

    ORDER BY [Дата поставки], [ID поставки];
END
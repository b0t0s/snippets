SELECT
      db_id() AS database_id,
      o.[type] AS object_type,
      i.[type] AS index_type,
      p.[data_compression],
      COUNT_BIG(DISTINCT p.[object_id]) AS NumTables,
      COUNT_BIG(DISTINCT CAST(p.[object_id] AS VARCHAR(30)) + '|' + CAST(p.[index_id] AS VARCHAR(10))) AS NumIndexes,
      ISNULL(px.[IsPartitioned], 0) AS IsPartitioned,
      IIF(px.[IsPartitioned] = 1, COUNT_BIG(1), 0) NumPartitions,
      SUM(p.[rows]) NumRows
      FROM sys.partitions p
      INNER JOIN sys.objects o
      ON o.[object_id] = p.[object_id]
      INNER JOIN sys.indexes i
      ON i.[object_id] = p.[object_id]
      AND i.[index_id] = p.[index_id]
      OUTER APPLY (SELECT
      x.[object_id], 1 AS [IsPartitioned]
      FROM sys.partitions x
      WHERE x.[object_id] = p.[object_id]
      GROUP by
      x.[object_id]
      HAVING MAX(x.partition_number) > 1) px
      WHERE o.[type] NOT IN ('S', 'IT')
      GROUP BY
      o.[type]
      ,i.[type]
      ,p.[data_compression]
      ,px.[IsPartitioned]

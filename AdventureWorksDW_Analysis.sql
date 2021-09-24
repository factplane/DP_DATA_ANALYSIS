----------------------------------------------------------------------------
-- 1. SQL to find whether an employee met sales quota
----------------------------------------------------------------------------
SELECT * 
    FROM (
    SELECT table3.*,
        CASE
            WHEN (table3.ActualSales > table3.TargetQuota) THEN 1 ELSE 0
        END AS TargetMet
        FROM (
        SELECT table1.EmployeeKey,
            table1.TargetQuota,
            table1.CalendarYear,
            table2.ActualSales,
            table2.year1
            FROM (
            SELECT SUM(SalesAmountQuota) AS TargetQuota,
                EmployeeKey,
                CalendarYear
                FROM AdventureWorksDW.FactSalesQuota
                GROUP BY EmployeeKey,
                    CalendarYear) AS table1 FULL OUTER JOIN (
            SELECT EmployeeKey,
                SUM(SalesAmount) AS ActualSales,
                YEAR(OrderDate) AS year1
                FROM AdventureWorksDW.FactResellerSales
                GROUP BY EmployeeKey,
                    year1) AS table2 ON (table1.EmployeeKey = table2.EmployeeKey AND table1.CalendarYear = year1) ) AS table3 ) AS table5
                    Order by EmployeeKey;
                    
-------------------------------------------------------                    
--2. Top 5 products based on profit across all region       
-------------------------------------------------------                    
                    
SELECT table4.*,
    table5.EnglishProductName,
    table6.SalesTerritoryCountry
    FROM (
    SELECT table3.*
        FROM (
        SELECT DENSE_RANK() OVER (PARTITION BY SalesTerritoryKey
            ORDER BY Profit DESC) AS rank_sales,
                Profit,
                ProductKey,
                TotalCostPrice,
                TotalSalePrice,
                SalesTerritoryKey
            FROM (
            SELECT ProductKey,
                (TotalSalePrice - TotalCostPrice) AS Profit,
                TotalCostPrice,
                TotalSalePrice,
                SalesTerritoryKey
                FROM (
                SELECT ProductKey,
                    SUM(TotalProductCost) AS TotalCostPrice,
                    SUM(SalesAmount) AS TotalSalePrice,
                    SalesTerritoryKey
                    FROM AdventureWorksDW.FactInternetSales
                    GROUP BY SalesTerritoryKey,
                        ProductKey UNION ALL
                SELECT ProductKey,
                    SUM(TotalProductCost) AS TotalCostPrice,
                    SUM(SalesAmount) AS TotalSalePrice,
                    SalesTerritoryKey
                    FROM AdventureWorksDW.FactResellerSales
                    GROUP BY SalesTerritoryKey,
                        ProductKey) AS table1) AS table2) AS table3
        WHERE table3.rank_sales <= 5) AS table4 LEFT JOIN AdventureWorksDW.DimProduct AS table5 ON (table4.ProductKey = table5.ProductKey) LEFT JOIN AdventureWorksDW.DimSalesTerritory AS table6 ON (table4.SalesTerritoryKey = table6.SalesTerritoryKey);
        
        
-------------------------------------------------------           
--3. Top 10 products with the lowest inventory (I found the top 10 products having lowest inventory RECENTLY)
-------------------------------------------------------    
    SELECT table4.*,
    jt.EnglishProductName
    FROM (
    SELECT *
        FROM (
        SELECT DENSE_RANK() OVER (
            ORDER BY UnitsBalance) AS rank_balance,
                table2.*
            FROM (
            SELECT table1.*
                FROM (
                SELECT ProductKey,
                    UnitsBalance,
                    DateKey,
                    ROW_NUMBER() OVER (PARTITION BY ProductKey
                    ORDER BY DateKey DESC) AS r_num
                    FROM AdventureWorksDW.FactProductInventory) AS table1
                WHERE r_num = 1) AS table2) AS table3
        WHERE rank_balance <= 10) AS table4 LEFT JOIN AdventureWorksDW.DimProduct AS jt ON (jt.ProductKey = table4.ProductKey);
        
 -------------------------------------------------------           
--4. Tops 5 profitable products in each region
-------------------------------------------------------    
 SELECT table4.*,
    table5.EnglishProductName,
    table6.SalesTerritoryCountry
    FROM
    (
    SELECT table3.*
        FROM 
        (
        SELECT DENSE_RANK() OVER (PARTITION BY SalesTerritoryKey
            ORDER BY Profit DESC) AS rank_sales,
                Profit,
                ProductKey,
                TotalCostPrice,
                TotalSalePrice,
                SalesTerritoryKey
            FROM
            (
            SELECT ProductKey,
                (TotalSalePrice - TotalCostPrice) AS Profit,
                TotalCostPrice,
                TotalSalePrice,
                SalesTerritoryKey
                FROM
                (
                SELECT ProductKey,
                    SUM(TotalProductCost) AS TotalCostPrice,
                    SUM(SalesAmount) AS TotalSalePrice,
                    SalesTerritoryKey
                    FROM AdventureWorksDW.FactInternetSales
                    GROUP BY SalesTerritoryKey,
                        ProductKey
                UNION ALL
                SELECT ProductKey,
                    SUM(TotalProductCost) AS TotalCostPrice,
                    SUM(SalesAmount) AS TotalSalePrice,
                    SalesTerritoryKey
                    FROM AdventureWorksDW.FactResellerSales
                    GROUP BY SalesTerritoryKey,
                        ProductKey) AS table1) AS table2) AS table3
        WHERE table3.rank_sales <= 5) AS table4
    LEFT JOIN AdventureWorksDW.DimProduct AS table5 ON (table4.ProductKey = table5.ProductKey)
    LEFT JOIN AdventureWorksDW.DimSalesTerritory AS table6 ON (table4.SalesTerritoryKey = table6.SalesTerritoryKey);
        
       
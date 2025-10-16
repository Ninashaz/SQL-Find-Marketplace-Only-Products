# Identifying Products Exclusively Sold on a Single Platform
## Description:
This repository contains a SQL script that solves a common business logic problem in product and inventory management. The task involves filtering products based on the business platform of their active variants.

## Problem Statement:
Given a ProductVariants table, which contains product variants (e.g., different sizes or colors for a single product), find all ProductCodes where every single active variant is sold only on the 'Marketplace' platform.

In other words, if a product has any active variant that is not on 'MarketPlace', it should be excluded from the result.

The Solution Approach:
The logic can be broken down into two main sets:

Set A: All products that have at least one active variant on 'MarketPlace'.

Set B: All products that have at least one active variant on a platform that is not 'MarketPlace' (i.e., 'Retail').

The final result is the set of products that are in Set A but are NOT in Set B. This is perfectly achieved using a LEFT JOIN and checking for NULL values from the second set.

## SQL Code:
    -- 1. Create and Populate the ProductVariants Table with Sample Data
    USE master;
    IF OBJECT_ID('ProductVariants', 'U') IS NOT NULL
        DROP TABLE ProductVariants;
    
    CREATE TABLE ProductVariants (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        ProductCode NVARCHAR(50) NOT NULL,
        ProductVariantCode NVARCHAR(50) NOT NULL UNIQUE,
        IsActive BIT NOT NULL,
        BusinessType NVARCHAR(20) NOT NULL CHECK (BusinessType IN ('MarketPlace', 'Retail')),
        BusinessCode BIT NOT NULL
    );
    
    -- Generate 500 random sample records
    DECLARE @i INT = 1;
    DECLARE @TotalRecords INT = 500;
    WHILE @i <= @TotalRecords
    BEGIN
        DECLARE @ProductCode NVARCHAR(50) = CONCAT('P', FORMAT((@i + ABS(CHECKSUM(NEWID()))) % 100, '000'));
        DECLARE @VariantCode NVARCHAR(50) = CONCAT(@ProductCode, '-', FORMAT(@i, '000'));
        DECLARE @IsActive BIT = ABS(CHECKSUM(NEWID())) % 2;
        DECLARE @BusinessType NVARCHAR(20);
        DECLARE @BusinessCode BIT;
  
      IF (ABS(CHECKSUM(NEWID())) % 2 = 0)
      BEGIN
          SET @BusinessType = 'MarketPlace';
          SET @BusinessCode = 0;
      END
      ELSE
      BEGIN
          SET @BusinessType = 'Retail';
          SET @BusinessCode = 1;
      END;
  
      INSERT INTO ProductVariants (ProductCode, ProductVariantCode, IsActive, BusinessType, BusinessCode)
      VALUES (@ProductCode, @VariantCode, @IsActive, @BusinessType, @BusinessCode);
      SET @i = @i + 1;
    END;
  
    -- 2. The Core Query to Solve the Problem
    WITH MarketplaceProducts AS (
        SELECT
            ProductCode,
            BusinessType
        FROM ProductVariants
        WHERE IsActive = 1
          AND BusinessType = 'MarketPlace'
    ),
    NonMarketplaceProducts AS (
        SELECT
            ProductCode,
            BusinessType
        FROM ProductVariants
        WHERE IsActive = 1
          AND BusinessType <> 'MarketPlace' -- This will capture 'Retail'
    )
    
    SELECT DISTINCT MarketplaceProducts.ProductCode
    FROM MarketplaceProducts
    LEFT JOIN NonMarketplaceProducts
        ON MarketplaceProducts.ProductCode = NonMarketplaceProducts.ProductCode
    -- The WHERE clause is key: it finds products in MarketplaceProducts
    -- that have NO matching entry in NonMarketplaceProducts.
    WHERE NonMarketplaceProducts.ProductCode IS NULL;

## Code Walkthrough:

Table Creation & Population:

The script first creates the ProductVariants table with constraints like UNIQUE and CHECK.

It then populates the table with 500 random records using a WHILE loop, simulating a real-world dataset.

Core Query using CTEs:

MarketplaceProducts CTE: Filters the table to get all active variants where the BusinessType is 'MarketPlace'.

NonMarketplaceProducts CTE: Filters the table to get all active variants where the BusinessType is not 'MarketPlace' (in this case, only 'Retail').

Final SELECT: Performs a LEFT JOIN from MarketplaceProducts to NonMarketplaceProducts on ProductCode. The WHERE NonMarketplaceProducts.ProductCode IS NULL condition is the crucial part. It returns only those products from the MarketplaceProducts list that have no corresponding entry in the NonMarketplaceProducts list. This means the product has active variants only in 'MarketPlace' and none in 'Retail'.

## Skills Demonstrated:

DDL (Data Definition Language): CREATE TABLE, DROP TABLE, defining constraints.

T-SQL Programming: Using variables, loops (WHILE), and random data generation for realistic testing.

Common Table Expressions (CTEs): Using WITH clauses to create named subqueries for better readability and structure.

Complex Joins and Filtering: Mastering the LEFT JOIN ... WHERE ... IS NULL pattern to perform an "anti-join," a powerful technique for finding exclusive records.

Set-Based Logic: Solving the problem by thinking in terms of sets and their relationships.

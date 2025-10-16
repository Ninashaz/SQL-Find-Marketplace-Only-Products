USE master;
IF OBJECT_ID('ProductVariants', 'U') IS NOT NULL
DROP TABLE ProductVariants;
CREATE TABLE ProductVariants (
ID INT IDENTITY(1,1) PRIMARY KEY,
ProductCode NVARCHAR(50) NOT NULL,
ProductVariantCode NVARCHAR(50) NOT NULL UNIQUE,
IsActive BIT NOT NULL,
BusinessType NVARCHAR(20) NOT NULL CHECK (BusinessType IN ('MarketPlace', 'Retail')),
BusinessCode BIT NOT NULL);
DECLARE @i INT = 1;
DECLARE @TotalRecords INT = 500;
WHILE @i <= @TotalRecords
BEGIN
DECLARE @ProductCode NVARCHAR(50) = CONCAT('P', FORMAT((@i + ABS(CHECKSUM(NEWID())))
% 100, '000'));
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
INSERT INTO ProductVariants (ProductCode, ProductVariantCode, IsActive, BusinessType,
BusinessCode)
VALUES (@ProductCode, @VariantCode, @IsActive, @BusinessType, @BusinessCode);
SET @i = @i + 1;
END;

with c2 as (
    SELECT
    ProductCode,
    BusinessType
    FROM ProductVariants
    WHERE isactive=1 AND BusinessType= 'MarketPlace'
),

c3 as (
   SELECT
    ProductCode,
    BusinessType
    FROM ProductVariants
    WHERE isactive=1 AND BusinessType <> 'MarketPlace'
)

SELECT distinct (c2.ProductCode )
from c2
 LEFT JOIN c3 ON c2.ProductCode = c3.ProductCode
 WHERE c3.ProductCode is NULL


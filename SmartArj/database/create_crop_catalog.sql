-- CREATE CROP CATALOG TABLE
IF OBJECT_ID('CropCatalog', 'U') IS NULL
BEGIN
    CREATE TABLE CropCatalog (
        CropCatalogID INT IDENTITY PRIMARY KEY,
        CropName NVARCHAR(100) NOT NULL,
        Category NVARCHAR(50) NOT NULL,
        MinTemp FLOAT,
        MaxTemp FLOAT,
        MinHumid FLOAT,
        MaxHumid FLOAT,
        ImageUrl NVARCHAR(500),
        Description NVARCHAR(500),
        IsSystemProvided BIT NOT NULL DEFAULT 1,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created CropCatalog table.';
END
ELSE
BEGIN
    PRINT 'CropCatalog table already exists.';
END

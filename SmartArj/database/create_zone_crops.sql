-- CREATE ZONE CROPS TABLE
IF OBJECT_ID('ZoneCrops', 'U') IS NULL
BEGIN
    CREATE TABLE ZoneCrops (
        ZoneCropID INT IDENTITY PRIMARY KEY,
        ZoneID INT NOT NULL,
        CropCatalogID INT NOT NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_ZoneCrops_Zone FOREIGN KEY (ZoneID) REFERENCES Zones(ZoneID),
        CONSTRAINT FK_ZoneCrops_CropCatalog FOREIGN KEY (CropCatalogID) REFERENCES CropCatalog(CropCatalogID),
        CONSTRAINT UQ_ZoneCrops_Zone_Crop UNIQUE (ZoneID, CropCatalogID)
    );
    PRINT 'Created ZoneCrops table.';
END
ELSE
BEGIN
    PRINT 'ZoneCrops table already exists.';
END

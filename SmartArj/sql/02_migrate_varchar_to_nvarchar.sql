-- =================================================================================
-- SCRIPT: TỰ ĐỘNG TẠO LỆNH SỬA VARCHAR SANG NVARCHAR VÀ XỬ LÝ INDEX
-- =================================================================================
-- Script này KHÔNG tự động thực thi (để đảm bảo an toàn). Nó sẽ `PRINT` ra các lệnh 
-- T-SQL. Bạn copy kết quả ở tab Messages trong SSMS ra một cửa sổ mới rồi chạy.
--
-- Điểm mạnh:
-- 1. Tự động quét toàn bộ cột VARCHAR.
-- 2. Đọc các Index phụ thuộc vào cột đó.
-- 3. Tạo lệnh DROP INDEX.
-- 4. Tạo lệnh ALTER TABLE ... ALTER COLUMN ... NVARCHAR.
-- 5. Tạo lệnh CREATE INDEX lại như cũ.
-- =================================================================================

SET NOCOUNT ON;

DECLARE @TableName NVARCHAR(256), @ColumnName NVARCHAR(256), @MaxLength INT, @IsNullable BIT
DECLARE @DropIndexSql NVARCHAR(MAX) = ''
DECLARE @RecreateIndexSql NVARCHAR(MAX) = ''
DECLARE @AlterColSql NVARCHAR(MAX) = ''
DECLARE @FinalScript NVARCHAR(MAX)

PRINT 'BEGIN TRANSACTION;';
PRINT 'GO';
PRINT '';

DECLARE col_cursor CURSOR FOR
SELECT t.name, c.name, c.max_length, c.is_nullable
FROM sys.columns c
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
JOIN sys.tables t ON c.object_id = t.object_id
WHERE ty.name = 'varchar' AND t.is_ms_shipped = 0

OPEN col_cursor
FETCH NEXT FROM col_cursor INTO @TableName, @ColumnName, @MaxLength, @IsNullable

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @DropIndexSql = ''
    SET @RecreateIndexSql = ''
    
    PRINT '-- ========================================='
    PRINT '-- Table: ' + @TableName + ' | Column: ' + @ColumnName
    PRINT '-- ========================================='

    -- Tìm các Index phụ thuộc
    DECLARE @IdxName NVARCHAR(256), @IsUnq BIT, @IsPK BIT, @FilterDef NVARCHAR(MAX)
    DECLARE idx_cursor CURSOR FOR
    SELECT i.name, i.is_unique, i.is_primary_key, i.filter_definition
    FROM sys.indexes i
    JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE i.object_id = OBJECT_ID(@TableName) AND c.name = @ColumnName AND i.type > 0
    
    OPEN idx_cursor
    FETCH NEXT FROM idx_cursor INTO @IdxName, @IsUnq, @IsPK, @FilterDef
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @IsPK = 1 
        BEGIN
            PRINT '-- Khóa chính (Primary Key)'
            PRINT 'ALTER TABLE [' + @TableName + '] DROP CONSTRAINT [' + @IdxName + '];'
            PRINT 'GO'
            
            -- Lấy tất cả các cột của PK này để tạo lại (không chỉ cột hiện tại)
            DECLARE @PKCols NVARCHAR(MAX) = ''
            SELECT @PKCols = @PKCols + '[' + c_pk.name + '], '
            FROM sys.index_columns ic_pk
            JOIN sys.columns c_pk ON ic_pk.object_id = c_pk.object_id AND ic_pk.column_id = c_pk.column_id
            WHERE ic_pk.object_id = OBJECT_ID(@TableName) AND ic_pk.index_id = (SELECT index_id FROM sys.indexes WHERE name = @IdxName)
            ORDER BY ic_pk.key_ordinal
            
            SET @PKCols = LEFT(@PKCols, LEN(@PKCols) - 1) -- Bỏ dấu phẩy cuối
            
            SET @RecreateIndexSql = @RecreateIndexSql + 'ALTER TABLE [' + @TableName + '] ADD CONSTRAINT [' + @IdxName + '] PRIMARY KEY (' + @PKCols + ');' + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)
        END
        ELSE
        BEGIN
            PRINT '-- Index thông thường'
            PRINT 'DROP INDEX [' + @IdxName + '] ON [' + @TableName + '];'
            PRINT 'GO'
            
            -- Lấy các cột cho Index
            DECLARE @IdxCols NVARCHAR(MAX) = ''
            SELECT @IdxCols = @IdxCols + '[' + c_idx.name + '] ' + CASE WHEN ic_idx.is_descending_key = 1 THEN 'DESC' ELSE 'ASC' END + ', '
            FROM sys.index_columns ic_idx
            JOIN sys.columns c_idx ON ic_idx.object_id = c_idx.object_id AND ic_idx.column_id = c_idx.column_id
            WHERE ic_idx.object_id = OBJECT_ID(@TableName) AND ic_idx.index_id = (SELECT index_id FROM sys.indexes WHERE name = @IdxName AND object_id = OBJECT_ID(@TableName))
            ORDER BY ic_idx.key_ordinal
            
            SET @IdxCols = LEFT(@IdxCols, LEN(@IdxCols) - 1)
            
            DECLARE @FilterClause NVARCHAR(MAX) = ''
            IF @FilterDef IS NOT NULL SET @FilterClause = ' WHERE ' + @FilterDef
            
            SET @RecreateIndexSql = @RecreateIndexSql + 'CREATE ' + CASE WHEN @IsUnq = 1 THEN 'UNIQUE ' ELSE '' END + 'NONCLUSTERED INDEX [' + @IdxName + '] ON [' + @TableName + '] (' + @IdxCols + ')' + @FilterClause + ';' + CHAR(13) + CHAR(10) + 'GO' + CHAR(13) + CHAR(10)
        END
        
        FETCH NEXT FROM idx_cursor INTO @IdxName, @IsUnq, @IsPK, @FilterDef
    END
    CLOSE idx_cursor
    DEALLOCATE idx_cursor

    -- Xác định độ dài mới
    DECLARE @NewLenStr NVARCHAR(10)
    IF @MaxLength = -1 OR @MaxLength > 4000 SET @NewLenStr = 'MAX'
    ELSE SET @NewLenStr = CAST(@MaxLength AS NVARCHAR(10))
    
    DECLARE @NullStr NVARCHAR(20) = CASE WHEN @IsNullable = 1 THEN 'NULL' ELSE 'NOT NULL' END

    PRINT '-- Chuyển đổi kiểu dữ liệu'
    PRINT 'ALTER TABLE [' + @TableName + '] ALTER COLUMN [' + @ColumnName + '] NVARCHAR(' + @NewLenStr + ') ' + @NullStr + ';'
    PRINT 'GO'
    
    IF @RecreateIndexSql <> ''
    BEGIN
        PRINT '-- Phục hồi lại các Index'
        PRINT @RecreateIndexSql
    END
    
    PRINT ''
    
    FETCH NEXT FROM col_cursor INTO @TableName, @ColumnName, @MaxLength, @IsNullable
END

CLOSE col_cursor
DEALLOCATE col_cursor

PRINT 'COMMIT TRANSACTION;';
PRINT 'GO';

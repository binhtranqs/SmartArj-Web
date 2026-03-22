# 01_check_varchar_columns.sql

Script này dùng để liệt kê tất cả các cột đang sử dụng kiểu `VARCHAR`, `CHAR`, hoặc `TEXT` trong cơ sở dữ liệu.

```sql
SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS IsNullable
FROM sys.columns c
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
JOIN sys.tables t ON c.object_id = t.object_id
WHERE ty.name IN ('varchar', 'char', 'text')
  AND t.is_ms_shipped = 0 -- Bỏ qua các bảng hệ thống
ORDER BY t.name, c.name;
```

-- SEED CROP CATALOG
SET NOCOUNT ON;
DECLARE @insertedCount INT = 0;

IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Lúa' AND Category = N'Lương thực')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Lúa', N'Lương thực', 22.0, 32.0, 60.0, 80.0, 'assets/crops/lua.jpg', N'Cây lúa thuộc nhóm lương thực.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Ngô' AND Category = N'Lương thực')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Ngô', N'Lương thực', 22.0, 32.0, 60.0, 80.0, 'assets/crops/ngo.jpg', N'Cây ngô thuộc nhóm lương thực.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Khoai lang' AND Category = N'Lương thực')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Khoai lang', N'Lương thực', 22.0, 32.0, 60.0, 80.0, 'assets/crops/khoai-lang.jpg', N'Cây khoai lang thuộc nhóm lương thực.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Khoai tây' AND Category = N'Lương thực')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Khoai tây', N'Lương thực', 22.0, 32.0, 60.0, 80.0, 'assets/crops/khoai-tay.jpg', N'Cây khoai tây thuộc nhóm lương thực.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Sắn' AND Category = N'Lương thực')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Sắn', N'Lương thực', 22.0, 32.0, 60.0, 80.0, 'assets/crops/san.jpg', N'Cây sắn thuộc nhóm lương thực.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Lúa mì' AND Category = N'Lương thực')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Lúa mì', N'Lương thực', 22.0, 32.0, 60.0, 80.0, 'assets/crops/lua-mi.jpg', N'Cây lúa mì thuộc nhóm lương thực.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Lúa mạch' AND Category = N'Lương thực')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Lúa mạch', N'Lương thực', 22.0, 32.0, 60.0, 80.0, 'assets/crops/lua-mach.jpg', N'Cây lúa mạch thuộc nhóm lương thực.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Đậu tương' AND Category = N'Lương thực')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Đậu tương', N'Lương thực', 22.0, 32.0, 60.0, 80.0, 'assets/crops/au-tuong.jpg', N'Cây đậu tương thuộc nhóm lương thực.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Đậu phộng' AND Category = N'Lương thực')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Đậu phộng', N'Lương thực', 22.0, 32.0, 60.0, 80.0, 'assets/crops/au-phong.jpg', N'Cây đậu phộng thuộc nhóm lương thực.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Đậu xanh' AND Category = N'Lương thực')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Đậu xanh', N'Lương thực', 22.0, 32.0, 60.0, 80.0, 'assets/crops/au-xanh.jpg', N'Cây đậu xanh thuộc nhóm lương thực.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Đậu đen' AND Category = N'Lương thực')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Đậu đen', N'Lương thực', 22.0, 32.0, 60.0, 80.0, 'assets/crops/au-en.jpg', N'Cây đậu đen thuộc nhóm lương thực.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Đậu đỏ' AND Category = N'Lương thực')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Đậu đỏ', N'Lương thực', 22.0, 32.0, 60.0, 80.0, 'assets/crops/au-o.jpg', N'Cây đậu đỏ thuộc nhóm lương thực.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Khoai sọ' AND Category = N'Lương thực')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Khoai sọ', N'Lương thực', 22.0, 32.0, 60.0, 80.0, 'assets/crops/khoai-so.jpg', N'Cây khoai sọ thuộc nhóm lương thực.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Khoai môn' AND Category = N'Lương thực')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Khoai môn', N'Lương thực', 22.0, 32.0, 60.0, 80.0, 'assets/crops/khoai-mon.jpg', N'Cây khoai môn thuộc nhóm lương thực.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Kê' AND Category = N'Lương thực')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Kê', N'Lương thực', 22.0, 32.0, 60.0, 80.0, 'assets/crops/ke.jpg', N'Cây kê thuộc nhóm lương thực.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Cà chua' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Cà chua', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/ca-chua.jpg', N'Cây cà chua thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Dưa leo' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Dưa leo', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/dua-leo.jpg', N'Cây dưa leo thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Bí đỏ' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Bí đỏ', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/bi-o.jpg', N'Cây bí đỏ thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Ớt' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Ớt', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/ot.jpg', N'Cây ớt thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Hành lá' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Hành lá', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/hanh-la.jpg', N'Cây hành lá thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Cải xanh' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Cải xanh', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/cai-xanh.jpg', N'Cây cải xanh thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Xà lách' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Xà lách', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/xa-lach.jpg', N'Cây xà lách thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Bắp cải' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Bắp cải', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/bap-cai.jpg', N'Cây bắp cải thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Rau muống' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Rau muống', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/rau-muong.jpg', N'Cây rau muống thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Cà rốt' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Cà rốt', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/ca-rot.jpg', N'Cây cà rốt thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Súp lơ' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Súp lơ', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/sup-lo.jpg', N'Cây súp lơ thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Bí đao' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Bí đao', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/bi-ao.jpg', N'Cây bí đao thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Dưa hấu' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Dưa hấu', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/dua-hau.jpg', N'Cây dưa hấu thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Khổ qua' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Khổ qua', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/kho-qua.jpg', N'Cây khổ qua thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Đậu cove' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Đậu cove', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/au-cove.jpg', N'Cây đậu cove thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Hành tây' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Hành tây', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/hanh-tay.jpg', N'Cây hành tây thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Tỏi' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Tỏi', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/toi.jpg', N'Cây tỏi thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Rau bina' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Rau bina', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/rau-bina.jpg', N'Cây rau bina thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Su hào' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Su hào', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/su-hao.jpg', N'Cây su hào thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Củ dền' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Củ dền', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/cu-den.jpg', N'Cây củ dền thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Cải ngọt' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Cải ngọt', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/cai-ngot.jpg', N'Cây cải ngọt thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Cải thìa' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Cải thìa', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/cai-thia.jpg', N'Cây cải thìa thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Cải thảo' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Cải thảo', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/cai-thao.jpg', N'Cây cải thảo thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Hành tím' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Hành tím', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/hanh-tim.jpg', N'Cây hành tím thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Măng tây' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Măng tây', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/mang-tay.jpg', N'Cây măng tây thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Cần tây' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Cần tây', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/can-tay.jpg', N'Cây cần tây thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Rau dền' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Rau dền', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/rau-den.jpg', N'Cây rau dền thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Rau ngót' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Rau ngót', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/rau-ngot.jpg', N'Cây rau ngót thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Mướp' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Mướp', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/muop.jpg', N'Cây mướp thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Bầu' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Bầu', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/bau.jpg', N'Cây bầu thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Cà tím' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Cà tím', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/ca-tim.jpg', N'Cây cà tím thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Su su' AND Category = N'Rau củ')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Su su', N'Rau củ', 18.0, 28.0, 70.0, 90.0, 'assets/crops/su-su.jpg', N'Cây su su thuộc nhóm rau củ.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Cà phê' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Cà phê', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/ca-phe.jpg', N'Cây cà phê thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Hồ tiêu' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Hồ tiêu', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/ho-tieu.jpg', N'Cây hồ tiêu thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Cao su' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Cao su', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/cao-su.jpg', N'Cây cao su thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Chè' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Chè', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/che.jpg', N'Cây chè thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Điều' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Điều', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/ieu.jpg', N'Cây điều thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Mía' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Mía', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/mia.jpg', N'Cây mía thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Bông' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Bông', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/bong.jpg', N'Cây bông thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Đay' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Đay', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/ay.jpg', N'Cây đay thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Cói' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Cói', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/coi.jpg', N'Cây cói thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Trầu không' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Trầu không', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/trau-khong.jpg', N'Cây trầu không thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Thuốc lá' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Thuốc lá', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/thuoc-la.jpg', N'Cây thuốc lá thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Cacao' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Cacao', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/cacao.jpg', N'Cây cacao thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Dừa sáp' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Dừa sáp', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/dua-sap.jpg', N'Cây dừa sáp thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Thầu dầu' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Thầu dầu', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/thau-dau.jpg', N'Cây thầu dầu thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Mắc ca' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Mắc ca', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/mac-ca.jpg', N'Cây mắc ca thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Quế' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Quế', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/que.jpg', N'Cây quế thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Hồi' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Hồi', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/hoi.jpg', N'Cây hồi thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Dâu tằm' AND Category = N'Công nghiệp')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Dâu tằm', N'Công nghiệp', 24.0, 35.0, 65.0, 85.0, 'assets/crops/dau-tam.jpg', N'Cây dâu tằm thuộc nhóm công nghiệp.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Thanh long' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Thanh long', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/thanh-long.jpg', N'Cây thanh long thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Xoài' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Xoài', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/xoai.jpg', N'Cây xoài thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Chuối' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Chuối', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/chuoi.jpg', N'Cây chuối thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Cam' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Cam', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/cam.jpg', N'Cây cam thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Bưởi' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Bưởi', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/buoi.jpg', N'Cây bưởi thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Sầu riêng' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Sầu riêng', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/sau-rieng.jpg', N'Cây sầu riêng thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Nhãn' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Nhãn', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/nhan.jpg', N'Cây nhãn thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Vải' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Vải', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/vai.jpg', N'Cây vải thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Chôm chôm' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Chôm chôm', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/chom-chom.jpg', N'Cây chôm chôm thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Mít' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Mít', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/mit.jpg', N'Cây mít thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Dừa' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Dừa', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/dua.jpg', N'Cây dừa thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Măng cụt' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Măng cụt', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/mang-cut.jpg', N'Cây măng cụt thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Đu đủ' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Đu đủ', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/u-u.jpg', N'Cây đu đủ thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Dưa lưới' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Dưa lưới', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/dua-luoi.jpg', N'Cây dưa lưới thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Nho' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Nho', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/nho.jpg', N'Cây nho thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Táo' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Táo', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/tao.jpg', N'Cây táo thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Lê' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Lê', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/le.jpg', N'Cây lê thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Ổi' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Ổi', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/oi.jpg', N'Cây ổi thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Mít tố nữ' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Mít tố nữ', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/mit-to-nu.jpg', N'Cây mít tố nữ thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Bơ' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Bơ', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/bo.jpg', N'Cây bơ thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Quýt' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Quýt', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/quyt.jpg', N'Cây quýt thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Chanh' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Chanh', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/chanh.jpg', N'Cây chanh thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Khế' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Khế', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/khe.jpg', N'Cây khế thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Vú sữa' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Vú sữa', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/vu-sua.jpg', N'Cây vú sữa thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Na' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Na', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/na.jpg', N'Cây na thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Mận' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Mận', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/man.jpg', N'Cây mận thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Đào' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Đào', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/ao.jpg', N'Cây đào thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Sơ ri' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Sơ ri', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/so-ri.jpg', N'Cây sơ ri thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Chanh dây' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Chanh dây', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/chanh-day.jpg', N'Cây chanh dây thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Kiwi' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Kiwi', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/kiwi.jpg', N'Cây kiwi thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Dâu tây' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Dâu tây', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/dau-tay.jpg', N'Cây dâu tây thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Mâm xôi' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Mâm xôi', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/mam-xoi.jpg', N'Cây mâm xôi thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Quất' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Quất', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/quat.jpg', N'Cây quất thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Quả óc chó' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Quả óc chó', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/qua-oc-cho.jpg', N'Cây quả óc chó thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END


IF NOT EXISTS (SELECT 1 FROM CropCatalog WHERE CropName = N'Hạt dẻ' AND Category = N'Trái cây')
BEGIN
    INSERT INTO CropCatalog (CropName, Category, MinTemp, MaxTemp, MinHumid, MaxHumid, ImageUrl, Description, IsSystemProvided) 
    VALUES (N'Hạt dẻ', N'Trái cây', 20.0, 30.0, 65.0, 85.0, 'assets/crops/hat-de.jpg', N'Cây hạt dẻ thuộc nhóm trái cây.', 1);
    SET @insertedCount = @insertedCount + 1;
END

PRINT 'Inserted ' + CAST(@insertedCount AS VARCHAR) + ' crops into CropCatalog.';
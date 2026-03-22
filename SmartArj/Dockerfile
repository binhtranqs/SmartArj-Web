# Dùng image chuẩn Tomcat bản mới nhất hỗ trợ Java 17
FROM tomcat:10.1-jdk17

# Nếu dự án của bạn (SmartArj) dùng phiên bản Tomcat cũ hơn (như Tomcat 9), hãy đổi lại như sau:
# FROM tomcat:9.0-jdk11

# Copy file WAR từ thư mục dist (sau khi NetBeans Clean & Build xong) vào Tomcat của máy chủ Render
# Đặc biệt: Tên file bắt buộc phải đổi thành ROOT.war để nó chạy ngay ở trang chủ (thay vì trangchu.com/SmartArj/)
COPY dist/SmartArj.war /usr/local/tomcat/webapps/ROOT.war

# Mở sẵn cổng 8080 cho Render
EXPOSE 8080

# Chạy Tomcat
CMD ["catalina.sh", "run"]

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="container">
    <h2>${editing ? "Edit Crop" : "New Crop"}</h2>

    <form method="post" action="${pageContext.request.contextPath}/crops">
        <c:if test="${editing}">
            <input type="hidden" name="id" value="${crop.cropId}" />
        </c:if>

        <%-- Crop Name: dropdown danh sách cây trồng phổ biến --%>
        <div class="form-group">
            <label>Tên cây trồng <span class="text-danger">*</span></label>
            <select name="cropName" class="form-control" required>
                <option value="">-- Chọn cây trồng --</option>

                <optgroup label="🌿 Công nghiệp">
                    <option value="Cà phê" ${crop.cropName == 'Cà phê' ? 'selected' : ''}>Cà phê</option>
                    <option value="Hồ tiêu" ${crop.cropName == 'Hồ tiêu' ? 'selected' : ''}>Hồ tiêu</option>
                    <option value="Cao su" ${crop.cropName == 'Cao su' ? 'selected' : ''}>Cao su</option>
                    <option value="Điều" ${crop.cropName == 'Điều' ? 'selected' : ''}>Điều</option>
                    <option value="Cacao" ${crop.cropName == 'Cacao' ? 'selected' : ''}>Cacao</option>
                    <option value="Chè" ${crop.cropName == 'Chè' ? 'selected' : ''}>Chè</option>
                </optgroup>

                <optgroup label="🍈 Trái cây">
                    <option value="Sầu riêng" ${crop.cropName == 'Sầu riêng' ? 'selected' : ''}>Sầu riêng</option>
                    <option value="Xoài" ${crop.cropName == 'Xoài' ? 'selected' : ''}>Xoài</option>
                    <option value="Thanh long" ${crop.cropName == 'Thanh long' ? 'selected' : ''}>Thanh long</option>
                    <option value="Mít Thái" ${crop.cropName == 'Mít Thái' ? 'selected' : ''}>Mít Thái</option>
                    <option value="Chanh leo" ${crop.cropName == 'Chanh leo' ? 'selected' : ''}>Chanh leo</option>
                    <option value="Bơ" ${crop.cropName == 'Bơ' ? 'selected' : ''}>Bơ</option>
                    <option value="Dừa" ${crop.cropName == 'Dừa' ? 'selected' : ''}>Dừa</option>
                    <option value="Nhãn" ${crop.cropName == 'Nhãn' ? 'selected' : ''}>Nhãn</option>
                    <option value="Vải thiều" ${crop.cropName == 'Vải thiều' ? 'selected' : ''}>Vải thiều</option>
                    <option value="Chuối" ${crop.cropName == 'Chuối' ? 'selected' : ''}>Chuối</option>
                    <option value="Ổi" ${crop.cropName == 'Ổi' ? 'selected' : ''}>Ổi</option>
                    <option value="Đu đủ" ${crop.cropName == 'Đu đủ' ? 'selected' : ''}>Đu đủ</option>
                </optgroup>

                <optgroup label="🌾 Lương thực">
                    <option value="Lúa gạo" ${crop.cropName == 'Lúa gạo' ? 'selected' : ''}>Lúa gạo</option>
                    <option value="Ngô" ${crop.cropName == 'Ngô' ? 'selected' : ''}>Ngô</option>
                    <option value="Khoai lang" ${crop.cropName == 'Khoai lang' ? 'selected' : ''}>Khoai lang</option>
                    <option value="Sắn" ${crop.cropName == 'Sắn' ? 'selected' : ''}>Sắn</option>
                </optgroup>

                <optgroup label="🥬 Rau củ">
                    <option value="Ớt đỏ" ${crop.cropName == 'Ớt đỏ' ? 'selected' : ''}>Ớt đỏ</option>
                    <option value="Hành lá" ${crop.cropName == 'Hành lá' ? 'selected' : ''}>Hành lá</option>
                    <option value="Rau muống" ${crop.cropName == 'Rau muống' ? 'selected' : ''}>Rau muống</option>
                    <option value="Cải xanh" ${crop.cropName == 'Cải xanh' ? 'selected' : ''}>Cải xanh</option>
                    <option value="Cải bắp" ${crop.cropName == 'Cải bắp' ? 'selected' : ''}>Cải bắp</option>
                    <option value="Cà chua" ${crop.cropName == 'Cà chua' ? 'selected' : ''}>Cà chua</option>
                    <option value="Dưa hấu" ${crop.cropName == 'Dưa hấu' ? 'selected' : ''}>Dưa hấu</option>
                    <option value="Dưa lưới" ${crop.cropName == 'Dưa lưới' ? 'selected' : ''}>Dưa lưới</option>
                </optgroup>
            </select>
        </div>

        <%-- Zone dropdown --%>
        <div class="form-group mt-3">
            <label>Zone <span class="text-danger">*</span></label>
            <select name="zoneId" class="form-control" required>
                <option value="">-- Chọn Zone --</option>
                <c:forEach var="z" items="${zones}">
                    <option value="${z.zoneId}"
                        <c:if test="${editing && crop.zone != null && z.zoneId == crop.zone.zoneId}">selected</c:if>>
                        Zone #${z.zoneId}<c:if test="${not empty z.zoneName}"> — ${z.zoneName}</c:if>
                    </option>
                </c:forEach>
            </select>
        </div>

        <br />

        <button type="submit" class="btn btn-primary">
            ${editing ? "Update" : "Create"}
        </button>
        <a href="${pageContext.request.contextPath}/crops" class="btn btn-secondary ms-2">
            Cancel
        </a>
    </form>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="container">
    <h2>${editing ? "Edit Crop" : "New Crop"}</h2>

    <form method="post" action="${pageContext.request.contextPath}/crops">
        <c:if test="${editing}">
            <input type="hidden" name="id" value="${crop.cropId}" />
        </c:if>

        <!-- Crop Name -->
        <div class="form-group">
            <label>Crop Name</label>
            <input
                type="text"
                name="cropName"
                class="form-control"
                value="${editing ? crop.cropName : ''}"
                required
            />
        </div>

        <!-- Zone -->
        <div class="form-group">
            <label>Zone</label>
            <select name="zoneId" class="form-control" required>
                <option value="">-- Select Zone --</option>

                <c:forEach var="z" items="${zones}">
                    <option value="${z.zoneId}"
                        <c:if test="${editing && crop.zone != null && z.zoneId == crop.zone.zoneId}">
                            selected
                        </c:if>
                    >
                        Zone #${z.zoneId} - ${z.zoneName}
                    </option>
                </c:forEach>
            </select>
        </div>

        <!-- Thresholds -->
        <h4 style="margin-top: 18px;">Threshold Configuration</h4>
        <div class="form-group">
            <label>Min Temperature (°C)</label>
            <input type="number" step="0.1" name="minTemp" class="form-control"
                   value="${editing ? crop.minTemp : ''}" placeholder="e.g. 20" />
        </div>
        <div class="form-group">
            <label>Max Temperature (°C)</label>
            <input type="number" step="0.1" name="maxTemp" class="form-control"
                   value="${editing ? crop.maxTemp : ''}" placeholder="e.g. 30" />
        </div>
        <div class="form-group">
            <label>Min Humidity (%)</label>
            <input type="number" step="0.1" name="minHumid" class="form-control"
                   value="${editing ? crop.minHumid : ''}" placeholder="e.g. 60" />
        </div>
        <div class="form-group">
            <label>Max Humidity (%)</label>
            <input type="number" step="0.1" name="maxHumid" class="form-control"
                   value="${editing ? crop.maxHumid : ''}" placeholder="e.g. 85" />
        </div>

        <br/>

        <button type="submit" class="btn btn-primary">
            ${editing ? "Update" : "Create"}
        </button>
        <a href="${pageContext.request.contextPath}/crops" class="btn btn-secondary">
            Cancel
        </a>
    </form>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

package controller;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.CropCatalog;
import model.ZoneCrop;
import service.CropCatalogService;
import service.ZoneCropService;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(name = "CropApiServlet", urlPatterns = { "/api/crops", "/api/zones/*" })
public class CropApiServlet extends HttpServlet {

    private CropCatalogService catalogService;
    private ZoneCropService zoneCropService;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        catalogService = new CropCatalogService();
        zoneCropService = new ZoneCropService();
        gson = new GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").create();
    }

    private void sendJsonResponse(HttpServletResponse response, Object data, int status) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(status);
        try (PrintWriter out = response.getWriter()) {
            if (data != null) {
                out.print(gson.toJson(data));
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();
        String pathInfo = request.getPathInfo();

        if ("/api/crops".equals(servletPath)) {
            List<CropCatalog> catalogs = catalogService.findAllCatalog();
            sendJsonResponse(response, catalogs, HttpServletResponse.SC_OK);
            return;
        }

        if ("/api/zones".equals(servletPath) && pathInfo != null) {
            // Path: /api/zones/{zoneId}/crops
            String[] parts = pathInfo.split("/");
            if (parts.length == 3 && "crops".equals(parts[2])) {
                try {
                    int zoneId = Integer.parseInt(parts[1]);
                    List<ZoneCrop> zoneCrops = zoneCropService.findByZoneId(zoneId);
                    sendJsonResponse(response, zoneCrops, HttpServletResponse.SC_OK);
                    return;
                } catch (NumberFormatException e) {
                    sendJsonResponse(response, "Invalid zoneId", HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
            }
        }

        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();
        String pathInfo = request.getPathInfo();

        if ("/api/crops".equals(servletPath)) {
            // Add custom crop
            JsonObject root = gson.fromJson(request.getReader(), JsonObject.class);
            String name = root.get("cropName").getAsString();
            String category = root.get("category").getAsString();
            Double minTemp = root.has("minTemp") && !root.get("minTemp").isJsonNull()
                    ? root.get("minTemp").getAsDouble()
                    : null;
            Double maxTemp = root.has("maxTemp") && !root.get("maxTemp").isJsonNull()
                    ? root.get("maxTemp").getAsDouble()
                    : null;
            Double minHum = root.has("minHumid") && !root.get("minHumid").isJsonNull()
                    ? root.get("minHumid").getAsDouble()
                    : null;
            Double maxHum = root.has("maxHumid") && !root.get("maxHumid").isJsonNull()
                    ? root.get("maxHumid").getAsDouble()
                    : null;
            String imgUrl = root.has("imageUrl") && !root.get("imageUrl").isJsonNull()
                    ? root.get("imageUrl").getAsString()
                    : "assets/crops/placeholder.jpg";
            String desc = root.has("description") && !root.get("description").isJsonNull()
                    ? root.get("description").getAsString()
                    : "";

            boolean success = catalogService.addCustomCrop(name, category, minTemp, maxTemp, minHum, maxHum, imgUrl,
                    desc);
            if (success) {
                sendJsonResponse(response, "Success", HttpServletResponse.SC_CREATED);
            } else {
                sendJsonResponse(response, "Error creating custom crop", HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
            return;
        }

        if ("/api/zones".equals(servletPath) && pathInfo != null) {
            // POST /api/zones/{zoneId}/crops
            String[] parts = pathInfo.split("/");
            if (parts.length == 3 && "crops".equals(parts[2])) {
                try {
                    int zoneId = Integer.parseInt(parts[1]);
                    JsonObject object = gson.fromJson(request.getReader(), JsonObject.class);
                    int catalogId = object.get("cropCatalogId").getAsInt();

                    boolean success = zoneCropService.assignCrop(zoneId, catalogId);
                    if (success) {
                        sendJsonResponse(response, "Success", HttpServletResponse.SC_CREATED);
                    } else {
                        // Conflict or Error
                        sendJsonResponse(response, "Failed to assign (possibly duplicate)",
                                HttpServletResponse.SC_CONFLICT);
                    }
                    return;
                } catch (Exception e) {
                    sendJsonResponse(response, "Invalid request body", HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
            }
        }

        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();
        String pathInfo = request.getPathInfo();

        if ("/api/zones".equals(servletPath) && pathInfo != null) {
            // DELETE /api/zones/{zoneId}/crops/{zoneCropId}
            String[] parts = pathInfo.split("/");
            if (parts.length == 4 && "crops".equals(parts[2])) {
                try {
                    int zoneCropId = Integer.parseInt(parts[3]);
                    boolean success = zoneCropService.removeCrop(zoneCropId);
                    if (success) {
                        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
                    } else {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    }
                    return;
                } catch (NumberFormatException e) {
                    sendJsonResponse(response, "Invalid zoneCropId", HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
            }
        }

        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
    }
}

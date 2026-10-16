package servlet;

import com.google.gson.Gson;
import entity.Category;
import entity.User;
import service.CategoryService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/category")
public class CategoryServlet extends HttpServlet {
    private CategoryService categoryService = new CategoryService();
    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        String action = req.getParameter("action");
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        if (action == null || action.isEmpty()) {
            listCategories(req, resp, user);
        } else if ("list".equals(action)) {
            listCategories(req, resp, user);
        } else if ("getByType".equals(action)) {
            getByType(req, resp, user);
        } else if ("add".equals(action)) {
            addCategory(req, resp, user);
        } else if ("update".equals(action)) {
            updateCategory(req, resp, user);
        } else if ("delete".equals(action)) {
            deleteCategory(req, resp, user);
        } else if ("get".equals(action)) {
            getCategory(req, resp, user);
        } else if ("batchUpdateSort".equals(action)) {
            batchUpdateSort(req, resp, user);
        } else {
            listCategories(req, resp, user);
        }
    }

    private void listCategories(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        List<Category> categories = categoryService.getCategories(user.getId());
        req.setAttribute("categories", categories);
        req.getRequestDispatcher("/category/list.jsp").forward(req, resp);
    }

    private void getByType(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String type = req.getParameter("type");
        List<Category> categories = categoryService.getCategoriesByType(user.getId(), type);
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write(gson.toJson(categories));
    }

    private void addCategory(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String name = req.getParameter("name");
        String type = req.getParameter("type");
        String icon = req.getParameter("icon");

        if (name == null || name.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/category?action=list&error=类别名称不能为空");
            return;
        }

        Category category = new Category();
        category.setUserId(user.getId());
        category.setName(name.trim());
        category.setType(type);
        category.setIcon(icon != null ? icon.trim() : "");
        category.setSortOrder(0);

        boolean success = categoryService.addCategory(category);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/category?action=list&success=新增成功");
        } else {
            resp.sendRedirect(req.getContextPath() + "/category?action=list&error=类别已存在或新增失败");
        }
    }

    private void updateCategory(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String idStr = req.getParameter("id");
        String name = req.getParameter("name");
        String icon = req.getParameter("icon");

        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/category?action=list&error=参数错误");
            return;
        }

        int id = Integer.parseInt(idStr);
        if (name == null || name.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/category?action=list&error=类别名称不能为空");
            return;
        }

        Category category = new Category();
        category.setId(id);
        category.setUserId(user.getId());
        category.setName(name.trim());
        category.setIcon(icon != null ? icon.trim() : "");
        category.setType(req.getParameter("type"));

        boolean success = categoryService.updateCategory(category);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/category?action=list&success=修改成功");
        } else {
            resp.sendRedirect(req.getContextPath() + "/category?action=list&error=修改失败");
        }
    }

    private void deleteCategory(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String idStr = req.getParameter("id");

        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/category?action=list&error=参数错误");
            return;
        }

        int id = Integer.parseInt(idStr);
        boolean success = categoryService.deleteCategory(id, user.getId());
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/category?action=list&success=删除成功");
        } else {
            resp.sendRedirect(req.getContextPath() + "/category?action=list&error=该类别已被使用，不能删除");
        }
    }

    private void getCategory(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.getWriter().write("{}");
            return;
        }
        int id = Integer.parseInt(idStr);
        Category category = categoryService.getCategoryById(id);
        resp.setContentType("application/json;charset=UTF-8");
        if (category != null && category.getUserId().equals(user.getId())) {
            resp.getWriter().write(gson.toJson(category));
        } else {
            resp.getWriter().write("{}");
        }
    }

    private void batchUpdateSort(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String type = req.getParameter("type");
        String dataJson = req.getParameter("data");

        if (dataJson == null || dataJson.isEmpty()) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"success\":false,\"message\":\"数据不能为空\"}");
            return;
        }

        try {
            com.google.gson.Gson gson = new com.google.gson.Gson();
            com.google.gson.JsonArray jsonArray = gson.fromJson(dataJson, com.google.gson.JsonArray.class);
            List<com.google.gson.JsonObject> updates = new ArrayList<>();
            for (int i = 0; i < jsonArray.size(); i++) {
                com.google.gson.JsonObject obj = jsonArray.get(i).getAsJsonObject();
                updates.add(obj);
            }

            boolean success = categoryService.batchUpdateSort(updates, user.getId());
            resp.setContentType("application/json;charset=UTF-8");
            if (success) {
                resp.getWriter().write("{\"success\":true,\"message\":\"排序更新成功\"}");
            } else {
                resp.getWriter().write("{\"success\":false,\"message\":\"排序更新失败\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.setContentType("application/json;charset=UTF-8");
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
    }
}
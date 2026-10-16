package servlet;

import com.google.gson.Gson;
import entity.User;
import entity.SystemLog;
import service.UserService;
import service.SystemLogService;
import service.AdminService;
import util.AESUtil;
import util.MD5Util;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
//import javax.servlet.http.Part;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,      // 1MB
        maxFileSize = 1024 * 1024 * 10,       // 10MB
        maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class AdminServlet extends HttpServlet {
    private UserService userService = new UserService();
    private SystemLogService systemLogService = new SystemLogService();
    private AdminService adminService = new AdminService();
    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "dashboard";

        System.out.println("===== AdminServlet action: " + action);

        switch (action) {
            case "dashboard":
                showDashboard(req, resp);
                break;
            case "users":
                showUsers(req, resp);
                break;
            case "addUser":
                addUser(req, resp);
                break;
            case "editUser":
                editUser(req, resp);
                break;
            case "updateUsername":
                updateUsername(req, resp);
                break;
            case "updatePassword":
                updatePassword(req, resp);
                break;
            case "setAdmin":
                setAdmin(req, resp);
                break;
            case "removeAdmin":
                removeAdmin(req, resp);
                break;
            case "deleteUser":
                deleteUser(req, resp);
                break;
            case "logs":
                showLogs(req, resp);
                break;
            case "clearLogs":
                clearLogs(req, resp);
                break;
            case "settings":
                showSettings(req, resp);
                break;
            case "updateSystemName":
                updateSystemName(req, resp);
                break;
            case "toggleMaintenance":
                toggleMaintenance(req, resp);
                break;
            case "exportData":
                exportData(req, resp);
                break;
            case "lockUser":
                lockUser(req, resp);
                break;
            case "unlockUser":
                unlockUser(req, resp);
                break;
            case "importData":
                importData(req, resp);
                break;
            default:
                showDashboard(req, resp);
                break;
        }
    }

    // ===== 仪表盘 =====
    private void showDashboard(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        List<User> allUsers = userService.getAllUsers();
        int totalUsers = allUsers != null ? allUsers.size() : 0;
        int adminCount = 0, userCount = 0;
        if (allUsers != null) {
            for (User u : allUsers) {
                if ("admin".equals(u.getRole())) adminCount++;
                else userCount++;
            }
        }

        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("adminCount", adminCount);
        req.setAttribute("userCount", userCount);
        req.setAttribute("users", allUsers);
        req.setAttribute("systemName", adminService.getSystemName());

        req.getRequestDispatcher("/admin/dashboard.jsp").forward(req, resp);
    }

    // ===== 用户管理 =====
    private void showUsers(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        List<User> users = userService.getAllUsers();
        req.setAttribute("users", users);
        req.setAttribute("systemName", adminService.getSystemName());
        req.getRequestDispatcher("/admin/users.jsp").forward(req, resp);
    }

    // ===== 管理员添加用户 =====
    private void addUser(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String username = req.getParameter("username").trim();
        String password = req.getParameter("password").trim();
        String email = req.getParameter("email").trim();
        String role = req.getParameter("role");

        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (userService.findByUsername(username) != null) {
            showUsersWithMessage(req, resp, "error", "用户名已存在，请使用其他用户名");
            return;
        }

        if (username.length() < 3) {
            showUsersWithMessage(req, resp, "error", "用户名至少3个字符");
            return;
        }

        if (password.length() < 6) {
            showUsersWithMessage(req, resp, "error", "密码至少6个字符");
            return;
        }

        User newUser = new User();
        newUser.setUsername(username);
        newUser.setPassword(MD5Util.md5(password));
        newUser.setEmail(email);
        newUser.setRole(role != null ? role : "user");

        boolean success = userService.addUserByAdmin(newUser);
        if (success) {
            systemLogService.log(currentUser.getId(), currentUser.getUsername(),
                    "addUser", "新增用户: " + username + " (角色: " + role + ")", req.getRemoteAddr());
            showUsersWithMessage(req, resp, "success", "用户 " + username + " 添加成功！");
        } else {
            showUsersWithMessage(req, resp, "error", "添加用户失败，请重试");
        }
    }

    // ===== 跳转到编辑用户页面 =====
    private void editUser(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            showUsersWithMessage(req, resp, "error", "参数错误");
            return;
        }
        int userId = Integer.parseInt(idStr);
        User user = userService.findById(userId);
        if (user == null) {
            showUsersWithMessage(req, resp, "error", "用户不存在");
            return;
        }
        req.setAttribute("editUser", user);
        req.setAttribute("systemName", adminService.getSystemName());
        req.getRequestDispatcher("/admin/editUser.jsp").forward(req, resp);
    }

    // ===== 修改用户名 =====
    private void updateUsername(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String idStr = req.getParameter("id");
        String newUsername = req.getParameter("newUsername").trim();

        if (idStr == null || idStr.isEmpty()) {
            showUsersWithMessage(req, resp, "error", "参数错误");
            return;
        }
        int userId = Integer.parseInt(idStr);

        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        User existingUser = userService.findByUsername(newUsername);
        if (existingUser != null && existingUser.getId() != userId) {
            showUsersWithMessage(req, resp, "error", "用户名已被其他用户使用");
            return;
        }

        if (newUsername.length() < 3) {
            showUsersWithMessage(req, resp, "error", "用户名至少3个字符");
            return;
        }

        boolean success = userService.updateUsername(userId, newUsername);
        if (success) {
            systemLogService.log(currentUser.getId(), currentUser.getUsername(),
                    "updateUsername", "修改用户ID-" + userId + " 的用户名为: " + newUsername, req.getRemoteAddr());
            showUsersWithMessage(req, resp, "success", "用户名修改成功！");
        } else {
            showUsersWithMessage(req, resp, "error", "修改用户名失败");
        }
    }

    // ===== 修改密码 =====
    private void updatePassword(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String idStr = req.getParameter("id");
        String newPassword = req.getParameter("newPassword").trim();

        if (idStr == null || idStr.isEmpty()) {
            showUsersWithMessage(req, resp, "error", "参数错误");
            return;
        }
        int userId = Integer.parseInt(idStr);

        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (newPassword.length() < 6) {
            showUsersWithMessage(req, resp, "error", "密码至少6个字符");
            return;
        }

        boolean success = userService.updatePassword(userId, MD5Util.md5(newPassword));
        if (success) {
            systemLogService.log(currentUser.getId(), currentUser.getUsername(),
                    "updatePassword", "修改用户ID-" + userId + " 的密码", req.getRemoteAddr());
            showUsersWithMessage(req, resp, "success", "密码修改成功！");
        } else {
            showUsersWithMessage(req, resp, "error", "修改密码失败");
        }
    }

    // ===== 设为管理员 =====
    private void setAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            showUsersWithMessage(req, resp, "error", "参数错误");
            return;
        }
        int userId = Integer.parseInt(idStr);

        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser.getId() == userId) {
            showUsersWithMessage(req, resp, "error", "不能修改自己的角色");
            return;
        }

        boolean success = userService.setAdmin(userId);
        if (success) {
            systemLogService.log(currentUser.getId(), currentUser.getUsername(),
                    "setAdmin", "将用户ID-" + userId + " 设为管理员", req.getRemoteAddr());
            showUsersWithMessage(req, resp, "success", "已设为管理员");
        } else {
            showUsersWithMessage(req, resp, "error", "操作失败");
        }
    }

    // ===== 取消管理员 =====
    private void removeAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            showUsersWithMessage(req, resp, "error", "参数错误");
            return;
        }
        int userId = Integer.parseInt(idStr);

        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser.getId() == userId) {
            showUsersWithMessage(req, resp, "error", "不能修改自己的角色");
            return;
        }

        boolean success = userService.removeAdmin(userId);
        if (success) {
            systemLogService.log(currentUser.getId(), currentUser.getUsername(),
                    "removeAdmin", "取消用户ID-" + userId + " 的管理员权限", req.getRemoteAddr());
            showUsersWithMessage(req, resp, "success", "已取消管理员");
        } else {
            showUsersWithMessage(req, resp, "error", "操作失败");
        }
    }

    // ===== 删除用户 =====
    private void deleteUser(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            showUsersWithMessage(req, resp, "error", "参数错误");
            return;
        }
        int userId = Integer.parseInt(idStr);

        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser.getId() == userId) {
            showUsersWithMessage(req, resp, "error", "不能删除自己");
            return;
        }

        boolean success = userService.deleteUser(userId);
        if (success) {
            systemLogService.log(currentUser.getId(), currentUser.getUsername(),
                    "deleteUser", "删除用户ID-" + userId, req.getRemoteAddr());
            showUsersWithMessage(req, resp, "success", "删除成功");
        } else {
            showUsersWithMessage(req, resp, "error", "删除失败");
        }
    }

    private void showUsersWithMessage(HttpServletRequest req, HttpServletResponse resp, String type, String message)
            throws ServletException, IOException {
        List<User> users = userService.getAllUsers();
        req.setAttribute("users", users);
        req.setAttribute("systemName", adminService.getSystemName());
        if ("success".equals(type)) req.setAttribute("success", message);
        else req.setAttribute("error", message);
        req.getRequestDispatcher("/admin/users.jsp").forward(req, resp);
    }

    // ===== 系统日志 =====
    private void showLogs(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int page = 1;
        int pageSize = 20;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception e) {}

        List<SystemLog> logs = systemLogService.getLogs(page, pageSize);
        int total = systemLogService.getLogCount();

        req.setAttribute("logs", logs);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPage", (int) Math.ceil((double) total / pageSize));
        req.setAttribute("totalCount", total);
        req.setAttribute("systemName", adminService.getSystemName());
        req.getRequestDispatcher("/admin/logs.jsp").forward(req, resp);
    }

    private void clearLogs(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");
        systemLogService.clearLogs();
        systemLogService.log(currentUser.getId(), currentUser.getUsername(),
                "clearLogs", "清空系统日志", req.getRemoteAddr());
        resp.sendRedirect(req.getContextPath() + "/admin?action=logs");
    }

    // ===== 系统设置 =====
    private void showSettings(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("systemName", adminService.getSystemName());
        req.setAttribute("maintenanceMode", adminService.isMaintenanceMode() ? "on" : "off");
        req.getRequestDispatcher("/admin/settings.jsp").forward(req, resp);
    }

    private void updateSystemName(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String name = req.getParameter("systemName");
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (name != null && !name.trim().isEmpty()) {
            adminService.updateSystemName(name.trim());
            systemLogService.log(currentUser.getId(), currentUser.getUsername(),
                    "updateSystemName", "修改系统名称为: " + name.trim(), req.getRemoteAddr());
        }
        resp.sendRedirect(req.getContextPath() + "/admin?action=settings&success=" + URLEncoder.encode("系统名称修改成功", "UTF-8"));
    }

    private void toggleMaintenance(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");
        adminService.toggleMaintenanceMode();
        systemLogService.log(currentUser.getId(), currentUser.getUsername(),
                "toggleMaintenance", "切换维护模式", req.getRemoteAddr());
        resp.sendRedirect(req.getContextPath() + "/admin?action=settings&success=" + URLEncoder.encode("维护模式切换成功", "UTF-8"));
    }

    // ===== 导出数据 =====
    private void exportData(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        List<User> users = userService.getAllUsers();

        List<Map<String, Object>> safeUsers = new ArrayList<>();
        for (User u : users) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", u.getId());
            item.put("username", u.getUsername());
            // ★★★ 密码用 AES 加密后导出 ★★★
            item.put("passwordEncrypted", AESUtil.encrypt(u.getPassword()));
            item.put("email", u.getEmail());
            item.put("role", u.getRole());
            item.put("status", u.getStatus());
            item.put("regTime", u.getRegTime());
            safeUsers.add(item);
        }

        Map<String, Object> data = new HashMap<>();
        data.put("exportTime", new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()));
        data.put("totalUsers", users.size());
        data.put("encrypted", true);    // ★★★ 标记：密码已加密
        data.put("users", safeUsers);

        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=users_export_" +
                new java.text.SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date()) + ".json");
        resp.getWriter().write(gson.toJson(data));
    }
    // 新增方法
    private void lockUser(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            showUsersWithMessage(req, resp, "error", "参数错误");
            return;
        }
        int userId = Integer.parseInt(idStr);
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser.getId() == userId) {
            showUsersWithMessage(req, resp, "error", "不能锁定自己");
            return;
        }

        boolean success = userService.lockUser(userId);
        if (success) {
            systemLogService.log(currentUser.getId(), currentUser.getUsername(),
                    "lockUser", "锁定用户ID-" + userId, req.getRemoteAddr());
            showUsersWithMessage(req, resp, "success", "已锁定该用户");
        } else {
            showUsersWithMessage(req, resp, "error", "操作失败");
        }
    }

    private void unlockUser(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            showUsersWithMessage(req, resp, "error", "参数错误");
            return;
        }
        int userId = Integer.parseInt(idStr);
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        boolean success = userService.unlockUser(userId);
        if (success) {
            systemLogService.log(currentUser.getId(), currentUser.getUsername(),
                    "unlockUser", "解锁用户ID-" + userId, req.getRemoteAddr());
            showUsersWithMessage(req, resp, "success", "已解锁该用户");
        } else {
            showUsersWithMessage(req, resp, "error", "操作失败");
        }
    }
    private void importData(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        try {
            Part filePart = req.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                resp.sendRedirect(req.getContextPath() + "/admin?action=settings&error=" +
                        URLEncoder.encode("请选择要导入的文件", "UTF-8"));
                return;
            }

            StringBuilder sb = new StringBuilder();
            try (java.io.BufferedReader reader = new java.io.BufferedReader(
                    new java.io.InputStreamReader(filePart.getInputStream(), "UTF-8"))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }
            String json = sb.toString();

            com.google.gson.JsonObject root = gson.fromJson(json, com.google.gson.JsonObject.class);
            if (root == null || !root.has("users")) {
                resp.sendRedirect(req.getContextPath() + "/admin?action=settings&error=" +
                        URLEncoder.encode("文件格式错误：缺少 users 字段", "UTF-8"));
                return;
            }

            // ★★★ 判断是否是加密导出 ★★★
            boolean encrypted = root.has("encrypted") && root.get("encrypted").getAsBoolean();

            com.google.gson.JsonArray usersArray = root.getAsJsonArray("users");
            int importedCount = 0;
            int skippedCount = 0;

            for (int i = 0; i < usersArray.size(); i++) {
                com.google.gson.JsonObject u = usersArray.get(i).getAsJsonObject();
                String username = u.has("username") ? u.get("username").getAsString() : null;
                if (username == null || username.isEmpty()) {
                    skippedCount++;
                    continue;
                }

                // 已存在则跳过
                if (userService.findByUsername(username) != null) {
                    skippedCount++;
                    continue;
                }

                User newUser = new User();
                newUser.setUsername(username);

                // ★★★ 密码处理 ★★★
                String password;
                if (encrypted && u.has("passwordEncrypted")) {
                    // 加密导出：用 AES 解密，恢复原密码
                    String encryptedPassword = u.get("passwordEncrypted").getAsString();
                    password = AESUtil.decrypt(encryptedPassword);
                    if (password == null) {
                        // 解密失败，用默认密码
                        password = MD5Util.md5("123456");
                        System.out.println("解密失败，用户 " + username + " 使用默认密码");
                    }
                } else if (u.has("password")) {
                    // 兼容旧的明文导出
                    password = u.get("password").getAsString();
                } else {
                    // 没有密码字段，用默认密码
                    password = MD5Util.md5("123456");
                }

                newUser.setPassword(password);
                newUser.setEmail(u.has("email") && !u.get("email").isJsonNull()
                        ? u.get("email").getAsString() : null);
                newUser.setRole(u.has("role") ? u.get("role").getAsString() : "user");
                newUser.setStatus(u.has("status") ? u.get("status").getAsString() : "active");

                if (userService.addUserByAdmin(newUser)) {
                    importedCount++;
                } else {
                    skippedCount++;
                }
            }

            systemLogService.log(currentUser.getId(), currentUser.getUsername(),
                    "importData",
                    "导入用户数据: 成功 " + importedCount + " 条, 跳过 " + skippedCount + " 条",
                    req.getRemoteAddr());

            String msg = "导入完成：成功 " + importedCount + " 条，跳过 " + skippedCount + " 条";
            resp.sendRedirect(req.getContextPath() + "/admin?action=settings&success=" +
                    URLEncoder.encode(msg, "UTF-8"));

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin?action=settings&error=" +
                    URLEncoder.encode("导入失败: " + e.getMessage(), "UTF-8"));
        }
    }
}
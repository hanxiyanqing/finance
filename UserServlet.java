package servlet;

import entity.User;
import service.UserService;
import service.SystemLogService;
import service.AdminService;
import util.MD5Util;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/user")
public class UserServlet extends HttpServlet {
    private UserService userService = new UserService();
    private SystemLogService systemLogService = new SystemLogService();
    private AdminService adminService = new AdminService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        String action = req.getParameter("action");
        if ("login".equals(action)) {
            login(req, resp);
        } else if ("register".equals(action)) {
            register(req, resp);
        } else if ("logout".equals(action)) {
            logout(req, resp);
        } else if ("updateUsername".equals(action)) {
            updateUsername(req, resp);
        } else if ("updatePassword".equals(action)) {
            updatePassword(req, resp);
        }
    }

    // ===== 登录（验证角色 + 维护模式检查） =====
    private void login(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String username = req.getParameter("username").trim();
        String password = req.getParameter("password").trim();
        String selectedRole = req.getParameter("role");

        // 先查用户是否存在（为了区分"密码错误"和"账号锁定"）
        User userForCheck = userService.findByUsername(username);
        if (userForCheck != null && "locked".equals(userForCheck.getStatus())) {
            req.setAttribute("error", "账号已被锁定，请联系管理员");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        User user = userService.login(username, password);

        // 验证登录身份与角色是否匹配
        if ("admin".equals(selectedRole) && !"admin".equals(user.getRole())) {
            req.setAttribute("error", "该账号不是管理员，请选择「普通用户」身份登录");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }
        if ("user".equals(selectedRole) && !"user".equals(user.getRole())) {
            req.setAttribute("error", "该账号不是普通用户，请选择「管理员」身份登录");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        // ===== 检查维护模式（普通用户被限制登录） =====
        boolean isMaintenance = adminService.isMaintenanceMode();
        if (isMaintenance && !"admin".equals(user.getRole())) {
            req.setAttribute("error", "系统正在维护中，普通用户暂无法登录，请稍后再试");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        systemLogService.log(user.getId(), user.getUsername(), "login",
                "用户登录 (身份: " + selectedRole + ")", req.getRemoteAddr());

        HttpSession session = req.getSession();
        session.setAttribute("user", user);
        session.setAttribute("loginRole", selectedRole);

        if ("admin".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/admin?action=dashboard");
        } else {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
        }
    }

    // ===== 注册（强制为普通用户） =====
    private void register(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String username = req.getParameter("username").trim();
        String password = req.getParameter("password").trim();
        String confirmPassword = req.getParameter("confirmPassword");
        String email = req.getParameter("email");

        // 验证两次密码是否一致
        if (!password.equals(confirmPassword)) {
            req.setAttribute("error", "两次密码输入不一致！");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        // 验证用户名长度
        if (username.length() < 3) {
            req.setAttribute("error", "用户名至少3个字符！");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        // 验证密码长度
        if (password.length() < 6) {
            req.setAttribute("error", "密码至少6个字符！");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        // ===== 注册强制为普通用户 =====
        boolean success = userService.registerUser(username, password, email);
        if (success) {
            req.setAttribute("message", "注册成功，请登录！");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        } else {
            req.setAttribute("error", "用户名已存在，请重新输入！");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
        }
    }

    // ===== 退出 =====
    private void logout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        resp.sendRedirect(req.getContextPath() + "/login.jsp");
    }

    // ===== 修改用户名 =====
    private void updateUsername(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String newUsername = req.getParameter("newUsername").trim();

        if (newUsername.length() < 3) {
            req.setAttribute("error", "用户名至少3个字符");
            req.setAttribute("user", currentUser);
            req.getRequestDispatcher("/user/profile.jsp").forward(req, resp);
            return;
        }

        User existingUser = userService.findByUsername(newUsername);
        if (existingUser != null && existingUser.getId() != currentUser.getId()) {
            req.setAttribute("error", "用户名已被其他用户使用，请重新输入");
            req.setAttribute("user", currentUser);
            req.getRequestDispatcher("/user/profile.jsp").forward(req, resp);
            return;
        }

        boolean success = userService.updateUsername(currentUser.getId(), newUsername);
        if (success) {
            currentUser.setUsername(newUsername);
            session.setAttribute("user", currentUser);
            systemLogService.log(currentUser.getId(), currentUser.getUsername(),
                    "updateUsername", "修改用户名为: " + newUsername, req.getRemoteAddr());
            req.setAttribute("success", "用户名修改成功！");
        } else {
            req.setAttribute("error", "修改用户名失败，请重试");
        }
        req.setAttribute("user", currentUser);
        req.getRequestDispatcher("/user/profile.jsp").forward(req, resp);
    }

    // ===== 修改密码 =====
    private void updatePassword(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String oldPassword = req.getParameter("oldPassword").trim();
        String newPassword = req.getParameter("newPassword").trim();
        String confirmPassword = req.getParameter("confirmPassword").trim();

        // 从数据库重新查询，避免 session 中的密码过期
        User dbUser = userService.findById(currentUser.getId());
        if (dbUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        if (!dbUser.getPassword().equals(MD5Util.md5(oldPassword))) {
            System.out.println("原密码错误");
            req.setAttribute("error", "原密码错误");
            req.setAttribute("user", currentUser);
            req.getRequestDispatcher("/user/profile.jsp").forward(req, resp);
            return;
        }

        // ===== 验证新旧密码不能相同 =====
        if (oldPassword.equals(newPassword)) {
            System.out.println("新旧密码相同");
            req.setAttribute("error", "新密码不能与当前密码相同，请重新设置");
            req.setAttribute("user", currentUser);
            req.getRequestDispatcher("/user/profile.jsp").forward(req, resp);
            return;
        }

        // ===== 验证两次新密码是否一致 =====
        if (!newPassword.equals(confirmPassword)) {
            System.out.println("两次密码不一致");
            req.setAttribute("error", "两次输入的密码不一致");
            req.setAttribute("user", currentUser);
            req.getRequestDispatcher("/user/profile.jsp").forward(req, resp);
            return;
        }

        // ===== 验证新密码长度 =====
        if (newPassword.length() < 6) {
            System.out.println("密码长度不足");
            req.setAttribute("error", "密码至少6个字符");
            req.setAttribute("user", currentUser);
            req.getRequestDispatcher("/user/profile.jsp").forward(req, resp);
            return;
        }

        // ===== 执行密码修改 - 加密后存入数据库 =====
        String encryptedNewPassword = MD5Util.md5(newPassword);
        System.out.println("新密码MD5: " + encryptedNewPassword);

        boolean success = userService.updatePassword(currentUser.getId(), encryptedNewPassword);

        if (success) {
            System.out.println("密码更新成功");
            // 更新会话中的用户密码信息
            currentUser.setPassword(encryptedNewPassword);
            session.setAttribute("user", currentUser);

            systemLogService.log(currentUser.getId(), currentUser.getUsername(),
                    "updatePassword", "修改密码", req.getRemoteAddr());
            req.setAttribute("success", "密码修改成功！");
        } else {
            System.out.println("密码更新失败");
            req.setAttribute("error", "密码修改失败，请重试");
        }
        req.setAttribute("user", currentUser);
        req.getRequestDispatcher("/user/profile.jsp").forward(req, resp);
    }
}
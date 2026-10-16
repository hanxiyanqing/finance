package filter;

import entity.User;
import service.AdminService;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class LoginFilter implements Filter {

    private AdminService adminService = new AdminService();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();

        // 放行登录、注册页面和静态资源
        if (uri.contains("/login.jsp") || uri.contains("/register.jsp") ||
                uri.contains("/css/") || uri.contains("/js/") || uri.contains("/images/") ||
                uri.contains("/user/profile.jsp") ||
                uri.equals(contextPath + "/") ||
                uri.equals(contextPath + "/login") ||
                uri.equals(contextPath + "/register") ||
                uri.equals(contextPath + "/user")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        User user = (User) (session != null ? session.getAttribute("user") : null);

        if (user == null) {
            resp.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        // ===== 检查维护模式 =====
        boolean isMaintenance = adminService.isMaintenanceMode();

        // 如果开启了维护模式
        if (isMaintenance) {
            // 管理员可以继续访问
            if ("admin".equals(user.getRole())) {
                // 管理员访问普通用户功能 → 跳转到仪表盘
                if (uri.contains("/transaction") || uri.contains("/account") ||
                        uri.contains("/loan") || uri.contains("/category") ||
                        uri.contains("/statistics") || uri.contains("/index.jsp")) {
                    resp.sendRedirect(contextPath + "/admin?action=dashboard");
                    return;
                }
                chain.doFilter(request, response);
                return;
            } else {
                // 普通用户被踢出，跳转到登录页并显示提示
                resp.sendRedirect(contextPath + "/login.jsp?maintenance=true");
                return;
            }
        }

        // ===== 正常模式下的权限控制 =====

        // 管理员访问 /admin 路径
        if (uri.contains("/admin")) {
            if ("admin".equals(user.getRole())) {
                chain.doFilter(request, response);
            } else {
                resp.sendRedirect(contextPath + "/login.jsp");
            }
            return;
        }

        // 管理员访问普通用户功能 → 跳转到仪表盘
        if ("admin".equals(user.getRole())) {
            if (uri.contains("/transaction") || uri.contains("/account") ||
                    uri.contains("/loan") || uri.contains("/category") ||
                    uri.contains("/statistics") || uri.contains("/index.jsp")) {
                resp.sendRedirect(contextPath + "/admin?action=dashboard");
                return;
            }
        }

        // 普通用户正常访问
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
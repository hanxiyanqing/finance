package servlet;

import com.google.gson.Gson;
import entity.Account;
import entity.User;
import service.AccountService;
import service.AdminService;  // 添加导入

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet("/account")
public class AccountServlet extends HttpServlet {
    private AccountService accountService = new AccountService();
    private AdminService adminService = new AdminService();  // 添加这一行
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

        System.out.println("===== AccountServlet action: " + action + ", userId: " + user.getId());

        try {
            if ("list".equals(action)) {
                listAccounts(req, resp, user);
            } else if ("add".equals(action)) {
                addAccount(req, resp, user);
            } else if ("delete".equals(action)) {
                deleteAccount(req, resp, user);
            } else if ("get".equals(action)) {
                getAccount(req, resp);
            } else if ("update".equals(action)) {
                updateAccount(req, resp, user);
            } else {
                // 默认也显示列表
                listAccounts(req, resp, user);
            }
        } catch (Exception e) {
            e.printStackTrace();
            // 发生异常时，跳转到列表页并显示错误信息
            resp.sendRedirect(req.getContextPath() + "/account?action=list&error=" +
                    java.net.URLEncoder.encode("操作异常: " + e.getMessage(), "UTF-8"));
        }
    }

    // ===== 显示账户列表 =====
    private void listAccounts(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        try {
            List<Account> accounts = accountService.getAccounts(user.getId());

            // 打印日志查看数据
            System.out.println("===== 账户列表 =====");
            if (accounts != null) {
                for (Account acc : accounts) {
                    System.out.println("id: " + acc.getId() +
                            ", name: " + acc.getAccountName() +
                            ", type: " + acc.getType() +
                            ", balance: " + acc.getBalance());
                }
            } else {
                System.out.println("账户列表为空");
            }

            req.setAttribute("accounts", accounts != null ? accounts : new java.util.ArrayList<>());
            req.getRequestDispatcher("/account/list.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            // 如果获取账户列表失败，设置空列表
            req.setAttribute("accounts", new java.util.ArrayList<>());
            req.setAttribute("error", "加载账户列表失败: " + e.getMessage());
            req.getRequestDispatcher("/account/list.jsp").forward(req, resp);
        }
    }

    // ===== 新增账户（修复版） =====
    private void addAccount(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        try {
            String accountName = req.getParameter("accountName");
            String type = req.getParameter("type");
            String balanceStr = req.getParameter("balance");
            String remark = req.getParameter("remark");

            System.out.println("===== 新增账户 =====");
            System.out.println("accountName: " + accountName);
            System.out.println("type: " + type);
            System.out.println("balanceStr: " + balanceStr);
            System.out.println("remark: " + remark);

            // 参数验证
            if (accountName == null || accountName.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/account?action=list&error=" +
                        java.net.URLEncoder.encode("账户名称不能为空", "UTF-8"));
                return;
            }
            accountName = accountName.trim();

            // 检查名称是否已存在
            if (accountService.isAccountNameExist(user.getId(), accountName)) {
                resp.sendRedirect(req.getContextPath() + "/account?action=list&error=" +
                        java.net.URLEncoder.encode("账户名称 \"" + accountName + "\" 已存在，请使用其他名称", "UTF-8"));
                return;
            }

            Account account = new Account();
            account.setUserId(user.getId());
            account.setAccountName(accountName);
            account.setType(type);

            // 处理余额
            BigDecimal balance;
            try {
                balance = new BigDecimal(balanceStr == null || balanceStr.isEmpty() ? "0" : balanceStr);
            } catch (NumberFormatException e) {
                balance = BigDecimal.ZERO;
            }

            // 非借贷账户初始余额不能为负
            boolean isCredit = "信用卡".equals(type) || "花呗".equals(type);
            if (!isCredit && balance.compareTo(BigDecimal.ZERO) < 0) {
                balance = BigDecimal.ZERO;
            }
            account.setBalance(balance);
            account.setRemark(remark);

            boolean success = accountService.addAccount(account);
            if (success) {
                // 新增成功后重新计算该账户余额（确保初始余额正确）
                // 注意：新增账户时还没有交易记录，所以余额就是初始值
                System.out.println("===== 账户添加成功 =====");
                resp.sendRedirect(req.getContextPath() + "/account?action=list&success=" +
                        java.net.URLEncoder.encode("账户添加成功", "UTF-8"));
            } else {
                resp.sendRedirect(req.getContextPath() + "/account?action=list&error=" +
                        java.net.URLEncoder.encode("添加失败，请重试", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/account?action=list&error=" +
                    java.net.URLEncoder.encode("添加异常: " + e.getMessage(), "UTF-8"));
        }
    }

    // ===== 更新账户 =====
    private void updateAccount(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            String accountName = req.getParameter("accountName");
            String type = req.getParameter("type");
            String remark = req.getParameter("remark");

            System.out.println("===== 更新账户 =====");
            System.out.println("id: " + id);
            System.out.println("accountName: " + accountName);
            System.out.println("type: " + type);

            if (accountName == null || accountName.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/account?action=list&error=" +
                        java.net.URLEncoder.encode("账户名称不能为空", "UTF-8"));
                return;
            }
            accountName = accountName.trim();

            // 检查名称是否重复（排除自己）
            if (accountService.isAccountNameExistExcludeId(user.getId(), accountName, id)) {
                resp.sendRedirect(req.getContextPath() + "/account?action=list&error=" +
                        java.net.URLEncoder.encode("账户名称 \"" + accountName + "\" 已存在，请使用其他名称", "UTF-8"));
                return;
            }

            // 获取原账户，保留余额
            Account existingAccount = accountService.getAccountById(id);
            if (existingAccount == null) {
                resp.sendRedirect(req.getContextPath() + "/account?action=list&error=" +
                        java.net.URLEncoder.encode("账户不存在", "UTF-8"));
                return;
            }

            Account account = new Account();
            account.setId(id);
            account.setUserId(user.getId());
            account.setAccountName(accountName);
            account.setType(type);
            account.setBalance(existingAccount.getBalance());  // 保留原余额
            account.setRemark(remark);

            boolean success = accountService.updateAccount(account);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/account?action=list&success=" +
                        java.net.URLEncoder.encode("修改成功", "UTF-8"));
            } else {
                resp.sendRedirect(req.getContextPath() + "/account?action=list&error=" +
                        java.net.URLEncoder.encode("修改失败", "UTF-8"));
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/account?action=list&error=" +
                    java.net.URLEncoder.encode("参数格式错误", "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/account?action=list&error=" +
                    java.net.URLEncoder.encode("修改异常: " + e.getMessage(), "UTF-8"));
        }
    }

    // ===== 删除账户 =====
    private void deleteAccount(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            System.out.println("===== 删除账户 id: " + id);

            boolean success = accountService.deleteAccount(id, user.getId());
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/account?action=list&success=" +
                        java.net.URLEncoder.encode("删除成功", "UTF-8"));
            } else {
                resp.sendRedirect(req.getContextPath() + "/account?action=list&error=" +
                        java.net.URLEncoder.encode("删除失败，该账户可能有交易记录", "UTF-8"));
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/account?action=list&error=" +
                    java.net.URLEncoder.encode("参数格式错误", "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/account?action=list&error=" +
                    java.net.URLEncoder.encode("删除异常: " + e.getMessage(), "UTF-8"));
        }
    }

    // ===== 获取单个账户（JSON） =====
    private void getAccount(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            System.out.println("===== 获取账户 id: " + id);

            Account account = accountService.getAccountById(id);
            resp.setContentType("application/json;charset=utf-8");
            if (account != null) {
                resp.getWriter().write(gson.toJson(account));
            } else {
                resp.getWriter().write("{}");
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
            resp.getWriter().write("{\"error\":\"参数格式错误\"}");
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
}
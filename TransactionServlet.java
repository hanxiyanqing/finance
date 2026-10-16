package servlet;

import com.google.gson.Gson;
import entity.PageBean;
import entity.Transaction;
import entity.User;
import service.CategoryService;
import service.TransactionService;
import service.AccountService;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/transaction")
public class TransactionServlet extends HttpServlet {
    private TransactionService transactionService = new TransactionService();
    private CategoryService categoryService = new CategoryService();
    private AccountService accountService = new AccountService();
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

        System.out.println("===== TransactionServlet action: " + action);

        if ("list".equals(action)) {
            listTransactions(req, resp, user);
        } else if ("add".equals(action)) {
            addTransaction(req, resp, user);
        } else if ("update".equals(action)) {
            updateTransaction(req, resp, user);
        } else if ("delete".equals(action)) {
            deleteTransaction(req, resp, user);
        } else if ("get".equals(action)) {
            getTransaction(req, resp, user);
        } else {
            listTransactions(req, resp, user);
        }
    }

    private void listTransactions(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        int currentPage = 1;
        int pageSize = 10;
        try {
            currentPage = Integer.parseInt(req.getParameter("page"));
        } catch (NumberFormatException e) {}
        try {
            pageSize = Integer.parseInt(req.getParameter("pageSize"));
        } catch (NumberFormatException e) {}

        String type = req.getParameter("type");
        String categoryIdStr = req.getParameter("categoryId");
        String accountIdStr = req.getParameter("accountId");
        String startDate = req.getParameter("startDate");
        String endDate = req.getParameter("endDate");

        Integer categoryId = null;
        Integer accountId = null;
        try {
            if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
                categoryId = Integer.parseInt(categoryIdStr);
            }
        } catch (NumberFormatException e) {}
        try {
            if (accountIdStr != null && !accountIdStr.isEmpty()) {
                accountId = Integer.parseInt(accountIdStr);
            }
        } catch (NumberFormatException e) {}

        PageBean<Transaction> pageBean = transactionService.getTransactionsByPage(
                user.getId(), type, categoryId, accountId, startDate, endDate, currentPage, pageSize
        );

        System.out.println("===== 交易列表 =====");
        System.out.println("总记录数: " + pageBean.getTotalCount());
        if (pageBean.getList() != null) {
            for (Transaction t : pageBean.getList()) {
                System.out.println("id: " + t.getId() + ", 金额: " + t.getAmount() + ", 类型: " + t.getType());
            }
        }

        req.setAttribute("pageBean", pageBean);
        req.setAttribute("categories", categoryService.getCategories(user.getId()));
        req.setAttribute("accounts", accountService.getAccounts(user.getId()));
        req.getRequestDispatcher("/transaction/list.jsp").forward(req, resp);
    }

    // ===== 新增交易 =====
    private void addTransaction(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        try {
            String type = req.getParameter("type");
            String categoryIdStr = req.getParameter("categoryId");
            String accountIdStr = req.getParameter("accountId");
            String amountStr = req.getParameter("amount");
            String dateStr = req.getParameter("transDate");
            String remark = req.getParameter("remark");

            System.out.println("===== 新增交易记录 =====");
            System.out.println("type: " + type);
            System.out.println("categoryId: " + categoryIdStr);
            System.out.println("accountId: " + accountIdStr);
            System.out.println("amount: " + amountStr);
            System.out.println("transDate: " + dateStr);

            // 参数验证
            if (type == null || type.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/transaction?action=list&error=" + URLEncoder.encode("类型不能为空", "UTF-8"));
                return;
            }
            if (categoryIdStr == null || categoryIdStr.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/transaction?action=list&error=" + URLEncoder.encode("请选择类别", "UTF-8"));
                return;
            }
            if (accountIdStr == null || accountIdStr.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/transaction?action=list&error=" + URLEncoder.encode("请选择账户", "UTF-8"));
                return;
            }
            if (amountStr == null || amountStr.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/transaction?action=list&error=" + URLEncoder.encode("请输入金额", "UTF-8"));
                return;
            }

            int categoryId = Integer.parseInt(categoryIdStr);
            int accountId = Integer.parseInt(accountIdStr);
            BigDecimal amount = new BigDecimal(amountStr);

            Transaction transaction = new Transaction();
            transaction.setUserId(user.getId());
            transaction.setType(type);
            transaction.setCategoryId(categoryId);
            transaction.setAccountId(accountId);
            transaction.setAmount(amount);
            transaction.setRemark(remark);

            try {
                String normalized = dateStr.replace("T", " ");
                SimpleDateFormat sdf;
                if (normalized.length() > 10) {
                    sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                } else {
                    sdf = new SimpleDateFormat("yyyy-MM-dd");
                }
                Date transDate = sdf.parse(normalized);
                transaction.setTransDate(transDate);
            } catch (Exception e) {
                transaction.setTransDate(new Date());
            }

            // 执行新增
            boolean success = transactionService.addTransaction(transaction);

            if (success) {
                // 重新计算该账户的余额
                System.out.println("===== 新增交易成功，已重新计算账户余额 =====");
                resp.sendRedirect(req.getContextPath() + "/transaction?action=list&success=" + URLEncoder.encode("新增成功", "UTF-8"));
            } else {
                resp.sendRedirect(req.getContextPath() + "/transaction?action=list&error=" + URLEncoder.encode("新增失败，请检查余额是否充足", "UTF-8"));
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/transaction?action=list&error=" + URLEncoder.encode("参数格式错误", "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/transaction?action=list&error=" + URLEncoder.encode("新增异常，请重试", "UTF-8"));
        }
    }

    // ===== 更新交易 =====
    private void updateTransaction(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            String type = req.getParameter("type");
            int categoryId = Integer.parseInt(req.getParameter("categoryId"));
            int accountId = Integer.parseInt(req.getParameter("accountId"));
            BigDecimal amount = new BigDecimal(req.getParameter("amount"));
            String dateStr = req.getParameter("transDate");
            String remark = req.getParameter("remark");

            System.out.println("===== 更新交易记录 =====");
            System.out.println("id: " + id + ", type: " + type + ", amount: " + amount);

            // 获取旧记录
            Transaction oldTrans = transactionService.getTransactionById(id, user.getId());
            if (oldTrans == null) {
                resp.sendRedirect(req.getContextPath() + "/transaction?action=list&error=" +
                        URLEncoder.encode("记录不存在", "UTF-8"));
                return;
            }

            // 构建新记录
            Transaction newTrans = new Transaction();
            newTrans.setId(id);
            newTrans.setUserId(user.getId());
            newTrans.setType(type);
            newTrans.setCategoryId(categoryId);
            newTrans.setAccountId(accountId);
            newTrans.setAmount(amount);
            newTrans.setRemark(remark);

            try {
                String normalized = dateStr.replace("T", " ");
                SimpleDateFormat sdf;
                if (normalized.length() > 10) {
                    sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                } else {
                    sdf = new SimpleDateFormat("yyyy-MM-dd");
                }
                Date transDate = sdf.parse(normalized);
                newTrans.setTransDate(transDate);
            } catch (Exception e) {
                newTrans.setTransDate(new Date());
            }

            // 执行更新
            boolean success = transactionService.updateTransaction(newTrans, oldTrans);

            if (success) {
                System.out.println("===== 更新交易成功，已重新计算账户余额 =====");
                resp.sendRedirect(req.getContextPath() + "/transaction?action=list&success=" +
                        URLEncoder.encode("修改成功", "UTF-8"));
            } else {
                resp.sendRedirect(req.getContextPath() + "/transaction?action=list&error=" +
                        URLEncoder.encode("修改失败，请检查余额是否充足", "UTF-8"));
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/transaction?action=list&error=" +
                    URLEncoder.encode("参数格式错误", "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/transaction?action=list&error=" +
                    URLEncoder.encode("修改异常，请重试", "UTF-8"));
        }
    }

    // ===== 删除交易 =====
    private void deleteTransaction(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            System.out.println("===== 删除交易记录 id: " + id);

            // 获取交易记录，用于获取账户ID
            Transaction transaction = transactionService.getTransactionById(id, user.getId());
            int accountId = transaction != null ? transaction.getAccountId() : -1;

            boolean success = transactionService.deleteTransaction(id, user.getId());

            if (success && accountId > 0) {
                System.out.println("===== 删除交易成功，已重新计算账户余额 =====");
                resp.sendRedirect(req.getContextPath() + "/transaction?action=list&success=" + URLEncoder.encode("删除成功", "UTF-8"));
            } else if (success) {
                resp.sendRedirect(req.getContextPath() + "/transaction?action=list&success=" + URLEncoder.encode("删除成功", "UTF-8"));
            } else {
                resp.sendRedirect(req.getContextPath() + "/transaction?action=list&error=" + URLEncoder.encode("删除失败", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/transaction?action=list&error=" + URLEncoder.encode("删除异常，请重试", "UTF-8"));
        }
    }

    // ===== 获取单条记录 =====
    private void getTransaction(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            System.out.println("===== 获取交易记录 id: " + id);

            Transaction transaction = transactionService.getTransactionById(id, user.getId());
            resp.setContentType("application/json;charset=UTF-8");
            if (transaction != null) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Map<String, Object> result = new HashMap<>();
                result.put("id", transaction.getId());
                result.put("type", transaction.getType());
                result.put("categoryId", transaction.getCategoryId());
                result.put("accountId", transaction.getAccountId());
                result.put("amount", transaction.getAmount());
                result.put("transDate", transaction.getTransDate() != null ? sdf.format(transaction.getTransDate()) : "");
                result.put("remark", transaction.getRemark() != null ? transaction.getRemark() : "");
                System.out.println("返回数据: " + gson.toJson(result));
                resp.getWriter().write(gson.toJson(result));
            } else {
                resp.getWriter().write("{}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
}
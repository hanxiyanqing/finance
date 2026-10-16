package servlet;

import com.google.gson.Gson;
import entity.User;
import service.TransactionService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/statistics")
public class StatisticsServlet extends HttpServlet {
    private TransactionService transactionService = new TransactionService();
    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");

        System.out.println("===== StatisticsServlet =====");
        System.out.println("action: " + action);
        System.out.println("user: " + (user != null ? user.getUsername() : "null"));

        if ("getData".equals(action)) {
            getStatisticsData(req, resp, user);
        }
    }

    private void getStatisticsData(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        if (user == null) {
            System.out.println("用户未登录!");
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.getWriter().write("{\"error\":\"未登录\"}");
            return;
        }

        String yearMonth = req.getParameter("yearMonth");
        if (yearMonth == null || yearMonth.isEmpty()) {
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM");
            yearMonth = sdf.format(new java.util.Date());
        }

        System.out.println("查询月份: " + yearMonth + ", userId: " + user.getId());

        BigDecimal income = transactionService.getMonthlyIncome(user.getId(), yearMonth);
        System.out.println("收入: " + income);

        BigDecimal expense = transactionService.getMonthlyExpense(user.getId(), yearMonth);
        System.out.println("支出: " + expense);

        BigDecimal balance = income.subtract(expense);

        List<Object[]> expenseCategory = transactionService.getCategoryStats(user.getId(), "expense", yearMonth);
        System.out.println("支出类别数: " + (expenseCategory != null ? expenseCategory.size() : 0));

        List<Object[]> incomeCategory = transactionService.getCategoryStats(user.getId(), "income", yearMonth);
        System.out.println("收入类别数: " + (incomeCategory != null ? incomeCategory.size() : 0));

        Map<String, Object> result = new HashMap<>();
        result.put("yearMonth", yearMonth);
        result.put("income", income);
        result.put("expense", expense);
        result.put("balance", balance);
        result.put("expenseCategory", expenseCategory);
        result.put("incomeCategory", incomeCategory);

        resp.setContentType("application/json;charset=utf-8");
        resp.getWriter().write(gson.toJson(result));
        System.out.println("JSON返回成功");
    }
}
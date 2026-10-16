package servlet;

import com.google.gson.Gson;
import entity.Loan;
import entity.User;
import service.LoanService;
import service.AccountService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/loan")
public class LoanServlet extends HttpServlet {
    private LoanService loanService = new LoanService();
    private AccountService accountService = new AccountService();

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

        if ("list".equals(action)) {
            listLoans(req, resp, user);
        } else if ("add".equals(action)) {
            addLoan(req, resp, user);
        } else if ("repay".equals(action)) {
            repayLoan(req, resp, user);
        } else if ("delete".equals(action)) {
            deleteLoan(req, resp, user);
        } else if ("update".equals(action)) {
            updateLoan(req, resp, user);
        } else if ("get".equals(action)) {
            getLoan(req, resp, user);
        } else {
            listLoans(req, resp, user);
        }
    }

    private void listLoans(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        try {
            String status = req.getParameter("status");
            List<Loan> loans;
            if (status != null && !status.isEmpty()) {
                loans = loanService.getLoansByStatus(user.getId(), status);
            } else {
                loans = loanService.getLoans(user.getId());
            }
            System.out.println("===== 借贷列表 =====");
            System.out.println("userId: " + user.getId() + ", status: " + status + ", 记录数: " + (loans != null ? loans.size() : 0));
            if (loans != null) {
                for (Loan loan : loans) {
                    System.out.println("id: " + loan.getId() + ", person: " + loan.getPerson() + ", amount: " + loan.getAmount());
                }
            }

            req.setAttribute("loans", loans != null ? loans : new ArrayList<>());
            req.setAttribute("accounts", accountService.getAccounts(user.getId()));
            req.getRequestDispatcher("/loan/list.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("loans", new ArrayList<>());
            req.setAttribute("error", "加载借贷数据失败: " + e.getMessage());
            req.getRequestDispatcher("/loan/list.jsp").forward(req, resp);
        }
    }

    private void addLoan(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String type = req.getParameter("type");
        String person = req.getParameter("person");
        BigDecimal amount = new BigDecimal(req.getParameter("amount"));
        String dateStr = req.getParameter("loanDate");
        String remark = req.getParameter("remark");
        String accountIdStr = req.getParameter("accountId");   // 新增

        Loan loan = new Loan();
        loan.setUserId(user.getId());
        loan.setType(type);
        loan.setPerson(person);
        loan.setAmount(amount);
        loan.setRemark(remark);

        if (accountIdStr != null && !accountIdStr.isEmpty()) {
            try {
                loan.setAccountId(Integer.parseInt(accountIdStr));
            } catch (NumberFormatException e) {
                loan.setAccountId(null);
            }
        }

        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date loanDate = sdf.parse(dateStr);
            loan.setLoanDate(loanDate);
        } catch (Exception e) {
            loan.setLoanDate(new Date());
        }

        boolean success = loanService.addLoan(loan);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/loan?action=list&success=借贷添加成功");
        } else {
            resp.sendRedirect(req.getContextPath() + "/loan?action=list&error=添加失败");
        }
    }

    private void getLoan(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        Loan loan = loanService.getLoanById(id, user.getId());
        resp.setContentType("application/json;charset=utf-8");
        if (loan != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Map<String, Object> result = new HashMap<>();
            result.put("id", loan.getId());
            result.put("type", loan.getType());
            result.put("person", loan.getPerson());
            result.put("amount", loan.getAmount());
            result.put("loanDate", loan.getLoanDate() != null ? sdf.format(loan.getLoanDate()) : "");
            result.put("status", loan.getStatus());
            result.put("remark", loan.getRemark());
            result.put("accountId", loan.getAccountId());           // 新增
            result.put("accountName", loan.getAccountName());       // 新增
            resp.getWriter().write(new Gson().toJson(result));
        } else {
            resp.getWriter().write("{}");
        }
    }

    private void updateLoan(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        String type = req.getParameter("type");
        String person = req.getParameter("person");
        BigDecimal amount = new BigDecimal(req.getParameter("amount"));
        String dateStr = req.getParameter("loanDate");
        String status = req.getParameter("status");
        String remark = req.getParameter("remark");
        String accountIdStr = req.getParameter("accountId");   // 新增

        Loan loan = new Loan();
        loan.setId(id);
        loan.setUserId(user.getId());
        loan.setType(type);
        loan.setPerson(person);
        loan.setAmount(amount);
        loan.setStatus(status);
        loan.setRemark(remark);

        if (accountIdStr != null && !accountIdStr.isEmpty()) {
            try {
                loan.setAccountId(Integer.parseInt(accountIdStr));
            } catch (NumberFormatException e) {
                loan.setAccountId(null);
            }
        }

        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date loanDate = sdf.parse(dateStr);
            loan.setLoanDate(loanDate);
        } catch (Exception e) {
            loan.setLoanDate(new Date());
        }

        boolean success = loanService.updateLoan(loan);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/loan?action=list&success=修改成功");
        } else {
            resp.sendRedirect(req.getContextPath() + "/loan?action=list&error=修改失败");
        }
    }

    private void repayLoan(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        boolean success = loanService.repayLoan(id, user.getId());
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/loan?action=list&success=还款成功");
        } else {
            resp.sendRedirect(req.getContextPath() + "/loan?action=list&error=还款失败");
        }
    }

    private void deleteLoan(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        boolean success = loanService.deleteLoan(id, user.getId());
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/loan?action=list&success=删除成功");
        } else {
            resp.sendRedirect(req.getContextPath() + "/loan?action=list&error=删除失败");
        }
    }
}
package service;

import dao.AccountDAO;
import dao.TransactionDAO;
import entity.PageBean;
import entity.Transaction;
import entity.Account;
import util.DBUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class TransactionService {
    private TransactionDAO transactionDAO = new TransactionDAO();
    private AccountDAO accountDAO = new AccountDAO();

    /**
     * 判断账户是否为借贷类（可透支）
     */
    private boolean isCreditAccount(Account account) {
        if (account == null) return false;
        String type = account.getType();
        return "信用卡".equals(type) || "花呗".equals(type);
    }

    // ===== 新增记账（保持不变） =====
    public boolean addTransaction(Transaction transaction) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            Account account = accountDAO.findById(transaction.getAccountId());
            if (account == null) {
                conn.rollback();
                System.out.println("账户不存在，accountId=" + transaction.getAccountId());
                return false;
            }

            BigDecimal currentBalance = account.getBalance();
            boolean isCredit = isCreditAccount(account);

            BigDecimal newBalance;
            if ("income".equals(transaction.getType())) {
                newBalance = currentBalance.add(transaction.getAmount());
            } else {
                newBalance = currentBalance.subtract(transaction.getAmount());
                if (!isCredit && newBalance.compareTo(BigDecimal.ZERO) < 0) {
                    conn.rollback();
                    System.out.println("余额不足！");
                    return false;
                }
            }

            boolean result = transactionDAO.addTransaction(transaction);
            if (!result) {
                conn.rollback();
                return false;
            }

            result = accountDAO.updateBalance(transaction.getAccountId(), newBalance);
            if (!result) {
                conn.rollback();
                return false;
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return false;
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // ===== 更新交易记录（修复版：情况2先预校验余额） =====
    public boolean updateTransaction(Transaction newTrans, Transaction oldTrans) {
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            boolean sameAccount = oldTrans.getAccountId().equals(newTrans.getAccountId());
            boolean sameType = oldTrans.getType().equals(newTrans.getType());

            // ===== 情况1：同一账户同一类型 =====
            if (sameAccount && sameType) {
                BigDecimal diff = newTrans.getAmount().subtract(oldTrans.getAmount());

                Account account = accountDAO.findById(oldTrans.getAccountId());
                if (account == null) {
                    conn.rollback();
                    return false;
                }

                BigDecimal oldBalance = account.getBalance();
                BigDecimal newBalance;
                if ("income".equals(newTrans.getType())) {
                    newBalance = oldBalance.add(diff);
                } else {
                    newBalance = oldBalance.subtract(diff);
                }

                boolean isCredit = isCreditAccount(account);
                if (!isCredit && newBalance.compareTo(BigDecimal.ZERO) < 0) {
                    conn.rollback();
                    System.out.println("余额不足！");
                    return false;
                }

                boolean result = transactionDAO.updateTransaction(newTrans);
                if (!result) {
                    conn.rollback();
                    return false;
                }

                result = accountDAO.updateBalance(oldTrans.getAccountId(), newBalance);
                if (!result) {
                    conn.rollback();
                    return false;
                }

                conn.commit();
                return true;
            }

            // ===== 情况2：不同账户或不同类型 =====
            // ★★★ 2.0 先预校验新账户余额（这一步是新增的） ★★★
            Account newAccountCheck = accountDAO.findById(newTrans.getAccountId());
            if (newAccountCheck == null) {
                conn.rollback();
                System.out.println("新账户不存在");
                return false;
            }

            if ("expense".equals(newTrans.getType())) {
                boolean isCreditNew = isCreditAccount(newAccountCheck);
                // 预估新账户在交易后的余额
                BigDecimal estimated = newAccountCheck.getBalance().subtract(newTrans.getAmount());

                // 如果新旧账户是同一个账户，需要先把旧交易的影响还原后再判断
                if (oldTrans.getAccountId().equals(newTrans.getAccountId())) {
                    if ("income".equals(oldTrans.getType())) {
                        estimated = estimated.add(oldTrans.getAmount());
                    } else {
                        estimated = estimated.subtract(oldTrans.getAmount());
                    }
                }

                if (!isCreditNew && estimated.compareTo(BigDecimal.ZERO) < 0) {
                    conn.rollback();
                    System.out.println("新账户余额不足，预校验失败");
                    return false;
                }
            }
            // ★★★ 预校验结束 ★★★

            // 2.1 回退旧账户
            Account oldAccount = accountDAO.findById(oldTrans.getAccountId());
            if (oldAccount == null) {
                conn.rollback();
                return false;
            }

            BigDecimal oldAccountBalance = oldAccount.getBalance();
            BigDecimal oldAccountNewBalance;
            if ("income".equals(oldTrans.getType())) {
                oldAccountNewBalance = oldAccountBalance.subtract(oldTrans.getAmount());
            } else {
                oldAccountNewBalance = oldAccountBalance.add(oldTrans.getAmount());
            }

            boolean result = accountDAO.updateBalance(oldTrans.getAccountId(), oldAccountNewBalance);
            if (!result) {
                conn.rollback();
                return false;
            }

            // 2.2 更新交易记录
            result = transactionDAO.updateTransaction(newTrans);
            if (!result) {
                conn.rollback();
                return false;
            }

            // 2.3 更新新账户
            Account newAccount = accountDAO.findById(newTrans.getAccountId());
            if (newAccount == null) {
                conn.rollback();
                return false;
            }

            BigDecimal newAccountBalance = newAccount.getBalance();
            BigDecimal newAccountNewBalance;
            if ("income".equals(newTrans.getType())) {
                newAccountNewBalance = newAccountBalance.add(newTrans.getAmount());
            } else {
                newAccountNewBalance = newAccountBalance.subtract(newTrans.getAmount());
            }

            boolean isCreditNew = isCreditAccount(newAccount);
            if (!isCreditNew && newAccountNewBalance.compareTo(BigDecimal.ZERO) < 0) {
                conn.rollback();
                System.out.println("新账户余额不足");
                return false;
            }

            result = accountDAO.updateBalance(newTrans.getAccountId(), newAccountNewBalance);
            if (!result) {
                conn.rollback();
                return false;
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return false;
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // ===== 删除交易记录（保持不变） =====
    public boolean deleteTransaction(int id, int userId) {
        Transaction transaction = transactionDAO.findById(id, userId);
        if (transaction == null) return false;

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            Account account = accountDAO.findById(transaction.getAccountId());
            if (account == null) {
                conn.rollback();
                return false;
            }

            BigDecimal currentBalance = account.getBalance();
            BigDecimal newBalance;
            if ("income".equals(transaction.getType())) {
                newBalance = currentBalance.subtract(transaction.getAmount());
            } else {
                newBalance = currentBalance.add(transaction.getAmount());
            }

            if ("income".equals(transaction.getType())) {
                boolean isCredit = isCreditAccount(account);
                if (!isCredit && newBalance.compareTo(BigDecimal.ZERO) < 0) {
                    conn.rollback();
                    return false;
                }
            }

            boolean result = transactionDAO.deleteTransaction(id, userId);
            if (!result) {
                conn.rollback();
                return false;
            }

            result = accountDAO.updateBalance(transaction.getAccountId(), newBalance);
            if (!result) {
                conn.rollback();
                return false;
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            return false;
        } finally {
            try { if (conn != null) { conn.setAutoCommit(true); conn.close(); } } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // ===== 以下分页、统计方法保持不变 =====
    public PageBean<Transaction> getTransactionsByPage(int userId, String type, Integer categoryId,
                                                       Integer accountId, String startDate, String endDate,
                                                       int currentPage, int pageSize) {
        int offset = (currentPage - 1) * pageSize;
        List<Transaction> list = transactionDAO.findByPage(userId, type, categoryId, accountId,
                startDate, endDate, offset, pageSize);
        int totalCount = transactionDAO.countByCondition(userId, type, categoryId, accountId,
                startDate, endDate);
        return new PageBean<>(currentPage, pageSize, totalCount, list);
    }

    public Transaction getTransactionById(int id, int userId) {
        return transactionDAO.findByIdWithDetail(id, userId);
    }

    public BigDecimal getMonthlyIncome(int userId, String yearMonth) {
        String[] parts = yearMonth.split("-");
        String startDate = yearMonth + "-01";
        String endDate = yearMonth + "-" + getDaysOfMonth(Integer.parseInt(parts[0]), Integer.parseInt(parts[1]));
        return transactionDAO.sumByTypeAndDate(userId, "income", startDate, endDate);
    }

    public BigDecimal getMonthlyExpense(int userId, String yearMonth) {
        String[] parts = yearMonth.split("-");
        String startDate = yearMonth + "-01";
        String endDate = yearMonth + "-" + getDaysOfMonth(Integer.parseInt(parts[0]), Integer.parseInt(parts[1]));
        return transactionDAO.sumByTypeAndDate(userId, "expense", startDate, endDate);
    }

    public List<Object[]> getCategoryStats(int userId, String type, String yearMonth) {
        String[] parts = yearMonth.split("-");
        String startDate = yearMonth + "-01";
        String endDate = yearMonth + "-" + getDaysOfMonth(Integer.parseInt(parts[0]), Integer.parseInt(parts[1]));
        return transactionDAO.groupByCategory(userId, type, startDate, endDate);
    }

    private int getDaysOfMonth(int year, int month) {
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.set(year, month - 1, 1);
        return cal.getActualMaximum(java.util.Calendar.DAY_OF_MONTH);
    }
}
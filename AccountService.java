package service;

import dao.AccountDAO;
import entity.Account;

import java.math.BigDecimal;
import java.util.List;

public class AccountService {
    private AccountDAO accountDAO = new AccountDAO();

    public List<Account> getAccounts(int userId) {
        return accountDAO.findByUserId(userId);
    }

    public Account getAccountById(int id) {
        return accountDAO.findById(id);
    }

    public boolean isAccountNameExist(int userId, String accountName) {
        return accountDAO.existsByUserIdAndName(userId, accountName);
    }

    public boolean isAccountNameExistExcludeId(int userId, String accountName, int excludeId) {
        return accountDAO.existsByUserIdAndNameExcludeId(userId, accountName, excludeId);
    }

    public boolean addAccount(Account account) {
        try {
            if (isAccountNameExist(account.getUserId(), account.getAccountName())) {
                return false;
            }
            if (account.getBalance() == null) {
                account.setBalance(BigDecimal.ZERO);
            }
            // 非借贷账户初始余额不能为负
            String type = account.getType();
            boolean isCredit = "信用卡".equals(type) || "花呗".equals(type);
            if (!isCredit && account.getBalance().compareTo(BigDecimal.ZERO) < 0) {
                account.setBalance(BigDecimal.ZERO);
            }
            return accountDAO.addAccount(account);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateAccount(Account account) {
        if (isAccountNameExistExcludeId(account.getUserId(), account.getAccountName(), account.getId())) {
            return false;
        }
        // 非借贷账户余额不能为负
        String type = account.getType();
        boolean isCredit = "信用卡".equals(type) || "花呗".equals(type);
        if (!isCredit && account.getBalance() != null
                && account.getBalance().compareTo(BigDecimal.ZERO) < 0) {
            account.setBalance(BigDecimal.ZERO);
        }
        return accountDAO.updateAccount(account);
    }

    public boolean deleteAccount(int id, int userId) {
        if (accountDAO.hasTransactions(id)) {
            return false;
        }
        return accountDAO.deleteAccount(id, userId);
    }

    public BigDecimal getTotalAssets(int userId) {
        List<Account> accounts = accountDAO.findByUserId(userId);
        BigDecimal total = BigDecimal.ZERO;
        for (Account account : accounts) {
            total = total.add(account.getBalance());
        }
        return total;
    }
}
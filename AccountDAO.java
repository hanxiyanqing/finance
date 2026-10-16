package dao;

import entity.Account;
import util.DBUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AccountDAO {

    public List<Account> findByUserId(int userId) {
        String sql = "SELECT * FROM account WHERE user_id = ? ORDER BY id";
        List<Account> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Account account = new Account();
                account.setId(rs.getInt("id"));
                account.setUserId(rs.getInt("user_id"));
                account.setAccountName(rs.getString("account_name"));
                account.setType(rs.getString("type"));
                account.setBalance(rs.getBigDecimal("balance"));
                account.setRemark(rs.getString("remark"));
                account.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(account);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public Account findById(int id) {
        String sql = "SELECT * FROM account WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                Account account = new Account();
                account.setId(rs.getInt("id"));
                account.setUserId(rs.getInt("user_id"));
                account.setAccountName(rs.getString("account_name"));
                account.setType(rs.getString("type"));
                account.setBalance(rs.getBigDecimal("balance"));
                account.setRemark(rs.getString("remark"));
                account.setCreatedAt(rs.getTimestamp("created_at"));
                return account;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return null;
    }

    public boolean existsByUserIdAndName(int userId, String accountName) {
        String sql = "SELECT COUNT(*) FROM account WHERE user_id = ? AND account_name = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, accountName);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return false;
    }

    public boolean existsByUserIdAndNameExcludeId(int userId, String accountName, int excludeId) {
        String sql = "SELECT COUNT(*) FROM account WHERE user_id = ? AND account_name = ? AND id != ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, accountName);
            ps.setInt(3, excludeId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return false;
    }

    public boolean addAccount(Account account) {
        String sql = "INSERT INTO account (user_id, account_name, type, balance, remark) VALUES (?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, account.getUserId());
            ps.setString(2, account.getAccountName());
            ps.setString(3, account.getType());
            ps.setBigDecimal(4, account.getBalance() == null ? BigDecimal.ZERO : account.getBalance());
            ps.setString(5, account.getRemark());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, ps);
        }
    }

    public boolean updateAccount(Account account) {
        String sql = "UPDATE account SET account_name = ?, type = ?, balance = ?, remark = ? WHERE id = ? AND user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, account.getAccountName());
            ps.setString(2, account.getType());
            ps.setBigDecimal(3, account.getBalance());
            ps.setString(4, account.getRemark());
            ps.setInt(5, account.getId());
            ps.setInt(6, account.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, ps);
        }
    }

    // ===== 修复版：更新余额时检查非借贷账户不能为负 =====
    public boolean updateBalance(int accountId, BigDecimal newBalance) {
        // ===== 先检查账户类型 =====
        String checkSql = "SELECT TYPE FROM account WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(checkSql);
            ps.setInt(1, accountId);
            rs = ps.executeQuery();
            if (rs.next()) {
                String type = rs.getString("TYPE");
                // 非借贷账户（不是信用卡和花呗）余额不能为负
                if (!"信用卡".equals(type) && !"花呗".equals(type) && newBalance.compareTo(BigDecimal.ZERO) < 0) {
                    System.err.println("===== 警告：非借贷账户余额将为负数！ =====");
                    System.err.println("accountId: " + accountId + ", type: " + type + ", newBalance: " + newBalance);
                    return false;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, ps, rs);
        }

        // ===== 执行更新 =====
        String sql = "UPDATE account SET balance = ? WHERE id = ?";
        conn = null;
        ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setBigDecimal(1, newBalance);
            ps.setInt(2, accountId);
            int rows = ps.executeUpdate();
            System.out.println("===== updateBalance =====");
            System.out.println("accountId: " + accountId + ", newBalance: " + newBalance + ", 影响行数: " + rows);
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, ps);
        }
    }

    public boolean deleteAccount(int id, int userId) {
        String sql = "DELETE FROM account WHERE id = ? AND user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, ps);
        }
    }

    public boolean hasTransactions(int accountId) {
        String sql = "SELECT COUNT(*) FROM transaction WHERE account_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, accountId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return false;
    }
}
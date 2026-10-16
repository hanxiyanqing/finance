package service;

import dao.AccountDAO;
import dao.SystemConfigDAO;
import dao.UserDAO;
import entity.SystemConfig;
import entity.User;
import util.DBUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class AdminService {
    private UserDAO userDAO = new UserDAO();
    private AccountDAO accountDAO = new AccountDAO();
    private SystemConfigDAO systemConfigDAO = new SystemConfigDAO();

    public BigDecimal getTotalSystemAssets() {
        String sql = "SELECT COALESCE(SUM(balance), 0) FROM account";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getBigDecimal(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return BigDecimal.ZERO;
    }

    public String getSystemName() {
        SystemConfig config = systemConfigDAO.findByKey("system_name");
        return config != null ? config.getConfigValue() : "简易财富记账系统";
    }

    public boolean updateSystemName(String name) {
        return systemConfigDAO.updateValue("system_name", name);
    }

    public boolean isMaintenanceMode() {
        SystemConfig config = systemConfigDAO.findByKey("maintenance_mode");
        return config != null && "on".equals(config.getConfigValue());
    }

    public boolean toggleMaintenanceMode() {
        SystemConfig config = systemConfigDAO.findByKey("maintenance_mode");
        String newValue = config != null && "on".equals(config.getConfigValue()) ? "off" : "on";
        return systemConfigDAO.updateValue("maintenance_mode", newValue);
    }


    // ===== 新增：重新计算单个账户余额 =====
    public boolean recalculateAccountBalance(int accountId) {
        String sql = "UPDATE account a " +
                "SET a.balance = COALESCE((" +
                "    SELECT SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE -t.amount END) " +
                "    FROM transaction t WHERE t.account_id = a.id" +
                "), 0) " +
                "WHERE a.id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, accountId);
            int rows = ps.executeUpdate();
            System.out.println("===== 重新计算账户余额，accountId: " + accountId + ", 影响行数: " + rows);
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, ps);
        }
    }
}
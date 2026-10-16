package service;

import dao.SystemLogDAO;
import entity.SystemLog;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;

public class SystemLogService {
    private SystemLogDAO systemLogDAO = new SystemLogDAO();

    // 记录日志
    public void log(int userId, String username, String action, String description, String ip) {
        SystemLog log = new SystemLog();
        log.setUserId(userId);
        log.setUsername(username);
        log.setAction(action);
        log.setDescription(description);
        log.setIp(ip);
        systemLogDAO.addLog(log);
    }

    // 获取所有日志（分页）
    public List<SystemLog> getLogs(int page, int pageSize) {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 20;
        int offset = (page - 1) * pageSize;
        return systemLogDAO.findAll(offset, pageSize);
    }

    // 获取日志总数
    public int getLogCount() {
        return systemLogDAO.count();
    }
    public boolean updateValue(String key, String value) {
        String sql = "UPDATE system_config SET config_value = ?, updated_at = NOW() WHERE config_key = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, value);
            ps.setString(2, key);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, ps);
        }
    }
    // 清空日志
    public boolean clearLogs() {
        return systemLogDAO.clearAll();
    }
}
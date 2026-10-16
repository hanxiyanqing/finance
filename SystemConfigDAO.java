package dao;

import entity.SystemConfig;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SystemConfigDAO {

    // 查询所有配置
    public List<SystemConfig> findAll() {
        String sql = "SELECT * FROM system_config";
        List<SystemConfig> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                SystemConfig config = new SystemConfig();
                config.setId(rs.getInt("id"));
                config.setConfigKey(rs.getString("config_key"));
                config.setConfigValue(rs.getString("config_value"));
                config.setDescription(rs.getString("description"));
                config.setUpdatedAt(rs.getTimestamp("updated_at"));
                list.add(config);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    // 根据键名查询配置
    public SystemConfig findByKey(String key) {
        String sql = "SELECT * FROM system_config WHERE config_key = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, key);
            rs = ps.executeQuery();
            if (rs.next()) {
                SystemConfig config = new SystemConfig();
                config.setId(rs.getInt("id"));
                config.setConfigKey(rs.getString("config_key"));
                config.setConfigValue(rs.getString("config_value"));
                config.setDescription(rs.getString("description"));
                config.setUpdatedAt(rs.getTimestamp("updated_at"));
                return config;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return null;
    }

    // 更新配置值
    public boolean updateValue(String key, String value) {
        String sql = "UPDATE system_config SET config_value = ? WHERE config_key = ?";
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
}
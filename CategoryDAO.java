package dao;

import entity.Category;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {

    public List<Category> findByUserId(int userId) {
        String sql = "SELECT * FROM category WHERE user_id = ? ORDER BY type, sort_order, id";
        List<Category> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Category category = new Category();
                category.setId(rs.getInt("id"));
                category.setUserId(rs.getInt("user_id"));
                category.setName(rs.getString("name"));
                category.setType(rs.getString("type"));
                category.setIcon(rs.getString("icon"));
                category.setSortOrder(rs.getInt("sort_order"));
                category.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(category);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public List<Category> findByUserIdAndType(int userId, String type) {
        String sql = "SELECT * FROM category WHERE user_id = ? AND type = ? ORDER BY sort_order, id";
        List<Category> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, type);
            rs = ps.executeQuery();
            while (rs.next()) {
                Category category = new Category();
                category.setId(rs.getInt("id"));
                category.setUserId(rs.getInt("user_id"));
                category.setName(rs.getString("name"));
                category.setType(rs.getString("type"));
                category.setIcon(rs.getString("icon"));
                category.setSortOrder(rs.getInt("sort_order"));
                category.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(category);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public Category findById(int id) {
        String sql = "SELECT * FROM category WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                Category category = new Category();
                category.setId(rs.getInt("id"));
                category.setUserId(rs.getInt("user_id"));
                category.setName(rs.getString("name"));
                category.setType(rs.getString("type"));
                category.setIcon(rs.getString("icon"));
                category.setSortOrder(rs.getInt("sort_order"));
                category.setCreatedAt(rs.getTimestamp("created_at"));
                return category;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return null;
    }

    public boolean addCategory(Category category) {
        String sql = "INSERT INTO category (user_id, name, type, icon, sort_order) VALUES (?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, category.getUserId());
            ps.setString(2, category.getName());
            ps.setString(3, category.getType());
            ps.setString(4, category.getIcon());
            ps.setInt(5, category.getSortOrder() == null ? 0 : category.getSortOrder());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, ps);
        }
    }

    public boolean updateCategory(Category category) {
        String sql = "UPDATE category SET name = ?, icon = ?, sort_order = ?, type = ? WHERE id = ? AND user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, category.getName());
            ps.setString(2, category.getIcon());
            ps.setInt(3, category.getSortOrder() == null ? 0 : category.getSortOrder());
            ps.setString(4, category.getType());
            ps.setInt(5, category.getId());
            ps.setInt(6, category.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, ps);
        }
    }

    public boolean deleteCategory(int id, int userId) {
        String sql = "DELETE FROM category WHERE id = ? AND user_id = ?";
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

    public boolean hasTransactions(int categoryId) {
        String sql = "SELECT COUNT(*) FROM transaction WHERE category_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, categoryId);
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
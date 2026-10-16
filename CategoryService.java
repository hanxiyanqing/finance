package service;

import dao.CategoryDAO;
import entity.Category;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;

public class CategoryService {
    private CategoryDAO categoryDAO = new CategoryDAO();

    public List<Category> getCategories(int userId) {
        return categoryDAO.findByUserId(userId);
    }

    public List<Category> getCategoriesByType(int userId, String type) {
        return categoryDAO.findByUserIdAndType(userId, type);
    }

    public Category getCategoryById(int id) {
        return categoryDAO.findById(id);
    }

    public boolean addCategory(Category category) {
        List<Category> existing = categoryDAO.findByUserIdAndType(category.getUserId(), category.getType());
        for (Category c : existing) {
            if (c.getName().equals(category.getName())) {
                return false;
            }
        }
        return categoryDAO.addCategory(category);
    }

    public boolean updateCategory(Category category) {
        return categoryDAO.updateCategory(category);
    }

    public boolean deleteCategory(int id, int userId) {
        if (categoryDAO.hasTransactions(id)) {
            return false;
        }
        return categoryDAO.deleteCategory(id, userId);
    }

    public boolean batchUpdateSort(List<com.google.gson.JsonObject> updates, int userId) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = util.DBUtil.getConnection();
            conn.setAutoCommit(false);

            String sql = "UPDATE category SET sort_order = ? WHERE id = ? AND user_id = ?";
            ps = conn.prepareStatement(sql);

            for (com.google.gson.JsonObject obj : updates) {
                int id = obj.get("id").getAsInt();
                int sortOrder = obj.get("sortOrder").getAsInt();
                ps.setInt(1, sortOrder);
                ps.setInt(2, id);
                ps.setInt(3, userId);
                ps.addBatch();
            }

            ps.executeBatch();
            conn.commit();
            return true;  // 没抛异常就是成功
        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (Exception ex) {}
            return false;
        } finally {
            try {
                if (ps != null) ps.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception e) {}
        }
    }
}
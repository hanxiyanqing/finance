package dao;

import entity.Transaction;
import util.DBUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TransactionDAO {

    // 插入交易记录
    public boolean addTransaction(Transaction transaction) {
        String sql = "INSERT INTO transaction (user_id, account_id, category_id, type, amount, trans_date, remark) VALUES (?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, transaction.getUserId());
            ps.setInt(2, transaction.getAccountId());
            ps.setInt(3, transaction.getCategoryId());
            ps.setString(4, transaction.getType());
            ps.setBigDecimal(5, transaction.getAmount());
            ps.setTimestamp(6, new java.sql.Timestamp(transaction.getTransDate().getTime()));
            ps.setString(7, transaction.getRemark());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, ps);
        }
    }

    // ===== 根据ID查询交易（仅交易本身，不含关联信息） =====
    public Transaction findById(int id, int userId) {
        String sql = "SELECT * FROM transaction WHERE id = ? AND user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.setInt(2, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                Transaction t = new Transaction();
                t.setId(rs.getInt("id"));
                t.setUserId(rs.getInt("user_id"));
                t.setAccountId(rs.getInt("account_id"));
                t.setCategoryId(rs.getInt("category_id"));
                t.setType(rs.getString("type"));
                t.setAmount(rs.getBigDecimal("amount"));
                t.setTransDate(rs.getTimestamp("trans_date"));
                t.setRemark(rs.getString("remark"));
                t.setCreatedAt(rs.getTimestamp("created_at"));
                return t;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return null;
    }

    // 分页查询交易记录（带条件筛选，含关联信息）
    public List<Transaction> findByPage(int userId, String type, Integer categoryId, Integer accountId,
                                        String startDate, String endDate, int offset, int pageSize) {
        StringBuilder sql = new StringBuilder(
                "SELECT t.*, a.account_name, c.name as category_name " +
                        "FROM transaction t " +
                        "LEFT JOIN account a ON t.account_id = a.id " +
                        "LEFT JOIN category c ON t.category_id = c.id " +
                        "WHERE t.user_id = ? "
        );
        List<Object> params = new ArrayList<>();
        params.add(userId);

        if (type != null && !type.isEmpty() && !"全部".equals(type)) {
            sql.append("AND t.type = ? ");
            params.add(type);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append("AND t.category_id = ? ");
            params.add(categoryId);
        }
        if (accountId != null && accountId > 0) {
            sql.append("AND t.account_id = ? ");
            params.add(accountId);
        }
        if (startDate != null && !startDate.isEmpty()) {
            sql.append("AND DATE(t.trans_date) >= ? ");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append("AND DATE(t.trans_date) <= ? ");
            params.add(endDate);
        }

        sql.append("ORDER BY t.trans_date DESC, t.id DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(offset);

        List<Transaction> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                Transaction t = new Transaction();
                t.setId(rs.getInt("id"));
                t.setUserId(rs.getInt("user_id"));
                t.setAccountId(rs.getInt("account_id"));
                t.setCategoryId(rs.getInt("category_id"));
                t.setType(rs.getString("type"));
                t.setAmount(rs.getBigDecimal("amount"));
                t.setTransDate(rs.getTimestamp("trans_date"));
                t.setRemark(rs.getString("remark"));
                t.setCreatedAt(rs.getTimestamp("created_at"));
                t.setAccountName(rs.getString("account_name"));
                t.setCategoryName(rs.getString("category_name"));
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    // 统计符合条件的记录总数
    public int countByCondition(int userId, String type, Integer categoryId, Integer accountId,
                                String startDate, String endDate) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM transaction WHERE user_id = ? ");
        List<Object> params = new ArrayList<>();
        params.add(userId);

        if (type != null && !type.isEmpty() && !"全部".equals(type)) {
            sql.append("AND type = ? ");
            params.add(type);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append("AND category_id = ? ");
            params.add(categoryId);
        }
        if (accountId != null && accountId > 0) {
            sql.append("AND account_id = ? ");
            params.add(accountId);
        }
        if (startDate != null && !startDate.isEmpty()) {
            sql.append("AND DATE(trans_date) >= ? ");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append("AND DATE(trans_date) <= ? ");
            params.add(endDate);
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return 0;
    }

    // 根据ID查询交易（含关联信息）
    public Transaction findByIdWithDetail(int id, int userId) {
        String sql = "SELECT t.*, a.account_name, c.name as category_name " +
                "FROM transaction t " +
                "LEFT JOIN account a ON t.account_id = a.id " +
                "LEFT JOIN category c ON t.category_id = c.id " +
                "WHERE t.id = ? AND t.user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ps.setInt(2, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                Transaction t = new Transaction();
                t.setId(rs.getInt("id"));
                t.setUserId(rs.getInt("user_id"));
                t.setAccountId(rs.getInt("account_id"));
                t.setCategoryId(rs.getInt("category_id"));
                t.setType(rs.getString("type"));
                t.setAmount(rs.getBigDecimal("amount"));
                t.setTransDate(rs.getTimestamp("trans_date"));
                t.setRemark(rs.getString("remark"));
                t.setCreatedAt(rs.getTimestamp("created_at"));
                t.setAccountName(rs.getString("account_name"));
                t.setCategoryName(rs.getString("category_name"));
                return t;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return null;
    }

    // 更新交易记录
    public boolean updateTransaction(Transaction transaction) {
        String sql = "UPDATE transaction SET account_id = ?, category_id = ?, type = ?, amount = ?, trans_date = ?, remark = ? WHERE id = ? AND user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, transaction.getAccountId());
            ps.setInt(2, transaction.getCategoryId());
            ps.setString(3, transaction.getType());
            ps.setBigDecimal(4, transaction.getAmount());
            ps.setTimestamp(5, new java.sql.Timestamp(transaction.getTransDate().getTime()));
            ps.setString(6, transaction.getRemark());
            ps.setInt(7, transaction.getId());
            ps.setInt(8, transaction.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, ps);
        }
    }

    // 删除交易记录
    public boolean deleteTransaction(int id, int userId) {
        String sql = "DELETE FROM transaction WHERE id = ? AND user_id = ?";
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

    // 查询某账户的所有交易
    public List<Transaction> findByAccountId(int accountId, int userId) {
        String sql = "SELECT * FROM transaction WHERE account_id = ? AND user_id = ?";
        List<Transaction> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, accountId);
            ps.setInt(2, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Transaction t = new Transaction();
                t.setId(rs.getInt("id"));
                t.setUserId(rs.getInt("user_id"));
                t.setAccountId(rs.getInt("account_id"));
                t.setCategoryId(rs.getInt("category_id"));
                t.setType(rs.getString("type"));
                t.setAmount(rs.getBigDecimal("amount"));
                t.setTransDate(rs.getTimestamp("trans_date"));
                t.setRemark(rs.getString("remark"));
                t.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    // 统计某用户在某时间段内的总收入和总支出
    public BigDecimal sumByTypeAndDate(int userId, String type, String startDate, String endDate) {
        String sql = "SELECT COALESCE(SUM(amount), 0) FROM transaction WHERE user_id = ? AND type = ? AND DATE(trans_date) >= ? AND DATE(trans_date) <= ?";
        System.out.println("===== sumByTypeAndDate =====");
        System.out.println("userId: " + userId + ", type: " + type + ", start: " + startDate + ", end: " + endDate);
        System.out.println("SQL: " + sql);

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, type);
            ps.setString(3, startDate);
            ps.setString(4, endDate);
            rs = ps.executeQuery();
            if (rs.next()) {
                BigDecimal result = rs.getBigDecimal(1);
                System.out.println("查询结果: " + result);
                return result;
            }
        } catch (SQLException e) {
            System.out.println("SQL异常: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return BigDecimal.ZERO;
    }

    // 按类别分组统计（用于图表）
    public List<Object[]> groupByCategory(int userId, String type, String startDate, String endDate) {
        String sql = "SELECT c.name, SUM(t.amount) as total " +
                "FROM transaction t " +
                "LEFT JOIN category c ON t.category_id = c.id " +
                "WHERE t.user_id = ? AND t.type = ? AND DATE(t.trans_date) >= ? AND DATE(t.trans_date) <= ? " +
                "GROUP BY t.category_id, c.name " +
                "ORDER BY total DESC";
        System.out.println("===== groupByCategory =====");
        System.out.println("userId: " + userId + ", type: " + type + ", start: " + startDate + ", end: " + endDate);
        System.out.println("SQL: " + sql);

        List<Object[]> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, type);
            ps.setString(3, startDate);
            ps.setString(4, endDate);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Object[]{rs.getString("name"), rs.getBigDecimal("total")});
                System.out.println("分类: " + rs.getString("name") + ", 金额: " + rs.getBigDecimal("total"));
            }
        } catch (SQLException e) {
            System.out.println("SQL异常: " + e.getMessage());
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        System.out.println("返回结果数量: " + list.size());
        return list;
    }
}
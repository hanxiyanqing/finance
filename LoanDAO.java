package dao;

import entity.Loan;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class LoanDAO {

    public List<Loan> findByUserId(int userId) {
        String sql = "SELECT l.*, a.account_name " +
                "FROM loan l " +
                "LEFT JOIN account a ON l.account_id = a.id " +
                "WHERE l.user_id = ? " +
                "ORDER BY l.loan_date DESC, l.id DESC";
        List<Loan> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Loan loan = mapRow(rs);
                list.add(loan);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public List<Loan> findByUserIdAndStatus(int userId, String status) {
        String sql = "SELECT l.*, a.account_name " +
                "FROM loan l " +
                "LEFT JOIN account a ON l.account_id = a.id " +
                "WHERE l.user_id = ? AND l.status = ? " +
                "ORDER BY l.loan_date DESC, l.id DESC";
        List<Loan> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, status);
            rs = ps.executeQuery();
            while (rs.next()) {
                Loan loan = mapRow(rs);
                list.add(loan);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return list;
    }

    public Loan findById(int id, int userId) {
        String sql = "SELECT l.*, a.account_name " +
                "FROM loan l " +
                "LEFT JOIN account a ON l.account_id = a.id " +
                "WHERE l.id = ? AND l.user_id = ?";
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
                return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBUtil.close(conn, ps, rs);
        }
        return null;
    }

    public boolean addLoan(Loan loan) {
        String sql = "INSERT INTO loan (user_id, type, person, amount, loan_date, status, remark, account_id, linked_transaction_id) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, loan.getUserId());
            ps.setString(2, loan.getType());
            ps.setString(3, loan.getPerson());
            ps.setBigDecimal(4, loan.getAmount());
            ps.setDate(5, new java.sql.Date(loan.getLoanDate().getTime()));
            ps.setString(6, loan.getStatus() == null ? "unpaid" : loan.getStatus());
            ps.setString(7, loan.getRemark());

            if (loan.getAccountId() != null) {
                ps.setInt(8, loan.getAccountId());
            } else {
                ps.setNull(8, java.sql.Types.INTEGER);
            }
            if (loan.getLinkedTransactionId() != null) {
                ps.setInt(9, loan.getLinkedTransactionId());
            } else {
                ps.setNull(9, java.sql.Types.INTEGER);
            }

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, ps);
        }
    }

    public boolean updateLoan(Loan loan) {
        String sql = "UPDATE loan SET type = ?, person = ?, amount = ?, loan_date = ?, " +
                "status = ?, remark = ?, account_id = ?, linked_transaction_id = ? " +
                "WHERE id = ? AND user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, loan.getType());
            ps.setString(2, loan.getPerson());
            ps.setBigDecimal(3, loan.getAmount());
            ps.setDate(4, new java.sql.Date(loan.getLoanDate().getTime()));
            ps.setString(5, loan.getStatus());
            ps.setString(6, loan.getRemark());

            if (loan.getAccountId() != null) {
                ps.setInt(7, loan.getAccountId());
            } else {
                ps.setNull(7, java.sql.Types.INTEGER);
            }
            if (loan.getLinkedTransactionId() != null) {
                ps.setInt(8, loan.getLinkedTransactionId());
            } else {
                ps.setNull(8, java.sql.Types.INTEGER);
            }

            ps.setInt(9, loan.getId());
            ps.setInt(10, loan.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, ps);
        }
    }

    public boolean updateStatus(int id, int userId, String status) {
        String sql = "SELECT l.*, a.account_name " +
                "FROM loan l " +
                "LEFT JOIN account a ON l.account_id = a.id " +
                "WHERE l.user_id = ? ORDER BY l.loan_date DESC, l.id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.setInt(3, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBUtil.close(conn, ps);
        }
    }

    public boolean deleteLoan(int id, int userId) {
        String sql = "DELETE FROM loan WHERE id = ? AND user_id = ?";
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
    private Loan mapRow(ResultSet rs) throws SQLException {
        Loan loan = new Loan();
        loan.setId(rs.getInt("id"));
        loan.setUserId(rs.getInt("user_id"));
        loan.setType(rs.getString("type"));
        loan.setPerson(rs.getString("person"));
        loan.setAmount(rs.getBigDecimal("amount"));
        loan.setLoanDate(rs.getDate("loan_date"));
        loan.setStatus(rs.getString("status"));
        loan.setRemark(rs.getString("remark"));
        loan.setCreatedAt(rs.getTimestamp("created_at"));

        // account_id 可能是 NULL，要用 getObject
        Object accountIdObj = rs.getObject("account_id");
        loan.setAccountId(accountIdObj != null ? ((Number) accountIdObj).intValue() : null);

        Object linkedTransIdObj = rs.getObject("linked_transaction_id");
        loan.setLinkedTransactionId(linkedTransIdObj != null ? ((Number) linkedTransIdObj).intValue() : null);

        loan.setAccountName(rs.getString("account_name"));
        return loan;
    }
}
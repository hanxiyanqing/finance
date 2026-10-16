package service;

import dao.UserDAO;
import entity.User;
import util.MD5Util;

import java.util.List;

public class UserService {
    private UserDAO userDAO = new UserDAO();

    // ===== 登录验证 =====
    public User login(String username, String password) {
        User user = userDAO.findByUsername(username);
        if (user != null && user.getPassword().equals(MD5Util.md5(password))) {
            // 检查账号状态
            if ("locked".equals(user.getStatus())) {
                return null;  // 账号被锁定
            }
            return user;
        }
        return null;
    }

    // 新增：锁定/解锁用户
    public boolean lockUser(int userId) {
        return userDAO.updateStatus(userId, "locked");
    }

    public boolean unlockUser(int userId) {
        return userDAO.updateStatus(userId, "active");
    }

    // ===== 用户注册（强制为普通用户） =====
    public boolean registerUser(String username, String password, String email) {
        if (userDAO.findByUsername(username) != null) {
            return false;
        }
        User user = new User(username, MD5Util.md5(password), email);
        user.setRole("user");  // 强制普通用户
        return userDAO.addUser(user);
    }

    // ===== 管理员功能 =====

    public List<User> getAllUsers() {
        return userDAO.findAll();
    }

    public User findByUsername(String username) {
        return userDAO.findByUsername(username);
    }

    public User findById(int userId) {
        return userDAO.findById(userId);
    }

    // 管理员新增用户（可选角色）
    public boolean addUserByAdmin(User user) {
        if (userDAO.findByUsername(user.getUsername()) != null) {
            return false;
        }
        return userDAO.addUser(user);
    }

    public boolean updateUsername(int userId, String newUsername) {
        return userDAO.updateUsername(userId, newUsername);
    }

    public boolean updatePassword(int userId, String encryptedPassword) {
        return userDAO.updatePassword(userId, encryptedPassword);
    }

    public boolean setAdmin(int userId) {
        return userDAO.updateRole(userId, "admin");
    }

    public boolean removeAdmin(int userId) {
        return userDAO.updateRole(userId, "user");
    }

    public boolean deleteUser(int userId) {
        return userDAO.deleteUser(userId);
    }

    // ===== 普通用户功能 =====

    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        User user = userDAO.findById(userId);
        if (user == null) {
            return false;
        }
        // 验证旧密码
        if (!user.getPassword().equals(MD5Util.md5(oldPassword))) {
            return false;
        }
        // 验证新旧密码不能相同
        if (oldPassword.equals(newPassword)) {
            return false;
        }
        // 更新密码（加密存储）
        return userDAO.updatePassword(userId, MD5Util.md5(newPassword));
    }

    // ===== 验证密码是否正确 =====
    public boolean verifyPassword(int userId, String password) {
        User user = userDAO.findById(userId);
        if (user == null) {
            return false;
        }
        return user.getPassword().equals(MD5Util.md5(password));
    }
}
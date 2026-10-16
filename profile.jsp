<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2026/6/25
  Time: 10:26
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    boolean isAdmin = "admin".equals(user.getRole());
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>个人设置</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
    <style>
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 10px;
        }
        .page-header h2 {
            font-size: 20px;
            color: rgba(255,255,255,0.9);
        }
        .profile-card {
            background: rgba(255,255,255,0.04);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255,255,255,0.06);
            border-radius: 14px;
            padding: 24px 28px;
            margin-bottom: 20px;
        }
        .profile-card .card-title {
            font-size: 16px;
            font-weight: 600;
            color: rgba(255,255,255,0.8);
            margin-bottom: 16px;
            padding-bottom: 8px;
            border-bottom: 1px solid rgba(255,255,255,0.06);
        }
        .profile-card .info-text {
            background: rgba(255,255,255,0.03);
            padding: 14px 18px;
            border-radius: 10px;
            color: rgba(255,255,255,0.7);
            font-size: 14px;
            line-height: 1.8;
            border: 1px solid rgba(255,255,255,0.04);
        }
        .profile-card .info-text strong {
            color: rgba(255,255,255,0.9);
        }
        .form-group {
            margin-bottom: 16px;
        }
        .form-group label {
            display: block;
            font-size: 13px;
            color: rgba(255,255,255,0.5);
            margin-bottom: 4px;
            font-weight: 500;
        }
        .form-group input {
            width: 100%;
            padding: 10px 14px;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 10px;
            font-size: 14px;
            color: rgba(255,255,255,0.85);
            outline: none;
            transition: all 0.3s ease;
        }
        .form-group input:focus {
            border-color: rgba(56,189,248,0.3);
            box-shadow: 0 0 0 3px rgba(56,189,248,0.06);
        }
        .form-group input.error {
            border-color: rgba(248,113,113,0.5);
            box-shadow: 0 0 0 3px rgba(248,113,113,0.1);
        }
        .form-group .hint {
            font-size: 12px;
            color: rgba(255,255,255,0.2);
            margin-top: 4px;
        }
        .form-group .hint.error-text {
            color: #f87171;
        }
        .form-group .hint.success-text {
            color: #6ee7b7;
        }
        .toast {
            padding: 12px 20px;
            border-radius: 10px;
            margin-bottom: 16px;
        }
        .toast-success {
            background: rgba(52,211,153,0.1);
            color: #6ee7b7;
            border: 1px solid rgba(52,211,153,0.06);
        }
        .toast-error {
            background: rgba(248,113,113,0.1);
            color: #fca5a5;
            border: 1px solid rgba(248,113,113,0.06);
        }
        .flex { display: flex; gap: 10px; flex-wrap: wrap; }
        .mt-2 { margin-top: 10px; }
        .btn-back {
            background: rgba(255,255,255,0.06);
            color: rgba(255,255,255,0.6);
            border: 1px solid rgba(255,255,255,0.08);
            padding: 10px 24px;
            border-radius: 10px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s;
        }
        .btn-back:hover {
            background: rgba(255,255,255,0.1);
            color: white;
        }
        @media (max-width:576px) {
            .profile-card { padding: 18px 16px; }
        }
    </style>
</head>
<body>

<nav class="navbar">
    <a class="brand" href="${pageContext.request.contextPath}/index.jsp"><i class="bi bi-wallet2"></i>简易财富记账系统</a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/transaction?action=list">收支管理</a>
        <a href="${pageContext.request.contextPath}/account?action=list">账户管理</a>
        <a href="${pageContext.request.contextPath}/loan?action=list">借贷管理</a>
        <a href="${pageContext.request.contextPath}/category?action=list">类别管理</a>
        <a href="${pageContext.request.contextPath}/statistics/index.jsp">统计分析</a>
        <% if (isAdmin) { %>
        <a href="${pageContext.request.contextPath}/admin?action=users">👑 用户管理</a>
        <% } %>
        <span class="divider">|</span>
        <span class="username">👤 <%= user.getUsername() %></span>
        <a href="${pageContext.request.contextPath}/user/profile.jsp" class="profile-link" style="background:rgba(255,255,255,0.25);">⚙️ 个人设置</a>
        <a href="${pageContext.request.contextPath}/user?action=logout" class="logout-btn">退出</a>
    </div>
</nav>

<div class="container">

    <div class="page-header">
        <h2><i class="bi bi-gear"></i> 个人设置</h2>
        <a href="${pageContext.request.contextPath}/index.jsp" class="btn-back">← 返回首页</a>
    </div>

    <% if (success != null && !success.isEmpty()) { %>
    <div class="toast toast-success"><i class="bi bi-check-circle"></i> <%= success %></div>
    <% } %>
    <% if (error != null && !error.isEmpty()) { %>
    <div class="toast toast-error"><i class="bi bi-exclamation-circle"></i> <%= error %></div>
    <% } %>

    <!-- 用户信息 -->
    <div class="profile-card">
        <div class="card-title">📋 我的信息</div>
        <div class="info-text">
            <p><strong>用户名：</strong><%= user.getUsername() %></p>
            <p><strong>邮箱：</strong><%= user.getEmail() != null ? user.getEmail() : "未设置" %></p>
            <p><strong>角色：</strong><%= "admin".equals(user.getRole()) ? "管理员" : "普通用户" %></p>
            <p><strong>注册时间：</strong><%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(user.getRegTime()) %></p>
        </div>
    </div>

    <!-- 修改用户名 -->
    <div class="profile-card">
        <div class="card-title">🔤 修改用户名</div>
        <form action="${pageContext.request.contextPath}/user" method="post" onsubmit="return validateUsername()">
            <input type="hidden" name="action" value="updateUsername">
            <div class="form-group">
                <label>新用户名 <span style="color:#f87171;">*</span></label>
                <input type="text" id="newUsername" name="newUsername" placeholder="请输入新用户名（至少3个字符）" required minlength="3">
                <div class="hint">用户名不可与其他用户重复</div>
            </div>
            <button type="submit" class="btn-primary"><i class="bi bi-check-lg"></i> 确认修改用户名</button>
        </form>
    </div>

    <!-- 修改密码 -->
    <div class="profile-card">
        <div class="card-title">🔒 修改密码</div>
        <form action="${pageContext.request.contextPath}/user" method="post" onsubmit="return validatePassword()">
            <input type="hidden" name="action" value="updatePassword">
            <div class="form-group">
                <label>当前密码 <span style="color:#f87171;">*</span></label>
                <input type="password" id="oldPassword" name="oldPassword" placeholder="请输入当前密码" required>
                <div class="hint" id="oldPasswordHint"></div>
            </div>
            <div class="form-group">
                <label>新密码 <span style="color:#f87171;">*</span></label>
                <input type="password" id="newPassword" name="newPassword" placeholder="请设置新密码（至少6个字符）" required minlength="6" oninput="checkPasswordMatch()">
                <div class="hint" id="newPasswordHint">密码至少6个字符</div>
            </div>
            <div class="form-group">
                <label>确认新密码 <span style="color:#f87171;">*</span></label>
                <input type="password" id="confirmPassword" name="confirmPassword" placeholder="请再次输入新密码" required oninput="checkPasswordMatch()">
                <div class="hint" id="confirmPasswordHint"></div>
            </div>
            <button type="submit" class="btn-primary" id="submitBtn"><i class="bi bi-check-lg"></i> 确认修改密码</button>
        </form>
    </div>

    <div class="flex mt-2">
        <a href="${pageContext.request.contextPath}/index.jsp" class="btn-back">← 返回首页</a>
    </div>
</div>

<script>
    // ===== 验证用户名 =====
    function validateUsername() {
        var username = document.getElementById('newUsername').value.trim();
        if (username.length < 3) {
            alert('用户名至少需要3个字符');
            document.getElementById('newUsername').focus();
            return false;
        }
        if (!/^[a-zA-Z0-9_\u4e00-\u9fa5]{3,20}$/.test(username)) {
            alert('用户名只能包含中文、字母、数字和下划线，长度3-20个字符');
            document.getElementById('newUsername').focus();
            return false;
        }
        return true;
    }

    // ===== 检查密码是否匹配 =====
    function checkPasswordMatch() {
        var oldPassword = document.getElementById('oldPassword').value;
        var newPassword = document.getElementById('newPassword').value;
        var confirmPassword = document.getElementById('confirmPassword').value;
        var submitBtn = document.getElementById('submitBtn');
        var newPasswordHint = document.getElementById('newPasswordHint');
        var confirmPasswordHint = document.getElementById('confirmPasswordHint');
        var oldPasswordHint = document.getElementById('oldPasswordHint');

        // 检查当前密码和新密码是否相同
        if (oldPassword.length > 0 && newPassword.length > 0 && oldPassword === newPassword) {
            oldPasswordHint.textContent = '⚠️ 新密码不能与当前密码相同';
            oldPasswordHint.className = 'hint error-text';
            submitBtn.disabled = true;
            return;
        } else {
            oldPasswordHint.textContent = '';
            oldPasswordHint.className = 'hint';
        }

        // 检查新密码长度
        if (newPassword.length > 0 && newPassword.length < 6) {
            newPasswordHint.textContent = '⚠️ 密码至少需要6个字符';
            newPasswordHint.className = 'hint error-text';
            submitBtn.disabled = true;
            return;
        } else {
            newPasswordHint.textContent = '✅ 密码长度符合要求';
            newPasswordHint.className = 'hint success-text';
        }

        // 检查确认密码是否匹配
        if (confirmPassword.length > 0) {
            if (newPassword === confirmPassword) {
                confirmPasswordHint.textContent = '✅ 密码匹配';
                confirmPasswordHint.className = 'hint success-text';
                submitBtn.disabled = false;
            } else {
                confirmPasswordHint.textContent = '⚠️ 两次输入的密码不一致';
                confirmPasswordHint.className = 'hint error-text';
                submitBtn.disabled = true;
            }
        } else {
            confirmPasswordHint.textContent = '';
            confirmPasswordHint.className = 'hint';
            submitBtn.disabled = false;
        }
    }

    // ===== 验证密码提交 =====
    function validatePassword() {
        var oldPassword = document.getElementById('oldPassword').value;
        var newPassword = document.getElementById('newPassword').value;
        var confirmPassword = document.getElementById('confirmPassword').value;

        // 验证当前密码不为空
        if (!oldPassword || oldPassword.length === 0) {
            alert('请输入当前密码');
            document.getElementById('oldPassword').focus();
            return false;
        }

        // 验证新密码不为空
        if (!newPassword || newPassword.length === 0) {
            alert('请设置新密码');
            document.getElementById('newPassword').focus();
            return false;
        }

        // 验证新密码长度
        if (newPassword.length < 6) {
            alert('新密码至少需要6个字符');
            document.getElementById('newPassword').focus();
            return false;
        }

        // 验证当前密码和新密码不能相同
        if (oldPassword === newPassword) {
            alert('新密码不能与当前密码相同，请重新设置');
            document.getElementById('newPassword').focus();
            return false;
        }

        // 验证确认密码
        if (newPassword !== confirmPassword) {
            alert('两次输入的密码不一致，请重新输入');
            document.getElementById('confirmPassword').focus();
            return false;
        }

        return true;
    }

    // ===== 页面加载完成后初始化 =====
    document.addEventListener('DOMContentLoaded', function() {
        // 监听所有密码输入框的变化
        var oldPwd = document.getElementById('oldPassword');
        var newPwd = document.getElementById('newPassword');
        var confirmPwd = document.getElementById('confirmPassword');

        if (oldPwd) {
            oldPwd.addEventListener('input', checkPasswordMatch);
        }
        if (newPwd) {
            newPwd.addEventListener('input', checkPasswordMatch);
        }
        if (confirmPwd) {
            confirmPwd.addEventListener('input', checkPasswordMatch);
        }
    });
</script>

</body>
</html>
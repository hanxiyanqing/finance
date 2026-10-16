<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2026/6/25
  Time: 10:12
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null || !"admin".equals(currentUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    User editUser = (User) request.getAttribute("editUser");
    if (editUser == null) {
        response.sendRedirect(request.getContextPath() + "/admin?action=users");
        return;
    }

    // 统一从session获取系统名称
    String systemName = (String) session.getAttribute("systemName");
    if (systemName == null) {
        systemName = (String) request.getAttribute("systemName");
    }
    if (systemName == null) systemName = "简易财富记账系统";

    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>编辑用户</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .header { display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; flex-wrap:wrap; gap:10px; }
        .header h2 { font-size:20px; color:rgba(255,255,255,0.9); }
        .header h2 i { color:#7dd3fc; margin-right:8px; }
        .card { background:rgba(255,255,255,0.05); backdrop-filter:blur(12px); border:1px solid rgba(255,255,255,0.06); border-radius:14px; padding:20px 24px; margin-bottom:20px; }
        .card-title { font-size:16px; font-weight:600; color:rgba(255,255,255,0.9); padding-bottom:12px; border-bottom:1px solid rgba(255,255,255,0.06); margin-bottom:14px; }
        .form-group { margin-bottom:16px; }
        .form-group label { display:block; font-size:13px; color:rgba(255,255,255,0.5); margin-bottom:4px; font-weight:500; }
        .form-group input { width:100%; padding:10px 14px; background:rgba(255,255,255,0.05); border:1px solid rgba(255,255,255,0.08); border-radius:10px; font-size:14px; color:rgba(255,255,255,0.85); outline:none; transition:all 0.3s; }
        .form-group input:focus { border-color:rgba(56,189,248,0.3); box-shadow:0 0 0 3px rgba(56,189,248,0.06); }
        .form-group .hint { font-size:12px; color:rgba(255,255,255,0.25); margin-top:4px; }
        .btn-back { background:rgba(255,255,255,0.06); color:rgba(255,255,255,0.6); border:1px solid rgba(255,255,255,0.08); padding:10px 24px; border-radius:10px; cursor:pointer; font-size:14px; text-decoration:none; display:inline-block; transition:all 0.2s; }
        .btn-back:hover { background:rgba(255,255,255,0.1); color:white; }
        .info-text { background:rgba(255,255,255,0.03); padding:14px 18px; border-radius:10px; color:rgba(255,255,255,0.7); font-size:14px; line-height:1.8; border:1px solid rgba(255,255,255,0.04); }
        .info-text strong { color:rgba(255,255,255,0.9); }
        .flex { display:flex; gap:10px; flex-wrap:wrap; }
        .mt-2 { margin-top:10px; }
        .toast { padding:12px 20px; border-radius:10px; margin-bottom:16px; }
        .toast-success { background:rgba(52,211,153,0.1); color:#6ee7b7; border:1px solid rgba(52,211,153,0.06); }
        .toast-error { background:rgba(248,113,113,0.1); color:#fca5a5; border:1px solid rgba(248,113,113,0.06); }
        .warning-box { background:rgba(251,191,36,0.08); border:1px solid rgba(251,191,36,0.12); border-radius:10px; padding:12px 16px; color:rgba(251,191,36,0.8); font-size:13px; margin-bottom:16px; }
        @media (max-width:768px){ .header{flex-direction:column;align-items:stretch;} }
    </style>
</head>
<body>

<nav class="navbar">
    <a class="brand" href="${pageContext.request.contextPath}/admin?action=dashboard">
        <i class="bi bi-wallet2"></i> <span><%= systemName %></span>
    </a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/admin?action=dashboard">📊 仪表盘</a>
        <a href="${pageContext.request.contextPath}/admin?action=users" class="active">👑 用户管理</a>
        <a href="${pageContext.request.contextPath}/admin?action=logs">📋 系统日志</a>
        <a href="${pageContext.request.contextPath}/admin?action=settings">⚙️ 系统设置</a>
        <span class="divider">|</span>
        <span class="username">👤 <%= currentUser.getUsername() %> (管理员)</span>
        <a href="${pageContext.request.contextPath}/user?action=logout" class="logout-btn">退出</a>
    </div>
</nav>

<div class="container">
    <div class="header">
        <h2><i class="bi bi-pencil-square"></i> 编辑用户</h2>
        <a href="${pageContext.request.contextPath}/admin?action=users" class="btn-back">← 返回用户列表</a>
    </div>

    <% if (success != null && !success.isEmpty()) { %>
    <div class="toast toast-success"><i class="bi bi-check-circle"></i> <%= success %></div>
    <% } %>
    <% if (error != null && !error.isEmpty()) { %>
    <div class="toast toast-error"><i class="bi bi-exclamation-circle"></i> <%= error %></div>
    <% } %>

    <!-- 警告：编辑管理员账号 -->
    <% if ("admin".equals(editUser.getRole()) && editUser.getId() == 1) { %>
    <div class="warning-box">
        <i class="bi bi-exclamation-triangle"></i> 注意：您正在编辑超级管理员账号，请谨慎操作！
    </div>
    <% } %>

    <!-- 用户信息 -->
    <div class="card">
        <div class="card-title">📋 用户信息</div>
        <div class="info-text">
            <p><strong>ID：</strong><%= editUser.getId() %></p>
            <p><strong>当前用户名：</strong><%= editUser.getUsername() %></p>
            <p><strong>邮箱：</strong><%= editUser.getEmail() != null ? editUser.getEmail() : "未设置" %></p>
            <p><strong>角色：</strong><%= "admin".equals(editUser.getRole()) ? "管理员" : "普通用户" %></p>
            <p><strong>注册时间：</strong><%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(editUser.getRegTime()) %></p>
        </div>
    </div>

    <!-- 修改用户名 -->
    <div class="card">
        <div class="card-title">🔤 修改用户名</div>
        <form action="${pageContext.request.contextPath}/admin?action=updateUsername" method="post" onsubmit="return validateUsername()">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="id" value="<%= editUser.getId() %>">
            <div class="form-group">
                <label>新用户名 <span style="color:#f87171;">*</span></label>
                <input type="text" id="newUsername" name="newUsername" placeholder="请输入新用户名（至少3个字符，支持中文、字母、数字、下划线）" required minlength="3" pattern="[a-zA-Z0-9_\u4e00-\u9fa5]{3,20}">
                <div class="hint">用户名不可与其他用户重复，3-20个字符</div>
            </div>
            <button type="submit" class="btn-primary"><i class="bi bi-check-lg"></i> 确认修改用户名</button>
        </form>
    </div>

    <!-- 修改密码 -->
    <div class="card">
        <div class="card-title">🔒 修改密码</div>
        <form action="${pageContext.request.contextPath}/admin?action=updatePassword" method="post" onsubmit="return validatePassword()">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <input type="hidden" name="id" value="<%= editUser.getId() %>">
            <div class="form-group">
                <label>新密码 <span style="color:#f87171;">*</span></label>
                <input type="password" id="newPassword" name="newPassword" placeholder="请设置新密码（至少6个字符）" required minlength="6">
                <div class="hint">密码至少6个字符，建议包含字母和数字</div>
            </div>
            <div class="form-group">
                <label>确认密码 <span style="color:#f87171;">*</span></label>
                <input type="password" id="confirmPassword" placeholder="请再次输入新密码" required>
                <div class="hint" id="passwordHint" style="color:#f87171;display:none;">两次输入的密码不一致</div>
            </div>
            <button type="submit" class="btn-primary"><i class="bi bi-check-lg"></i> 确认修改密码</button>
        </form>
    </div>

    <div class="flex mt-2">
        <a href="${pageContext.request.contextPath}/admin?action=users" class="btn-back">← 返回用户列表</a>
    </div>
</div>

<script>
    function validateUsername() {
        var username = document.getElementById('newUsername').value;
        if (username.length < 3) {
            alert('用户名至少需要3个字符');
            return false;
        }
        if (!/^[a-zA-Z0-9_\u4e00-\u9fa5]{3,20}$/.test(username)) {
            alert('用户名只能包含中文、字母、数字和下划线，长度3-20个字符');
            return false;
        }
        return true;
    }

    function validatePassword() {
        var password = document.getElementById('newPassword').value;
        var confirm = document.getElementById('confirmPassword').value;
        if (password.length < 6) {
            alert('密码至少需要6个字符');
            return false;
        }
        if (password !== confirm) {
            document.getElementById('passwordHint').style.display = 'block';
            return false;
        }
        document.getElementById('passwordHint').style.display = 'none';
        return true;
    }

    // 实时检查密码确认
    document.getElementById('confirmPassword').addEventListener('input', function() {
        var password = document.getElementById('newPassword').value;
        var confirm = this.value;
        var hint = document.getElementById('passwordHint');
        if (password !== confirm && confirm.length > 0) {
            hint.style.display = 'block';
        } else {
            hint.style.display = 'none';
        }
    });
</script>

</body>
</html>
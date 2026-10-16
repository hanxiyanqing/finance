<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2026/6/22
  Time: 9:22
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>简易财富记账系统 - 注册</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body {
            font-family:'Microsoft YaHei','PingFang SC',sans-serif;
            min-height:100vh;
            display:flex;
            justify-content:center;
            align-items:center;
            background:linear-gradient(135deg,#0f172a 0%,#1a3a5f 40%,#1a2a4a 100%);
            padding:20px;
        }
        .register-container {
            background:rgba(255,255,255,0.05);
            backdrop-filter:blur(24px);
            -webkit-backdrop-filter:blur(24px);
            border:1px solid rgba(255,255,255,0.08);
            border-radius:20px;
            padding:40px 45px;
            width:440px;
            box-shadow:0 20px 60px rgba(0,0,0,0.4);
            animation:slideUp 0.6s ease;
        }
        .register-container h1 { text-align:center; font-size:24px; color:rgba(255,255,255,0.9); margin-bottom:4px; }
        .register-container h1 i { color:#7dd3fc; margin-right:8px; }
        .register-container .subtitle { text-align:center; color:rgba(255,255,255,0.3); font-size:14px; margin-bottom:20px; }
        .register-container .role-hint { text-align:center; background:rgba(56,189,248,0.06); color:#7dd3fc; padding:10px 14px; border-radius:10px; font-size:13px; margin-bottom:18px; border:1px solid rgba(56,189,248,0.06); }
        .form-group { margin-bottom:16px; }
        .form-group label { display:block; font-size:13px; color:rgba(255,255,255,0.4); margin-bottom:4px; font-weight:500; }
        .form-group input { width:100%; padding:11px 16px; background:rgba(255,255,255,0.05); border:1px solid rgba(255,255,255,0.08); border-radius:12px; font-size:14px; color:rgba(255,255,255,0.85); transition:all 0.3s; outline:none; }
        .form-group input:focus { border-color:rgba(56,189,248,0.3); box-shadow:0 0 0 3px rgba(56,189,248,0.06); }
        .form-group input::placeholder { color:rgba(255,255,255,0.2); }
        .form-group .hint { font-size:12px; color:rgba(255,255,255,0.2); margin-top:4px; }
        .form-group .hint .required { color:#f87171; }
        .btn-register { width:100%; padding:14px; background:rgba(56,189,248,0.2); color:#7dd3fc; border:1px solid rgba(56,189,248,0.15); border-radius:12px; font-size:17px; font-weight:600; cursor:pointer; transition:all 0.3s; margin-top:4px; }
        .btn-register:hover { background:rgba(56,189,248,0.3); border-color:rgba(56,189,248,0.25); transform:translateY(-1px); }
        .login-link { text-align:center; margin-top:16px; font-size:14px; color:rgba(255,255,255,0.3); }
        .login-link a { color:#7dd3fc; text-decoration:none; font-weight:500; transition:color 0.3s; }
        .login-link a:hover { color:#bae6fd; }
        .error-msg { background:rgba(248,113,113,0.1); color:#fca5a5; padding:10px 16px; border-radius:10px; font-size:14px; margin-bottom:14px; border:1px solid rgba(248,113,113,0.06); }
        .success-msg { background:rgba(52,211,153,0.1); color:#6ee7b7; padding:10px 16px; border-radius:10px; font-size:14px; margin-bottom:14px; border:1px solid rgba(52,211,153,0.06); }
        @keyframes slideUp { from { opacity:0; transform:translateY(30px); } to { opacity:1; transform:translateY(0); } }
        @media (max-width:480px){ .register-container{ padding:30px 24px; width:100%; } }
    </style>
</head>
<body>
<div class="register-container">
    <h1><i class="bi bi-person-plus"></i> 注册账号</h1>
    <p class="subtitle">加入简易财富记账系统</p>

    <div class="role-hint"><i class="bi bi-info-circle"></i> 注册即成为普通用户，管理员账号由系统管理员创建</div>

    <%
        String error = (String) request.getAttribute("error");
        String message = (String) request.getAttribute("message");
        if (error != null && !error.isEmpty()) {
    %>
    <div class="error-msg"><i class="bi bi-exclamation-circle"></i> <%= error %></div>
    <%
        }
        if (message != null && !message.isEmpty()) {
    %>
    <div class="success-msg"><i class="bi bi-check-circle"></i> <%= message %></div>
    <%
        }
    %>

    <form action="${pageContext.request.contextPath}/user" method="post">
        <input type="hidden" name="action" value="register">
        <div class="form-group">
            <label>👤 用户名 <span class="required">*</span></label>
            <input type="text" name="username" placeholder="请设置用户名（至少3位）" required minlength="3" autofocus>
            <div class="hint">用户名不可与其他用户重复</div>
        </div>
        <div class="form-group">
            <label>📧 邮箱</label>
            <input type="email" name="email" placeholder="请输入邮箱（可选）">
        </div>
        <div class="form-group">
            <label>🔒 密码 <span class="required">*</span></label>
            <input type="password" name="password" placeholder="请设置密码（至少6位）" required minlength="6">
            <div class="hint">密码至少6个字符</div>
        </div>
        <div class="form-group">
            <label>✔️ 确认密码 <span class="required">*</span></label>
            <input type="password" name="confirmPassword" placeholder="请再次输入密码" required>
        </div>
        <button type="submit" class="btn-register">注 册</button>
    </form>
    <div class="login-link">已有账号？<a href="${pageContext.request.contextPath}/login.jsp">返回登录</a></div>
</div>
</body>
</html>
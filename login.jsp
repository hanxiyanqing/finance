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
    <title>简易财富记账系统 - 登录</title>
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
        .login-container {
            background:rgba(255,255,255,0.05);
            backdrop-filter:blur(24px);
            -webkit-backdrop-filter:blur(24px);
            border:1px solid rgba(255,255,255,0.08);
            border-radius:20px;
            padding:50px 45px;
            width:420px;
            box-shadow:0 20px 60px rgba(0,0,0,0.4);
            animation:slideUp 0.6s ease;
        }
        .login-container .logo { text-align:center; font-size:48px; margin-bottom:10px; }
        .login-container h1 { text-align:center; font-size:24px; color:rgba(255,255,255,0.9); margin-bottom:4px; }
        .login-container h1 i { color:#7dd3fc; margin-right:8px; }
        .login-container .subtitle { text-align:center; color:rgba(255,255,255,0.3); font-size:14px; margin-bottom:28px; }
        .form-group { margin-bottom:18px; }
        .form-group label { display:block; font-size:13px; color:rgba(255,255,255,0.4); margin-bottom:4px; font-weight:500; }
        .form-group input, .form-group select { width:100%; padding:12px 16px; background:rgba(255,255,255,0.05); border:1px solid rgba(255,255,255,0.08); border-radius:12px; font-size:15px; color:rgba(255,255,255,0.85); transition:all 0.3s; outline:none; }
        .form-group input:focus, .form-group select:focus { border-color:rgba(56,189,248,0.3); box-shadow:0 0 0 3px rgba(56,189,248,0.06); }
        .form-group input::placeholder { color:rgba(255,255,255,0.2); }
        .form-group select option { background:#0f172a; color:#e8edf5; }
        .role-hint { font-size:12px; color:rgba(255,255,255,0.2); margin-top:4px; }
        .btn-login { width:100%; padding:14px; background:rgba(56,189,248,0.2); color:#7dd3fc; border:1px solid rgba(56,189,248,0.15); border-radius:12px; font-size:17px; font-weight:600; cursor:pointer; transition:all 0.3s; margin-top:4px; }
        .btn-login:hover { background:rgba(56,189,248,0.3); border-color:rgba(56,189,248,0.25); transform:translateY(-1px); }
        .register-link { text-align:center; margin-top:18px; font-size:14px; color:rgba(255,255,255,0.3); }
        .register-link a { color:#7dd3fc; text-decoration:none; font-weight:500; transition:color 0.3s; }
        .register-link a:hover { color:#bae6fd; }
        .error-msg { background:rgba(248,113,113,0.1); color:#fca5a5; padding:10px 16px; border-radius:10px; font-size:14px; margin-bottom:16px; border:1px solid rgba(248,113,113,0.06); }
        .success-msg { background:rgba(52,211,153,0.1); color:#6ee7b7; padding:10px 16px; border-radius:10px; font-size:14px; margin-bottom:16px; border:1px solid rgba(52,211,153,0.06); }
        .maintenance-msg {
            background:rgba(251,191,36,0.1);
            color:#fcd34d;
            padding:10px 16px;
            border-radius:10px;
            font-size:14px;
            margin-bottom:16px;
            border:1px solid rgba(251,191,36,0.08);
            text-align:center;
        }
        @keyframes slideUp { from { opacity:0; transform:translateY(30px); } to { opacity:1; transform:translateY(0); } }
        @media (max-width:480px){ .login-container{ padding:30px 24px; width:100%; } }
    </style>
</head>
<body>
<div class="login-container">
    <div class="logo">💰</div>
    <h1><i class="bi bi-wallet2"></i> 简易财富记账系统</h1>
    <p class="subtitle">记录每一笔收支，掌控财务自由</p>

    <%
        String error = (String) request.getAttribute("error");
        String message = (String) request.getAttribute("message");
        String maintenance = request.getParameter("maintenance");

        if ("true".equals(maintenance)) {
    %>
    <div class="maintenance-msg"><i class="bi bi-tools"></i> 系统正在维护中，普通用户暂无法登录，请稍后再试</div>
    <%
        }
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
        <input type="hidden" name="action" value="login">
        <div class="form-group">
            <label>👤 用户名</label>
            <input type="text" name="username" placeholder="请输入用户名" required autofocus>
        </div>
        <div class="form-group">
            <label>🔒 密码</label>
            <input type="password" name="password" placeholder="请输入密码" required>
        </div>
        <div class="form-group">
            <label>🎯 登录身份</label>
            <select name="role" required>
                <option value="user">👤 普通用户</option>
                <option value="admin">👑 管理员</option>
            </select>
            <div class="role-hint">💡 请选择与账号角色匹配的身份</div>
        </div>
        <button type="submit" class="btn-login">登 录</button>
    </form>
    <div class="register-link">还没有账号？<a href="${pageContext.request.contextPath}/register.jsp">立即注册</a></div>
</div>
</body>
</html>
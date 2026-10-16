<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2026/6/25
  Time: 8:27
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.User, java.util.List, java.text.SimpleDateFormat" %>
<%
  User currentUser = (User) session.getAttribute("user");
  if (currentUser == null || !"admin".equals(currentUser.getRole())) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  Integer totalUsers = (Integer) request.getAttribute("totalUsers");
  Integer adminCount = (Integer) request.getAttribute("adminCount");
  Integer userCount = (Integer) request.getAttribute("userCount");
  List<User> users = (List<User>) request.getAttribute("users");

  // 统一从session获取系统名称
  String systemName = (String) session.getAttribute("systemName");
  if (systemName == null) {
    systemName = (String) request.getAttribute("systemName");
  }
  if (systemName == null) systemName = "简易财富记账系统";

  if (totalUsers == null) totalUsers = 0;
  if (adminCount == null) adminCount = 0;
  if (userCount == null) userCount = 0;
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>管理员仪表盘</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    .stats-row { display:grid; grid-template-columns:repeat(3,1fr); gap:16px; margin-bottom:24px; }
    .quick-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:12px; margin-bottom:20px; }
    .quick-btn { background:rgba(255,255,255,0.05); border-radius:12px; padding:16px; text-align:center; text-decoration:none; color:rgba(255,255,255,0.7); border:1px solid rgba(255,255,255,0.06); transition:all 0.3s ease; }
    .quick-btn:hover { background:rgba(255,255,255,0.1); border-color:rgba(56,189,248,0.3); color:white; transform:translateY(-2px); }
    .quick-btn i { font-size:24px; display:block; margin-bottom:6px; opacity:0.8; }
    @media (max-width:768px){ .stats-row{grid-template-columns:1fr;} .quick-grid{grid-template-columns:1fr;} }
  </style>
</head>
<body>

<nav class="navbar">
  <a class="brand" href="${pageContext.request.contextPath}/admin?action=dashboard">
    <i class="bi bi-wallet2"></i> <span><%= systemName %></span>
  </a>
  <div class="nav-links">
    <a href="${pageContext.request.contextPath}/admin?action=dashboard" class="active">📊 仪表盘</a>
    <a href="${pageContext.request.contextPath}/admin?action=users">👑 用户管理</a>
    <a href="${pageContext.request.contextPath}/admin?action=logs">📋 系统日志</a>
    <a href="${pageContext.request.contextPath}/admin?action=settings">⚙️ 系统设置</a>
    <span class="divider">|</span>
    <span class="username">👤 <%= currentUser.getUsername() %> (管理员)</span>
    <a href="${pageContext.request.contextPath}/user?action=logout" class="logout-btn">退出</a>
  </div>
</nav>

<div class="container">
  <h4 style="margin-bottom:20px;color:rgba(255,255,255,0.9);">👋 欢迎回来，管理员 <%= currentUser.getUsername() %>！</h4>

  <div class="stats-row">
    <div class="stat-card blue"><div class="stat-icon">👥</div><div class="stat-value"><%= totalUsers %></div><div class="stat-label">总用户数</div></div>
    <div class="stat-card green"><div class="stat-icon">👤</div><div class="stat-value"><%= userCount %></div><div class="stat-label">普通用户</div></div>
    <div class="stat-card purple"><div class="stat-icon">⭐</div><div class="stat-value"><%= adminCount %></div><div class="stat-label">管理员</div></div>
  </div>

  <div class="quick-grid">
    <a href="${pageContext.request.contextPath}/admin?action=users" class="quick-btn"><i class="bi bi-people"></i>用户管理</a>
    <a href="${pageContext.request.contextPath}/admin?action=logs" class="quick-btn"><i class="bi bi-clock-history"></i>系统日志</a>
    <a href="${pageContext.request.contextPath}/admin?action=settings" class="quick-btn"><i class="bi bi-gear"></i>系统设置</a>
  </div>

  <div class="card">
    <div class="card-title"><span>👥 最近用户</span><a href="${pageContext.request.contextPath}/admin?action=users">查看全部 →</a></div>
    <table>
      <thead><tr><th>用户名</th><th>邮箱</th><th>角色</th><th>注册时间</th></tr></thead>
      <tbody>
      <% if (users != null && !users.isEmpty()) {
        int count=0;
        for (User u : users) {
          if (count++ >= 5) break;
      %>
      <tr><td><%= u.getUsername() %></td><td><%= u.getEmail() != null ? u.getEmail() : "-" %></td>
        <td><% if ("admin".equals(u.getRole())) { %><span class="badge-admin">管理员</span><% } else { %><span class="badge-user">普通用户</span><% } %></td>
        <td style="color:rgba(255,255,255,0.4);"><%= u.getRegTime() != null ? sdf.format(u.getRegTime()) : "-" %></td></tr>
      <% } } else { %>
      <tr><td colspan="4" style="text-align:center;color:rgba(255,255,255,0.3);padding:20px;">暂无用户</td></tr>
      <% } %>
      </tbody>
    </table>
    <div style="text-align:center;font-size:13px;color:rgba(255,255,255,0.2);padding-top:10px;">共 <%= totalUsers %> 位用户</div>
  </div>

  <div class="footer">&copy; 2026 <%= systemName %> | 管理员后台</div>
</div>

</body>
</html>
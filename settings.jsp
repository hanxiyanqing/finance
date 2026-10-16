<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2026/6/25
  Time: 8:29
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

  String systemName = (String) session.getAttribute("systemName");
  if (systemName == null) {
    systemName = (String) request.getAttribute("systemName");
  }
  if (systemName == null) systemName = "简易财富记账系统";

  String maintenanceMode = (String) request.getAttribute("maintenanceMode");
  if (maintenanceMode == null) maintenanceMode = "off";

  String success = request.getParameter("success");
  String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>系统设置</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
      flex-wrap: wrap;
      gap: 10px;
    }
    .header h2 {
      font-size: 20px;
      color: rgba(255,255,255,0.9);
    }
    .card {
      background: rgba(255,255,255,0.05);
      backdrop-filter: blur(12px);
      border: 1px solid rgba(255,255,255,0.06);
      border-radius: 14px;
      padding: 20px 24px;
      margin-bottom: 20px;
    }
    .card-title {
      font-size: 16px;
      font-weight: 600;
      color: rgba(255,255,255,0.9);
      padding-bottom: 12px;
      border-bottom: 1px solid rgba(255,255,255,0.06);
      margin-bottom: 14px;
    }
    .form-group {
      margin-bottom: 14px;
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
      transition: all 0.3s;
    }
    .form-group input:focus {
      border-color: rgba(56,189,248,0.4);
      box-shadow: 0 0 0 3px rgba(56,189,248,0.08);
    }
    .badge-on {
      background: rgba(52,211,153,0.12);
      color: #6ee7b7;
      padding: 2px 12px;
      border-radius: 12px;
      font-size: 12px;
      border: 1px solid rgba(52,211,153,0.08);
    }
    .badge-off {
      background: rgba(248,113,113,0.12);
      color: #fca5a5;
      padding: 2px 12px;
      border-radius: 12px;
      font-size: 12px;
      border: 1px solid rgba(248,113,113,0.08);
    }
    .flex {
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
      align-items: center;
    }
    .text-muted {
      color: rgba(255,255,255,0.3);
      font-size: 14px;
    }
    .toast {
      padding: 12px 20px;
      border-radius: 10px;
      margin-bottom: 16px;
    }
    .toast-success {
      background: rgba(52,211,153,0.12);
      color: #6ee7b7;
      border: 1px solid rgba(52,211,153,0.08);
    }
    .toast-error {
      background: rgba(248,113,113,0.12);
      color: #fca5a5;
      border: 1px solid rgba(248,113,113,0.08);
    }
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
    @media (max-width:768px) {
      .header {
        flex-direction: column;
        align-items: stretch;
      }
    }
  </style>
</head>
<body>

<nav class="navbar">
  <a class="brand" href="${pageContext.request.contextPath}/admin?action=dashboard">
    <i class="bi bi-wallet2"></i> <span><%= systemName %></span>
  </a>
  <div class="nav-links">
    <a href="${pageContext.request.contextPath}/admin?action=dashboard">📊 仪表盘</a>
    <a href="${pageContext.request.contextPath}/admin?action=users">👑 用户管理</a>
    <a href="${pageContext.request.contextPath}/admin?action=logs">📋 系统日志</a>
    <a href="${pageContext.request.contextPath}/admin?action=settings" class="active">⚙️ 系统设置</a>
    <span class="divider">|</span>
    <span class="username">👤 <%= currentUser.getUsername() %> (管理员)</span>
    <a href="${pageContext.request.contextPath}/user?action=logout" class="logout-btn">退出</a>
  </div>
</nav>

<div class="container">
  <div class="header">
    <h2>⚙️ 系统设置</h2>
    <a href="${pageContext.request.contextPath}/admin?action=dashboard" class="btn-back">← 返回仪表盘</a>
  </div>

  <% if (success != null && !success.isEmpty()) { %>
  <div class="toast toast-success"><i class="bi bi-check-circle"></i> <%= success %></div>
  <% } %>
  <% if (error != null && !error.isEmpty()) { %>
  <div class="toast toast-error"><i class="bi bi-exclamation-circle"></i> <%= error %></div>
  <% } %>

  <!-- 基本设置 -->
  <div class="card">
    <div class="card-title">🔧 基本设置</div>
    <form action="${pageContext.request.contextPath}/admin?action=updateSystemName" method="post">
      <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
      <div class="form-group">
        <label>系统名称</label>
        <input type="text" name="systemName" value="<%= systemName %>" required maxlength="50">
      </div>
      <button type="submit" class="btn-primary"><i class="bi bi-check-lg"></i> 保存设置</button>
    </form>
  </div>

  <!-- 维护模式 -->
  <div class="card">
    <div class="card-title">🔒 维护模式</div>
    <p class="text-muted" style="margin-bottom:12px;">开启维护模式后，普通用户将无法访问系统，只有管理员可以登录。</p>
    <div class="flex">
      <span style="color:rgba(255,255,255,0.6);font-weight:500;">当前状态：</span>
      <% if ("on".equals(maintenanceMode)) { %>
      <span class="badge-on">已开启</span>
      <form action="${pageContext.request.contextPath}/admin?action=toggleMaintenance" method="post" style="display:inline;">
        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
        <input type="hidden" name="mode" value="off">
        <button type="submit" class="btn-danger">关闭维护模式</button>
      </form>
      <% } else { %>
      <span class="badge-off">已关闭</span>
      <form action="${pageContext.request.contextPath}/admin?action=toggleMaintenance" method="post" style="display:inline;">
        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
        <input type="hidden" name="mode" value="on">
        <button type="submit" class="btn-primary">开启维护模式</button>
      </form>
      <% } %>
    </div>
  </div>

  <!-- 导出数据（已完全去除导入功能） -->
  <div class="card">
    <div class="card-title">💾 导出数据</div>
    <div>
      <a href="${pageContext.request.contextPath}/admin?action=exportData" class="btn-primary"><i class="bi bi-download"></i> 导出用户数据</a>
      <p class="text-muted" style="margin-top:8px;">导出所有用户信息为JSON格式文件，便于备份。</p>
    </div>
  </div>

</div>

</body>
</html>
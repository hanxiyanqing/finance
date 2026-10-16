<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2026/6/25
  Time: 8:29
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.User, entity.SystemLog, java.util.List, java.text.SimpleDateFormat" %>
<%
  User currentUser = (User) session.getAttribute("user");
  if (currentUser == null || !"admin".equals(currentUser.getRole())) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  List<SystemLog> logs = (List<SystemLog>) request.getAttribute("logs");
  Integer currentPage = (Integer) request.getAttribute("currentPage");
  Integer totalPage = (Integer) request.getAttribute("totalPage");
  Integer totalCount = (Integer) request.getAttribute("totalCount");
  if (currentPage == null) currentPage = 1;
  if (totalPage == null) totalPage = 1;
  if (totalCount == null) totalCount = 0;
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

  // 统一从session获取系统名称，如果没有则使用默认值
  String systemName = (String) session.getAttribute("systemName");
  if (systemName == null) {
    systemName = (String) request.getAttribute("systemName");
  }
  if (systemName == null) systemName = "简易财富记账系统";
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>系统日志</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    .header { display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; flex-wrap:wrap; gap:10px; }
    .header h2 { font-size:20px; color:rgba(255,255,255,0.9); }
    .header .sub { color:rgba(255,255,255,0.4); font-size:14px; margin-right:15px; }
    .btn-clear-logs { background:rgba(239,68,68,0.12); color:#f87171; border:1px solid rgba(239,68,68,0.08); padding:6px 14px; border-radius:8px; cursor:pointer; font-size:13px; transition:all 0.2s; }
    .btn-clear-logs:hover { background:rgba(239,68,68,0.2); }
    .btn-outline-light { background:rgba(255,255,255,0.06); color:rgba(255,255,255,0.6); border:1px solid rgba(255,255,255,0.08); padding:6px 14px; border-radius:8px; cursor:pointer; font-size:13px; text-decoration:none; display:inline-block; transition:all 0.2s; }
    .btn-outline-light:hover { background:rgba(255,255,255,0.1); color:white; }
    .badge-action { background:rgba(56,189,248,0.12); color:#7dd3fc; padding:2px 10px; border-radius:12px; font-size:12px; border:1px solid rgba(56,189,248,0.06); }
    .empty { text-align:center; padding:40px; color:rgba(255,255,255,0.3); }
    .toast { padding:12px 20px; border-radius:10px; margin-bottom:16px; }
    .toast-success { background:rgba(52,211,153,0.12); color:#6ee7b7; border:1px solid rgba(52,211,153,0.08); }
    .toast-error { background:rgba(248,113,113,0.12); color:#fca5a5; border:1px solid rgba(248,113,113,0.08); }
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
    <a href="${pageContext.request.contextPath}/admin?action=users">👑 用户管理</a>
    <a href="${pageContext.request.contextPath}/admin?action=logs" class="active">📋 系统日志</a>
    <a href="${pageContext.request.contextPath}/admin?action=settings">⚙️ 系统设置</a>
    <span class="divider">|</span>
    <span class="username">👤 <%= currentUser.getUsername() %> (管理员)</span>
    <a href="${pageContext.request.contextPath}/user?action=logout" class="logout-btn">退出</a>
  </div>
</nav>

<div class="container">
  <%
    String success = request.getParameter("success");
    String error = request.getParameter("error");
    if (success != null && !success.isEmpty()) {
  %>
  <div class="toast toast-success"><i class="bi bi-check-circle"></i> <%= success %></div>
  <%
    }
    if (error != null && !error.isEmpty()) {
  %>
  <div class="toast toast-error"><i class="bi bi-exclamation-circle"></i> <%= error %></div>
  <%
    }
  %>

  <div class="header">
    <h2>📋 系统日志 <span class="sub">共 <%= totalCount %> 条记录</span></h2>
    <div>
      <button class="btn-clear-logs" onclick="clearLogs()"><i class="bi bi-trash"></i> 清空日志</button>
      <a href="${pageContext.request.contextPath}/admin?action=dashboard" class="btn-outline-light">← 返回仪表盘</a>
    </div>
  </div>

  <div class="table-wrap">
    <table>
      <thead><tr><th>ID</th><th>用户</th><th>操作</th><th>描述</th><th>IP</th><th>时间</th></tr></thead>
      <tbody>
      <% if (logs == null || logs.isEmpty()) { %>
      <tr><td colspan="6" class="empty">暂无日志记录</td></tr>
      <% } else { for (SystemLog log : logs) { %>
      <tr>
        <td><%= log.getId() %></td>
        <td><%= log.getUsername() != null ? log.getUsername() : "系统" %></td>
        <td><span class="badge-action"><%= log.getAction() %></span></td>
        <td><%= log.getDescription() != null ? log.getDescription() : "" %></td>
        <td style="color:rgba(255,255,255,0.4);"><%= log.getIp() != null ? log.getIp() : "" %></td>
        <td style="color:rgba(255,255,255,0.4);font-size:13px;"><%= log.getCreatedAt() != null ? sdf.format(log.getCreatedAt()) : "" %></td>
      </tr>
      <% } } %>
      </tbody>
    </table>

    <% if (totalPage > 1) { %>
    <div class="pagination">
      <a href="${pageContext.request.contextPath}/admin?action=logs&page=1" class="<%= currentPage <= 1 ? "disabled" : "" %>">首页</a>
      <a href="${pageContext.request.contextPath}/admin?action=logs&page=<%= currentPage - 1 %>" class="<%= currentPage <= 1 ? "disabled" : "" %>">上一页</a>
      <% for (int i = Math.max(1, currentPage - 2); i <= Math.min(totalPage, currentPage + 2); i++) { %>
      <a href="${pageContext.request.contextPath}/admin?action=logs&page=<%= i %>" class="<%= i == currentPage ? "active" : "" %>"><%= i %></a>
      <% } %>
      <a href="${pageContext.request.contextPath}/admin?action=logs&page=<%= currentPage + 1 %>" class="<%= currentPage >= totalPage ? "disabled" : "" %>">下一页</a>
      <a href="${pageContext.request.contextPath}/admin?action=logs&page=<%= totalPage %>" class="<%= currentPage >= totalPage ? "disabled" : "" %>">末页</a>
    </div>
    <% } %>
  </div>
</div>

<script>
  function clearLogs() {
    if (!confirm('确定要清空所有系统日志吗？此操作不可恢复！')) return;
    // 使用POST请求防止CSRF和URL长度限制
    var form = document.createElement('form');
    form.method = 'POST';
    form.action = '${pageContext.request.contextPath}/admin?action=clearLogs';
    // 添加CSRF token（如果后端支持）
    var tokenInput = document.createElement('input');
    tokenInput.type = 'hidden';
    tokenInput.name = 'csrfToken';
    tokenInput.value = '${sessionScope.csrfToken}';
    form.appendChild(tokenInput);
    document.body.appendChild(form);
    form.submit();
  }
</script>

</body>
</html>
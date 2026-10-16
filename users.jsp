<%--
  Created by IntelliJ IDEA.
  User: Administrator
  Date: 2026/6/22
  Time: 17:09
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
    List<User> users = (List<User>) request.getAttribute("users");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    if (success == null) success = request.getParameter("success");
    if (error == null) error = request.getParameter("error");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

    // 统一从session获取系统名称
    String systemName = (String) session.getAttribute("systemName");
    if (systemName == null) {
        systemName = (String) request.getAttribute("systemName");
    }
    if (systemName == null) systemName = "简易财富记账系统";

    // 分页参数
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPage = (Integer) request.getAttribute("totalPage");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    if (currentPage == null) currentPage = 1;
    if (totalPage == null) totalPage = 1;
    if (totalCount == null) totalCount = users != null ? users.size() : 0;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>用户管理</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .header { display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; flex-wrap:wrap; gap:10px; }
        .header h2 { font-size:20px; color:rgba(255,255,255,0.9); }
        .header .sub { color:rgba(255,255,255,0.4); font-size:14px; font-weight:400; margin-left:8px; }
        .actions { display:flex; gap:4px; flex-wrap:wrap; }
        .empty { text-align:center; padding:40px; color:rgba(255,255,255,0.3); }
        .toast { padding:12px 20px; border-radius:10px; margin-bottom:16px; }
        .toast-success { background:rgba(52,211,153,0.12); color:#6ee7b7; border:1px solid rgba(52,211,153,0.08); }
        .toast-error { background:rgba(248,113,113,0.12); color:#fca5a5; border:1px solid rgba(248,113,113,0.08); }
        .search-bar { display:flex; gap:10px; margin-bottom:16px; flex-wrap:wrap; }
        .search-bar input { padding:8px 14px; background:rgba(255,255,255,0.05); border:1px solid rgba(255,255,255,0.08); border-radius:8px; color:rgba(255,255,255,0.85); outline:none; flex:1; min-width:200px; }
        .search-bar input:focus { border-color:rgba(56,189,248,0.3); }
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
        <h2>👑 用户管理 <span class="sub">共 <%= totalCount %> 位用户</span></h2>
        <button class="btn-primary" onclick="openAddModal()"><i class="bi bi-plus-circle"></i> 新增用户</button>
    </div>

    <% if (success != null && !success.isEmpty()) { %>
    <div class="toast toast-success"><i class="bi bi-check-circle"></i> <%= success %></div>
    <% } %>
    <% if (error != null && !error.isEmpty()) { %>
    <div class="toast toast-error"><i class="bi bi-exclamation-circle"></i> <%= error %></div>
    <% } %>

    <!-- 搜索栏 -->
    <div class="search-bar">
        <input type="text" id="searchInput" placeholder="🔍 搜索用户名或邮箱..." onkeyup="searchUsers()">
        <button class="btn-outline" onclick="resetSearch()">重置</button>
    </div>

    <div class="table-wrap">
        <table id="userTable">
            <thead>
            <tr>
                <th>ID</th>
                <th>用户名</th>
                <th>邮箱</th>
                <th>角色</th>
                <th>状态</th>    <!-- ★★★ 新增这一列 ★★★ -->
                <th>注册时间</th>
                <th>操作</th>
            </tr>
            </thead>
            <tbody>
            <% if (users == null || users.isEmpty()) { %>
            <tr><td colspan="6" class="empty">暂无用户</td></tr>
            <% } else { for (User u : users) { %>
            <tr data-username="<%= u.getUsername().toLowerCase() %>"
                data-email="<%= u.getEmail() != null ? u.getEmail().toLowerCase() : "" %>">
                <td><%= u.getId() %></td>
                <td><%= u.getUsername() %></td>
                <td><%= u.getEmail() != null ? u.getEmail() : "" %></td>
                <td>
                    <% if ("admin".equals(u.getRole())) { %>
                    <span class="badge-admin">管理员</span>
                    <% } else { %>
                    <span class="badge-user">普通用户</span>
                    <% } %>
                </td>
                <!-- ★★★ 新增状态单元格 ★★★ -->
                <td>
                    <% if ("locked".equals(u.getStatus())) { %>
                    <span class="badge-unpaid">已锁定</span>
                    <% } else { %>
                    <span class="badge-paid">正常</span>
                    <% } %>
                </td>
                <td style="color:rgba(255,255,255,0.4);">
                    <%= u.getRegTime() != null ? sdf.format(u.getRegTime()) : "" %>
                </td>
                <td class="actions">
                    <a href="${pageContext.request.contextPath}/admin?action=editUser&id=<%= u.getId() %>" class="btn-edit">
                        <i class="bi bi-pencil"></i> 编辑
                    </a>
                    <% if (!"admin".equals(u.getRole())) { %>
                    <button class="btn-admin" onclick="setAdmin(<%= u.getId() %>)">设为管理员</button>
                    <% } else if (u.getId() != 1) { %>
                    <button class="btn-remove" onclick="removeAdmin(<%= u.getId() %>)">取消管理员</button>
                    <% } %>

                    <%-- 锁定/解锁按钮 --%>
                    <% if (u.getId() != 1) { %>
                    <% if ("locked".equals(u.getStatus())) { %>
                    <button class="btn-sm-success" onclick="unlockUser(<%= u.getId() %>)">🔓 解锁</button>
                    <% } else { %>
                    <button class="btn-delete" onclick="lockUser(<%= u.getId() %>)">🔒 锁定</button>
                    <% } %>
                    <% } %>

                    <% if (u.getId() != 1) { %>
                    <button class="btn-delete" onclick="deleteUser(<%= u.getId() %>)">删除</button>
                    <% } %>
                </td>
            </tr>
            <% } } %>
            </tbody>
        </table>

        <% if (totalPage > 1) { %>
        <div class="pagination">
            <a href="${pageContext.request.contextPath}/admin?action=users&page=1" class="<%= currentPage <= 1 ? "disabled" : "" %>">首页</a>
            <a href="${pageContext.request.contextPath}/admin?action=users&page=<%= currentPage - 1 %>" class="<%= currentPage <= 1 ? "disabled" : "" %>">上一页</a>
            <% for (int i = Math.max(1, currentPage - 2); i <= Math.min(totalPage, currentPage + 2); i++) { %>
            <a href="${pageContext.request.contextPath}/admin?action=users&page=<%= i %>" class="<%= i == currentPage ? "active" : "" %>"><%= i %></a>
            <% } %>
            <a href="${pageContext.request.contextPath}/admin?action=users&page=<%= currentPage + 1 %>" class="<%= currentPage >= totalPage ? "disabled" : "" %>">下一页</a>
            <a href="${pageContext.request.contextPath}/admin?action=users&page=<%= totalPage %>" class="<%= currentPage >= totalPage ? "disabled" : "" %>">末页</a>
        </div>
        <% } %>
    </div>
</div>

<!-- 新增模态框 -->
<div class="modal" id="addModal">
    <div class="modal-content">
        <h3><i class="bi bi-plus-circle"></i> 新增用户</h3>
        <form id="addForm" action="${pageContext.request.contextPath}/admin?action=addUser" method="post">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <label>用户名 <span style="color:#f87171;">*</span></label>
            <input type="text" name="username" placeholder="至少3个字符" required minlength="3" pattern="[a-zA-Z0-9_\u4e00-\u9fa5]{3,20}" title="3-20个字符，支持中文、字母、数字和下划线">
            <label>密码 <span style="color:#f87171;">*</span></label>
            <input type="password" name="password" placeholder="至少6个字符" required minlength="6">
            <label>邮箱</label>
            <input type="email" name="email" placeholder="请输入邮箱（可选）">
            <label>角色</label>
            <select name="role">
                <option value="user">普通用户</option>
                <option value="admin">管理员</option>
            </select>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('addModal')">取消</button>
                <button type="submit" class="btn-save"><i class="bi bi-check-lg"></i> 保存</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openModal(id) { document.getElementById(id).classList.add('show'); }
    function closeModal(id) { document.getElementById(id).classList.remove('show'); }
    document.querySelectorAll('.modal').forEach(function(m) {
        m.addEventListener('click', function(e) { if (e.target === this) this.classList.remove('show'); });
    });
    function openAddModal() {
        document.getElementById('addForm').reset();
        // 重置角色为默认值
        document.getElementById('addForm').querySelector('select[name="role"]').value = 'user';
        openModal('addModal');
    }

    function setAdmin(id) {
        if (!confirm('确定要将该用户设为管理员吗？')) return;
        window.location.href = '${pageContext.request.contextPath}/admin?action=setAdmin&id=' + id;
    }
    function removeAdmin(id) {
        if (!confirm('确定要取消该用户的管理员权限吗？')) return;
        window.location.href = '${pageContext.request.contextPath}/admin?action=removeAdmin&id=' + id;
    }
    function deleteUser(id) {
        if (!confirm('确定要删除该用户吗？此操作不可恢复！')) return;
        window.location.href = '${pageContext.request.contextPath}/admin?action=deleteUser&id=' + id;
    }
    function lockUser(id) {
        if (!confirm('确定要锁定该用户吗？锁定后该用户将无法登录。')) return;
        window.location.href = '${pageContext.request.contextPath}/admin?action=lockUser&id=' + id;
    }

    function unlockUser(id) {
        if (!confirm('确定要解锁该用户吗？')) return;
        window.location.href = '${pageContext.request.contextPath}/admin?action=unlockUser&id=' + id;
    }
    // 搜索功能
    function searchUsers() {
        var input = document.getElementById('searchInput');
        var filter = input.value.toLowerCase();
        var table = document.getElementById('userTable');
        var rows = table.getElementsByTagName('tr');

        for (var i = 1; i < rows.length; i++) {
            var row = rows[i];
            var username = row.getAttribute('data-username') || '';
            var email = row.getAttribute('data-email') || '';
            if (username.indexOf(filter) > -1 || email.indexOf(filter) > -1) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        }
    }

    function resetSearch() {
        document.getElementById('searchInput').value = '';
        searchUsers();
    }
</script>

</body>
</html>
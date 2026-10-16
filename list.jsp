<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.User, entity.PageBean, entity.Transaction, entity.Category, entity.Account" %>
<%@ page import="service.CategoryService, service.AccountService, java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%
  User user = (User) session.getAttribute("user");
  if (user == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  boolean isAdmin = "admin".equals(user.getRole());

  PageBean<Transaction> pageBean = (PageBean<Transaction>) request.getAttribute("pageBean");
  if (pageBean == null) {
    response.sendRedirect(request.getContextPath() + "/transaction?action=list");
    return;
  }
  CategoryService categoryService = new CategoryService();
  AccountService accountService = new AccountService();
  List<Category> categories = categoryService.getCategories(user.getId());
  List<Account> accounts = accountService.getAccounts(user.getId());
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
  String success = request.getParameter("success");
  String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>收支管理</title>
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
    .filter-bar {
      background: rgba(255,255,255,0.04);
      backdrop-filter: blur(12px);
      border: 1px solid rgba(255,255,255,0.06);
      border-radius: 14px;
      padding: 16px 22px;
      margin-bottom: 20px;
    }
    .filter-bar .group label {
      font-size: 12px;
      color: rgba(255,255,255,0.4);
      margin-bottom: 4px;
      font-weight: 500;
    }
    .filter-bar .group select,
    .filter-bar .group input {
      background: rgba(255,255,255,0.06);
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 10px;
      padding: 8px 14px;
      font-size: 13px;
      color: rgba(255,255,255,0.85);
      outline: none;
      height: 40px;
      transition: all 0.3s ease;
      width: 100%;
    }
    .filter-bar .group select option {
      background: #0f172a;
      color: #e8edf5;
    }
    .filter-bar .group select:focus,
    .filter-bar .group input:focus {
      border-color: rgba(56,189,248,0.3);
      box-shadow: 0 0 0 3px rgba(56,189,248,0.06);
    }
    .filter-bar .group input[type="date"] {
      color-scheme: dark;
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
    .text-income { color: #34d399; font-weight: 600; }
    .text-expense { color: #f87171; font-weight: 600; }
    .empty { text-align: center; padding: 40px 20px; color: rgba(255,255,255,0.3); }
    td .actions { display: flex; gap: 4px; flex-wrap: wrap; }
    .pagination {
      display: flex;
      justify-content: center;
      gap: 6px;
      margin-top: 14px;
      flex-wrap: wrap;
    }
    .pagination a {
      padding: 6px 14px;
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 8px;
      text-decoration: none;
      color: rgba(255,255,255,0.6);
      font-size: 13px;
      transition: all 0.3s ease;
    }
    .pagination a:hover {
      background: rgba(255,255,255,0.06);
      color: white;
    }
    .pagination a.active {
      background: rgba(56,189,248,0.2);
      color: #7dd3fc;
      border-color: rgba(56,189,248,0.15);
    }
    .pagination .disabled {
      color: rgba(255,255,255,0.2);
      cursor: not-allowed;
      pointer-events: none;
    }
    .page-info {
      text-align: center;
      font-size: 13px;
      color: rgba(255,255,255,0.2);
      margin-top: 8px;
    }
    .modal .form-group {
      margin-bottom: 14px;
    }
    .modal .form-group label {
      display: block;
      font-size: 13px;
      color: rgba(255,255,255,0.5);
      margin-bottom: 4px;
      font-weight: 500;
    }
    .modal .form-group input,
    .modal .form-group select {
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
    .modal .form-group input:focus,
    .modal .form-group select:focus {
      border-color: rgba(56,189,248,0.3);
      box-shadow: 0 0 0 3px rgba(56,189,248,0.06);
    }
    .modal .form-group select option {
      background: #0f172a;
      color: #e8edf5;
    }
    .loading-mask {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0,0,0,0.6);
      backdrop-filter: blur(4px);
      z-index: 1000;
      display: none;
      align-items: center;
      justify-content: center;
    }
    .loading-mask.show {
      display: flex;
    }
    .loading-spinner {
      background: rgba(15,23,42,0.95);
      padding: 30px 40px;
      border-radius: 16px;
      border: 1px solid rgba(255,255,255,0.08);
      text-align: center;
    }
    .loading-spinner i {
      font-size: 36px;
      color: #7dd3fc;
      animation: spin 1s linear infinite;
    }
    .loading-spinner p {
      margin-top: 12px;
      color: rgba(255,255,255,0.5);
    }
    @keyframes spin {
      from { transform: rotate(0deg); }
      to { transform: rotate(360deg); }
    }
    @media (max-width:768px) {
      .filter-bar .group { min-width: 100%; }
    }
  </style>
</head>
<body>

<nav class="navbar">
  <a class="brand" href="${pageContext.request.contextPath}/index.jsp"><i class="bi bi-wallet2"></i>简易财富记账系统</a>
  <div class="nav-links">
    <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
    <a href="${pageContext.request.contextPath}/transaction?action=list" class="active">收支管理</a>
    <a href="${pageContext.request.contextPath}/account?action=list">账户管理</a>
    <a href="${pageContext.request.contextPath}/loan?action=list">借贷管理</a>
    <a href="${pageContext.request.contextPath}/category?action=list">类别管理</a>
    <a href="${pageContext.request.contextPath}/statistics/index.jsp">统计分析</a>
    <% if (isAdmin) { %>
    <a href="${pageContext.request.contextPath}/admin?action=users">👑 用户管理</a>
    <% } %>
    <span class="divider">|</span>
    <span class="username">👤 <%= user.getUsername() %></span>
    <a href="${pageContext.request.contextPath}/user/profile.jsp" class="profile-link">⚙️ 个人设置</a>
    <a href="${pageContext.request.contextPath}/user?action=logout" class="logout-btn">退出</a>
  </div>
</nav>

<div class="container">

  <div class="page-header">
    <h2><i class="bi bi-receipt"></i> 收支管理</h2>
    <button class="btn-primary" onclick="openAddModal()"><i class="bi bi-plus-circle"></i> 新增记账</button>
  </div>

  <% if (success != null && !success.isEmpty()) { %>
  <div class="toast toast-success"><i class="bi bi-check-circle"></i> <%= success %></div>
  <% } %>
  <% if (error != null && !error.isEmpty()) { %>
  <div class="toast toast-error"><i class="bi bi-exclamation-circle"></i> <%= error %></div>
  <% } %>

  <!-- 筛选栏 -->
  <div class="filter-bar">
    <form action="${pageContext.request.contextPath}/transaction" method="get" id="filterForm" style="display:flex;flex-wrap:wrap;gap:12px 16px;align-items:flex-end;width:100%;">
      <input type="hidden" name="action" value="list">
      <div class="group" style="flex:1;min-width:120px;">
        <label>类型</label>
        <select name="type">
          <option value="">全部</option>
          <option value="income" ${param.type=='income'?'selected':''}>收入</option>
          <option value="expense" ${param.type=='expense'?'selected':''}>支出</option>
        </select>
      </div>
      <div class="group" style="flex:1;min-width:120px;">
        <label>类别</label>
        <select name="categoryId">
          <option value="">全部</option>
          <% for (Category c : categories) { %>
          <option value="<%= c.getId() %>" <%= String.valueOf(c.getId()).equals(request.getParameter("categoryId")) ? "selected" : "" %>><%= c.getName() %></option>
          <% } %>
        </select>
      </div>
      <div class="group" style="flex:1;min-width:120px;">
        <label>账户</label>
        <select name="accountId">
          <option value="">全部</option>
          <% for (Account a : accounts) { %>
          <option value="<%= a.getId() %>" <%= String.valueOf(a.getId()).equals(request.getParameter("accountId")) ? "selected" : "" %>><%= a.getAccountName() %></option>
          <% } %>
        </select>
      </div>
      <div class="group" style="flex:1;min-width:140px;">
        <label>开始</label>
        <input type="date" name="startDate" value="${param.startDate}">
      </div>
      <div class="group" style="flex:1;min-width:140px;">
        <label>结束</label>
        <input type="date" name="endDate" value="${param.endDate}">
      </div>
      <div class="group" style="display:flex;flex-direction:row;gap:8px;align-items:center;padding-bottom:0;flex:0 0 auto;">
        <button type="submit" class="btn-filter"><i class="bi bi-search"></i> 筛选</button>
        <button type="button" class="btn-reset" onclick="resetFilter()"><i class="bi bi-arrow-counterclockwise"></i> 重置</button>
      </div>
    </form>
  </div>

  <!-- 列表 -->
  <div class="table-wrap">
    <table>
      <thead>
      <tr>
        <th>时间</th>
        <th>类别</th>
        <th>类型</th>
        <th>金额</th>
        <th>账户</th>
        <th>备注</th>
        <th>操作</th>
      </tr>
      </thead>
      <tbody>
      <% if (pageBean.getList() == null || pageBean.getList().isEmpty()) { %>
      <tr><td colspan="7" class="empty">暂无记录，赶快记一笔吧！</td></tr>
      <% } else { for (Transaction t : pageBean.getList()) { %>
      <tr>
        <td style="color:rgba(255,255,255,0.4);font-size:13px;"><%= sdf.format(t.getTransDate()) %></td>
        <td><%= t.getCategoryName() != null ? t.getCategoryName() : "" %></td>
        <td><span class="<%= "income".equals(t.getType()) ? "badge-income" : "badge-expense" %>"><%= "income".equals(t.getType()) ? "收入" : "支出" %></span></td>
        <td class="<%= "income".equals(t.getType()) ? "text-income" : "text-expense" %>"><%= "income".equals(t.getType()) ? "+" : "-" %> ¥<%= String.format("%.2f", t.getAmount()) %></td>
        <td style="color:rgba(255,255,255,0.4);font-size:13px;"><%= t.getAccountName() != null ? t.getAccountName() : "" %></td>
        <td style="color:rgba(255,255,255,0.4);"><%= t.getRemark() != null ? t.getRemark() : "" %></td>
        <td class="actions">
          <button class="btn-edit" onclick="openEditModal(<%= t.getId() %>)"><i class="bi bi-pencil"></i> 编辑</button>
          <button class="btn-delete" onclick="deleteTransaction(<%= t.getId() %>)"><i class="bi bi-trash"></i></button>
        </td>
      </tr>
      <% } } %>
      </tbody>
    </table>

    <% if (pageBean.getTotalPage() > 1) { %>
    <div class="pagination">
      <a href="?action=list&page=1<%= request.getQueryString() != null ? "&" + request.getQueryString().replaceAll("page=\\d+&?", "").replaceAll("action=list&?", "") : "" %>" class="<%= pageBean.getCurrentPage() <= 1 ? "disabled" : "" %>">首页</a>
      <a href="?action=list&page=<%= pageBean.getCurrentPage() - 1 %><%= request.getQueryString() != null ? "&" + request.getQueryString().replaceAll("page=\\d+&?", "").replaceAll("action=list&?", "") : "" %>" class="<%= pageBean.getCurrentPage() <= 1 ? "disabled" : "" %>">上一页</a>
      <% for (int i = Math.max(1, pageBean.getCurrentPage() - 2); i <= Math.min(pageBean.getTotalPage(), pageBean.getCurrentPage() + 2); i++) { %>
      <a href="?action=list&page=<%= i %><%= request.getQueryString() != null ? "&" + request.getQueryString().replaceAll("page=\\d+&?", "").replaceAll("action=list&?", "") : "" %>" class="<%= i == pageBean.getCurrentPage() ? "active" : "" %>"><%= i %></a>
      <% } %>
      <a href="?action=list&page=<%= pageBean.getCurrentPage() + 1 %><%= request.getQueryString() != null ? "&" + request.getQueryString().replaceAll("page=\\d+&?", "").replaceAll("action=list&?", "") : "" %>" class="<%= pageBean.getCurrentPage() >= pageBean.getTotalPage() ? "disabled" : "" %>">下一页</a>
      <a href="?action=list&page=<%= pageBean.getTotalPage() %><%= request.getQueryString() != null ? "&" + request.getQueryString().replaceAll("page=\\d+&?", "").replaceAll("action=list&?", "") : "" %>" class="<%= pageBean.getCurrentPage() >= pageBean.getTotalPage() ? "disabled" : "" %>">末页</a>
    </div>
    <% } %>
    <div class="page-info">共 <%= pageBean.getTotalCount() %> 条，第 <%= pageBean.getCurrentPage() %> / <%= pageBean.getTotalPage() %> 页</div>
  </div>
</div>

<!-- ===== 加载遮罩 ===== -->
<div class="loading-mask" id="loadingMask">
  <div class="loading-spinner">
    <i class="bi bi-arrow-repeat"></i>
    <p>处理中...</p>
  </div>
</div>

<!-- ===== 新增模态框 ===== -->
<div class="modal" id="addModal">
  <div class="modal-content">
    <h3><i class="bi bi-plus-circle"></i> 新增记账</h3>
    <form id="addForm" onsubmit="return false;">
      <div class="form-group">
        <label>类型 <span style="color:#f87171;">*</span></label>
        <select id="addType" required>
          <option value="income">💰 收入</option>
          <option value="expense">💸 支出</option>
        </select>
      </div>
      <div class="form-group">
        <label>类别 <span style="color:#f87171;">*</span></label>
        <select id="addCategory" required>
          <% if (categories != null && !categories.isEmpty()) {
            for (Category c : categories) { %>
          <option value="<%= c.getId() %>" data-type="<%= c.getType() %>"><%= c.getName() %></option>
          <% }
          } else { %>
          <option value="">请先添加类别</option>
          <% } %>
        </select>
      </div>
      <div class="form-group">
        <label>账户 <span style="color:#f87171;">*</span></label>
        <select id="addAccount" required>
          <% if (accounts != null && !accounts.isEmpty()) {
            for (Account a : accounts) { %>
          <option value="<%= a.getId() %>"><%= a.getAccountName() %> (¥<%= String.format("%.2f", a.getBalance()) %>)</option>
          <% }
          } else { %>
          <option value="">请先添加账户</option>
          <% } %>
        </select>
      </div>
      <div class="form-group">
        <label>金额 (¥) <span style="color:#f87171;">*</span></label>
        <input type="number" id="addAmount" step="0.01" min="0.01" placeholder="请输入金额" required>
      </div>
      <div class="form-group">
        <label>日期 <span style="color:#f87171;">*</span></label>
        <input type="datetime-local" id="addDate" value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" required>
      </div>
      <div class="form-group">
        <label>备注</label>
        <input type="text" id="addRemark" placeholder="可选备注信息">
      </div>
    </form>
    <div class="modal-footer">
      <button class="btn-cancel" onclick="closeModal('addModal')">取消</button>
      <button class="btn-save" id="addSaveBtn" onclick="saveTransaction()"><i class="bi bi-check-lg"></i> 保存</button>
    </div>
  </div>
</div>

<!-- ===== 编辑模态框 ===== -->
<div class="modal" id="editModal">
  <div class="modal-content">
    <h3><i class="bi bi-pencil-square"></i> 编辑记账</h3>
    <form id="editForm" onsubmit="return false;">
      <input type="hidden" id="editId">
      <div class="form-group">
        <label>类型 <span style="color:#f87171;">*</span></label>
        <select id="editType" required>
          <option value="income">💰 收入</option>
          <option value="expense">💸 支出</option>
        </select>
      </div>
      <div class="form-group">
        <label>类别 <span style="color:#f87171;">*</span></label>
        <select id="editCategory" required>
          <% if (categories != null) {
            for (Category c : categories) { %>
          <option value="<%= c.getId() %>"><%= c.getName() %></option>
          <% }
          } %>
        </select>
      </div>
      <div class="form-group">
        <label>账户 <span style="color:#f87171;">*</span></label>
        <select id="editAccount" required>
          <% if (accounts != null) {
            for (Account a : accounts) { %>
          <option value="<%= a.getId() %>"><%= a.getAccountName() %> (¥<%= String.format("%.2f", a.getBalance()) %>)</option>
          <% }
          } %>
        </select>
      </div>
      <div class="form-group">
        <label>金额 (¥) <span style="color:#f87171;">*</span></label>
        <input type="number" id="editAmount" step="0.01" min="0.01" placeholder="请输入金额" required>
      </div>
      <div class="form-group">
        <label>日期 <span style="color:#f87171;">*</span></label>
        <input type="datetime-local" id="editDate" required>
      </div>
      <div class="form-group">
        <label>备注</label>
        <input type="text" id="editRemark" placeholder="可选备注信息">
      </div>
    </form>
    <div class="modal-footer">
      <button class="btn-cancel" onclick="closeModal('editModal')">取消</button>
      <button class="btn-save" id="editSaveBtn" onclick="updateTransaction()"><i class="bi bi-check-lg"></i> 更新</button>
    </div>
  </div>
</div>

<script>
  // ===== 重置筛选 =====
  function resetFilter() {
    var form = document.getElementById('filterForm');
    form.querySelectorAll('select').forEach(function(el) { el.selectedIndex = 0; });
    form.querySelectorAll('input[type="date"]').forEach(function(el) { el.value = ''; });
    form.submit();
  }

  // ===== 模态框控制 =====
  function openModal(id) {
    var modal = document.getElementById(id);
    if (modal) {
      modal.classList.add('show');
      document.body.style.overflow = 'hidden';
    }
  }

  function closeModal(id) {
    var modal = document.getElementById(id);
    if (modal) {
      modal.classList.remove('show');
      document.body.style.overflow = '';
    }
  }

  document.querySelectorAll('.modal').forEach(function(m) {
    m.addEventListener('click', function(e) {
      if (e.target === this) {
        this.classList.remove('show');
        document.body.style.overflow = '';
      }
    });
  });

  // ===== 加载遮罩 =====
  function showLoading() {
    var mask = document.getElementById('loadingMask');
    if (mask) mask.classList.add('show');
  }

  function hideLoading() {
    var mask = document.getElementById('loadingMask');
    if (mask) mask.classList.remove('show');
  }

  // ===== 类别过滤 =====
  function filterCategories(type, selectId) {
    var select = document.getElementById(selectId);
    if (!select) return;
    var options = select.querySelectorAll('option');
    var hasVisible = false;
    options.forEach(function(option) {
      var dataType = option.getAttribute('data-type');
      if (dataType === type || dataType === null || option.value === '') {
        option.style.display = '';
        if (option.value !== '') hasVisible = true;
      } else {
        option.style.display = 'none';
      }
    });
    if (hasVisible) {
      options.forEach(function(option) {
        if (option.style.display !== 'none' && option.value !== '') {
          select.selectedIndex = Array.from(options).indexOf(option);
          return false;
        }
      });
    }
  }

  // ===== 监听类型变化 =====
  document.addEventListener('DOMContentLoaded', function() {
    var addTypeSelect = document.getElementById('addType');
    if (addTypeSelect) {
      addTypeSelect.addEventListener('change', function() {
        filterCategories(this.value, 'addCategory');
      });
    }
  });

  // ===== 打开新增模态框 =====
  function openAddModal() {
    document.getElementById('addForm').reset();
    var now = new Date();
    now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
    document.getElementById('addDate').value = now.toISOString().slice(0, 16);

    var saveBtn = document.getElementById('addSaveBtn');
    saveBtn.disabled = false;
    saveBtn.innerHTML = '<i class="bi bi-check-lg"></i> 保存';

    openModal('addModal');

    setTimeout(function() {
      var typeSelect = document.getElementById('addType');
      if (typeSelect) {
        filterCategories(typeSelect.value, 'addCategory');
      }
      document.getElementById('addAmount').focus();
    }, 100);
  }

  // ===== 保存新增交易 =====
  function saveTransaction() {
    var type = document.getElementById('addType').value;
    var categoryId = document.getElementById('addCategory').value;
    var accountId = document.getElementById('addAccount').value;
    var amount = document.getElementById('addAmount').value;
    var transDate = document.getElementById('addDate').value;
    var remark = document.getElementById('addRemark').value.trim();

    if (!categoryId || categoryId === '') {
      alert('请选择类别');
      document.getElementById('addCategory').focus();
      return;
    }
    if (!accountId || accountId === '') {
      alert('请选择账户');
      document.getElementById('addAccount').focus();
      return;
    }
    if (!amount || parseFloat(amount) <= 0) {
      alert('请输入有效的金额（大于0）');
      document.getElementById('addAmount').focus();
      return;
    }
    if (!transDate) {
      alert('请选择日期');
      return;
    }

    var saveBtn = document.getElementById('addSaveBtn');
    saveBtn.disabled = true;
    saveBtn.innerHTML = '<i class="bi bi-hourglass-split"></i> 保存中...';

    var form = document.createElement('form');
    form.method = 'POST';
    form.action = '${pageContext.request.contextPath}/transaction';

    var params = [
      {name: 'action', value: 'add'},
      {name: 'type', value: type},
      {name: 'categoryId', value: categoryId},
      {name: 'accountId', value: accountId},
      {name: 'amount', value: amount},
      {name: 'transDate', value: transDate},
      {name: 'remark', value: remark}
    ];

    params.forEach(function(p) {
      var input = document.createElement('input');
      input.type = 'hidden';
      input.name = p.name;
      input.value = p.value;
      form.appendChild(input);
    });

    document.body.appendChild(form);
    form.submit();
  }

  // ===== 打开编辑模态框 =====
  function openEditModal(id) {
    showLoading();

    var saveBtn = document.getElementById('editSaveBtn');
    saveBtn.disabled = false;
    saveBtn.innerHTML = '<i class="bi bi-check-lg"></i> 更新';

    fetch('${pageContext.request.contextPath}/transaction?action=get&id=' + id)
            .then(function(response) {
              if (!response.ok) {
                throw new Error('网络响应异常: ' + response.status);
              }
              return response.json();
            })
            .then(function(data) {
              hideLoading();
              if (data && data.id) {
                document.getElementById('editId').value = data.id;
                document.getElementById('editType').value = data.type || 'income';
                document.getElementById('editCategory').value = data.categoryId || '';
                document.getElementById('editAccount').value = data.accountId || '';
                document.getElementById('editAmount').value = data.amount || '';
                if (data.transDate) {
                  document.getElementById('editDate').value =
                          data.transDate.substring(0, 16).replace(' ', 'T');
                }

                document.getElementById('editRemark').value = data.remark || '';

                openModal('editModal');
                document.getElementById('editAmount').focus();
              } else {
                alert('获取数据失败，请刷新后重试');
              }
            })
            .catch(function(error) {
              hideLoading();
              console.error('请求错误:', error);
              alert('获取数据失败: ' + error.message);
            });
  }

  // ===== 更新交易 =====
  function updateTransaction() {
    var id = document.getElementById('editId').value;
    var type = document.getElementById('editType').value;
    var categoryId = document.getElementById('editCategory').value;
    var accountId = document.getElementById('editAccount').value;
    var amount = document.getElementById('editAmount').value;
    var transDate = document.getElementById('editDate').value;
    var remark = document.getElementById('editRemark').value.trim();

    if (!categoryId || categoryId === '') {
      alert('请选择类别');
      document.getElementById('editCategory').focus();
      return;
    }
    if (!accountId || accountId === '') {
      alert('请选择账户');
      document.getElementById('editAccount').focus();
      return;
    }
    if (!amount || parseFloat(amount) <= 0) {
      alert('请输入有效的金额（大于0）');
      document.getElementById('editAmount').focus();
      return;
    }
    if (!transDate) {
      alert('请选择日期');
      return;
    }

    var saveBtn = document.getElementById('editSaveBtn');
    saveBtn.disabled = true;
    saveBtn.innerHTML = '<i class="bi bi-hourglass-split"></i> 更新中...';

    var form = document.createElement('form');
    form.method = 'POST';
    form.action = '${pageContext.request.contextPath}/transaction';

    var params = [
      {name: 'action', value: 'update'},
      {name: 'id', value: id},
      {name: 'type', value: type},
      {name: 'categoryId', value: categoryId},
      {name: 'accountId', value: accountId},
      {name: 'amount', value: amount},
      {name: 'transDate', value: transDate},
      {name: 'remark', value: remark}
    ];

    params.forEach(function(p) {
      var input = document.createElement('input');
      input.type = 'hidden';
      input.name = p.name;
      input.value = p.value;
      form.appendChild(input);
    });

    document.body.appendChild(form);
    form.submit();
  }

  // ===== 删除交易 =====
  function deleteTransaction(id) {
    if (!confirm('确定要删除这条记录吗？此操作不可恢复！')) return;

    var form = document.createElement('form');
    form.method = 'POST';
    form.action = '${pageContext.request.contextPath}/transaction';

    var params = [
      {name: 'action', value: 'delete'},
      {name: 'id', value: id}
    ];

    params.forEach(function(p) {
      var input = document.createElement('input');
      input.type = 'hidden';
      input.name = p.name;
      input.value = p.value;
      form.appendChild(input);
    });

    document.body.appendChild(form);
    form.submit();
  }

  // ===== 键盘事件 =====
  document.addEventListener('DOMContentLoaded', function() {
    var addForm = document.getElementById('addForm');
    if (addForm) {
      addForm.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
          e.preventDefault();
          var btn = document.getElementById('addSaveBtn');
          if (!btn.disabled) {
            saveTransaction();
          }
        }
      });
    }

    var editForm = document.getElementById('editForm');
    if (editForm) {
      editForm.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
          e.preventDefault();
          var btn = document.getElementById('editSaveBtn');
          if (!btn.disabled) {
            updateTransaction();
          }
        }
      });
    }
  });

  // ===== Toast自动消失 =====
  document.addEventListener('DOMContentLoaded', function() {
    var toasts = document.querySelectorAll('.toast');
    toasts.forEach(function(toast) {
      setTimeout(function() {
        toast.style.transition = 'opacity 0.5s ease';
        toast.style.opacity = '0';
        setTimeout(function() {
          toast.style.display = 'none';
        }, 500);
      }, 3000);
    });
  });

  // ===== 页面刷新前清理 =====
  window.addEventListener('beforeunload', function() {
    document.querySelectorAll('.modal').forEach(function(m) {
      m.classList.remove('show');
    });
    document.body.style.overflow = '';
  });
</script>

</body>
</html>
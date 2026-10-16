<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="entity.User, entity.Account, service.AccountService, service.TransactionService" %>
<%@ page import="java.math.BigDecimal, java.text.SimpleDateFormat, java.util.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    boolean isAdmin = "admin".equals(user.getRole());

    AccountService accountService = new AccountService();
    TransactionService transactionService = new TransactionService();
    List<Account> accounts = accountService.getAccounts(user.getId());

    BigDecimal totalAssets = BigDecimal.ZERO;
    for (Account acc : accounts) {
        totalAssets = totalAssets.add(acc.getBalance());
    }

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM");
    String yearMonth = sdf.format(new Date());
    BigDecimal monthIncome = transactionService.getMonthlyIncome(user.getId(), yearMonth);
    BigDecimal monthExpense = transactionService.getMonthlyExpense(user.getId(), yearMonth);
    BigDecimal monthBalance = monthIncome.subtract(monthExpense);
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>简易财富记账系统 - 首页</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* ===== 首页特有样式 ===== */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }
        .main-grid {
            display: grid;
            grid-template-columns: 1fr 2fr;
            gap: 20px;
        }
        .quick-actions {
            display: flex;
            gap: 10px;
            margin-top: 12px;
            flex-wrap: wrap;
        }
        .quick-btn {
            flex: 1;
            min-width: 90px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 12px;
            padding: 14px 10px;
            text-align: center;
            text-decoration: none;
            color: rgba(255, 255, 255, 0.7);
            border: 1px solid rgba(255, 255, 255, 0.06);
            transition: all 0.3s ease;
            font-size: 13px;
            font-weight: 500;
        }
        .quick-btn:hover {
            background: rgba(255, 255, 255, 0.1);
            border-color: rgba(102, 126, 234, 0.3);
            color: white;
            transform: translateY(-2px);
        }
        .quick-btn i {
            font-size: 20px;
            display: block;
            margin-bottom: 4px;
            opacity: 0.8;
        }
        .account-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 14px;
            border-radius: 10px;
            margin-top: 6px;
            background: rgba(255, 255, 255, 0.03);
            border-left: 3px solid rgba(102, 126, 234, 0.4);
            transition: background 0.3s ease;
        }
        .account-item:hover {
            background: rgba(255, 255, 255, 0.06);
        }
        .account-item .ac-name {
            font-weight: 500;
            font-size: 14px;
            color: rgba(255, 255, 255, 0.85);
        }
        .account-item .ac-balance {
            font-weight: 600;
            font-size: 15px;
        }
        .account-empty {
            text-align: center;
            padding: 20px 0;
            color: rgba(255, 255, 255, 0.3);
            font-size: 14px;
        }
        .account-empty a {
            color: #667eea;
            text-decoration: none;
        }
        .account-empty a:hover {
            text-decoration: underline;
        }
        .transaction-empty {
            text-align: center;
            padding: 30px 0;
            color: rgba(255, 255, 255, 0.3);
            font-size: 14px;
        }
        .transaction-empty i {
            font-size: 28px;
            display: block;
            color: rgba(255, 255, 255, 0.1);
            margin-bottom: 8px;
        }
        .transaction-table td {
            padding: 10px 8px;
        }
        .transaction-table .text-income {
            color: #34d399;
            font-weight: 600;
        }
        .transaction-table .text-expense {
            color: #f87171;
            font-weight: 600;
        }
        .welcome-text {
            margin-bottom: 20px;
        }
        .welcome-text h4 {
            font-size: 20px;
            color: rgba(255, 255, 255, 0.9);
        }
        .welcome-text p {
            color: rgba(255, 255, 255, 0.4);
            font-size: 14px;
        }

        @media (max-width: 992px) {
            .main-grid {
                grid-template-columns: 1fr;
            }
            .stats-row {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        @media (max-width: 576px) {
            .stats-row {
                grid-template-columns: 1fr;
            }
            .quick-btn {
                min-width: 70px;
                font-size: 12px;
                padding: 10px 8px;
            }
        }
    </style>
</head>
<body>

<!-- ===== 导航栏 ===== -->
<nav class="navbar">
    <a class="brand" href="${pageContext.request.contextPath}/index.jsp">
        <i class="bi bi-wallet2"></i> <span>简易财富记账系统</span>
    </a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/index.jsp" class="active">首页</a>
        <a href="${pageContext.request.contextPath}/transaction?action=list">收支管理</a>
        <a href="${pageContext.request.contextPath}/account?action=list">账户管理</a>
        <a href="${pageContext.request.contextPath}/loan?action=list">借贷管理</a>
        <a href="${pageContext.request.contextPath}/category?action=list">类别管理</a>
        <a href="${pageContext.request.contextPath}/statistics/index.jsp">统计分析</a>
        <% if (isAdmin) { %>
        <a href="${pageContext.request.contextPath}/admin?action=users">👑 用户管理</a>
        <% } %>
        <span class="divider">|</span>
        <span class="username">👤 ${user.username}</span>
        <a href="${pageContext.request.contextPath}/user/profile.jsp" class="profile-link">⚙️ 个人设置</a>
        <a href="${pageContext.request.contextPath}/user?action=logout" class="logout-btn">退出</a>
    </div>
</nav>

<!-- ===== 内容 ===== -->
<div class="container">

    <!-- 欢迎语 -->
    <div class="welcome-text fade-in">
        <h4>👋 你好，<%= user.getUsername() %>！</h4>
        <p>记录每一笔收支，掌控财务自由</p>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-row">
        <div class="stat-card blue">
            <div class="stat-icon">💰</div>
            <div class="stat-value">¥<%= String.format("%.2f", totalAssets) %></div>
            <div class="stat-label">总资产</div>
        </div>
        <div class="stat-card green">
            <div class="stat-icon">📈</div>
            <div class="stat-value">¥<%= String.format("%.2f", monthIncome) %></div>
            <div class="stat-label">本月收入</div>
        </div>
        <div class="stat-card red">
            <div class="stat-icon">📉</div>
            <div class="stat-value">¥<%= String.format("%.2f", monthExpense) %></div>
            <div class="stat-label">本月支出</div>
        </div>
        <div class="stat-card purple">
            <div class="stat-icon">📊</div>
            <div class="stat-value" style="color:<%= monthBalance.compareTo(BigDecimal.ZERO)>=0?"#34d399":"#f87171" %>">¥<%= String.format("%.2f", monthBalance) %></div>
            <div class="stat-label">本月结余</div>
        </div>
    </div>

    <!-- 两栏布局 -->
    <div class="main-grid">

        <!-- 左侧：账户 + 快捷操作 -->
        <div>
            <div class="card" style="margin-bottom:16px;">
                <div class="card-title">
                    <span>🏦 我的账户</span>
                    <a href="${pageContext.request.contextPath}/account?action=list">管理 →</a>
                </div>
                <div>
                    <% if (accounts.isEmpty()) { %>
                    <div class="account-empty">
                        <i class="bi bi-bank" style="font-size:32px;display:block;color:rgba(255,255,255,0.1);margin-bottom:8px;"></i>
                        暂无账户<br>
                        <a href="${pageContext.request.contextPath}/account?action=list">去添加</a>
                    </div>
                    <% } else { %>
                    <% for (Account acc : accounts) { %>
                    <div class="account-item">
                        <span class="ac-name"><%= acc.getAccountName() %></span>
                        <span class="ac-balance" style="color:<%= acc.getBalance().compareTo(BigDecimal.ZERO)>=0?"#34d399":"#f87171" %>">¥<%= String.format("%.2f", acc.getBalance()) %></span>
                    </div>
                    <% } %>
                    <% } %>
                </div>
            </div>

            <!-- 快捷操作 -->
            <div class="quick-actions">
                <a href="${pageContext.request.contextPath}/transaction?action=list" class="quick-btn"><i class="bi bi-plus-circle"></i>记一笔</a>
                <a href="${pageContext.request.contextPath}/account?action=list" class="quick-btn"><i class="bi bi-bank"></i>账户</a>
                <a href="${pageContext.request.contextPath}/statistics/index.jsp" class="quick-btn"><i class="bi bi-bar-chart"></i>报表</a>
            </div>
        </div>

        <!-- 右侧：最近交易 -->
        <div class="card">
            <div class="card-title">
                <span>📋 最近交易</span>
                <a href="${pageContext.request.contextPath}/transaction?action=list">查看全部 →</a>
            </div>
            <div style="overflow-x:auto;">
                <table class="transaction-table">
                    <thead>
                    <tr>
                        <th style="width:25%;">日期</th>
                        <th style="width:18%;">类别</th>
                        <th style="width:16%;">类型</th>
                        <th style="width:20%;">金额</th>
                        <th style="width:21%;">账户</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        entity.PageBean<entity.Transaction> pageBean = transactionService.getTransactionsByPage(
                                user.getId(), null, null, null, null, null, 1, 5
                        );
                        if (pageBean.getList() == null || pageBean.getList().isEmpty()) {
                    %>
                    <tr><td colspan="5" class="transaction-empty"><i class="bi bi-inbox"></i>暂无交易记录，赶快记一笔吧！</td></tr>
                    <%
                    } else {
                        SimpleDateFormat sdf2 = new SimpleDateFormat("MM-dd HH:mm");
                        for (entity.Transaction t : pageBean.getList()) {
                    %>
                    <tr>
                        <td style="color:rgba(255,255,255,0.4);font-size:12px;"><%= sdf2.format(t.getTransDate()) %></td>
                        <td><%= t.getCategoryName() != null ? t.getCategoryName() : "-" %></td>
                        <td><span class="<%= "income".equals(t.getType()) ? "badge-income" : "badge-expense" %>"><%= "income".equals(t.getType()) ? "收入" : "支出" %></span></td>
                        <td class="<%= "income".equals(t.getType()) ? "text-income" : "text-expense" %>"><%= "income".equals(t.getType()) ? "+" : "-" %> ¥<%= String.format("%.2f", t.getAmount()) %></td>
                        <td style="font-size:12px;color:rgba(255,255,255,0.4);"><%= t.getAccountName() != null ? t.getAccountName() : "-" %></td>
                    </tr>
                    <%
                            }
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <div class="footer">&copy; 2026 简易财富记账系统</div>
</div>

</body>
</html>
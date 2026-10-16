-- =============================================
-- 简易财富记账系统 - 完整数据库脚本（修复版）
-- 数据库: finance_db
-- 说明: 执行前会 DROP DATABASE，请谨慎
-- =============================================

DROP DATABASE IF EXISTS finance_db;
CREATE DATABASE finance_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE finance_db;


-- =============================================
-- 1. 用户表
-- =============================================
CREATE TABLE USER (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) UNIQUE NOT NULL COMMENT '用户名',
    PASSWORD VARCHAR(100) NOT NULL COMMENT '密码(MD5加密)',
    email VARCHAR(100) COMMENT '电子邮箱',
    role VARCHAR(20) DEFAULT 'user' COMMENT '角色: admin(管理员)/user(普通用户)',
    STATUS VARCHAR(10) DEFAULT 'active' COMMENT '状态: active(正常)/locked(锁定)',
    reg_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间'
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';


-- =============================================
-- 2. 账户表
-- =============================================
CREATE TABLE account (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '账户ID',
    user_id INT NOT NULL COMMENT '所属用户ID',
    account_name VARCHAR(50) NOT NULL COMMENT '账户名称',
    TYPE VARCHAR(20) NOT NULL COMMENT '账户类型: 银行卡/现金/微信/支付宝/信用卡/花呗/其他',
    balance DECIMAL(12,2) DEFAULT 0.00 COMMENT '当前余额',
    remark VARCHAR(200) COMMENT '备注',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES USER(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_account (user_id, account_name) COMMENT '同一用户下账户名称唯一',
    INDEX idx_user_id (user_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COMMENT='账户表';


-- =============================================
-- 3. 收支类别表
-- =============================================
CREATE TABLE category (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '类别ID',
    user_id INT NOT NULL COMMENT '所属用户ID',
    NAME VARCHAR(30) NOT NULL COMMENT '类别名称',
    TYPE VARCHAR(10) NOT NULL COMMENT '类别类型: income/expense',
    icon VARCHAR(50) COMMENT '图标标识',
    sort_order INT DEFAULT 0 COMMENT '排序号',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES USER(id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_category (user_id, NAME, TYPE) COMMENT '同一用户下同类型类别名称唯一',
    INDEX idx_user_id_type (user_id, TYPE)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COMMENT='收支类别表';


-- =============================================
-- 4. 收支流水表
--    外键用 RESTRICT，防止级联删除交易
-- =============================================
CREATE TABLE TRANSACTION (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '流水ID',
    user_id INT NOT NULL COMMENT '所属用户ID',
    account_id INT NOT NULL COMMENT '关联账户ID',
    category_id INT NOT NULL COMMENT '关联类别ID',
    TYPE VARCHAR(10) NOT NULL COMMENT '收支类型: income/expense',
    amount DECIMAL(12,2) NOT NULL COMMENT '金额',
    trans_date DATETIME NOT NULL COMMENT '交易日期',
    remark VARCHAR(200) COMMENT '备注',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (user_id) REFERENCES USER(id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES account(id) ON DELETE RESTRICT,
    FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE RESTRICT,
    INDEX idx_user_date (user_id, trans_date),
    INDEX idx_user_type (user_id, TYPE)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COMMENT='收支流水表';


-- =============================================
-- 5. 借贷表
--    保留 account_id 和 linked_transaction_id
-- =============================================
CREATE TABLE loan (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '借贷ID',
    user_id INT NOT NULL COMMENT '所属用户ID',
    TYPE VARCHAR(10) NOT NULL COMMENT '类型: borrow(借入)/lend(借出)',
    person VARCHAR(50) NOT NULL COMMENT '对方姓名',
    amount DECIMAL(12,2) NOT NULL COMMENT '金额',
    loan_date DATE NOT NULL COMMENT '借贷日期',
    STATUS VARCHAR(10) DEFAULT 'unpaid' COMMENT '状态: unpaid(未还)/paid(已还)',
    remark VARCHAR(200) COMMENT '备注',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    account_id INT NULL COMMENT '关联账户ID',
    linked_transaction_id INT NULL COMMENT '关联收支记录ID',
    FOREIGN KEY (user_id) REFERENCES USER(id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES account(id) ON DELETE SET NULL,
    INDEX idx_user_status (user_id, STATUS)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COMMENT='借贷表';


-- =============================================
-- 6. 系统日志表
-- =============================================
CREATE TABLE system_log (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '日志ID',
    user_id INT NULL COMMENT '操作用户ID',
    username VARCHAR(50) NOT NULL COMMENT '操作用户名',
    ACTION VARCHAR(50) NOT NULL COMMENT '操作类型',
    description VARCHAR(200) COMMENT '操作描述',
    ip VARCHAR(50) COMMENT 'IP地址',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    FOREIGN KEY (user_id) REFERENCES USER(id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COMMENT='系统日志表';


-- =============================================
-- 7. 系统设置表
-- =============================================
CREATE TABLE system_config (
    id INT PRIMARY KEY AUTO_INCREMENT COMMENT '配置ID',
    config_key VARCHAR(50) UNIQUE NOT NULL COMMENT '配置键名',
    config_value VARCHAR(200) COMMENT '配置值',
    description VARCHAR(100) COMMENT '配置说明',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COMMENT='系统设置表';


-- =============================================
-- 8. 系统默认配置
-- =============================================
INSERT INTO system_config (config_key, config_value, description) VALUES
('system_name', '简易财富记账系统', '系统名称'),
('maintenance_mode', 'off', '维护模式: on/off');


-- =============================================
-- 9. 测试用户
--    密码: 123456 → MD5: E10ADC3949BA59ABBE56E057F20F883E
-- =============================================
INSERT INTO USER (username, PASSWORD, email, role, STATUS) VALUES
('admin',    'E10ADC3949BA59ABBE56E057F20F883E', 'admin@finance.com',    'admin', 'active'),
('zhangsan', 'E10ADC3949BA59ABBE56E057F20F883E', 'zhangsan@test.com',    'user',  'active'),
('lisi',     'E10ADC3949BA59ABBE56E057F20F883E', 'lisi@test.com',        'user',  'active'),
('wangwu',   'E10ADC3949BA59ABBE56E057F20F883E', 'wangwu@test.com',      'user',  'active'),
('zhaoliu',  'E10ADC3949BA59ABBE56E057F20F883E', 'zhaoliu@test.com',     'user',  'active'),
('sunqi',    'E10ADC3949BA59ABBE56E057F20F883E', 'sunqi@test.com',       'user',  'active'),
('zhouba',   'E10ADC3949BA59ABBE56E057F20F883E', 'zhouba@test.com',      'user',  'active');


-- =============================================
-- 10. 类别（zhangsan, user_id=2）
-- =============================================
INSERT INTO category (user_id, NAME, TYPE, sort_order) VALUES
(2, '餐饮',     'expense', 1),
(2, '交通',     'expense', 2),
(2, '购物',     'expense', 3),
(2, '娱乐',     'expense', 4),
(2, '住房',     'expense', 5),
(2, '医疗',     'expense', 6),
(2, '教育',     'expense', 7),
(2, '通讯',     'expense', 8),
(2, '服饰',     'expense', 9),
(2, '人情',     'expense', 10),
(2, '其他支出', 'expense', 99),
(2, '工资',     'income',  1),
(2, '奖金',     'income',  2),
(2, '投资收益', 'income',  3),
(2, '兼职收入', 'income',  4),
(2, '其他收入', 'income',  99);


-- =============================================
-- 11. 类别（lisi, user_id=3）
-- =============================================
INSERT INTO category (user_id, NAME, TYPE, sort_order) VALUES
(3, '餐饮',     'expense', 1),
(3, '交通',     'expense', 2),
(3, '购物',     'expense', 3),
(3, '娱乐',     'expense', 4),
(3, '住房',     'expense', 5),
(3, '医疗',     'expense', 6),
(3, '教育',     'expense', 7),
(3, '通讯',     'expense', 8),
(3, '服饰',     'expense', 9),
(3, '人情',     'expense', 10),
(3, '其他支出', 'expense', 99),
(3, '工资',     'income',  1),
(3, '奖金',     'income',  2),
(3, '投资收益', 'income',  3),
(3, '兼职收入', 'income',  4),
(3, '其他收入', 'income',  99);


-- =============================================
-- 12. 类别（wangwu, user_id=4）
-- =============================================
INSERT INTO category (user_id, NAME, TYPE, sort_order) VALUES
(4, '餐饮',     'expense', 1),
(4, '交通',     'expense', 2),
(4, '购物',     'expense', 3),
(4, '娱乐',     'expense', 4),
(4, '住房',     'expense', 5),
(4, '医疗',     'expense', 6),
(4, '教育',     'expense', 7),
(4, '通讯',     'expense', 8),
(4, '服饰',     'expense', 9),
(4, '人情',     'expense', 10),
(4, '其他支出', 'expense', 99),
(4, '工资',     'income',  1),
(4, '奖金',     'income',  2),
(4, '投资收益', 'income',  3),
(4, '兼职收入', 'income',  4),
(4, '其他收入', 'income',  99);


-- =============================================
-- 13. 账户（zhangsan, user_id=2）
--     微信钱包初始余额给 1000，避免为负
-- =============================================
INSERT INTO account (user_id, account_name, TYPE, balance, remark) VALUES
(2, '建设银行储蓄卡', '银行卡', 0.00, '工资卡'),
(2, '微信钱包',       '微信',   0.00, '日常消费'),
(2, '现金',           '现金',   0.00, '备用金');


-- =============================================
-- 14. 账户（lisi, user_id=3）
-- =============================================
INSERT INTO account (user_id, account_name, TYPE, balance, remark) VALUES
(3, '农业银行储蓄卡', '银行卡', 0.00, '工资卡'),
(3, '支付宝',         '支付宝', 0.00, '网购专用'),
(3, '现金',           '现金',   0.00, '零钱');


-- =============================================
-- 15. 账户（wangwu, user_id=4）
-- =============================================
INSERT INTO account (user_id, account_name, TYPE, balance, remark) VALUES
(4, '工商银行储蓄卡', '银行卡', 0.00, '工资卡'),
(4, '微信钱包',       '微信',   0.00, '日常消费');


-- =============================================
-- 16. 给每个账户补"账户初始余额"收入（关键修复！）
--     这样重算后所有账户余额都 ≥ 0
-- =============================================

-- zhangsan 建行卡：初始 8000
INSERT INTO TRANSACTION (user_id, account_id, category_id, TYPE, amount, trans_date, remark)
VALUES (2, 1, (SELECT id FROM category WHERE user_id=2 AND NAME='其他收入' AND TYPE='income'),
        'income', 8000.00, '2026-06-01 00:00:00', '账户初始余额');

-- zhangsan 微信钱包：初始 1500
INSERT INTO TRANSACTION (user_id, account_id, category_id, TYPE, amount, trans_date, remark)
VALUES (2, 2, (SELECT id FROM category WHERE user_id=2 AND NAME='其他收入' AND TYPE='income'),
        'income', 1500.00, '2026-06-01 00:00:00', '账户初始余额');

-- zhangsan 现金：初始 800
INSERT INTO TRANSACTION (user_id, account_id, category_id, TYPE, amount, trans_date, remark)
VALUES (2, 3, (SELECT id FROM category WHERE user_id=2 AND NAME='其他收入' AND TYPE='income'),
        'income', 800.00, '2026-06-01 00:00:00', '账户初始余额');

-- lisi 农行卡：初始 5000
INSERT INTO TRANSACTION (user_id, account_id, category_id, TYPE, amount, trans_date, remark)
VALUES (3, 4, (SELECT id FROM category WHERE user_id=3 AND NAME='其他收入' AND TYPE='income'),
        'income', 5000.00, '2026-06-01 00:00:00', '账户初始余额');

-- lisi 支付宝：初始 1200（要覆盖 -793 的支出）
INSERT INTO TRANSACTION (user_id, account_id, category_id, TYPE, amount, trans_date, remark)
VALUES (3, 5, (SELECT id FROM category WHERE user_id=3 AND NAME='其他收入' AND TYPE='income'),
        'income', 2000.00, '2026-06-01 00:00:00', '账户初始余额');

-- lisi 现金：初始 500（要覆盖 -35 的支出）
INSERT INTO TRANSACTION (user_id, account_id, category_id, TYPE, amount, trans_date, remark)
VALUES (3, 6, (SELECT id FROM category WHERE user_id=3 AND NAME='其他收入' AND TYPE='income'),
        'income', 800.00, '2026-06-01 00:00:00', '账户初始余额');

-- wangwu 工行卡：初始 3000
INSERT INTO TRANSACTION (user_id, account_id, category_id, TYPE, amount, trans_date, remark)
VALUES (4, 7, (SELECT id FROM category WHERE user_id=4 AND NAME='其他收入' AND TYPE='income'),
        'income', 3000.00, '2026-06-01 00:00:00', '账户初始余额');

-- wangwu 微信钱包：初始 800（要覆盖 -230 的支出）
INSERT INTO TRANSACTION (user_id, account_id, category_id, TYPE, amount, trans_date, remark)
VALUES (4, 8, (SELECT id FROM category WHERE user_id=4 AND NAME='其他收入' AND TYPE='income'),
        'income', 800.00, '2026-06-01 00:00:00', '账户初始余额');


-- =============================================
-- 17. 6月收支记录（zhangsan, user_id=2）
-- =============================================
INSERT INTO TRANSACTION (user_id, account_id, category_id, TYPE, amount, trans_date, remark) VALUES
(2, 1, (SELECT id FROM category WHERE user_id=2 AND NAME='工资' AND TYPE='income'),  'income',  6000.00, '2026-06-01 09:00:00', '6月工资'),
(2, 1, (SELECT id FROM category WHERE user_id=2 AND NAME='奖金' AND TYPE='income'),  'income',  1000.00, '2026-06-10 10:00:00', '项目奖金'),
(2, 1, (SELECT id FROM category WHERE user_id=2 AND NAME='娱乐' AND TYPE='expense'), 'expense',   88.00, '2026-06-08 19:00:00', '看电影'),
(2, 1, (SELECT id FROM category WHERE user_id=2 AND NAME='娱乐' AND TYPE='expense'), 'expense',   56.00, '2026-06-12 20:00:00', '游戏充值'),
(2, 2, (SELECT id FROM category WHERE user_id=2 AND NAME='餐饮' AND TYPE='expense'), 'expense',   35.00, '2026-06-02 12:30:00', '午餐'),
(2, 2, (SELECT id FROM category WHERE user_id=2 AND NAME='餐饮' AND TYPE='expense'), 'expense',   42.00, '2026-06-05 18:00:00', '晚餐'),
(2, 2, (SELECT id FROM category WHERE user_id=2 AND NAME='交通' AND TYPE='expense'), 'expense',    8.00, '2026-06-03 08:00:00', '公交'),
(2, 2, (SELECT id FROM category WHERE user_id=2 AND NAME='交通' AND TYPE='expense'), 'expense',   15.00, '2026-06-07 08:30:00', '地铁'),
(2, 2, (SELECT id FROM category WHERE user_id=2 AND NAME='通讯' AND TYPE='expense'), 'expense',   30.00, '2026-06-10 09:00:00', '话费充值'),
(2, 2, (SELECT id FROM category WHERE user_id=2 AND NAME='通讯' AND TYPE='expense'), 'expense',   50.00, '2026-06-18 09:00:00', '宽带续费'),
(2, 3, (SELECT id FROM category WHERE user_id=2 AND NAME='购物' AND TYPE='expense'), 'expense',  199.00, '2026-06-06 15:00:00', '网购商品'),
(2, 3, (SELECT id FROM category WHERE user_id=2 AND NAME='购物' AND TYPE='expense'), 'expense',  268.00, '2026-06-14 20:00:00', '超市购物');


-- =============================================
-- 18. 6月收支记录（lisi, user_id=3）
-- =============================================
INSERT INTO TRANSACTION (user_id, account_id, category_id, TYPE, amount, trans_date, remark) VALUES
(3, 4, (SELECT id FROM category WHERE user_id=3 AND NAME='工资' AND TYPE='income'),     'income',  4500.00, '2026-06-01 09:00:00', '6月工资'),
(3, 4, (SELECT id FROM category WHERE user_id=3 AND NAME='兼职收入' AND TYPE='income'), 'income',   300.00, '2026-06-05 18:00:00', '兼职收入'),
(3, 4, (SELECT id FROM category WHERE user_id=3 AND NAME='住房' AND TYPE='expense'),    'expense', 1200.00, '2026-06-15 10:00:00', '房租'),
(3, 5, (SELECT id FROM category WHERE user_id=3 AND NAME='餐饮' AND TYPE='expense'),    'expense',   45.00, '2026-06-02 12:30:00', '午餐'),
(3, 5, (SELECT id FROM category WHERE user_id=3 AND NAME='餐饮' AND TYPE='expense'),    'expense',   38.00, '2026-06-06 18:00:00', '晚餐'),
(3, 5, (SELECT id FROM category WHERE user_id=3 AND NAME='交通' AND TYPE='expense'),    'expense',   12.00, '2026-06-03 08:00:00', '地铁'),
(3, 5, (SELECT id FROM category WHERE user_id=3 AND NAME='购物' AND TYPE='expense'),    'expense',  156.00, '2026-06-07 20:00:00', '日用品'),
(3, 5, (SELECT id FROM category WHERE user_id=3 AND NAME='娱乐' AND TYPE='expense'),    'expense',  120.00, '2026-06-09 19:00:00', '音乐会');


-- =============================================
-- 19. 6月收支记录（wangwu, user_id=4）
-- =============================================
INSERT INTO TRANSACTION (user_id, account_id, category_id, TYPE, amount, trans_date, remark) VALUES
(4, 7, (SELECT id FROM category WHERE user_id=4 AND NAME='工资' AND TYPE='income'),     'income',  3500.00, '2026-06-01 09:00:00', '6月工资'),
(4, 7, (SELECT id FROM category WHERE user_id=4 AND NAME='奖金' AND TYPE='income'),     'income',   500.00, '2026-06-10 10:00:00', '绩效奖金'),
(4, 8, (SELECT id FROM category WHERE user_id=4 AND NAME='餐饮' AND TYPE='expense'),    'expense',   28.00, '2026-06-02 12:30:00', '午餐'),
(4, 8, (SELECT id FROM category WHERE user_id=4 AND NAME='交通' AND TYPE='expense'),    'expense',   10.00, '2026-06-03 08:00:00', '公交'),
(4, 8, (SELECT id FROM category WHERE user_id=4 AND NAME='通讯' AND TYPE='expense'),    'expense',   30.00, '2026-06-05 09:00:00', '话费充值');


-- =============================================
-- 20. 借贷记录（zhangsan, user_id=2）
-- =============================================
INSERT INTO loan (user_id, TYPE, person, amount, loan_date, STATUS, remark, account_id) VALUES
(2, 'lend',   '赵六', 800.00, '2026-06-12', 'unpaid', '同学借款',  1),
(2, 'borrow', '钱七', 300.00, '2026-06-08', 'paid',   '已还清',    2),
(2, 'lend',   '孙九', 500.00, '2026-06-18', 'unpaid', '朋友借款',  1);


-- =============================================
-- 21. 借贷记录（lisi, user_id=3）
-- =============================================
INSERT INTO loan (user_id, TYPE, person, amount, loan_date, STATUS, remark, account_id) VALUES
(3, 'lend',   '周十', 500.00,  '2026-06-10', 'unpaid', '朋友借款', 4),
(3, 'borrow', '吴一', 1000.00, '2026-06-15', 'unpaid', '临时周转', 4);


-- =============================================
-- 22. 借贷记录（wangwu, user_id=4）
-- =============================================
INSERT INTO loan (user_id, TYPE, person, amount, loan_date, STATUS, remark, account_id) VALUES
(4, 'lend',   '郑二', 200.00, '2026-06-05', 'paid', '已还清', 7);


-- =============================================
-- 23. 系统日志
-- =============================================
INSERT INTO system_log (user_id, username, ACTION, description, ip) VALUES
(1, 'admin',    'login',          '管理员登录系统',          '127.0.0.1'),
(2, 'zhangsan', 'login',          '用户登录系统',            '127.0.0.1'),
(3, 'lisi',     'login',          '用户登录系统',            '127.0.0.1'),
(1, 'admin',    'addUser',        '新增用户 wangwu',         '127.0.0.1'),
(1, 'admin',    'setAdmin',       '将用户 zhangsan 设为管理员', '127.0.0.1'),
(2, 'zhangsan', 'addTransaction', '新增收支记录: 工资 6000.00', '127.0.0.1'),
(2, 'zhangsan', 'addTransaction', '新增收支记录: 午餐 -35.00',  '127.0.0.1'),
(3, 'lisi',     'addTransaction', '新增收支记录: 工资 4500.00', '127.0.0.1'),
(1, 'admin',    'deleteUser',     '删除用户 zhaoliu',        '127.0.0.1');


-- =============================================
-- 24. 7月收支记录
-- =============================================

-- zhangsan, user_id=2
INSERT INTO TRANSACTION (user_id, account_id, category_id, TYPE, amount, trans_date, remark) VALUES
(2, 1, (SELECT id FROM category WHERE user_id=2 AND NAME='工资' AND TYPE='income'),     'income',  6200.00, '2026-07-01 09:00:00', '7月基本工资'),
(2, 1, (SELECT id FROM category WHERE user_id=2 AND NAME='投资收益' AND TYPE='income'), 'income',   450.00, '2026-07-12 14:20:00', '基金理财收益'),
(2, 3, (SELECT id FROM category WHERE user_id=2 AND NAME='其他收入' AND TYPE='income'), 'income',  3000.00, '2026-07-02 10:00:00', '线下现金红包收入'),
(2, 1, (SELECT id FROM category WHERE user_id=2 AND NAME='住房' AND TYPE='expense'),    'expense', 1300.00, '2026-07-05 10:10:00', '7月房租'),
(2, 1, (SELECT id FROM category WHERE user_id=2 AND NAME='医疗' AND TYPE='expense'),    'expense',  268.00, '2026-07-08 16:30:00', '感冒买药'),
(2, 3, (SELECT id FROM category WHERE user_id=2 AND NAME='人情' AND TYPE='expense'),    'expense',  300.00, '2026-07-14 11:00:00', '朋友生日红包'),
(2, 3, (SELECT id FROM category WHERE user_id=2 AND NAME='购物' AND TYPE='expense'),    'expense',  135.00, '2026-07-22 17:20:00', '超市零食水果');

-- lisi, user_id=3
INSERT INTO TRANSACTION (user_id, account_id, category_id, TYPE, amount, trans_date, remark) VALUES
(3, 4, (SELECT id FROM category WHERE user_id=3 AND NAME='工资' AND TYPE='income'),     'income',  6000.00, '2026-07-01 09:00:00', '7月工资'),
(3, 4, (SELECT id FROM category WHERE user_id=3 AND NAME='奖金' AND TYPE='income'),     'income',  2600.00, '2026-07-01 09:00:00', '7月奖金'),
(3, 4, (SELECT id FROM category WHERE user_id=3 AND NAME='兼职收入' AND TYPE='income'), 'income',   420.00, '2026-07-18 17:00:00', '周末兼职稿费'),
(3, 4, (SELECT id FROM category WHERE user_id=3 AND NAME='住房' AND TYPE='expense'),    'expense', 1200.00, '2026-07-03 09:40:00', '月度房租'),
(3, 4, (SELECT id FROM category WHERE user_id=3 AND NAME='教育' AND TYPE='expense'),    'expense',  360.00, '2026-07-09 15:10:00', '线上课程续费'),
(3, 5, (SELECT id FROM category WHERE user_id=3 AND NAME='餐饮' AND TYPE='expense'),    'expense',   32.00, '2026-07-03 12:10:00', '快餐午餐'),
(3, 5, (SELECT id FROM category WHERE user_id=3 AND NAME='购物' AND TYPE='expense'),    'expense',  245.00, '2026-07-11 21:00:00', '家居日用品'),
(3, 5, (SELECT id FROM category WHERE user_id=3 AND NAME='通讯' AND TYPE='expense'),    'expense',   59.00, '2026-07-06 10:20:00', '手机话费套餐'),
(3, 5, (SELECT id FROM category WHERE user_id=3 AND NAME='医疗' AND TYPE='expense'),    'expense',   86.00, '2026-07-25 14:30:00', '体检开药'),
(3, 6, (SELECT id FROM category WHERE user_id=3 AND NAME='交通' AND TYPE='expense'),    'expense',   35.00, '2026-07-12 08:30:00', '公交地铁充值');

-- wangwu, user_id=4
INSERT INTO TRANSACTION (user_id, account_id, category_id, TYPE, amount, trans_date, remark) VALUES
(4, 7, (SELECT id FROM category WHERE user_id=4 AND NAME='工资' AND TYPE='income'),     'income',  3600.00, '2026-07-01 09:00:00', '7月薪资'),
(4, 7, (SELECT id FROM category WHERE user_id=4 AND NAME='其他收入' AND TYPE='income'), 'income',   200.00, '2026-07-21 16:00:00', '闲置物品卖出'),
(4, 7, (SELECT id FROM category WHERE user_id=4 AND NAME='住房' AND TYPE='expense'),    'expense',  950.00, '2026-07-04 10:00:00', '合租房租分摊'),
(4, 7, (SELECT id FROM category WHERE user_id=4 AND NAME='人情' AND TYPE='expense'),    'expense',  200.00, '2026-07-16 12:00:00', '同事随礼'),
(4, 8, (SELECT id FROM category WHERE user_id=4 AND NAME='餐饮' AND TYPE='expense'),    'expense',   33.00, '2026-07-05 12:30:00', '外卖盖饭'),
(4, 8, (SELECT id FROM category WHERE user_id=4 AND NAME='娱乐' AND TYPE='expense'),    'expense',   65.00, '2026-07-13 19:20:00', '网吧充值'),
(4, 8, (SELECT id FROM category WHERE user_id=4 AND NAME='交通' AND TYPE='expense'),    'expense',   16.00, '2026-07-08 08:00:00', '公交出行'),
(4, 8, (SELECT id FROM category WHERE user_id=4 AND NAME='其他支出' AND TYPE='expense'),'expense',   48.00, '2026-07-28 17:00:00', '饮用水零食');


-- =============================================
-- 25. 重算所有账户余额
--     余额 = 所有交易流水求和（含初始余额收入）
-- =============================================
UPDATE account a
SET a.balance = COALESCE((
    SELECT SUM(CASE WHEN t.TYPE = 'income' THEN t.amount ELSE -t.amount END)
    FROM TRANSACTION t
    WHERE t.account_id = a.id
), 0);


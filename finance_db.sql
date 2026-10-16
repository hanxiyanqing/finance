/*
SQLyog Ultimate v10.00 Beta1
MySQL - 8.0.44 : Database - finance_db
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`finance_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `finance_db`;

/*Table structure for table `account` */

DROP TABLE IF EXISTS `account`;

CREATE TABLE `account` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '账户ID',
  `user_id` int NOT NULL COMMENT '所属用户ID',
  `account_name` varchar(50) NOT NULL COMMENT '账户名称',
  `TYPE` varchar(20) NOT NULL COMMENT '账户类型: 银行卡/现金/微信/支付宝/信用卡/花呗/其他',
  `balance` decimal(12,2) DEFAULT '0.00' COMMENT '当前余额',
  `remark` varchar(200) DEFAULT NULL COMMENT '备注',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_account` (`user_id`,`account_name`) COMMENT '同一用户下账户名称唯一',
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `account_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='账户表';

/*Data for the table `account` */

insert  into `account`(`id`,`user_id`,`account_name`,`TYPE`,`balance`,`remark`,`created_at`) values (1,2,'建设银行储蓄卡','银行卡','19938.00','工资卡','2026-10-15 19:53:51'),(2,2,'微信钱包','微信','1320.00','日常消费','2026-10-15 19:53:51'),(3,2,'现金','现金','2898.00','备用金','2026-10-15 19:53:51'),(4,3,'农业银行储蓄卡','银行卡','16060.00','工资卡','2026-10-15 19:53:51'),(5,3,'支付宝','支付宝','1207.00','网购专用','2026-10-15 19:53:51'),(6,3,'现金','现金','765.00','零钱','2026-10-15 19:53:51'),(7,4,'工商银行储蓄卡','银行卡','9650.00','工资卡','2026-10-15 19:53:51'),(8,4,'微信钱包','微信','570.00','日常消费','2026-10-15 19:53:51');

/*Table structure for table `category` */

DROP TABLE IF EXISTS `category`;

CREATE TABLE `category` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '类别ID',
  `user_id` int NOT NULL COMMENT '所属用户ID',
  `NAME` varchar(30) NOT NULL COMMENT '类别名称',
  `TYPE` varchar(10) NOT NULL COMMENT '类别类型: income/expense',
  `icon` varchar(50) DEFAULT NULL COMMENT '图标标识',
  `sort_order` int DEFAULT '0' COMMENT '排序号',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_category` (`user_id`,`NAME`,`TYPE`) COMMENT '同一用户下同类型类别名称唯一',
  KEY `idx_user_id_type` (`user_id`,`TYPE`),
  CONSTRAINT `category_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收支类别表';

/*Data for the table `category` */

insert  into `category`(`id`,`user_id`,`NAME`,`TYPE`,`icon`,`sort_order`,`created_at`) values (1,2,'餐饮','expense',NULL,1,'2026-10-15 19:53:51'),(2,2,'交通','expense',NULL,2,'2026-10-15 19:53:51'),(3,2,'购物','expense',NULL,3,'2026-10-15 19:53:51'),(4,2,'娱乐','expense',NULL,4,'2026-10-15 19:53:51'),(5,2,'住房','expense',NULL,5,'2026-10-15 19:53:51'),(6,2,'医疗','expense',NULL,6,'2026-10-15 19:53:51'),(7,2,'教育','expense',NULL,7,'2026-10-15 19:53:51'),(8,2,'通讯','expense',NULL,8,'2026-10-15 19:53:51'),(9,2,'服饰','expense',NULL,9,'2026-10-15 19:53:51'),(10,2,'人情','expense',NULL,10,'2026-10-15 19:53:51'),(11,2,'其他支出','expense',NULL,99,'2026-10-15 19:53:51'),(12,2,'工资','income',NULL,1,'2026-10-15 19:53:51'),(13,2,'奖金','income',NULL,2,'2026-10-15 19:53:51'),(14,2,'投资收益','income',NULL,3,'2026-10-15 19:53:51'),(15,2,'兼职收入','income',NULL,4,'2026-10-15 19:53:51'),(16,2,'其他收入','income',NULL,99,'2026-10-15 19:53:51'),(17,3,'餐饮','expense',NULL,1,'2026-10-15 19:53:51'),(18,3,'交通','expense',NULL,2,'2026-10-15 19:53:51'),(19,3,'购物','expense',NULL,3,'2026-10-15 19:53:51'),(20,3,'娱乐','expense',NULL,4,'2026-10-15 19:53:51'),(21,3,'住房','expense',NULL,5,'2026-10-15 19:53:51'),(22,3,'医疗','expense',NULL,6,'2026-10-15 19:53:51'),(23,3,'教育','expense',NULL,7,'2026-10-15 19:53:51'),(24,3,'通讯','expense',NULL,8,'2026-10-15 19:53:51'),(25,3,'服饰','expense',NULL,9,'2026-10-15 19:53:51'),(26,3,'人情','expense',NULL,10,'2026-10-15 19:53:51'),(27,3,'其他支出','expense',NULL,99,'2026-10-15 19:53:51'),(28,3,'工资','income',NULL,1,'2026-10-15 19:53:51'),(29,3,'奖金','income',NULL,2,'2026-10-15 19:53:51'),(30,3,'投资收益','income',NULL,3,'2026-10-15 19:53:51'),(31,3,'兼职收入','income',NULL,4,'2026-10-15 19:53:51'),(32,3,'其他收入','income',NULL,99,'2026-10-15 19:53:51'),(33,4,'餐饮','expense',NULL,1,'2026-10-15 19:53:51'),(34,4,'交通','expense',NULL,2,'2026-10-15 19:53:51'),(35,4,'购物','expense',NULL,3,'2026-10-15 19:53:51'),(36,4,'娱乐','expense',NULL,4,'2026-10-15 19:53:51'),(37,4,'住房','expense',NULL,5,'2026-10-15 19:53:51'),(38,4,'医疗','expense',NULL,6,'2026-10-15 19:53:51'),(39,4,'教育','expense',NULL,7,'2026-10-15 19:53:51'),(40,4,'通讯','expense',NULL,8,'2026-10-15 19:53:51'),(41,4,'服饰','expense',NULL,9,'2026-10-15 19:53:51'),(42,4,'人情','expense',NULL,10,'2026-10-15 19:53:51'),(43,4,'其他支出','expense',NULL,99,'2026-10-15 19:53:51'),(44,4,'工资','income',NULL,1,'2026-10-15 19:53:51'),(45,4,'奖金','income',NULL,2,'2026-10-15 19:53:51'),(46,4,'投资收益','income',NULL,3,'2026-10-15 19:53:51'),(47,4,'兼职收入','income',NULL,4,'2026-10-15 19:53:51'),(48,4,'其他收入','income',NULL,99,'2026-10-15 19:53:51');

/*Table structure for table `loan` */

DROP TABLE IF EXISTS `loan`;

CREATE TABLE `loan` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '借贷ID',
  `user_id` int NOT NULL COMMENT '所属用户ID',
  `TYPE` varchar(10) NOT NULL COMMENT '类型: borrow(借入)/lend(借出)',
  `person` varchar(50) NOT NULL COMMENT '对方姓名',
  `amount` decimal(12,2) NOT NULL COMMENT '金额',
  `loan_date` date NOT NULL COMMENT '借贷日期',
  `STATUS` varchar(10) DEFAULT 'unpaid' COMMENT '状态: unpaid(未还)/paid(已还)',
  `remark` varchar(200) DEFAULT NULL COMMENT '备注',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `account_id` int DEFAULT NULL COMMENT '关联账户ID',
  `linked_transaction_id` int DEFAULT NULL COMMENT '关联收支记录ID',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `idx_user_status` (`user_id`,`STATUS`),
  CONSTRAINT `loan_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `loan_ibfk_2` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='借贷表';

/*Data for the table `loan` */

insert  into `loan`(`id`,`user_id`,`TYPE`,`person`,`amount`,`loan_date`,`STATUS`,`remark`,`created_at`,`account_id`,`linked_transaction_id`) values (1,2,'lend','赵六','800.00','2026-06-12','unpaid','同学借款','2026-10-15 19:53:51',1,NULL),(2,2,'borrow','钱七','300.00','2026-06-08','paid','已还清','2026-10-15 19:53:51',2,NULL),(3,2,'lend','孙九','500.00','2026-06-18','unpaid','朋友借款','2026-10-15 19:53:51',1,NULL),(4,3,'lend','周十','500.00','2026-06-10','unpaid','朋友借款','2026-10-15 19:53:51',4,NULL),(5,3,'borrow','吴一','1000.00','2026-06-15','unpaid','临时周转','2026-10-15 19:53:51',4,NULL),(6,4,'lend','郑二','200.00','2026-06-05','paid','已还清','2026-10-15 19:53:51',7,NULL);

/*Table structure for table `system_config` */

DROP TABLE IF EXISTS `system_config`;

CREATE TABLE `system_config` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_key` varchar(50) NOT NULL COMMENT '配置键名',
  `config_value` varchar(200) DEFAULT NULL COMMENT '配置值',
  `description` varchar(100) DEFAULT NULL COMMENT '配置说明',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `config_key` (`config_key`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统设置表';

/*Data for the table `system_config` */

insert  into `system_config`(`id`,`config_key`,`config_value`,`description`,`updated_at`) values (1,'system_name','简易财富记账系统','系统名称','2026-10-15 19:53:51'),(2,'maintenance_mode','off','维护模式: on/off','2026-10-15 19:53:51');

/*Table structure for table `system_log` */

DROP TABLE IF EXISTS `system_log`;

CREATE TABLE `system_log` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `user_id` int DEFAULT NULL COMMENT '操作用户ID',
  `username` varchar(50) NOT NULL COMMENT '操作用户名',
  `ACTION` varchar(50) NOT NULL COMMENT '操作类型',
  `description` varchar(200) DEFAULT NULL COMMENT '操作描述',
  `ip` varchar(50) DEFAULT NULL COMMENT 'IP地址',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `system_log_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统日志表';

/*Data for the table `system_log` */

insert  into `system_log`(`id`,`user_id`,`username`,`ACTION`,`description`,`ip`,`created_at`) values (1,1,'admin','login','管理员登录系统','127.0.0.1','2026-10-15 19:53:51'),(2,2,'zhangsan','login','用户登录系统','127.0.0.1','2026-10-15 19:53:51'),(3,3,'lisi','login','用户登录系统','127.0.0.1','2026-10-15 19:53:51'),(4,1,'admin','addUser','新增用户 wangwu','127.0.0.1','2026-10-15 19:53:51'),(5,1,'admin','setAdmin','将用户 zhangsan 设为管理员','127.0.0.1','2026-10-15 19:53:51'),(6,2,'zhangsan','addTransaction','新增收支记录: 工资 6000.00','127.0.0.1','2026-10-15 19:53:51'),(7,2,'zhangsan','addTransaction','新增收支记录: 午餐 -35.00','127.0.0.1','2026-10-15 19:53:51'),(8,3,'lisi','addTransaction','新增收支记录: 工资 4500.00','127.0.0.1','2026-10-15 19:53:51'),(9,1,'admin','deleteUser','删除用户 zhaoliu','127.0.0.1','2026-10-15 19:53:51'),(10,2,'zhangsan','login','用户登录 (身份: user)','0:0:0:0:0:0:0:1','2026-10-15 19:54:58');

/*Table structure for table `transaction` */

DROP TABLE IF EXISTS `transaction`;

CREATE TABLE `transaction` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '流水ID',
  `user_id` int NOT NULL COMMENT '所属用户ID',
  `account_id` int NOT NULL COMMENT '关联账户ID',
  `category_id` int NOT NULL COMMENT '关联类别ID',
  `TYPE` varchar(10) NOT NULL COMMENT '收支类型: income/expense',
  `amount` decimal(12,2) NOT NULL COMMENT '金额',
  `trans_date` datetime NOT NULL COMMENT '交易日期',
  `remark` varchar(200) DEFAULT NULL COMMENT '备注',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `category_id` (`category_id`),
  KEY `idx_user_date` (`user_id`,`trans_date`),
  KEY `idx_user_type` (`user_id`,`TYPE`),
  CONSTRAINT `transaction_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
  CONSTRAINT `transaction_ibfk_2` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `transaction_ibfk_3` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='收支流水表';

/*Data for the table `transaction` */

insert  into `transaction`(`id`,`user_id`,`account_id`,`category_id`,`TYPE`,`amount`,`trans_date`,`remark`,`created_at`) values (1,2,1,16,'income','8000.00','2026-06-01 00:00:00','账户初始余额','2026-10-15 19:53:51'),(2,2,2,16,'income','1500.00','2026-06-01 00:00:00','账户初始余额','2026-10-15 19:53:51'),(3,2,3,16,'income','800.00','2026-06-01 00:00:00','账户初始余额','2026-10-15 19:53:51'),(4,3,4,32,'income','5000.00','2026-06-01 00:00:00','账户初始余额','2026-10-15 19:53:51'),(5,3,5,32,'income','2000.00','2026-06-01 00:00:00','账户初始余额','2026-10-15 19:53:51'),(6,3,6,32,'income','800.00','2026-06-01 00:00:00','账户初始余额','2026-10-15 19:53:51'),(7,4,7,48,'income','3000.00','2026-06-01 00:00:00','账户初始余额','2026-10-15 19:53:51'),(8,4,8,48,'income','800.00','2026-06-01 00:00:00','账户初始余额','2026-10-15 19:53:51'),(9,2,1,12,'income','6000.00','2026-06-01 09:00:00','6月工资','2026-10-15 19:53:51'),(10,2,1,13,'income','1000.00','2026-06-10 10:00:00','项目奖金','2026-10-15 19:53:51'),(11,2,1,4,'expense','88.00','2026-06-08 19:00:00','看电影','2026-10-15 19:53:51'),(12,2,1,4,'expense','56.00','2026-06-12 20:00:00','游戏充值','2026-10-15 19:53:51'),(13,2,2,1,'expense','35.00','2026-06-02 12:30:00','午餐','2026-10-15 19:53:51'),(14,2,2,1,'expense','42.00','2026-06-05 18:00:00','晚餐','2026-10-15 19:53:51'),(15,2,2,2,'expense','8.00','2026-06-03 08:00:00','公交','2026-10-15 19:53:51'),(16,2,2,2,'expense','15.00','2026-06-07 08:30:00','地铁','2026-10-15 19:53:51'),(17,2,2,8,'expense','30.00','2026-06-10 09:00:00','话费充值','2026-10-15 19:53:51'),(18,2,2,8,'expense','50.00','2026-06-18 09:00:00','宽带续费','2026-10-15 19:53:51'),(19,2,3,3,'expense','199.00','2026-06-06 15:00:00','网购商品','2026-10-15 19:53:51'),(20,2,3,3,'expense','268.00','2026-06-14 20:00:00','超市购物','2026-10-15 19:53:51'),(21,3,4,28,'income','4500.00','2026-06-01 09:00:00','6月工资','2026-10-15 19:53:51'),(22,3,4,31,'income','300.00','2026-06-05 18:00:00','兼职收入','2026-10-15 19:53:51'),(23,3,4,21,'expense','1200.00','2026-06-15 10:00:00','房租','2026-10-15 19:53:51'),(24,3,5,17,'expense','45.00','2026-06-02 12:30:00','午餐','2026-10-15 19:53:51'),(25,3,5,17,'expense','38.00','2026-06-06 18:00:00','晚餐','2026-10-15 19:53:51'),(26,3,5,18,'expense','12.00','2026-06-03 08:00:00','地铁','2026-10-15 19:53:51'),(27,3,5,19,'expense','156.00','2026-06-07 20:00:00','日用品','2026-10-15 19:53:51'),(28,3,5,20,'expense','120.00','2026-06-09 19:00:00','音乐会','2026-10-15 19:53:51'),(29,4,7,44,'income','3500.00','2026-06-01 09:00:00','6月工资','2026-10-15 19:53:51'),(30,4,7,45,'income','500.00','2026-06-10 10:00:00','绩效奖金','2026-10-15 19:53:51'),(31,4,8,33,'expense','28.00','2026-06-02 12:30:00','午餐','2026-10-15 19:53:51'),(32,4,8,34,'expense','10.00','2026-06-03 08:00:00','公交','2026-10-15 19:53:51'),(33,4,8,40,'expense','30.00','2026-06-05 09:00:00','话费充值','2026-10-15 19:53:51'),(34,2,1,12,'income','6200.00','2026-07-01 09:00:00','7月基本工资','2026-10-15 19:53:51'),(35,2,1,14,'income','450.00','2026-07-12 14:20:00','基金理财收益','2026-10-15 19:53:51'),(36,2,3,16,'income','3000.00','2026-07-02 10:00:00','线下现金红包收入','2026-10-15 19:53:51'),(37,2,1,5,'expense','1300.00','2026-07-05 10:10:00','7月房租','2026-10-15 19:53:51'),(38,2,1,6,'expense','268.00','2026-07-08 16:30:00','感冒买药','2026-10-15 19:53:51'),(39,2,3,10,'expense','300.00','2026-07-14 11:00:00','朋友生日红包','2026-10-15 19:53:51'),(40,2,3,3,'expense','135.00','2026-07-22 17:20:00','超市零食水果','2026-10-15 19:53:51'),(41,3,4,28,'income','6000.00','2026-07-01 09:00:00','7月工资','2026-10-15 19:53:51'),(42,3,4,29,'income','2600.00','2026-07-01 09:00:00','7月奖金','2026-10-15 19:53:51'),(43,3,4,31,'income','420.00','2026-07-18 17:00:00','周末兼职稿费','2026-10-15 19:53:51'),(44,3,4,21,'expense','1200.00','2026-07-03 09:40:00','月度房租','2026-10-15 19:53:51'),(45,3,4,23,'expense','360.00','2026-07-09 15:10:00','线上课程续费','2026-10-15 19:53:51'),(46,3,5,17,'expense','32.00','2026-07-03 12:10:00','快餐午餐','2026-10-15 19:53:51'),(47,3,5,19,'expense','245.00','2026-07-11 21:00:00','家居日用品','2026-10-15 19:53:51'),(48,3,5,24,'expense','59.00','2026-07-06 10:20:00','手机话费套餐','2026-10-15 19:53:51'),(49,3,5,22,'expense','86.00','2026-07-25 14:30:00','体检开药','2026-10-15 19:53:51'),(50,3,6,18,'expense','35.00','2026-07-12 08:30:00','公交地铁充值','2026-10-15 19:53:51'),(51,4,7,44,'income','3600.00','2026-07-01 09:00:00','7月薪资','2026-10-15 19:53:51'),(52,4,7,48,'income','200.00','2026-07-21 16:00:00','闲置物品卖出','2026-10-15 19:53:51'),(53,4,7,37,'expense','950.00','2026-07-04 10:00:00','合租房租分摊','2026-10-15 19:53:51'),(54,4,7,42,'expense','200.00','2026-07-16 12:00:00','同事随礼','2026-10-15 19:53:51'),(55,4,8,33,'expense','33.00','2026-07-05 12:30:00','外卖盖饭','2026-10-15 19:53:51'),(56,4,8,36,'expense','65.00','2026-07-13 19:20:00','网吧充值','2026-10-15 19:53:51'),(57,4,8,34,'expense','16.00','2026-07-08 08:00:00','公交出行','2026-10-15 19:53:51'),(58,4,8,43,'expense','48.00','2026-07-28 17:00:00','饮用水零食','2026-10-15 19:53:51');

/*Table structure for table `user` */

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `PASSWORD` varchar(100) NOT NULL COMMENT '密码(MD5加密)',
  `email` varchar(100) DEFAULT NULL COMMENT '电子邮箱',
  `role` varchar(20) DEFAULT 'user' COMMENT '角色: admin(管理员)/user(普通用户)',
  `STATUS` varchar(10) DEFAULT 'active' COMMENT '状态: active(正常)/locked(锁定)',
  `reg_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';

/*Data for the table `user` */

insert  into `user`(`id`,`username`,`PASSWORD`,`email`,`role`,`STATUS`,`reg_time`) values (1,'admin','E10ADC3949BA59ABBE56E057F20F883E','admin@finance.com','admin','active','2026-10-15 19:53:51'),(2,'zhangsan','E10ADC3949BA59ABBE56E057F20F883E','zhangsan@test.com','user','active','2026-10-15 19:53:51'),(3,'lisi','E10ADC3949BA59ABBE56E057F20F883E','lisi@test.com','user','active','2026-10-15 19:53:51'),(4,'wangwu','E10ADC3949BA59ABBE56E057F20F883E','wangwu@test.com','user','active','2026-10-15 19:53:51'),(5,'zhaoliu','E10ADC3949BA59ABBE56E057F20F883E','zhaoliu@test.com','user','active','2026-10-15 19:53:51'),(6,'sunqi','E10ADC3949BA59ABBE56E057F20F883E','sunqi@test.com','user','active','2026-10-15 19:53:51'),(7,'zhouba','E10ADC3949BA59ABBE56E057F20F883E','zhouba@test.com','user','active','2026-10-15 19:53:51');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

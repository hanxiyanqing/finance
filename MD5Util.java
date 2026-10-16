package util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class MD5Util {
    public static String md5(String str) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] digest = md.digest(str.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02X", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return str;
        } catch (Exception e) {
            e.printStackTrace();
            return str;
        }
    }

    // 测试方法
    public static void main(String[] args) {
        System.out.println("123456 -> " + md5("123456"));
        // 输出: 123456 -> E10ADC3949BA59ABBE56E057F20F883E
    }
}
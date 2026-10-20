package com.m01profile;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import pub.ConnDB;
import com.m01user.UserBean;

public class ProfileDAO {
    
    /**
     * 根据用户名获取用户信息（专门为个人设置优化的方法）
     */
    public UserBean getUserProfile(String username) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            // 专门查询电话和邮箱字段
            String sql = "SELECT phone, email, roleID, fusername, fpassword, role, status FROM user WHERE fusername = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                UserBean user = new UserBean();
                user.setPhone(rs.getString("phone"));
                user.setEmail(rs.getString("email"));
                user.setRoleID(rs.getString("roleID"));
                user.setFusername(rs.getString("fusername"));
                user.setFpassword(rs.getString("fpassword"));
                user.setRole(rs.getString("role"));
                user.setStatus(rs.getString("status"));
                return user;
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("获取用户信息失败: " + e.getMessage());
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return null;
    }
    
    /**
     * 获取用户的电话和邮箱（简化版）
     */
    public String[] getUserContactInfo(String username) {
        String[] contactInfo = new String[2]; // [0] = phone, [1] = email
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "SELECT phone, email FROM user WHERE fusername = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                contactInfo[0] = rs.getString("phone");
                contactInfo[1] = rs.getString("email");
                
                // 确保不为null
                if (contactInfo[0] == null) contactInfo[0] = "";
                if (contactInfo[1] == null) contactInfo[1] = "";
                
                System.out.println("ProfileDAO获取到联系信息: phone=" + contactInfo[0] + ", email=" + contactInfo[1]);
            } else {
                System.out.println("ProfileDAO未找到用户: " + username);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return contactInfo;
    }
    
    /**
     * 更新用户信息（与UserDAO方法一致，但放在ProfileDAO中）
     */
    public boolean updateUserProfile(String username, String password, String phone, String email) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = ConnDB.getConnection();
            
            String sql;
            if (password != null && !password.trim().isEmpty()) {
                // 更新密码、电话、邮箱
                sql = "UPDATE user SET fpassword = ?, phone = ?, email = ? WHERE fusername = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, password.trim());
                pstmt.setString(2, phone != null ? phone.trim() : "");
                pstmt.setString(3, email != null ? email.trim() : "");
                pstmt.setString(4, username);
            } else {
                // 只更新电话、邮箱
                sql = "UPDATE user SET phone = ?, email = ? WHERE fusername = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, phone != null ? phone.trim() : "");
                pstmt.setString(2, email != null ? email.trim() : "");
                pstmt.setString(3, username);
            }
            
            int result = pstmt.executeUpdate();
            System.out.println("ProfileDAO更新用户信息结果: " + (result > 0 ? "成功" : "失败"));
            return result > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }
}
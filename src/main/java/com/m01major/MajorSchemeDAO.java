package com.m01major;

import pub.ConnDB;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class MajorSchemeDAO {
    
    // 1. 查询所有培养方案（按专业）
    public List<MajorSchemeBean> queryAllMajorScheme() {
        List<MajorSchemeBean> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String sql = "SELECT schemeId, collegeId, collegeName, majorId, majorName, uploadTime " +
                     "FROM majorScheme ORDER BY collegeName, majorName";
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                MajorSchemeBean bean = new MajorSchemeBean();
                bean.setSchemeId(rs.getString("schemeId"));
                bean.setCollegeId(rs.getString("collegeId"));
                bean.setCollegeName(rs.getString("collegeName"));
                bean.setMajorId(rs.getString("majorId"));
                bean.setMajorName(rs.getString("majorName"));
                bean.setUploadTime(rs.getTimestamp("uploadTime"));
                list.add(bean);
            }
        } catch (Exception e) {
            System.out.println("查询培养方案失败：" + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return list;
    }
    
    // 2. 根据条件查询培养方案
    public List<MajorSchemeBean> queryByConditions(String majorName, String collegeName) {
        List<MajorSchemeBean> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        StringBuilder sql = new StringBuilder(
            "SELECT schemeId, collegeId, collegeName, majorId, majorName, uploadTime " +
            "FROM majorScheme WHERE 1=1"
        );
        
        List<Object> params = new ArrayList<>();
        
        if (majorName != null && !majorName.trim().isEmpty()) {
            sql.append(" AND majorName LIKE ?");
            params.add("%" + majorName.trim() + "%");
        }
        
        if (collegeName != null && !collegeName.trim().isEmpty()) {
            sql.append(" AND collegeName LIKE ?");
            params.add("%" + collegeName.trim() + "%");
        }
        
        sql.append(" ORDER BY collegeName, majorName");
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            
            // 设置参数
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                MajorSchemeBean bean = new MajorSchemeBean();
                bean.setSchemeId(rs.getString("schemeId"));
                bean.setCollegeId(rs.getString("collegeId"));
                bean.setCollegeName(rs.getString("collegeName"));
                bean.setMajorId(rs.getString("majorId"));
                bean.setMajorName(rs.getString("majorName"));
                bean.setUploadTime(rs.getTimestamp("uploadTime"));
                list.add(bean);
            }
        } catch (Exception e) {
            System.out.println("条件查询培养方案失败：" + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return list;
    }
    
    // 辅助方法：生成5位随机数字ID（10000-99999）
    private String generateFiveDigitId() {
        Random random = new Random();
        return String.valueOf(random.nextInt(90000) + 10000);
    }
        
        // 3. 新增培养方案记录（修复版本）
    public boolean addMajorScheme(MajorSchemeBean bean) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        String sql = "INSERT INTO majorScheme (schemeId, collegeId, collegeName, majorId, majorName) " +
                     "VALUES (?, ?, ?, ?, ?)";
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            
            // 1. 生成学院ID（5位数字）
            String collegeId = generateFiveDigitId();
            bean.setCollegeId(collegeId);
            
            // 2. 生成专业ID（5位数字）
            String majorId = generateFiveDigitId();
            bean.setMajorId(majorId);
            
            // 3. 生成培养方案ID（专业ID + 时间戳） - 修复拼接错误
            String schemeId = "SCHEME_" + bean.getMajorId() + "_" + 
                            new java.text.SimpleDateFormat("yyyyMMdd").format(new java.util.Date());
            bean.setSchemeId(schemeId);
            
            pstmt.setString(1, bean.getSchemeId());
            pstmt.setString(2, bean.getCollegeId());
            pstmt.setString(3, bean.getCollegeName());
            pstmt.setString(4, bean.getMajorId());
            pstmt.setString(5, bean.getMajorName());
            
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("新增培养方案失败：" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

 // 4. 删除培养方案记录
    public boolean deleteMajorScheme(String majorName) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        String sql = "DELETE FROM majorScheme WHERE majorName = ?";
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, majorName);
            
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("删除培养方案失败：" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    // 5. 检查专业是否已有培养方案
    public boolean hasSchemeForMajor(String majorId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String sql = "SELECT COUNT(*) as count FROM majorScheme WHERE majorId = ?";
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, majorId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (Exception e) {
            System.out.println("检查培养方案失败：" + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return false;
    }
    
 // 6. 根据专业名称检查是否已有培养方案
    public boolean hasSchemeForMajorByMajorName(String majorName) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String sql = "SELECT COUNT(*) as count FROM majorScheme WHERE majorName = ?";
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, majorName);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (Exception e) {
            System.out.println("检查培养方案失败：" + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return false;
    }
    
 // 在 MajorSchemeDAO 类中添加以下分页方法

 // 分页查询培养方案
 public List<MajorSchemeBean> queryMajorSchemesByPage(String majorName, String collegeName, 
                                                     int pageNum, int pageSize) {
     List<MajorSchemeBean> list = new ArrayList<>();
     
     StringBuilder sql = new StringBuilder(
         "SELECT schemeId, collegeId, collegeName, majorId, majorName, uploadTime " +
         "FROM majorScheme WHERE 1=1"
     );
     
     List<Object> params = new ArrayList<>();
     
     if (majorName != null && !majorName.trim().isEmpty()) {
         sql.append(" AND majorName LIKE ?");
         params.add("%" + majorName.trim() + "%");
     }
     
     if (collegeName != null && !collegeName.trim().isEmpty()) {
         sql.append(" AND collegeName LIKE ?");
         params.add("%" + collegeName.trim() + "%");
     }
     
     sql.append(" ORDER BY collegeName, majorName LIMIT ?, ?");
     
     Connection conn = null;
     PreparedStatement pstmt = null;
     ResultSet rs = null;
     
     try {
         conn = ConnDB.getConnection();
         pstmt = conn.prepareStatement(sql.toString());
         
         // 设置查询参数
         for (int i = 0; i < params.size(); i++) {
             pstmt.setObject(i + 1, params.get(i));
         }
         
         // 计算起始位置
         int start = (pageNum - 1) * pageSize;
         pstmt.setInt(params.size() + 1, start);
         pstmt.setInt(params.size() + 2, pageSize);
         
         rs = pstmt.executeQuery();
         
         while (rs.next()) {
             MajorSchemeBean bean = new MajorSchemeBean();
             bean.setSchemeId(rs.getString("schemeId"));
             bean.setCollegeId(rs.getString("collegeId"));
             bean.setCollegeName(rs.getString("collegeName"));
             bean.setMajorId(rs.getString("majorId"));
             bean.setMajorName(rs.getString("majorName"));
             bean.setUploadTime(rs.getTimestamp("uploadTime"));
             list.add(bean);
         }
     } catch (Exception e) {
         System.out.println("分页查询培养方案失败：" + e.getMessage());
         e.printStackTrace();
     } finally {
         try {
             if (rs != null) rs.close();
             if (pstmt != null) pstmt.close();
             if (conn != null) conn.close();
         } catch (SQLException e) {
             e.printStackTrace();
         }
     }
     return list;
 }

 // 获取总记录数
 public int getTotalCount(String majorName, String collegeName) {
     int total = 0;
     
     StringBuilder sql = new StringBuilder(
         "SELECT COUNT(*) FROM majorScheme WHERE 1=1"
     );
     
     List<Object> params = new ArrayList<>();
     
     if (majorName != null && !majorName.trim().isEmpty()) {
         sql.append(" AND majorName LIKE ?");
         params.add("%" + majorName.trim() + "%");
     }
     
     if (collegeName != null && !collegeName.trim().isEmpty()) {
         sql.append(" AND collegeName LIKE ?");
         params.add("%" + collegeName.trim() + "%");
     }
     
     Connection conn = null;
     PreparedStatement pstmt = null;
     ResultSet rs = null;
     
     try {
         conn = ConnDB.getConnection();
         pstmt = conn.prepareStatement(sql.toString());
         
         // 设置查询参数
         for (int i = 0; i < params.size(); i++) {
             pstmt.setObject(i + 1, params.get(i));
         }
         
         rs = pstmt.executeQuery();
         if (rs.next()) {
             total = rs.getInt(1);
         }
     } catch (Exception e) {
         System.out.println("获取培养方案总数失败：" + e.getMessage());
         e.printStackTrace();
     } finally {
         try {
             if (rs != null) rs.close();
             if (pstmt != null) pstmt.close();
             if (conn != null) conn.close();
         } catch (SQLException e) {
             e.printStackTrace();
         }
     }
     return total;
 }
}
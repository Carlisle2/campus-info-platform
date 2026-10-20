package com.m01major;

import java.sql.*;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;
import pub.ConnDB;

public class MajorDAO {
    
    // 生成4位随机专业编号
    private String generateMajorId() {
        return String.format("%04d", ThreadLocalRandom.current().nextInt(1000, 10000));
    }
    
    // 检查专业编号是否已存在
    private boolean isMajorIdExists(String majorId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM major WHERE major_id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, majorId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
    
    // 生成唯一的专业编号
    public String generateUniqueMajorId() throws SQLException {
        String majorId;
        int attempts = 0;
        do {
            majorId = generateMajorId();
            attempts++;
            if (attempts > 100) {
                throw new RuntimeException("无法生成唯一专业编号");
            }
        } while (isMajorIdExists(majorId));
        return majorId;
    }
    
    // 查询专业列表（支持模糊查询）
    public List<MajorBean> queryMajors(String majorId, String majorName) {
        List<MajorBean> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM major WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        if (majorId != null && !majorId.trim().isEmpty()) {
            sql.append(" AND major_id LIKE ?");
            params.add("%" + majorId.trim() + "%");
        }
        
        if (majorName != null && !majorName.trim().isEmpty()) {
            sql.append(" AND major_name LIKE ?");
            params.add("%" + majorName.trim() + "%");
        }
        
        sql.append(" ORDER BY major_id");
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            
            rs = pstmt.executeQuery();
            while (rs.next()) {
                MajorBean bean = new MajorBean();
                bean.setMajorId(rs.getString("major_id"));
                bean.setMajorName(rs.getString("major_name"));
                list.add(bean);
            }
        } catch (SQLException e) {
            System.out.println("查询专业信息失败：" + e.getMessage());
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
    
    // 新增专业
    public boolean addMajor(MajorBean bean) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            // 如果bean中没有专业编号，自动生成
            if (bean.getMajorId() == null || bean.getMajorId().isEmpty()) {
                String majorId = generateUniqueMajorId();
                bean.setMajorId(majorId);
            }
            
            String sql = "INSERT INTO major (major_id, major_name) VALUES (?, ?)";
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            
            pstmt.setString(1, bean.getMajorId());
            pstmt.setString(2, bean.getMajorName());
            
            int result = pstmt.executeUpdate();
            System.out.println("新增专业成功，专业编号：" + bean.getMajorId());
            return result > 0;
        } catch (SQLException e) {
            System.out.println("新增专业失败：" + e.getMessage());
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
    
    // 修改专业
    public boolean updateMajor(MajorBean bean) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "UPDATE major SET major_name = ? WHERE major_id = ?";
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            
            pstmt.setString(1, bean.getMajorName());
            pstmt.setString(2, bean.getMajorId());
            
            int result = pstmt.executeUpdate();
            System.out.println("修改专业成功，专业编号：" + bean.getMajorId());
            return result > 0;
        } catch (SQLException e) {
            System.out.println("修改专业失败：" + e.getMessage());
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
    
    // 删除专业
    public boolean deleteMajor(String majorId) {
        Connection conn = null;
        PreparedStatement checkPstmt = null;
        PreparedStatement deletePstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            
            // 先检查是否有学生关联
            String checkSql = "SELECT COUNT(*) FROM student WHERE major_id = ?";
            checkPstmt = conn.prepareStatement(checkSql);
            checkPstmt.setString(1, majorId);
            rs = checkPstmt.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                // 还有学生关联，不能删除
                System.out.println("删除专业失败：专业 " + majorId + " 还有学生关联");
                return false;
            }
            
            // 删除专业
            String deleteSql = "DELETE FROM major WHERE major_id = ?";
            deletePstmt = conn.prepareStatement(deleteSql);
            deletePstmt.setString(1, majorId);
            
            int result = deletePstmt.executeUpdate();
            System.out.println("删除专业成功，专业编号：" + majorId);
            return result > 0;
            
        } catch (SQLException e) {
            System.out.println("删除专业失败：" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (rs != null) rs.close();
                if (checkPstmt != null) checkPstmt.close();
                if (deletePstmt != null) deletePstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    // 根据ID获取专业
    public MajorBean getMajorById(String majorId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM major WHERE major_id = ?";
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, majorId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                MajorBean bean = new MajorBean();
                bean.setMajorId(rs.getString("major_id"));
                bean.setMajorName(rs.getString("major_name"));
                return bean;
            }
        } catch (SQLException e) {
            System.out.println("按ID查询专业失败：" + e.getMessage());
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
        return null;
    }
    
    // 根据专业名称获取专业
    public MajorBean getMajorByName(String majorName) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM major WHERE major_name = ?";
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, majorName);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                MajorBean bean = new MajorBean();
                bean.setMajorId(rs.getString("major_id"));
                bean.setMajorName(rs.getString("major_name"));
                return bean;
            }
        } catch (SQLException e) {
            System.out.println("按名称查询专业失败：" + e.getMessage());
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
        return null;
    }
    
    // 获取所有专业（用于下拉框）
    public List<MajorBean> getAllMajors() {
        List<MajorBean> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM major ORDER BY major_name";
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                MajorBean bean = new MajorBean();
                bean.setMajorId(rs.getString("major_id"));
                bean.setMajorName(rs.getString("major_name"));
                list.add(bean);
            }
        } catch (SQLException e) {
            System.out.println("获取所有专业失败：" + e.getMessage());
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
    
 // 在 MajorDAO 类中添加以下方法

 // 分页查询专业
 public List<MajorBean> queryMajorsByPage(String majorId, String majorName, 
                                         int pageNum, int pageSize) {
     List<MajorBean> list = new ArrayList<>();
     StringBuilder sql = new StringBuilder("SELECT * FROM major WHERE 1=1");
     List<Object> params = new ArrayList<>();
     
     if (majorId != null && !majorId.trim().isEmpty()) {
         sql.append(" AND major_id LIKE ?");
         params.add("%" + majorId.trim() + "%");
     }
     
     if (majorName != null && !majorName.trim().isEmpty()) {
         sql.append(" AND major_name LIKE ?");
         params.add("%" + majorName.trim() + "%");
     }
     
     sql.append(" ORDER BY major_id LIMIT ?, ?");
     
     Connection conn = null;
     PreparedStatement pstmt = null;
     ResultSet rs = null;
     
     try {
         conn = ConnDB.getConnection();
         pstmt = conn.prepareStatement(sql.toString());
         
         for (int i = 0; i < params.size(); i++) {
             pstmt.setObject(i + 1, params.get(i));
         }
         
         // 计算起始位置
         int start = (pageNum - 1) * pageSize;
         pstmt.setInt(params.size() + 1, start);
         pstmt.setInt(params.size() + 2, pageSize);
         
         rs = pstmt.executeQuery();
         while (rs.next()) {
             MajorBean bean = new MajorBean();
             bean.setMajorId(rs.getString("major_id"));
             bean.setMajorName(rs.getString("major_name"));
             list.add(bean);
         }
     } catch (SQLException e) {
         System.out.println("分页查询专业信息失败：" + e.getMessage());
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
 public int getTotalCount(String majorId, String majorName) {
     int total = 0;
     StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM major WHERE 1=1");
     List<Object> params = new ArrayList<>();
     
     if (majorId != null && !majorId.trim().isEmpty()) {
         sql.append(" AND major_id LIKE ?");
         params.add("%" + majorId.trim() + "%");
     }
     
     if (majorName != null && !majorName.trim().isEmpty()) {
         sql.append(" AND major_name LIKE ?");
         params.add("%" + majorName.trim() + "%");
     }
     
     Connection conn = null;
     PreparedStatement pstmt = null;
     ResultSet rs = null;
     
     try {
         conn = ConnDB.getConnection();
         pstmt = conn.prepareStatement(sql.toString());
         
         for (int i = 0; i < params.size(); i++) {
             pstmt.setObject(i + 1, params.get(i));
         }
         
         rs = pstmt.executeQuery();
         if (rs.next()) {
             total = rs.getInt(1);
         }
     } catch (SQLException e) {
         System.out.println("获取专业总数失败：" + e.getMessage());
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
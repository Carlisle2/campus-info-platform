package com.m01student;

import java.sql.*;
import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

import com.m01major.MajorBean;
import com.m01major.MajorDAO;

import pub.ConnDB;

public class StudentDAO {
    
    // 生成6位随机学号
    private String generateStudentId() {
        return String.format("%06d", ThreadLocalRandom.current().nextInt(100000, 1000000));
    }
    
    // 检查学号是否已存在
    private boolean isStudentIdExists(String studentId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM student WHERE student_id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
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
    
    // 生成唯一的学号
    public String generateUniqueStudentId() throws SQLException {
        String studentId;
        int attempts = 0;
        do {
            studentId = generateStudentId();
            attempts++;
            if (attempts > 100) {
                throw new RuntimeException("无法生成唯一学号");
            }
        } while (isStudentIdExists(studentId));
        return studentId;
    }
    
    // 检查专业是否存在
    private boolean isMajorExists(String majorName) throws SQLException {
        String sql = "SELECT COUNT(*) FROM major WHERE major_name = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, majorName);
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
    
    // 获取专业ID
    private String getMajorId(String majorName) throws SQLException {
        String sql = "SELECT major_id FROM major WHERE major_name = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, majorName);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getString("major_id");
            }
            return null;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
    
    // 查询学生列表（支持模糊查询）
    public List<StudentBean> queryStudents(String studentId, String studentName, String majorName) {
        List<StudentBean> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT s.*, m.major_name FROM student s " +
            "LEFT JOIN major m ON s.major_id = m.major_id WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        
        if (studentId != null && !studentId.trim().isEmpty()) {
            sql.append(" AND s.student_id LIKE ?");
            params.add("%" + studentId.trim() + "%");
        }
        
        if (studentName != null && !studentName.trim().isEmpty()) {
            sql.append(" AND s.student_name LIKE ?");
            params.add("%" + studentName.trim() + "%");
        }
        
        if (majorName != null && !majorName.trim().isEmpty()) {
            sql.append(" AND m.major_name LIKE ?");
            params.add("%" + majorName.trim() + "%");
        }
        
        sql.append(" ORDER BY s.student_id");
        
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
                StudentBean bean = new StudentBean();
                bean.setStudentId(rs.getString("student_id"));
                bean.setStudentName(rs.getString("student_name"));
                bean.setGender(rs.getString("gender"));
                bean.setMajorId(rs.getString("major_id"));
                bean.setMajorName(rs.getString("major_name"));
                bean.setRemark(rs.getString("remark"));
                list.add(bean);
            }
        } catch (SQLException e) {
            System.out.println("查询学生信息失败：" + e.getMessage());
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
    
    // 新增学生
    public boolean addStudent(StudentBean bean) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = ConnDB.getConnection();
            conn.setAutoCommit(false);
            
            // 1. 检查专业是否存在，不存在则新增
            String majorId = bean.getMajorId();
            String majorName = bean.getMajorName();
            
            if ((majorId == null || majorId.isEmpty()) && majorName != null && !majorName.isEmpty()) {
                if (!isMajorExists(majorName)) {
                    MajorDAO majorDao = new MajorDAO();
                    MajorBean majorBean = new MajorBean();
                    majorBean.setMajorName(majorName);
                    // 专业编号由MajorDAO自动生成
                    if (!majorDao.addMajor(majorBean)) {
                        conn.rollback();
                        return false;
                    }
                }
                // 获取专业ID
                majorId = getMajorId(majorName);
                if (majorId == null) {
                    conn.rollback();
                    return false;
                }
                bean.setMajorId(majorId);
            }
            
            // 2. 生成学号并新增学生
            String studentId = generateUniqueStudentId();
            bean.setStudentId(studentId);
            
            String sql = "INSERT INTO student (student_id, student_name, gender, major_id, remark) VALUES (?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
            pstmt.setString(2, bean.getStudentName());
            pstmt.setString(3, bean.getGender());
            pstmt.setString(4, majorId);
            pstmt.setString(5, bean.getRemark());
            
            int result = pstmt.executeUpdate();
            conn.commit();
            System.out.println("新增学生成功，学号：" + studentId);
            return result > 0;
            
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                System.out.println("回滚失败：" + ex.getMessage());
                ex.printStackTrace();
            }
            System.out.println("新增学生失败：" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    // 修改学生
    public boolean updateStudent(StudentBean bean) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "UPDATE student SET student_name=?, gender=?, major_id=?, remark=? WHERE student_id=?";
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, bean.getStudentName());
            pstmt.setString(2, bean.getGender());
            pstmt.setString(3, bean.getMajorId());
            pstmt.setString(4, bean.getRemark());
            pstmt.setString(5, bean.getStudentId());
            
            int result = pstmt.executeUpdate();
            System.out.println("修改学生成功，学号：" + bean.getStudentId());
            return result > 0;
        } catch (SQLException e) {
            System.out.println("修改学生失败：" + e.getMessage());
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
    
    // 删除学生
    public boolean deleteStudent(String studentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = ConnDB.getConnection();
            String sql = "DELETE FROM student WHERE student_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
            
            int result = pstmt.executeUpdate();
            System.out.println("删除学生成功，学号：" + studentId);
            return result > 0;
            
        } catch (SQLException e) {
            System.out.println("删除学生失败：" + e.getMessage());
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
    
    // 根据ID获取学生
    public StudentBean getStudentById(String studentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT s.*, m.major_name FROM student s " +
                    "LEFT JOIN major m ON s.major_id = m.major_id " +
                    "WHERE s.student_id = ?";
        
        try {
            conn = ConnDB.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                StudentBean bean = new StudentBean();
                bean.setStudentId(rs.getString("student_id"));
                bean.setStudentName(rs.getString("student_name"));
                bean.setGender(rs.getString("gender"));
                bean.setMajorId(rs.getString("major_id"));
                bean.setMajorName(rs.getString("major_name"));
                bean.setRemark(rs.getString("remark"));
                return bean;
            }
        } catch (SQLException e) {
            System.out.println("按ID查询学生失败：" + e.getMessage());
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
    
 // 在StudentDAO类中添加以下方法

 // 分页查询学生
 public List<StudentBean> queryStudentsByPage(String studentId, String studentName, String majorName, 
                                             int pageNum, int pageSize) {
     List<StudentBean> list = new ArrayList<>();
     StringBuilder sql = new StringBuilder(
         "SELECT s.*, m.major_name FROM student s " +
         "LEFT JOIN major m ON s.major_id = m.major_id WHERE 1=1"
     );
     List<Object> params = new ArrayList<>();
     
     if (studentId != null && !studentId.trim().isEmpty()) {
         sql.append(" AND s.student_id LIKE ?");
         params.add("%" + studentId.trim() + "%");
     }
     
     if (studentName != null && !studentName.trim().isEmpty()) {
         sql.append(" AND s.student_name LIKE ?");
         params.add("%" + studentName.trim() + "%");
     }
     
     if (majorName != null && !majorName.trim().isEmpty()) {
         sql.append(" AND m.major_name LIKE ?");
         params.add("%" + majorName.trim() + "%");
     }
     
     sql.append(" ORDER BY s.student_id LIMIT ?, ?");
     
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
             StudentBean bean = new StudentBean();
             bean.setStudentId(rs.getString("student_id"));
             bean.setStudentName(rs.getString("student_name"));
             bean.setGender(rs.getString("gender"));
             bean.setMajorId(rs.getString("major_id"));
             bean.setMajorName(rs.getString("major_name"));
             bean.setRemark(rs.getString("remark"));
             list.add(bean);
         }
     } catch (SQLException e) {
         System.out.println("分页查询学生信息失败：" + e.getMessage());
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
 public int getTotalCount(String studentId, String studentName, String majorName) {
     int total = 0;
     StringBuilder sql = new StringBuilder(
         "SELECT COUNT(*) FROM student s " +
         "LEFT JOIN major m ON s.major_id = m.major_id WHERE 1=1"
     );
     List<Object> params = new ArrayList<>();
     
     if (studentId != null && !studentId.trim().isEmpty()) {
         sql.append(" AND s.student_id LIKE ?");
         params.add("%" + studentId.trim() + "%");
     }
     
     if (studentName != null && !studentName.trim().isEmpty()) {
         sql.append(" AND s.student_name LIKE ?");
         params.add("%" + studentName.trim() + "%");
     }
     
     if (majorName != null && !majorName.trim().isEmpty()) {
         sql.append(" AND m.major_name LIKE ?");
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
         System.out.println("获取学生总数失败：" + e.getMessage());
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
package com.m01major;

import java.util.Date;

public class MajorSchemeBean {
    // 核心字段
    private String schemeId;     // 培养方案ID
    private String collegeId;    // 学院ID
    private String collegeName;  // 学院名称
    private String majorId;      // 专业ID
    private String majorName;    // 专业名称
    private Date uploadTime;     // 上传时间
    
    // 空参构造  
    public MajorSchemeBean() {}
    
    // 全参构造
    public MajorSchemeBean(String schemeId, String collegeId, String collegeName, 
                          String majorId, String majorName, Date uploadTime) {
        this.schemeId = schemeId;
        this.collegeId = collegeId;
        this.collegeName = collegeName;
        this.majorId = majorId;
        this.majorName = majorName;
        this.uploadTime = uploadTime;
    }
    
    // 简化构造（用于新增）
    public MajorSchemeBean(String schemeId, String collegeName, String majorName) {
        this.schemeId = schemeId;
        this.collegeName = collegeName;
        this.majorName = majorName;
        this.uploadTime = new Date();
    }
    
    // Getter & Setter
    public String getSchemeId() {
        return schemeId;
    }
    
    public void setSchemeId(String schemeId) {
        this.schemeId = schemeId;
    }
    
    public String getCollegeId() {
        return collegeId;
    }
    
    public void setCollegeId(String collegeId) {
        this.collegeId = collegeId;
    }
    
    public String getCollegeName() {
        return collegeName;
    }
    
    public void setCollegeName(String collegeName) {
        this.collegeName = collegeName;
    }
    
    public String getMajorId() {
        return majorId;
    }
    
    public void setMajorId(String majorId) {
        this.majorId = majorId;
    }
    
    public String getMajorName() {
        return majorName;
    }
    
    public void setMajorName(String majorName) {
        this.majorName = majorName;
    }
    
    public Date getUploadTime() {
        return uploadTime;
    }
    
    public void setUploadTime(Date uploadTime) {
        this.uploadTime = uploadTime;
    }
    
    // 辅助方法：获取格式化上传时间
    public String getFormattedUploadTime() {
        if (uploadTime == null) return "未知";
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");
        return sdf.format(uploadTime);
    }
}
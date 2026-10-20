package com.m01major;

public class MajorBean {
    private String majorId;    // 专业编号（随机生成）
    private String majorName;  // 专业名称

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
}
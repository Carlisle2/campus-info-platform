<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01student.StudentBean" %>
<%@ page import="com.m01major.MajorBean" %>
<%@ page import="java.util.List" %>
<%
    StudentBean student = (StudentBean) request.getAttribute("student");
    List<MajorBean> majors = (List<MajorBean>) request.getAttribute("majors");
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>修改学生信息</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student_common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student_update.css">
    <script>
	    function backToMain() {
	        if (window.parent && window.parent.loadPage) {
	            window.parent.loadPage('student_query.jsp');
	        } else {
	            window.location.href = 'student_query.jsp';
	        }
	    }
    
        function validateForm() {
            var studentName = document.getElementById('studentName').value.trim();
            var gender = document.getElementById('gender').value;
            var majorId = document.getElementById('majorId').value;
            
            if (studentName === '') {
                alert('请输入学生姓名');
                document.getElementById('studentName').focus();
                return false;
            }
            
            if (gender === '') {
                alert('请选择性别');
                return false;
            }
            
            if (majorId === '') {
                alert('请选择专业');
                return false;
            }
            
            return true;
        }
        
        function cancelAction() {
            if (confirm('确定要取消修改吗？未保存的修改将丢失。')) {
                window.location.href = 'StudentServlet?action=query';
            }
        }
        
        function handleEnterKey(event) {
            if (event.key === 'Enter') {
                event.preventDefault();
                return false;
            }
        }
    </script>
</head>
<body>
    <div class="container">
    	<button class="close-btn" onclick="backToMain()">×</button>
        <h1>修改学生信息</h1>
        
        <% if (message != null && !message.isEmpty()) { %>
            <div class="message <%= messageType != null ? messageType : "success" %>">
                <%= message %>
            </div>
        <% } %>
        
        <% if (student != null) { %>
            <div class="form-container">
                <form method="post" action="StudentServlet" id="studentForm" 
                      onsubmit="return validateForm()" onkeypress="handleEnterKey(event)">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="studentId" value="<%= student.getStudentId() %>">
                    
                    <div class="form-group">
                        <label>学号</label>
                        <div class="readonly-field">
                            <%= student.getStudentId() %>
                        </div>
                        <div class="form-hint">系统生成的唯一标识，不可修改</div>
                    </div>
                    
                    <div class="form-group">
                        <label class="required">学生姓名</label>
                        <input type="text" id="studentName" name="studentName" 
                               value="<%= student.getStudentName() != null ? student.getStudentName() : "" %>" 
                               placeholder="请输入学生姓名" maxlength="50" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="required">性别</label>
                        <div class="gender-options">
                            <label class="gender-option">
                                <input type="radio" name="gender" value="男" 
                                       <%= "男".equals(student.getGender()) ? "checked" : "" %>>
                                <span>男</span>
                            </label>
                            <label class="gender-option">
                                <input type="radio" name="gender" value="女" 
                                       <%= "女".equals(student.getGender()) ? "checked" : "" %>>
                                <span>女</span>
                            </label>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="required">专业</label>
                        <div class="major-select">
                            <select id="majorId" name="majorId" required>
                                <option value="">-- 请选择专业 --</option>
                                <% if (majors != null) {
                                    for (MajorBean major : majors) { %>
                                    <option value="<%= major.getMajorId() %>" 
                                            <%= major.getMajorId().equals(student.getMajorId()) ? "selected" : "" %>>
                                        <%= major.getMajorName() %>
                                    </option>
                                <% } } %>
                            </select>
                        </div>
                        <% if (student.getMajorName() != null) { %>
                            <div class="current-info"><%= student.getMajorName() %></div>
                        <% } %>
                    </div>
                    
                    <div class="form-group">
                        <label>备注</label>
                        <textarea id="remark" name="remark" 
                                  placeholder="请输入备注信息" maxlength="200"><%= student.getRemark() != null ? student.getRemark() : "" %></textarea>
                    </div>
                    
                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">保存修改</button>
                        <button type="button" class="btn btn-secondary" onclick="cancelAction()">取消返回</button>
                    </div>
                </form>
            </div>
        <% } else { %>
            <div class="no-data">
                未找到学生信息，<a href="StudentServlet?action=query">返回列表</a>
            </div>
        <% } %>
    </div>
</body>
</html>
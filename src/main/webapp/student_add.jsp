<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01major.MajorBean" %>
<%@ page import="java.util.List" %>
<%
    // 获取所有专业
    List<MajorBean> majors = (List<MajorBean>) request.getAttribute("majors");
    if (majors == null) {
    }
    
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>新增学生信息</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student_common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student_add.css">
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
            
            if (studentName === '') {
                alert('请输入学生姓名');
                document.getElementById('studentName').focus();
                return false;
            }
            
            if (gender === '') {
                alert('请选择性别');
                return false;
            }
            
            return true;
        }
        
        function clearForm() {
            if (confirm('确定要清空所有表单内容吗？')) {
                document.getElementById('studentForm').reset();
            }
        }
        
        function cancelAction() {
            if (confirm('确定要取消吗？未保存的内容将丢失。')) {
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
        <h1>新增学生信息</h1>
        
        <% if (message != null && !message.isEmpty()) { %>
            <div class="message <%= messageType != null ? messageType : "success" %>">
                <%= message %>
            </div>
        <% } %>
        
        <div class="form-container">
            <form method="post" action="StudentServlet" id="studentForm" 
                  onsubmit="return validateForm()" onkeypress="handleEnterKey(event)">
                <input type="hidden" name="action" value="add">
                
                <div class="form-group">
                    <label class="required">学生姓名</label>
                    <input type="text" id="studentName" name="studentName" 
                           placeholder="请输入学生姓名" maxlength="50" required>
                </div>
                
                <div class="form-group">
                    <label class="required">性别</label>
                    <div class="gender-options">
                        <label class="gender-option">
                            <input type="radio" name="gender" value="男" checked>
                            <span>男</span>
                        </label>
                        <label class="gender-option">
                            <input type="radio" name="gender" value="女">
                            <span>女</span>
                        </label>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>专业选择</label>
                    <div style="display: flex; gap: 10px;">
                        <select id="majorId" name="majorId" style="flex: 1;">
                            <option value="">-- 选择已有专业 --</option>
                            <% if (majors != null) {
                                for (MajorBean major : majors) { %>
                                <option value="<%= major.getMajorId() %>">
                                    <%= major.getMajorName() %>
                                </option>
                            <% } } %>
                        </select>
                        <span style="line-height: 40px;">或</span>
                        <input type="text" id="majorName" name="majorName" 
                               placeholder="输入新专业名称" style="flex: 1;">
                    </div>
                    <div class="form-hint">可以选择已有专业或输入新专业（系统会自动创建）</div>
                </div>
                
                <div class="form-group">
                    <label>备注</label>
                    <textarea id="remark" name="remark" 
                              placeholder="请输入备注信息" maxlength="200"></textarea>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">新增学生</button>
                    <button type="button" class="btn btn-warning" onclick="clearForm()">重置</button>
                    <button type="button" class="btn btn-secondary" onclick="cancelAction()">取消返回</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
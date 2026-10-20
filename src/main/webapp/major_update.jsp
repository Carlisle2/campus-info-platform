<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01major.MajorBean" %>
<%
    MajorBean major = (MajorBean) request.getAttribute("major");
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>修改专业信息</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student_common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student_update.css">
    <script>
	    function backToMain() {
	        if (window.parent && window.parent.loadPage) {
	            window.parent.loadPage('major_query.jsp');
	        } else {
	            window.location.href = 'major_query.jsp';
	        }
	    }
    
        function validateForm() {
            var majorName = document.getElementById('majorName').value.trim();
            
            if (majorName === '') {
                alert('请输入专业名称');
                document.getElementById('majorName').focus();
                return false;
            }
            
            if (majorName.length < 2) {
                alert('专业名称至少需要2个字符');
                document.getElementById('majorName').focus();
                return false;
            }
            
            return true;
        }
        
        function cancelAction() {
            if (confirm('确定要取消修改吗？未保存的修改将丢失。')) {
                window.location.href = 'MajorServlet?action=query';
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
        <h1>修改专业信息</h1>
        
        <% if (message != null && !message.isEmpty()) { %>
            <div class="message <%= messageType != null ? messageType : "success" %>">
                <%= message %>
            </div>
        <% } %>
        
        <% if (major != null) { %>
            <div class="form-container">
                <form method="post" action="MajorServlet" id="majorForm" 
                      onsubmit="return validateForm()" onkeypress="handleEnterKey(event)">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="majorId" value="<%= major.getMajorId() %>">
                    
                    <!-- 专业编号（只读） -->
                    <div class="form-group">
                        <label>专业编号</label>
                        <div class="readonly-field">
                            <%= major.getMajorId() %>
                        </div>
                        <div class="form-hint">系统生成的唯一标识，不可修改</div>
                    </div>
                    
                    <!-- 当前信息提示 -->
                    <% if (major.getMajorName() != null) { %>
                        <div class="current-info">
                            当前名称：<%= major.getMajorName() %>
                        </div>
                    <% } %>
                    
                    <!-- 专业名称 -->
                    <div class="form-group">
                        <label class="required">专业名称</label>
                        <input type="text" id="majorName" name="majorName" 
                               value="<%= major.getMajorName() != null ? major.getMajorName() : "" %>" 
                               placeholder="请输入新的专业名称" 
                               maxlength="50" required>
                        <div class="form-hint">修改专业名称会影响所有关联此专业的学生信息</div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">保存修改</button>
                        <button type="button" class="btn btn-secondary" onclick="cancelAction()">取消返回</button>
                    </div>
                </form>
            </div>
        <% } else { %>
            <div class="no-data">
                未找到专业信息，<a href="MajorServlet?action=query" class="btn btn-primary">返回列表</a>
            </div>
        <% } %>
    </div>
</body>
</html>
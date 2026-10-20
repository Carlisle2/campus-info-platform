<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>新增专业信息</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student_common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student_add.css">
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
        
        function clearForm() {
            if (confirm('确定要清空所有表单内容吗？')) {
                document.getElementById('majorForm').reset();
            }
        }
        
        function cancelAction() {
            if (confirm('确定要取消吗？未保存的内容将丢失。')) {
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
        <h1>新增专业信息</h1>
        
        <% if (message != null && !message.isEmpty()) { %>
            <div class="message <%= messageType != null ? messageType : "success" %>">
                <%= message %>
            </div>
        <% } %>
        
        <div class="form-container">
            <!-- 提示信息 -->
            <div class="info-box">
                <h3>提示</h3>
                <ul>
                    <li>专业编号将由系统自动生成</li>
                    <li>专业名称应该准确、完整</li>
                    <li>专业名称长度建议在2-50个字符之间</li>
                </ul>
            </div>
            
            <form method="post" action="MajorServlet" id="majorForm" 
                  onsubmit="return validateForm()" onkeypress="handleEnterKey(event)">
                <input type="hidden" name="action" value="add">
                
                <div class="form-group">
                    <label class="required">专业名称</label>
                    <input type="text" id="majorName" name="majorName" 
                           placeholder="请输入专业名称，如：计算机科学与技术" 
                           maxlength="50" required>
                    <div class="form-hint">请填写完整的专业名称，长度2-50个字符</div>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">新增专业</button>
                    <button type="button" class="btn btn-warning" onclick="clearForm()">重置</button>
                    <button type="button" class="btn btn-secondary" onclick="cancelAction()">取消返回</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
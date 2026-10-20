<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
	List<String> allRoles = (List<String>) request.getAttribute("allRoles");
	if (allRoles == null) {
	    try {
	        // 直接创建UserDAO对象获取角色列表
	        com.m01user.UserDAO userDAO = new com.m01user.UserDAO();
	        allRoles = userDAO.getAllRoles();
	        request.setAttribute("allRoles", allRoles);
	    } catch (Exception e) {
	        e.printStackTrace();
	        allRoles = new ArrayList<>();
	    }
	}

    String errorMsg = (String) request.getAttribute("errorMsg");
    String formRoleID = (String) request.getAttribute("formRoleID");
    String formUsername = (String) request.getAttribute("formUsername");
    String formRole = (String) request.getAttribute("formRole");
    String formStatus = (String) request.getAttribute("formStatus");
    
    if (formRoleID == null) formRoleID = "";
    if (formUsername == null) formUsername = "";
    if (formRole == null) formRole = "";
    if (formStatus == null) formStatus = "1";
%>
<html>
<head>
    <title>用户管理 - 添加</title>
    <link rel="stylesheet" href="css/user_add.css">
    <script>
        function backToMain() {
            if (window.parent && window.parent.loadPage) {
                window.parent.loadPage('UserServlet?action=query');
            } else {
                window.location.href = 'UserServlet?action=query';
            }
        }
        
        function checkForm() {
            const roleID = document.getElementById("roleID").value.trim();
            const username = document.getElementById("username").value.trim();
            const password = document.getElementById("password").value.trim();
            const confirmPassword = document.getElementById("confirmPassword").value.trim();
            const role = document.getElementById("role").value;

            if (roleID === "") {
                alert("用户ID不能为空！");
                return false;
            }
            if (username === "") {
                alert("用户名不能为空！");
                return false;
            }
            if (password === "") {
                alert("密码不能为空！");
                return false;
            }
            if (confirmPassword === "") {
                alert("确认密码不能为空！");
                return false;
            }
            if (password !== confirmPassword) {
                alert("两次输入的密码不一致！");
                return false;
            }
            if (role === "") {
                alert("请选择用户角色！");
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
    <div class="container">
        <button class="close-btn" onclick="backToMain()">×</button>
        <h2 class="page-title">添加用户</h2>
        
        <form class="add-form" action="UserServlet" method="post" onsubmit="return checkForm()">
            <input type="hidden" name="action" value="add">
            
            <div class="form-item">
                <label>用户ID：</label>
                <input type="text" name="roleID" id="roleID" required
                       placeholder="请输入用户ID"
                       value="<%= formRoleID %>">
            </div>
            
            <div class="form-item">
                <label>用户名：</label>
                <input type="text" name="username" id="username" required
                       placeholder="请输入用户名"
                       value="<%= formUsername %>">
            </div>
            
            <div class="form-item">
                <label>密码：</label>
                <input type="password" name="password" id="password" required>
            </div>
            
            <div class="form-item">
                <label>确认密码：</label>
                <input type="password" id="confirmPassword" required>
            </div>
            
            <div class="form-item">
                <label>角色：</label>
                <select name="role" id="role" required>
                    <option value="">请选择</option>
                    <% 
                        // 动态生成角色选项
                        if (allRoles != null && !allRoles.isEmpty()) {
                            for (String roleName : allRoles) {
                                if (roleName != null && !roleName.trim().isEmpty()) {
                    %>
                        <option value="<%= roleName %>" 
                                <%= roleName.equals(formRole) ? "selected" : "" %>>
                            <%= roleName %>
                        </option>
                    <% 
                                }
                            }
                        } else {
                            // 如果角色列表为空，显示提示
                    %>
                        <option value="">(暂无角色数据)</option>
                    <% 
                        }
                    %>
                </select>
            </div>
            
            <div class="form-item">
                <label>状态：</label>
                <div class="radio-group">
                    <label>
                        <input type="radio" name="status" value="1" <%= "1".equals(formStatus) ? "checked" : "" %>> 启用
                    </label>
                    <label>
                        <input type="radio" name="status" value="0" <%= "0".equals(formStatus) ? "checked" : "" %>> 禁用
                    </label>
                </div>
            </div>
            
            <div class="form-btn">
                <button type="submit" class="btn btn-primary">提交添加</button>
                <button type="button" class="btn btn-default" onclick="backToMain()">返回列表</button>
            </div>
            
            <% if (errorMsg != null) { %>
                <div class="error-msg"><%= errorMsg %></div>
            <% } %>
        </form>
    </div>
</body>
</html>
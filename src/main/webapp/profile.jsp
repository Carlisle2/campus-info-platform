<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // 从request中获取参数
    String currentUsername = (String) request.getAttribute("currentUsername");
    String phone = (String) request.getAttribute("phone");
    String email = (String) request.getAttribute("email");
    String successMsg = (String) request.getAttribute("successMsg");
    String errorMsg = (String) request.getAttribute("errorMsg");
    
    // 如果没有从request获取到，尝试从session获取
    if (currentUsername == null) {
        currentUsername = (String) session.getAttribute("username");
    }
    
    // 如果还是没有用户名，说明未登录
    if (currentUsername == null || currentUsername.trim().isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // 设置默认值
    if (phone == null) phone = "";
    if (email == null) email = "";
%>
<!DOCTYPE html>
<html>
<head>
    <title>系统设置 - 个人设置</title>
    <style>
        /* 原有样式不变 */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: "Microsoft YaHei", sans-serif;
        }
        .container {
            width: 500px;
            margin: 20px auto;
            position: relative;
            padding-top: 10px;
        }
      
        .close-btn {
            position: absolute;
            top: 15px;
            right: 15px;
            width: 30px;
            height: 30px;
            background: none;          
            color: #dc3545;
            border: none;
            cursor: pointer;
            z-index: 150;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 30px;          
            transition: all 0.3s ease; 
            opacity: 0.7;             
        }
        .close-btn:hover {
            opacity: 1;              
            color: #c82333;             
            transform: rotate(-90deg); 
        }
        .page-title {
            text-align: center;
            margin-bottom: 20px;
            color: #333;
            font-size: 20px;
            font-weight: bold;
        }
        .profile-form {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
        }
        .form-item {
            margin-bottom: 15px;
        }
        .form-item label {
            display: inline-block;
            width: 100px;
            text-align: right;
            margin-right: 10px;
        }
        .form-item input[type="text"], .form-item input[type="password"], .form-item input[type="email"] {
            padding: 6px 10px;
            width: 250px;
            border: 1px solid #ddd;
            border-radius: 3px;
        }
        .form-tips {
            color: #6c757d;
            font-size: 12px;
            margin-left: 110px;
            margin-top: 5px;
        }
        .form-btn {
            text-align: center;
            margin-top: 20px;
        }
        .btn {
            padding: 6px 15px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
            margin: 0 5px;
        }
        .btn-primary {
            background: #007bff;
            color: white;
        }
        .btn-primary:hover {
            background: #0056b3;
        }
        .btn-default {
            background: #6c757d;
            color: white;
        }
        .btn-default:hover {
            background: #545b62;
        }
        .success-msg {
            color: #28a745;
            text-align: center;
            margin-top: 10px;
            padding: 10px;
            background: #d4edda;
            border-radius: 4px;
        }
        .error-msg {
            color: #dc3545;
            text-align: center;
            margin-top: 10px;
            padding: 10px;
            background: #f8d7da;
            border-radius: 4px;
        }
    </style>
    <script>
        function backToMain() {
            if (window.parent && window.parent.loadPage) {
                window.parent.loadPage('main.jsp');
            } else {
                window.location.href = 'main.jsp';
            }
        }
        // 表单校验
        function checkForm() {
            const newPwd = document.getElementById("newPwd").value.trim();
            const confirmPwd = document.getElementById("confirmPwd").value.trim();
            const phone = document.getElementById("phone").value.trim();
            const email = document.getElementById("email").value.trim();

            // 密码非空时校验一致性
            if (newPwd !== "" || confirmPwd !== "") {
                if (newPwd.length < 6) {
                    alert("新密码长度不能少于6位！");
                    return false;
                }
                if (newPwd !== confirmPwd) {
                    alert("两次输入的密码不一致！");
                    return false;
                }
            }
            // 手机号校验（非空时）
            if (phone !== "" && !/^1[3-9]\d{9}$/.test(phone)) {
                alert("请输入正确的手机号！");
                return false;
            }
            // 邮箱校验（非空时）
            if (email !== "" && !/^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/.test(email)) {
                alert("请输入正确的邮箱地址！");
                return false;
            }
            return true;
        }
        
        // 页面加载后自动聚焦
        window.onload = function() {
            // 如果有错误信息，焦点移到第一个输入框
            <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
                document.getElementById("newPwd").focus();
            <% } %>
        };
    </script>
</head>
<body>
    <div class="container">
        <!-- 关闭按钮 -->
        <button class="close-btn" id="closeBtn" onclick="backToMain()" title="返回主页面">×</button>
        
        <h2 class="page-title">个人设置</h2>
        
        <form action="ProfileServlet" method="post" class="profile-form" onsubmit="return checkForm()">
            <!-- 当前用户名（只读） -->
            <div class="form-item">
                <label>当前用户名：</label>
                <input type="text" name="currentUsername" value="<%= currentUsername %>" readonly style="background: #e9ecef;">
            </div>
            
            <!-- 新密码 -->
            <div class="form-item">
                <label>新密码：</label>
                <input type="password" name="newPwd" id="newPwd" placeholder="不修改请留空">
                <div class="form-tips">提示：密码长度不少于6位，不修改请留空</div>
            </div>
            
            <!-- 确认密码 -->
            <div class="form-item">
                <label>确认新密码：</label>
                <input type="password" name="confirmPwd" id="confirmPwd" placeholder="不修改请留空">
            </div>
            
            <!-- 联系电话 -->
            <div class="form-item">
                <label>联系电话：</label>
                <input type="text" name="phone" id="phone" value="<%= phone %>" placeholder="请输入手机号" require>
            </div>
            
            <!-- 邮箱 -->
            <div class="form-item">
                <label>电子邮箱：</label>
                <input type="email" name="email" id="email" value="<%= email %>" placeholder="请输入邮箱" require>
            </div>
            
            <!-- 提交按钮 -->
            <div class="form-btn">
                <button type="submit" class="btn btn-primary">保存修改</button>
                <button type="reset" class="btn btn-default">重置</button>
            </div>
            
            <!-- 提示信息 -->
            <% if (successMsg != null && !successMsg.isEmpty()) { %>
                <div class="success-msg"><%= successMsg %></div>
            <% } %>
            <% if (errorMsg != null && !errorMsg.isEmpty()) { %>
                <div class="error-msg"><%= errorMsg %></div>
            <% } %>
        </form>
    </div>
</body>
</html>
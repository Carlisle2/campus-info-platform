<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // 从request中获取数据
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
    String collegeName = (String) request.getAttribute("collegeName");
    String majorName = (String) request.getAttribute("majorName");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>新增培养方案</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student_common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/major_scheme_add.css">
    <script>
        // 页面加载完成后自动聚焦到第一个输入框
        window.onload = function() {
            document.getElementById('collegeName').focus();
        };
        
        function backToMain() {
            if (window.parent && window.parent.loadPage) {
                window.parent.loadPage('major_scheme.jsp');
            } else {
                window.location.href = 'major_scheme.jsp';
            }
        }
        
        // 表单验证
        function validateForm() {
            var collegeName = document.getElementById('collegeName').value.trim();
            var majorName = document.getElementById('majorName').value.trim();
            
            if (collegeName === '') {
                alert('请填写学院名称！');
                document.getElementById('collegeName').focus();
                return false;
            }
            
            if (majorName === '') {
                alert('请填写专业名称！');
                document.getElementById('majorName').focus();
                return false;
            }
            
            return true;
        }
        
        // 返回列表页
        function goBack() {
            window.location.href = 'MajorSchemeServlet?action=query';
            return false;
        }
        
        // 显示加载动画
        function showLoading() {
            var form = document.getElementById('addForm');
            var loading = document.getElementById('loading');
            var submitBtn = document.querySelector('button[type="submit"]');
            
            // 禁用提交按钮
            submitBtn.disabled = true;
            submitBtn.innerHTML = '提交中...';
            
            // 显示加载动画
            loading.style.display = 'block';
            
            // 提交表单
            form.submit();
        }
    </script>
</head>
<body>
    <div class="scheme-add-container">
        <button class="close-btn" onclick="backToMain()">×</button>
        
        <h1 class="scheme-add-title">新增培养方案</h1>
        
        <a href="MajorSchemeServlet?action=query" class="back-link">← 返回培养方案列表</a>
        
        <% if (message != null && !message.isEmpty()) { %>
            <div class="scheme-message <%= messageType != null ? messageType : "success" %>">
                <%= message %>
            </div>
        <% } %>
        
        <!-- 新增表单 -->
        <div class="scheme-form-section">
            <form method="post" action="MajorSchemeServlet" id="addForm" onsubmit="return validateForm()">
                <input type="hidden" name="action" value="add">
                
                <div class="scheme-form-group">
                    <label for="collegeName">学院名称：<span class="required-mark">*</span></label>
                    <input type="text" id="collegeName" name="collegeName" 
                           placeholder="请输入学院名称，如：计算机学院"
                           value="<%= collegeName != null ? collegeName : "" %>">
                    <div class="placeholder-hint">请输入完整的学院名称</div>
                </div>
                
                <div class="scheme-form-group">
                    <label for="majorName">专业名称：<span class="required-mark">*</span></label>
                    <input type="text" id="majorName" name="majorName" 
                           placeholder="请输入完整专业名称，如：计算机科学与技术"
                           value="<%= majorName != null ? majorName : "" %>">
                    <div class="placeholder-hint">请确保专业名称准确无误</div>
                </div>
                
                <div class="scheme-form-buttons">
                    <button type="submit" class="scheme-btn scheme-btn-primary" onclick="showLoading()">添加培养方案</button>
                    <button type="button" class="scheme-btn scheme-btn-secondary" onclick="goBack()">取消返回</button>
                </div>
            </form>
            
            <div class="loading-spinner" id="loading">
                <div class="spinner"></div>
                <p>正在提交，请稍候...</p>
            </div>
        </div>
    </div>
</body>
</html>
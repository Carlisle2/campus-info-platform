<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01student.StudentBean" %>
<%@ page import="com.m01major.MajorBean" %>
<%@ page import="java.util.List" %>
<%
    // 从request中获取数据
    List<StudentBean> studentList = (List<StudentBean>) request.getAttribute("studentList");
    String studentId = (String) request.getAttribute("studentId");
    String studentName = (String) request.getAttribute("studentName");
    String majorName = (String) request.getAttribute("majorName");
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
    
    // 分页参数
    Integer pageNum = (Integer) request.getAttribute("pageNum");
    Integer pageSize = (Integer) request.getAttribute("pageSize");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    Integer totalPage = (Integer) request.getAttribute("totalPage");
    
    // 设置默认值
    if (pageNum == null) pageNum = 1;
    if (pageSize == null) pageSize = 10;
    if (totalCount == null) totalCount = 0;
    if (totalPage == null) totalPage = 1;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>学生信息管理</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student_common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student_query.css">
    <script>
	    function backToMain() {
	        if (window.parent && window.parent.loadPage) {
	            window.parent.loadPage('main.jsp');
	        } else {
	            window.location.href = 'main.jsp';
	        }
	    }
    
        function clearSearch() {
            document.getElementById('studentId').value = '';
            document.getElementById('studentName').value = '';
            document.getElementById('majorName').value = '';
        }
        
        function confirmDelete(studentId, studentName) {
            if (confirm('确定要删除学生 "' + studentName + '" 吗？')) {
                location.href = 'StudentServlet?action=delete&studentId=' + studentId;
            }
            return false;
        }
        
        function handleKeyPress(event) {
            if (event.key === 'Enter') {
                event.preventDefault();
                document.getElementById('searchForm').submit();
            }
        }
        
        function changePageSize(size) {
            var studentId = '<%= studentId != null ? studentId : "" %>';
            var studentName = '<%= studentName != null ? studentName : "" %>';
            var majorName = '<%= majorName != null ? majorName : "" %>';
            
            var url = 'StudentServlet?action=query&pageSize=' + size + '&pageNum=1';
            if (studentId) url += '&studentId=' + encodeURIComponent(studentId);
            if (studentName) url += '&studentName=' + encodeURIComponent(studentName);
            if (majorName) url += '&majorName=' + encodeURIComponent(majorName);
            
            location.href = url;
        }
        
        function jumpToPage() {
            var page = document.getElementById('jumpPage').value;
            var studentId = '<%= studentId != null ? studentId : "" %>';
            var studentName = '<%= studentName != null ? studentName : "" %>';
            var majorName = '<%= majorName != null ? majorName : "" %>';
            
            if (page < 1) page = 1;
            if (page > <%= totalPage %>) page = <%= totalPage %>;
            
            var url = 'StudentServlet?action=query&pageNum=' + page;
            if (studentId) url += '&studentId=' + encodeURIComponent(studentId);
            if (studentName) url += '&studentName=' + encodeURIComponent(studentName);
            if (majorName) url += '&majorName=' + encodeURIComponent(majorName);
            
            location.href = url;
        }
    </script>
</head>
<body>
    <div class="container">
    	<button class="close-btn" onclick="backToMain()">×</button>
        <h1>学生信息管理</h1>
        
        <% if (message != null && !message.isEmpty()) { %>
            <div class="message <%= messageType != null ? messageType : "success" %>">
                <%= message %>
            </div>
        <% } %>
        
        <!-- 查询表单 -->
        <div class="search-form">
            <h3>学生信息查询</h3>
            <form method="get" action="StudentServlet" id="searchForm">
                <input type="hidden" name="action" value="query">
                <div class="search-row">
                    <div class="search-field">
                        <label for="studentId">学号：</label>
                        <input type="text" id="studentId" name="studentId" 
                               value="<%= studentId != null ? studentId : "" %>" 
                               placeholder="请输入学号"
                               onkeypress="handleKeyPress(event)">
                    </div>
                    
                    <div class="search-field">
                        <label for="studentName">姓名：</label>
                        <input type="text" id="studentName" name="studentName" 
                               value="<%= studentName != null ? studentName : "" %>" 
                               placeholder="请输入姓名"
                               onkeypress="handleKeyPress(event)">
                    </div>
                    
                    <div class="search-field">
                        <label for="majorName">专业：</label>
                        <input type="text" id="majorName" name="majorName" 
                               value="<%= majorName != null ? majorName : "" %>" 
                               placeholder="请输入专业名称"
                               onkeypress="handleKeyPress(event)">
                    </div>
                    
                    <div class="search-actions">
                        <button type="submit" class="btn btn-primary">查询</button>
                        <button type="button" class="btn btn-warning" onclick="clearSearch()">清空</button>
                        <a href="StudentServlet?action=add" class="btn btn-success">新增学生</a>
                    </div>
                </div>
            </form>
        </div>
        
        <!-- 查询结果统计 -->
        <% if (studentList != null) { %>
            <div class="search-stats">
                共找到 <%= totalCount %> 位学生
                <% if ((studentId != null && !studentId.trim().isEmpty()) ||
                       (studentName != null && !studentName.trim().isEmpty()) ||
                       (majorName != null && !majorName.trim().isEmpty())) { %>
                    （已应用查询条件）
                <% } %>
                ，当前显示第 <%= (pageNum-1)*pageSize+1 %> 到 <%= Math.min(pageNum*pageSize, totalCount) %> 条
            </div>
        <% } %>
        
        <!-- 学生列表 -->
        <div class="table-container">
            <% if (studentList != null && !studentList.isEmpty()) { %>
                <table class="student-table">
                    <thead>
                        <tr>
                            <th>序号</th>
                            <th>学号</th>
                            <th>姓名</th>
                            <th>性别</th>
                            <th>专业编号</th>
                            <th>专业名称</th>
                            <th>备注</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            int index = (pageNum - 1) * pageSize + 1;
                            for (StudentBean bean : studentList) { 
                        %>
                            <tr>
                                <td><%= index++ %></td>
                                <td><strong><%= bean.getStudentId() %></strong></td>
                                <td><%= bean.getStudentName() %></td>
                                <td><%= bean.getGender() %></td>
                                <td><%= bean.getMajorId() != null ? bean.getMajorId() : "" %></td>
                                <td><%= bean.getMajorName() != null ? bean.getMajorName() : "" %></td>
                                <td><%= bean.getRemark() != null ? bean.getRemark() : "" %></td>
                                <td class="action-cell">
                                    <a href="StudentServlet?action=edit&studentId=<%= bean.getStudentId() %>" 
                                       class="btn btn-warning btn-small" title="修改学生信息">
                                        修改
                                    </a>
                                    <a href="#" onclick="return confirmDelete('<%= bean.getStudentId() %>', '<%= bean.getStudentName() %>')" 
                                       class="btn btn-danger btn-small" title="删除学生">
                                        删除
                                    </a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
                
                <!-- 分页导航 -->
                <div class="pagination-container">
                    <div class="pagination-info">
                        共 <%= totalCount %> 条记录，第 <%= pageNum %> 页 / 共 <%= totalPage %> 页
                    </div>
                    <div class="pagination">
                        <% if (pageNum > 1) { %>
                            <a href="StudentServlet?action=query&studentId=<%= studentId != null ? studentId : "" %>&studentName=<%= studentName != null ? studentName : "" %>&majorName=<%= majorName != null ? majorName : "" %>&pageNum=1" class="btn btn-small">首页</a>
                            <a href="StudentServlet?action=query&studentId=<%= studentId != null ? studentId : "" %>&studentName=<%= studentName != null ? studentName : "" %>&majorName=<%= majorName != null ? majorName : "" %>&pageNum=<%= pageNum-1 %>" class="btn btn-small">上一页</a>
                        <% } else { %>
                            <span class="btn btn-small disabled">首页</span>
                            <span class="btn btn-small disabled">上一页</span>
                        <% } %>
                        
                        <% 
                            // 显示页码范围
                            int startPage = Math.max(1, pageNum - 2);
                            int endPage = Math.min(totalPage, pageNum + 2);
                            
                            for (int i = startPage; i <= endPage; i++) {
                                if (i == pageNum) {
                        %>
                                    <span class="btn btn-small btn-primary"><%= i %></span>
                        <%      } else { %>
                                    <a href="StudentServlet?action=query&studentId=<%= studentId != null ? studentId : "" %>&studentName=<%= studentName != null ? studentName : "" %>&majorName=<%= majorName != null ? majorName : "" %>&pageNum=<%= i %>" class="btn btn-small"><%= i %></a>
                        <%      }
                            }
                        %>
                        
                        <% if (pageNum < totalPage) { %>
                            <a href="StudentServlet?action=query&studentId=<%= studentId != null ? studentId : "" %>&studentName=<%= studentName != null ? studentName : "" %>&majorName=<%= majorName != null ? majorName : "" %>&pageNum=<%= pageNum+1 %>" class="btn btn-small">下一页</a>
                            <a href="StudentServlet?action=query&studentId=<%= studentId != null ? studentId : "" %>&studentName=<%= studentName != null ? studentName : "" %>&majorName=<%= majorName != null ? majorName : "" %>&pageNum=<%= totalPage %>" class="btn btn-small">末页</a>
                        <% } else { %>
                            <span class="btn btn-small disabled">下一页</span>
                            <span class="btn btn-small disabled">末页</span>
                        <% } %>
                        
                        <!-- 跳转到指定页 -->
                        <div class="page-jump">
                            <input type="number" id="jumpPage" min="1" max="<%= totalPage %>" value="<%= pageNum %>" style="width: 60px;">
                            <button onclick="jumpToPage()" class="btn btn-small btn-info">跳转</button>
                        </div>
                        
                        <!-- 每页显示条数选择 -->
                        <div class="page-size-select">
                            <span>每页显示：</span>
                            <select onchange="changePageSize(this.value)">
                                <option value="5" <%= pageSize == 5 ? "selected" : "" %>>5条</option>
                                <option value="10" <%= pageSize == 10 ? "selected" : "" %>>10条</option>
                                <option value="20" <%= pageSize == 20 ? "selected" : "" %>>20条</option>
                                <option value="50" <%= pageSize == 50 ? "selected" : "" %>>50条</option>
                            </select>
                        </div>
                    </div>
                </div>
            <% } else if (studentList != null) { %>
                <div class="no-data">
                    没有找到符合条件的学生信息
                </div>
            <% } else { %>
                <div class="no-data">
                    请点击查询按钮查看学生信息
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>
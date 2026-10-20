<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01major.MajorBean" %>
<%@ page import="java.util.List" %>
<%
    // 从request中获取数据
    List<MajorBean> majorList = (List<MajorBean>) request.getAttribute("majorList");
    String majorId = (String) request.getAttribute("majorId");
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
    <title>专业信息管理</title>
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
            document.getElementById('majorId').value = '';
            document.getElementById('majorName').value = '';
        }
        
        function confirmDelete(majorId, majorName) {
            if (confirm('确定要删除专业 "' + majorName + '" 吗？\n\n注意：如果有学生关联此专业，则无法删除！')) {
                // 获取当前分页参数
                var pageNum = <%= pageNum %>;
                var pageSize = <%= pageSize %>;
                var searchMajorId = '<%= majorId != null ? majorId : "" %>';
                var searchMajorName = '<%= majorName != null ? majorName : "" %>';
                
                var url = 'MajorServlet?action=delete&majorId=' + majorId + 
                          '&pageNum=' + pageNum + 
                          '&pageSize=' + pageSize;
                
                if (searchMajorId) url += '&majorId=' + encodeURIComponent(searchMajorId);
                if (searchMajorName) url += '&majorName=' + encodeURIComponent(searchMajorName);
                
                location.href = url;
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
            var majorId = '<%= majorId != null ? majorId : "" %>';
            var majorName = '<%= majorName != null ? majorName : "" %>';
            
            var url = 'MajorServlet?action=query&pageSize=' + size + '&pageNum=1';
            if (majorId) url += '&majorId=' + encodeURIComponent(majorId);
            if (majorName) url += '&majorName=' + encodeURIComponent(majorName);
            
            location.href = url;
        }
        
        function jumpToPage() {
            var page = document.getElementById('jumpPage').value;
            var majorId = '<%= majorId != null ? majorId : "" %>';
            var majorName = '<%= majorName != null ? majorName : "" %>';
            
            if (page < 1) page = 1;
            if (page > <%= totalPage %>) page = <%= totalPage %>;
            
            var url = 'MajorServlet?action=query&pageNum=' + page;
            if (majorId) url += '&majorId=' + encodeURIComponent(majorId);
            if (majorName) url += '&majorName=' + encodeURIComponent(majorName);
            
            location.href = url;
        }
    </script>
</head>
<body>
    <div class="container">
    	<button class="close-btn" onclick="backToMain()">×</button>
        <h1>专业信息管理</h1>
        
        <% if (message != null && !message.isEmpty()) { %>
            <div class="message <%= messageType != null ? messageType : "success" %>">
                <%= message %>
            </div>
        <% } %>
        
        <!-- 查询表单 -->
        <div class="search-form">
            <h3>专业查询</h3>
            <form method="get" action="MajorServlet" id="searchForm">
                <input type="hidden" name="action" value="query">
                <input type="hidden" name="pageNum" value="1">
                <input type="hidden" name="pageSize" value="<%= pageSize %>">
                <div class="search-row">
                    <div class="search-field">
                        <label for="majorId">专业编号：</label>
                        <input type="text" id="majorId" name="majorId" 
                               value="<%= majorId != null ? majorId : "" %>" 
                               placeholder="请输入专业编号"
                               onkeypress="handleKeyPress(event)">
                    </div>
                    
                    <div class="search-field">
                        <label for="majorName">专业名称：</label>
                        <input type="text" id="majorName" name="majorName" 
                               value="<%= majorName != null ? majorName : "" %>" 
                               placeholder="请输入专业名称"
                               onkeypress="handleKeyPress(event)">
                    </div>
                    
                    <div class="search-actions">
                        <button type="submit" class="btn btn-primary">查询</button>
                        <button type="button" class="btn btn-warning" onclick="clearSearch()">清空</button>
                        <a href="major_add.jsp" class="btn btn-success">新增专业</a>
                    </div>
                </div>
            </form>
        </div>
        
        <!-- 查询结果统计 -->
        <% if (majorList != null) { %>
            <div class="search-stats">
                共找到 <%= totalCount %> 个专业
                <% if ((majorId != null && !majorId.trim().isEmpty()) ||
                       (majorName != null && !majorName.trim().isEmpty())) { %>
                    （已应用查询条件）
                <% } %>
                ，当前显示第 <%= (pageNum-1)*pageSize+1 %> 到 <%= Math.min(pageNum*pageSize, totalCount) %> 条
            </div>
        <% } %>
        
        <!-- 专业列表 -->
        <div class="table-container">
            <% if (majorList != null && !majorList.isEmpty()) { %>
                <table class="student-table">
                    <thead>
                        <tr>
                            <th>序号</th>
                            <th>专业编号</th>
                            <th>专业名称</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            int index = (pageNum - 1) * pageSize + 1;
                            for (MajorBean bean : majorList) { 
                        %>
                            <tr>
                                <td><%= index++ %></td>
                                <td><strong><%= bean.getMajorId() %></strong></td>
                                <td><%= bean.getMajorName() %></td>
                                <td class="action-cell">
                                    <a href="MajorServlet?action=edit&majorId=<%= bean.getMajorId() %>" 
                                       class="btn btn-warning btn-small" title="修改专业信息">
                                        修改
                                    </a>
                                    <a href="#" onclick="return confirmDelete('<%= bean.getMajorId() %>', '<%= bean.getMajorName() %>')" 
                                       class="btn btn-danger btn-small" title="删除专业">
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
                            <a href="MajorServlet?action=query&majorId=<%= majorId != null ? majorId : "" %>&majorName=<%= majorName != null ? majorName : "" %>&pageNum=1&pageSize=<%= pageSize %>" 
                               class="btn btn-small">首页</a>
                            <a href="MajorServlet?action=query&majorId=<%= majorId != null ? majorId : "" %>&majorName=<%= majorName != null ? majorName : "" %>&pageNum=<%= pageNum-1 %>&pageSize=<%= pageSize %>" 
                               class="btn btn-small">上一页</a>
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
                                    <a href="MajorServlet?action=query&majorId=<%= majorId != null ? majorId : "" %>&majorName=<%= majorName != null ? majorName : "" %>&pageNum=<%= i %>&pageSize=<%= pageSize %>" 
                                       class="btn btn-small"><%= i %></a>
                        <%      }
                            }
                        %>
                        
                        <% if (pageNum < totalPage) { %>
                            <a href="MajorServlet?action=query&majorId=<%= majorId != null ? majorId : "" %>&majorName=<%= majorName != null ? majorName : "" %>&pageNum=<%= pageNum+1 %>&pageSize=<%= pageSize %>" 
                               class="btn btn-small">下一页</a>
                            <a href="MajorServlet?action=query&majorId=<%= majorId != null ? majorId : "" %>&majorName=<%= majorName != null ? majorName : "" %>&pageNum=<%= totalPage %>&pageSize=<%= pageSize %>" 
                               class="btn btn-small">末页</a>
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
            <% } else if (majorList != null) { %>
                <div class="no-data">
                    没有找到符合条件的专业信息
                </div>
            <% } else { %>
                <div class="no-data">
                    请点击查询按钮查看专业信息
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.m01major.MajorSchemeBean" %>
<%@ page import="java.util.List" %>
<%
    // 从request中获取数据
    List<MajorSchemeBean> schemeList = (List<MajorSchemeBean>) request.getAttribute("schemeList");
    String searchMajorName = (String) request.getAttribute("searchMajorName");
    String searchCollegeName = (String) request.getAttribute("searchCollegeName");
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
    Boolean hasSearched = (Boolean) request.getAttribute("hasSearched");
    
    // 分页参数
    Integer pageNum = (Integer) request.getAttribute("pageNum");
    Integer pageSize = (Integer) request.getAttribute("pageSize");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    Integer totalPage = (Integer) request.getAttribute("totalPage");
    
    // 设置默认值
    if (hasSearched == null) hasSearched = false;
    if (pageNum == null) pageNum = 1;
    if (pageSize == null) pageSize = 10;
    if (totalCount == null) totalCount = 0;
    if (totalPage == null) totalPage = 1;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>培养方案管理</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/student_common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/major_scheme.css">
    <script>
        function backToMain() {
            if (window.parent && window.parent.loadPage) {
                window.parent.loadPage('main.jsp');
            } else {
                window.location.href = 'main.jsp';
            }
        }
        
        // 清空查询条件
        function clearSearch() {
            document.getElementById('searchMajorName').value = '';
            document.getElementById('searchCollegeName').value = '';
            document.getElementById('searchForm').submit();
        }
        
        // 生成安全的文件名
        function getSchemeFileName(majorName) {
            return majorName.replace(/[^\u4e00-\u9fa5a-zA-Z0-9]/g, '_') + '_培养方案.pdf';
        }
        
        // 预览培养方案
        function previewScheme(majorName) {
            var fileName = getSchemeFileName(majorName);
            var fileUrl = 'schemes/' + encodeURIComponent(fileName);
            window.open(fileUrl, '_blank', 'width=1000,height=700');
            return false;
        }
        
        // 下载培养方案
        function downloadScheme(majorName) {
            var fileName = getSchemeFileName(majorName);
            var fileUrl = 'schemes/' + encodeURIComponent(fileName);
            
            var link = document.createElement('a');
            link.href = fileUrl;
            link.download = fileName;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            return false;
        }
        
        // 分页功能
        function changePageSize(size) {
            var majorName = '<%= searchMajorName != null ? searchMajorName : "" %>';
            var collegeName = '<%= searchCollegeName != null ? searchCollegeName : "" %>';
            
            var url = 'MajorSchemeServlet?action=query&pageSize=' + size + '&pageNum=1';
            if (majorName) url += '&searchMajorName=' + encodeURIComponent(majorName);
            if (collegeName) url += '&searchCollegeName=' + encodeURIComponent(collegeName);
            
            location.href = url;
        }
        
        function jumpToPage() {
            var page = document.getElementById('jumpPage').value;
            var majorName = '<%= searchMajorName != null ? searchMajorName : "" %>';
            var collegeName = '<%= searchCollegeName != null ? searchCollegeName : "" %>';
            
            if (page < 1) page = 1;
            if (page > <%= totalPage %>) page = <%= totalPage %>;
            
            var url = 'MajorSchemeServlet?action=query&pageNum=' + page;
            if (majorName) url += '&searchMajorName=' + encodeURIComponent(majorName);
            if (collegeName) url += '&searchCollegeName=' + encodeURIComponent(collegeName);
            
            location.href = url;
        }
    </script>
</head>
<body>
    <div class="major-scheme-container">
        <button class="close-btn" onclick="backToMain()">×</button>
        <h1 class="page-title">培养方案管理</h1>
        
        <% if (message != null && !message.isEmpty()) { %>
            <div class="message <%= messageType != null ? messageType : "success" %>">
                <%= message %>
            </div>
        <% } %>
        
        <!-- 查询表单 -->
        <div class="scheme-search-form">
            <h3>培养方案查询</h3>
            <form method="get" action="MajorSchemeServlet" id="searchForm">
                <input type="hidden" name="action" value="query">
                <input type="hidden" name="pageNum" value="1">
                <input type="hidden" name="pageSize" value="<%= pageSize %>">
                <div class="scheme-search-row">
                    <div class="scheme-search-field">
                        <label for="searchMajorName">专业名称：</label>
                        <input type="text" id="searchMajorName" name="searchMajorName" 
                               value="<%= searchMajorName != null ? searchMajorName : "" %>" 
                               placeholder="请输入专业名称">
                    </div>
                    
                    <div class="scheme-search-field">
                        <label for="searchCollegeName">学院名称：</label>
                        <input type="text" id="searchCollegeName" name="searchCollegeName" 
                               value="<%= searchCollegeName != null ? searchCollegeName : "" %>" 
                               placeholder="请输入学院名称">
                    </div>
                    
                    <div class="scheme-search-actions">
                        <button type="submit" class="btn btn-primary">查询</button>
                        <button type="button" class="btn btn-warning" onclick="clearSearch()">清空</button>
                    </div>
                </div>
            </form>
        </div>
        
        <% if (hasSearched) { %>
            <!-- 查询结果统计 -->
            <div class="scheme-stats">
                共找到 <%= totalCount %> 个培养方案
                <% if ((searchMajorName != null && !searchMajorName.trim().isEmpty()) ||
                       (searchCollegeName != null && !searchCollegeName.trim().isEmpty())) { %>
                    （已应用查询条件）
                <% } %>
                ，当前显示第 <%= (pageNum-1)*pageSize+1 %> 到 <%= Math.min(pageNum*pageSize, totalCount) %> 条
            </div>
            
            <div class="scheme-page-header">
                <h2>培养方案列表</h2>
                <div class="scheme-page-actions">
                    <a href="major_scheme_add.jsp" class="btn btn-success">新增培养方案</a>
                </div>
            </div>
            
            <!-- 培养方案列表 -->
            <div class="scheme-table-container">
                <% if (schemeList != null && !schemeList.isEmpty()) { %>
                    <table class="scheme-table">
                        <thead>
                            <tr>
                                <th>序号</th>
                                <th>培养方案ID</th>
                                <th>学院名称</th>
                                <th>专业名称</th>
                                <th>上传时间</th>
                                <th>文件操作</th>
                                <th>管理操作</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                int index = (pageNum - 1) * pageSize + 1;
                                for (MajorSchemeBean bean : schemeList) { 
                                    // 检查文件是否存在
                                    String fileName = bean.getMajorName().replaceAll("[^\\u4e00-\\u9fa5a-zA-Z0-9]", "_") + "_培养方案.pdf";
                                    String filePath = application.getRealPath("/") + "schemes/" + fileName;
                                    java.io.File file = new java.io.File(filePath);
                                    boolean fileExists = file.exists();
                            %>
                                <tr>
                                    <td><%= index++ %></td>
                                    <td><%= bean.getSchemeId() %></td>
                                    <td><%= bean.getCollegeName() != null ? bean.getCollegeName() : "-" %></td>
                                    <td>
                                        <%= bean.getMajorName() %>
                                        <span class="file-status <%= fileExists ? "file-exists" : "file-missing" %>">
                                            <%= fileExists ? "文件已就绪" : "文件缺失" %>
                                        </span>
                                    </td>
                                    <td class="upload-time"><%= bean.getFormattedUploadTime() %></td>
                                    <td class="scheme-action-cell">
                                        <% if (fileExists) { %>
                                            <button onclick="return previewScheme('<%= bean.getMajorName() %>')" 
                                                    class="btn btn-preview" 
                                                    title="在线预览培养方案">
                                                预览
                                            </button>
                                            <button onclick="return downloadScheme('<%= bean.getMajorName() %>')" 
                                                    class="btn btn-download" 
                                                    title="下载培养方案文件">
                                                下载
                                            </button>
                                        <% } else { %>
                                            <span style="color: #6c757d; font-size: 12px;">文件缺失，无法操作</span>
                                        <% } %>
                                    </td>
                                    <td class="scheme-action-cell">
                                        <!-- 删除按钮 -->
                                        <a href="MajorSchemeServlet?action=delete&majorName=<%= java.net.URLEncoder.encode(bean.getMajorName(), "UTF-8") %>&pageNum=<%= pageNum %>&pageSize=<%= pageSize %>&searchMajorName=<%= searchMajorName != null ? java.net.URLEncoder.encode(searchMajorName, "UTF-8") : "" %>&searchCollegeName=<%= searchCollegeName != null ? java.net.URLEncoder.encode(searchCollegeName, "UTF-8") : "" %>" 
                                           onclick="return confirm('确定删除【<%= bean.getMajorName() %>】的培养方案吗？')" 
                                           class="btn btn-danger" 
                                           title="删除培养方案">
                                            删除
                                        </a>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <!-- 分页导航 -->
                    <div class="scheme-pagination-container">
                        <div class="scheme-pagination-info">
                            共 <%= totalCount %> 条记录，第 <%= pageNum %> 页 / 共 <%= totalPage %> 页
                        </div>
                        <div class="scheme-pagination">
                            <% if (pageNum > 1) { %>
                                <a href="MajorSchemeServlet?action=query&searchMajorName=<%= searchMajorName != null ? searchMajorName : "" %>&searchCollegeName=<%= searchCollegeName != null ? searchCollegeName : "" %>&pageNum=1&pageSize=<%= pageSize %>" 
                                   class="btn btn-small">首页</a>
                                <a href="MajorSchemeServlet?action=query&searchMajorName=<%= searchMajorName != null ? searchMajorName : "" %>&searchCollegeName=<%= searchCollegeName != null ? searchCollegeName : "" %>&pageNum=<%= pageNum-1 %>&pageSize=<%= pageSize %>" 
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
                                        <a href="MajorSchemeServlet?action=query&searchMajorName=<%= searchMajorName != null ? searchMajorName : "" %>&searchCollegeName=<%= searchCollegeName != null ? searchCollegeName : "" %>&pageNum=<%= i %>&pageSize=<%= pageSize %>" 
                                           class="btn btn-small"><%= i %></a>
                            <%      }
                                }
                            %>
                            
                            <% if (pageNum < totalPage) { %>
                                <a href="MajorSchemeServlet?action=query&searchMajorName=<%= searchMajorName != null ? searchMajorName : "" %>&searchCollegeName=<%= searchCollegeName != null ? searchCollegeName : "" %>&pageNum=<%= pageNum+1 %>&pageSize=<%= pageSize %>" 
                                   class="btn btn-small">下一页</a>
                                <a href="MajorSchemeServlet?action=query&searchMajorName=<%= searchMajorName != null ? searchMajorName : "" %>&searchCollegeName=<%= searchCollegeName != null ? searchCollegeName : "" %>&pageNum=<%= totalPage %>&pageSize=<%= pageSize %>" 
                                   class="btn btn-small">末页</a>
                            <% } else { %>
                                <span class="btn btn-small disabled">下一页</span>
                                <span class="btn btn-small disabled">末页</span>
                            <% } %>
                            
                            <!-- 跳转到指定页 -->
                            <div class="scheme-page-jump">
                                <input type="number" id="jumpPage" min="1" max="<%= totalPage %>" value="<%= pageNum %>" style="width: 60px;">
                                <button onclick="jumpToPage()" class="btn btn-small btn-info">跳转</button>
                            </div>
                            
                            <!-- 每页显示条数选择 -->
                            <div class="scheme-page-size-select">
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
                <% } else { %>
                    <div class="scheme-no-data">
                        <% if ((searchMajorName != null && !searchMajorName.trim().isEmpty()) ||
                               (searchCollegeName != null && !searchCollegeName.trim().isEmpty())) { %>
                            没有找到符合条件的培养方案
                        <% } else { %>
                            没有找到培养方案数据
                        <% } %>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <!-- 未查询时的提示 -->
            <div class="scheme-no-data" style="margin-top: 30px;">
                <p>请点击查询按钮查看培养方案信息</p>            
            </div>
        <% } %>
        
    </div>
</body>
</html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>系统设置 - 关于系统</title>
    <style>
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
        /* 原系统一致的关闭按钮样式 */
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
        .about-card {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 5px;
            text-align: center;
        }
        .system-logo {
            font-size: 60px;
            color: #007bff;
            margin-bottom: 20px;
        }
        .about-info {
            margin-bottom: 15px;
            font-size: 16px;
            color: #333;
            line-height: 1.8;
        }
        .about-info span {
            display: inline-block;
            width: 100px;
            text-align: right;
            margin-right: 10px;
            color: #6c757d;
        }
        .copyright {
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #e9ecef;
            color: #6c757d;
            font-size: 14px;
        }
    </style>
    <script>
        // 返回主页方法
        function backToMain() {
            if (window.parent && window.parent.loadPage) {
                window.parent.loadPage('main.jsp');
            } else {
                window.location.href = 'main.jsp';
            }
        }
    </script>
</head>
<body>
    <div class="container">
        <!-- 关闭按钮 -->
        <button class="close-btn" id="closeBtn" onclick="backToMain()" title="返回主页面">×</button>
        
        <h2 class="page-title">关于系统</h2>
        <div class="about-card">
            <!-- 系统图标（用文字替代，也可替换为img标签） -->
            <div class="system-logo">🎓</div>
            
            <!-- 系统信息 -->
            <div class="about-info">
                <span>系统名称：</span>智慧校园信息管理平台
            </div>
            <div class="about-info">
                <span>版本号：</span>v1.0.0
            </div>
            <div class="about-info">
                <span>技术栈：</span>Java + JSP + MySQL
            </div>
            <div class="about-info">
                <span>更新时间：</span>2026-1-5
            </div>
            
            <!-- 版权信息 -->
            <div class="copyright">
                © 2026 智慧校园信息管理平台 版权所有
            </div>
        </div>
    </div>
</body>
</html>
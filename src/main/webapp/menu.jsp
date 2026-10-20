<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>系统菜单</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Microsoft YaHei', Arial, sans-serif;
            background: #ecf0f1;
            height: 100vh;
            overflow-y: auto;
        }
        
        .menu-container {
            padding: 20px 0;
        }
        
        .menu-group {
            margin-bottom: 20px;
        }
        
        .menu-title {
            padding: 10px 20px;
            background: #3498db;
            color: white;
            font-weight: bold;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: background 0.3s;
        }
        
        .menu-title:hover {
            background: #2980b9;
        }
        
        .menu-items {
            background: white;
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.3s ease-out;
        }
        
        .menu-items.expanded {
            max-height: 500px;
        }
        
        .menu-item {
            padding: 12px 30px;
            color: #555;
            cursor: pointer;
            transition: all 0.3s;
            border-left: 3px solid transparent;
            position: relative;
        }
        
        .menu-item:hover {
            background: #f8f9fa;
            color: #3498db;
            border-left-color: #3498db;
        }
        
        .menu-item.active {
            background: #e3f2fd;
            color: #3498db;
            border-left-color: #3498db;
            font-weight: bold;
        }
        
		/* 子菜单样式 */
		.submenu-items {
		    background: #f8f9fa;
		    max-height: 0;
		    overflow: hidden;
		    transition: max-height 0.3s ease-out;
		    padding-left: 20px;
		}
		
		.submenu-items.expanded {
		    max-height: 200px;
		}
		
		.menu-subitem {
		    padding: 10px 30px 10px 40px;
		    color: #666;
		    cursor: pointer;
		    transition: all 0.3s;
		    border-left: 2px solid transparent;
		    font-size: 14px;
		}
		
		.menu-subitem:hover {
		    background: #edf2f7;
		    color: #3498db;
		    border-left-color: #3498db;
		}
		
		.menu-subitem.active {
		    background: #e3f2fd;
		    color: #3498db;
		    border-left-color: #3498db;
		    font-weight: normal;
		}
		
        .arrow {
            transition: transform 0.3s;
        }
        
        .sub-arrow {
		    font-size: 10px;
		    margin-left: 5px;    
		    transition: transform 0.3s;
		    display: inline-block;
		}
        
        .arrow.expanded, .sub-arrow.expanded {
            transform: rotate(90deg);
        }
        
        .menu-divider {
            height: 1px;
            background: #ddd;
            margin: 15px 20px;
        }
    </style>
</head>
<body>
    <div class="menu-container">
        <!-- 用户管理 -->
		<div class="menu-group">
		    <div class="menu-title" onclick="loadPage('user_query.jsp')">
		        用户管理
		    </div>
		</div>
        
        <!-- 角色管理 -->
		<div class="menu-group">
		    <div class="menu-title" onclick="loadPage('role_query.jsp')">
		        角色管理
		    </div>
		</div>
		
        <!-- 专业管理 -->
        <div class="menu-group">
            <div class="menu-title" onclick="toggleMenu(this)">
                专业管理
                <span class="arrow">▶</span>
            </div>
            <div class="menu-items">
                <div class="menu-item" onclick="loadPage('major_query.jsp')">专业信息</div>
                <div class="menu-item" onclick="loadPage('major_scheme.jsp')">培养方案管理</div>
            </div>
        </div>
        
        <!-- 学生管理 -->
        <div class="menu-group">
            <div class="menu-title" onclick="loadPage('student_query.jsp')">
                学生管理
            </div>
        </div>     
        
        <div class="menu-divider"></div>
        
        <!-- 系统设置 -->
        <div class="menu-group">
            <div class="menu-title" onclick="toggleMenu(this)">
                系统设置
                <span class="arrow">▶</span>
            </div>
            <div class="menu-items">
                <div class="menu-item" onclick="loadPage('profile.jsp')">个人设置</div>
                <div class="menu-item" onclick="loadPage('about.jsp')">关于系统</div>
            </div>
        </div>
    </div>

    <script>
        // 切换主菜单展开/收起
        function toggleMenu(element) {
            const menuItems = element.nextElementSibling;
            const arrow = element.querySelector('.arrow');
            
            menuItems.classList.toggle('expanded');
            arrow.classList.toggle('expanded');
        }
        
        // 切换子菜单展开/收起
		function toggleSubMenu(element) {
		    event.stopPropagation(); // 阻止事件冒泡
		    
		    const submenuItems = element.nextElementSibling;
		    const subArrow = element.querySelector('.sub-arrow');
		    
		    submenuItems.classList.toggle('expanded');
		    subArrow.classList.toggle('expanded');
		    
		    // 移除其他子菜单的展开状态
		    const allSubmenus = document.querySelectorAll('.submenu-items');
		    const allSubArrows = document.querySelectorAll('.sub-arrow');
		    
		    allSubmenus.forEach(submenu => {
		        if (submenu !== submenuItems) {
		            submenu.classList.remove('expanded');
		        }
		    });
		    
		    allSubArrows.forEach(arrow => {
		        if (arrow !== subArrow) {
		            arrow.classList.remove('expanded');
		        }
		    });
		}
        
        // 加载页面到主框架
        function loadPage(pageUrl) {
            // 移除所有active类
            document.querySelectorAll('.menu-item, .menu-subitem').forEach(item => {
                item.classList.remove('active');
            });
            
            // 添加active类到当前菜单项
            event.target.classList.add('active');
            
            // 如果是子菜单项，也激活父菜单项
            if (event.target.classList.contains('menu-subitem')) {
                const parentMenuItem = event.target.closest('.submenu-items').previousElementSibling;
                if (parentMenuItem) {
                    parentMenuItem.classList.add('active');
                }
            }
            
            // 在父框架中加载页面
            if (window.parent && window.parent.loadPage) {
                window.parent.loadPage(pageUrl);
            } else {
                // 独立运行时的处理
                window.location.href = 'frame.jsp?page=' + pageUrl;
            }
        }
       
    </script>
</body>
</html>
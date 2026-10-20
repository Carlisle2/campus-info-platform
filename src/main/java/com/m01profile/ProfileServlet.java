package com.m01profile;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ProfileServlet")
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ProfileDAO profileDAO = new ProfileDAO(); // 新增ProfileDAO
    
    public ProfileServlet() {
        super();
    }

    /**
     * 从数据库获取用户的原始联系信息 - 修改这个方法
     */
    private String[] getUserOriginalInfo(String username) {
        String[] info = new String[2]; // [0]=phone, [1]=email
        
        // 使用新增的ProfileDAO获取用户联系信息
        info = profileDAO.getUserContactInfo(username);
        
        System.out.println("获取用户联系信息:");
        System.out.println("用户名: " + username);
        System.out.println("电话: " + info[0]);
        System.out.println("邮箱: " + info[1]);
        
        return info;
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        // 获取当前登录用户
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        
        if (username == null || username.trim().isEmpty()) {
            // 未登录，重定向到登录页面
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // 从数据库获取用户原始的联系信息 - 使用ProfileDAO
        String[] originalInfo = getUserOriginalInfo(username);
        
        // 添加调试信息
        System.out.println("设置到request的数据:");
        System.out.println("用户名: " + username);
        System.out.println("电话: " + originalInfo[0]);
        System.out.println("邮箱: " + originalInfo[1]);
        
        // 设置到request属性中
        request.setAttribute("currentUsername", username);
        request.setAttribute("phone", originalInfo[0]);
        request.setAttribute("email", originalInfo[1]);
        
        // 转发到profile.jsp页面
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        // 获取当前登录用户
        HttpSession session = request.getSession();
        String username = (String) session.getAttribute("username");
        
        if (username == null || username.trim().isEmpty()) {
            request.setAttribute("errorMsg", "用户未登录或会话已过期");
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
            return;
        }
        
        // 获取表单参数
        String newPassword = request.getParameter("newPwd");
        String confirmPassword = request.getParameter("confirmPwd");
        String inputPhone = request.getParameter("phone");
        String inputEmail = request.getParameter("email");
        
        // 先获取用户原始的联系信息（用于验证失败时回显）
        String[] originalInfo = getUserOriginalInfo(username);
        String originalPhone = originalInfo[0];
        String originalEmail = originalInfo[1];
        
        // 密码一致性验证
        if ((newPassword != null && !newPassword.trim().isEmpty()) || 
            (confirmPassword != null && !confirmPassword.trim().isEmpty())) {
            if (newPassword == null || newPassword.trim().isEmpty() || 
                confirmPassword == null || confirmPassword.trim().isEmpty()) {
                request.setAttribute("errorMsg", "请完整填写新密码和确认密码");
                // 验证失败时，回显用户原始的联系信息
                request.setAttribute("phone", originalPhone);
                request.setAttribute("email", originalEmail);
                request.getRequestDispatcher("/profile.jsp").forward(request, response);
                return;
            }
            
            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("errorMsg", "两次输入的密码不一致");
                // 验证失败时，回显用户原始的联系信息
                request.setAttribute("phone", originalPhone);
                request.setAttribute("email", originalEmail);
                request.getRequestDispatcher("/profile.jsp").forward(request, response);
                return;
            }
            
            if (newPassword.length() < 6) {
                request.setAttribute("errorMsg", "密码长度不能少于6位");
                // 验证失败时，回显用户原始的联系信息
                request.setAttribute("phone", originalPhone);
                request.setAttribute("email", originalEmail);
                request.getRequestDispatcher("/profile.jsp").forward(request, response);
                return;
            }
        }
        
        // 手机号格式验证（非空时）
        if (inputPhone != null && !inputPhone.trim().isEmpty()) {
            if (!inputPhone.matches("^1[3-9]\\d{9}$")) {
                request.setAttribute("errorMsg", "请输入正确的手机号格式");
                // 验证失败时，回显用户原始的联系信息
                request.setAttribute("phone", originalPhone);
                request.setAttribute("email", originalEmail);
                request.getRequestDispatcher("/profile.jsp").forward(request, response);
                return;
            }
        }
        
        // 邮箱格式验证（非空时）
        if (inputEmail != null && !inputEmail.trim().isEmpty()) {
            if (!inputEmail.matches("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")) {
                request.setAttribute("errorMsg", "请输入正确的邮箱格式");
                // 验证失败时，回显用户原始的联系信息
                request.setAttribute("phone", originalPhone);
                request.setAttribute("email", originalEmail);
                request.getRequestDispatcher("/profile.jsp").forward(request, response);
                return;
            }
        }
        
        // 更新数据库 - 使用ProfileDAO
        boolean success = false;
        
        try {
            // 使用ProfileDAO更新用户信息
            success = profileDAO.updateUserProfile(username, newPassword, inputPhone, inputEmail);
            System.out.println("ProfileServlet更新用户信息结果: " + (success ? "成功" : "失败"));
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "数据库操作失败：" + e.getMessage());
        }
        
        // 设置结果信息
        if (success) {
            request.setAttribute("successMsg", "个人信息修改成功！");
            // 修改成功后，显示新修改的信息
            request.setAttribute("phone", inputPhone);
            request.setAttribute("email", inputEmail);
        } else if (request.getAttribute("errorMsg") == null) {
            request.setAttribute("errorMsg", "个人信息修改失败，请重试");
            // 修改失败时，回显用户原始的联系信息
            request.setAttribute("phone", originalPhone);
            request.setAttribute("email", originalEmail);
        }
        
        // 设置用户名
        request.setAttribute("currentUsername", username);
        
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }
}
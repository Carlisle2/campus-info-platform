package com.m01student;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.m01major.MajorBean;
import com.m01major.MajorDAO;

/**
 * Servlet implementation class StudentServlet
 */
@WebServlet("/StudentServlet")
public class StudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private StudentDAO studentDAO;
    private MajorDAO majorDAO;
    
    /**
     * @see HttpServlet#HttpServlet()
     */
    public StudentServlet() {
        super();
    }
    
    @Override
    public void init() throws ServletException {
        studentDAO = new StudentDAO();
        majorDAO = new MajorDAO();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 设置字符编码
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        String action = request.getParameter("action");
        System.out.println("StudentServlet doGet action: " + action);
        
        if ("delete".equals(action)) {
            // 删除学生
            String studentId = request.getParameter("studentId");
            if (studentId != null && !studentId.trim().isEmpty()) {
                boolean success = studentDAO.deleteStudent(studentId);
                if (success) {
                    request.setAttribute("message", "删除成功");
                    request.setAttribute("messageType", "success");
                } else {
                    request.setAttribute("message", "删除失败");
                    request.setAttribute("messageType", "error");
                }
            }
            // 重新查询并显示列表
            queryAndForward(request, response);
            
        } else if ("edit".equals(action)) {
            // 跳转到修改页面
            String studentId = request.getParameter("studentId");
            if (studentId != null && !studentId.trim().isEmpty()) {
                StudentBean student = studentDAO.getStudentById(studentId);
                List<MajorBean> majors = majorDAO.getAllMajors();
                
                request.setAttribute("student", student);
                request.setAttribute("majors", majors);
                request.getRequestDispatcher("student_update.jsp").forward(request, response);
            } else {
                response.sendRedirect("student_query.jsp");
            }
            
        } else if ("add".equals(action)) {
        	// 增加学生
            handleAddPage(request, response);
            
        } else if ("query".equals(action)) {
            // 查询学生
            queryAndForward(request, response);
            
        } else {
            // 默认跳转到查询页面
            response.sendRedirect("student_query.jsp");
        }     
        
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 设置字符编码
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        String action = request.getParameter("action");
        System.out.println("StudentServlet doPost action: " + action);
        
        if ("add".equals(action)) {
            // 新增学生
            StudentBean bean = new StudentBean();
            bean.setStudentName(request.getParameter("studentName"));
            bean.setGender(request.getParameter("gender"));
            bean.setMajorName(request.getParameter("majorName")); // 接收专业名称
            bean.setRemark(request.getParameter("remark"));
            
            boolean success = studentDAO.addStudent(bean);
            if (success) {
                request.setAttribute("message", "新增成功");
                request.setAttribute("messageType", "success");
            } else {
                request.setAttribute("message", "新增失败");
                request.setAttribute("messageType", "error");
            }
            request.getRequestDispatcher("student_add.jsp").forward(request, response);
            
        } else if ("update".equals(action)) {
            // 修改学生
            StudentBean bean = new StudentBean();
            bean.setStudentId(request.getParameter("studentId"));
            bean.setStudentName(request.getParameter("studentName"));
            bean.setGender(request.getParameter("gender"));
            bean.setMajorId(request.getParameter("majorId"));
            bean.setRemark(request.getParameter("remark"));
            
            boolean success = studentDAO.updateStudent(bean);
            if (success) {
                request.setAttribute("message", "修改成功");
                request.setAttribute("messageType", "success");
            } else {
                request.setAttribute("message", "修改失败");
                request.setAttribute("messageType", "error");
            }
            
            // 重新获取学生信息和专业列表
            StudentBean updatedStudent = studentDAO.getStudentById(bean.getStudentId());
            List<MajorBean> majors = majorDAO.getAllMajors();
            
            request.setAttribute("student", updatedStudent);
            request.setAttribute("majors", majors);
            request.getRequestDispatcher("student_update.jsp").forward(request, response);
            
        } else if ("query".equals(action)) {
            // 查询学生
            queryAndForward(request, response);
            
        } else {
            // 默认查询
            queryAndForward(request, response);
        }
    }
    
    private void queryAndForward(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String studentId = request.getParameter("studentId");
        String studentName = request.getParameter("studentName");
        String majorName = request.getParameter("majorName");
        
        // 分页参数
        int pageNum = 1;
        int pageSize = 10; // 每页显示10条
        
        try {
            String pageNumStr = request.getParameter("pageNum");
            if (pageNumStr != null && !pageNumStr.trim().isEmpty()) {
                pageNum = Integer.parseInt(pageNumStr);
                if (pageNum < 1) pageNum = 1;
            }
        } catch (NumberFormatException e) {
            pageNum = 1;
        }
        
        // 查询数据
        List<StudentBean> studentList = studentDAO.queryStudentsByPage(studentId, studentName, majorName, pageNum, pageSize);
        int totalCount = studentDAO.getTotalCount(studentId, studentName, majorName);
        
        // 计算总页数
        int totalPage = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPage == 0) totalPage = 1;
        
        // 确保当前页不超过总页数
        if (pageNum > totalPage) {
            pageNum = totalPage;
        }
        
        request.setAttribute("studentList", studentList);
        request.setAttribute("studentId", studentId);
        request.setAttribute("studentName", studentName);
        request.setAttribute("majorName", majorName);
        request.setAttribute("pageNum", pageNum);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("totalPage", totalPage);
        
        request.getRequestDispatcher("student_query.jsp").forward(request, response);
    }
    
    private void handleAddPage(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // 获取所有专业信息
        List<MajorBean> majors = studentDAO.getAllMajors();
        
        // 将专业列表设置到request中
        request.setAttribute("majors", majors);
        
        // 转发到添加页面
        request.getRequestDispatcher("student_add.jsp").forward(request, response);
    }
}
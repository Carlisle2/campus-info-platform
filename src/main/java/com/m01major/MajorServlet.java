package com.m01major;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class MajorServlet
 */
@WebServlet("/MajorServlet")
public class MajorServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MajorDAO majorDAO;
    
    /**
     * @see HttpServlet#HttpServlet()
     */
    public MajorServlet() {
        super();
    }
    
    @Override
    public void init() throws ServletException {
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
        System.out.println("MajorServlet doGet action: " + action);
        
        if ("delete".equals(action)) {
            // 删除专业
            String majorId = request.getParameter("majorId");
            if (majorId != null && !majorId.trim().isEmpty()) {
                boolean success = majorDAO.deleteMajor(majorId);
                if (success) {
                    request.setAttribute("message", "删除成功");
                    request.setAttribute("messageType", "success");
                } else {
                    request.setAttribute("message", "删除失败（可能还有学生关联）");
                    request.setAttribute("messageType", "error");
                }
            }
            // 重新查询并显示列表
            queryAndForward(request, response);
            
        } else if ("edit".equals(action)) {
            // 跳转到修改页面
            String majorId = request.getParameter("majorId");
            if (majorId != null && !majorId.trim().isEmpty()) {
                MajorBean major = majorDAO.getMajorById(majorId);
                request.setAttribute("major", major);
                request.getRequestDispatcher("major_update.jsp").forward(request, response);
            } else {
                response.sendRedirect("major_query.jsp");
            }
            
        } else if ("query".equals(action)) {
            // 查询专业
            queryAndForward(request, response);
            
        } else {
            // 默认跳转到查询页面
            response.sendRedirect("major_query.jsp");
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
        System.out.println("MajorServlet doPost action: " + action);
        
        if ("add".equals(action)) {
            // 新增专业
            MajorBean bean = new MajorBean();
            bean.setMajorName(request.getParameter("majorName"));
            
            boolean success = majorDAO.addMajor(bean);
            if (success) {
                request.setAttribute("message", "新增成功");
                request.setAttribute("messageType", "success");
            } else {
                request.setAttribute("message", "新增失败");
                request.setAttribute("messageType", "error");
            }
            request.getRequestDispatcher("major_add.jsp").forward(request, response);
            
        } else if ("update".equals(action)) {
            // 修改专业
            MajorBean bean = new MajorBean();
            bean.setMajorId(request.getParameter("majorId"));
            bean.setMajorName(request.getParameter("majorName"));
            
            boolean success = majorDAO.updateMajor(bean);
            if (success) {
                request.setAttribute("message", "修改成功");
                request.setAttribute("messageType", "success");
            } else {
                request.setAttribute("message", "修改失败");
                request.setAttribute("messageType", "error");
            }
            
            // 重新获取专业信息
            MajorBean updatedMajor = majorDAO.getMajorById(bean.getMajorId());
            request.setAttribute("major", updatedMajor);
            request.getRequestDispatcher("major_update.jsp").forward(request, response);
            
        } else if ("query".equals(action)) {
            // 查询专业
            queryAndForward(request, response);
            
        } else {
            // 默认查询
            queryAndForward(request, response);
        }
    }
    
    private void queryAndForward(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String majorId = request.getParameter("majorId");
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
        List<MajorBean> majorList = majorDAO.queryMajorsByPage(majorId, majorName, pageNum, pageSize);
        int totalCount = majorDAO.getTotalCount(majorId, majorName);
        
        // 计算总页数
        int totalPage = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPage == 0) totalPage = 1;
        
        // 确保当前页不超过总页数
        if (pageNum > totalPage) {
            pageNum = totalPage;
        }
        
        request.setAttribute("majorList", majorList);
        request.setAttribute("majorId", majorId);
        request.setAttribute("majorName", majorName);
        request.setAttribute("pageNum", pageNum);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("totalPage", totalPage);
        
        request.getRequestDispatcher("major_query.jsp").forward(request, response);
    }

}
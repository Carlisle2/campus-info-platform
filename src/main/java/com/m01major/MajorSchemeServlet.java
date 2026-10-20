package com.m01major;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class MajorSchemeServlet
 */
@WebServlet("/MajorSchemeServlet")
public class MajorSchemeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MajorSchemeDAO majorSchemeDAO;
    
    /**
     * @see HttpServlet#HttpServlet()
     */
    public MajorSchemeServlet() {
        super(); 
    }
    
    @Override
    public void init() throws ServletException {
        majorSchemeDAO = new MajorSchemeDAO();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 设置字符编码
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        
        String action = request.getParameter("action");
        System.out.println("MajorSchemeServlet doGet action: " + action);
        
        if ("delete".equals(action)) {
            // 删除培养方案
            String majorName = request.getParameter("majorName");
            if (majorName != null && !majorName.trim().isEmpty()) {
                boolean success = majorSchemeDAO.deleteMajorScheme(majorName);
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
            
        } else if ("query".equals(action)) {
            // 查询培养方案
            queryAndForward(request, response);
            
        } else {
            // 默认跳转到查询页面
            request.getRequestDispatcher("major_scheme.jsp").forward(request, response);
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
        System.out.println("MajorSchemeServlet doPost action: " + action);
        
        if ("add".equals(action)) {
            // 新增培养方案
            String collegeName = request.getParameter("collegeName");
            String majorName = request.getParameter("majorName");
            
            // 验证输入
            if (collegeName == null || collegeName.trim().isEmpty()) {
                request.setAttribute("message", "学院名称不能为空");
                request.setAttribute("messageType", "error");
                request.getRequestDispatcher("major_scheme_add.jsp").forward(request, response);
                return;
            }
            
            if (majorName == null || majorName.trim().isEmpty()) {
                request.setAttribute("message", "专业名称不能为空");
                request.setAttribute("messageType", "error");
                request.setAttribute("collegeName", collegeName);
                request.getRequestDispatcher("major_scheme_add.jsp").forward(request, response);
                return;
            }
            
            // 检查是否已存在该专业的培养方案
            if (majorSchemeDAO.hasSchemeForMajorByMajorName(majorName.trim())) {
                request.setAttribute("message", "该专业已存在培养方案记录");
                request.setAttribute("messageType", "error");
                request.setAttribute("collegeName", collegeName);
                request.setAttribute("majorName", majorName);
                request.getRequestDispatcher("major_scheme_add.jsp").forward(request, response);
                return;
            }
            
            // 创建Bean对象并保存
            try {
                MajorSchemeBean bean = new MajorSchemeBean();
                bean.setCollegeName(collegeName.trim());
                bean.setMajorName(majorName.trim());
                
                boolean success = majorSchemeDAO.addMajorScheme(bean);
                
                if (success) {
                    request.setAttribute("message", "培养方案添加成功！系统已自动生成ID。");
                    request.setAttribute("messageType", "success");
                    // 成功后重定向到查询页面
                    queryAndForward(request, response);
                } else {
                    request.setAttribute("message", "培养方案添加失败，请重试");
                    request.setAttribute("messageType", "error");
                    request.setAttribute("collegeName", collegeName);
                    request.setAttribute("majorName", majorName);
                    request.getRequestDispatcher("major_scheme_add.jsp").forward(request, response);
                }
            } catch (Exception e) {
                request.setAttribute("message", "添加时发生错误：" + e.getMessage());
                request.setAttribute("messageType", "error");
                request.setAttribute("collegeName", collegeName);
                request.setAttribute("majorName", majorName);
                request.getRequestDispatcher("major_scheme_add.jsp").forward(request, response);
            }
            
        } else if ("query".equals(action)) {
            // 查询培养方案
            queryAndForward(request, response);
            
        } else {
            // 默认查询
            queryAndForward(request, response);
        }
    }
    
    private void queryAndForward(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String searchMajorName = request.getParameter("searchMajorName");
        String searchCollegeName = request.getParameter("searchCollegeName");
        
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
        List<MajorSchemeBean> schemeList = majorSchemeDAO.queryMajorSchemesByPage(
            searchMajorName, searchCollegeName, pageNum, pageSize);
        int totalCount = majorSchemeDAO.getTotalCount(searchMajorName, searchCollegeName);
        
        // 计算总页数
        int totalPage = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPage == 0) totalPage = 1;
        
        // 确保当前页不超过总页数
        if (pageNum > totalPage) {
            pageNum = totalPage;
        }
        
        request.setAttribute("schemeList", schemeList);
        request.setAttribute("searchMajorName", searchMajorName);
        request.setAttribute("searchCollegeName", searchCollegeName);
        request.setAttribute("pageNum", pageNum);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("totalPage", totalPage);
        request.setAttribute("hasSearched", true);
        
        request.getRequestDispatcher("major_scheme.jsp").forward(request, response);
    }
}
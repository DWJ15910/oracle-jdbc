<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import ="java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	//DB연동
	String driver="oracle.jdbc.driver.OracleDriver";
	String dburl="jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser="hr";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl,dbuser,dbpw);
	System.out.println(conn);
	
	//변수 선언
	int rowPerPage= 10;
	int currentPage = 1;
	
	//페이징 유효성검사
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	int startRow = (currentPage-1)*rowPerPage+1;
	int endRow = startRow+(rowPerPage-1);
	
	
	//전체 행 구하기
	int totalRow = 0;
	String totalRowSql = "select count(*) from employees";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt("count(*)");
	}
	if(endRow>totalRow){
		endRow = totalRow;
	}
	String rank = "rank()";
	if(request.getParameter("rank") !=null){
		rank = request.getParameter("rank");
		System.out.println(rank+"<--rank");
	}
	//RANK 함수 펑선 리스트 출력
	String sql = "SELECT 번호, 아이디, 이름, 급여, 급여순위,급여랭크 " +
				"FROM (SELECT rownum 번호, 아이디, 이름, 급여, 급여순위,급여랭크 " +
				"FROM (SELECT employee_id 아이디, last_name 이름, salary 급여,"+rank+" OVER (ORDER BY salary DESC) 급여순위,ntile(10) OVER(ORDER BY salary DESC) 급여랭크 FROM employees)) " +
				"WHERE 번호 BETWEEN ? AND ?";
	
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1,startRow);
	stmt.setInt(2,endRow);
	ResultSet rs = stmt.executeQuery();
	
	//리스트 제작
	ArrayList<HashMap<String,Object>> list = new ArrayList<>();
	while(rs.next()){
		HashMap<String,Object> m = new HashMap<String, Object>();
		m.put("번호",rs.getInt("번호"));
		m.put("아이디",rs.getString("아이디"));
		m.put("이름",rs.getString("이름"));
		m.put("급여",rs.getInt("급여"));
		m.put("급여순위",rs.getInt("급여순위"));
		m.put("급여랭크",rs.getInt("급여랭크"));
		list.add(m);
	}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
	<div class="container">
	<h1>급여 순위</h1>
	<form action="<%=request.getContextPath()%>/rankNtileList.jsp">
		<select name="rank">
			<option value="rank()" <%= (request.getParameter("rank") != null && request.getParameter("rank").equals("rank()")) ? "selected" : "" %>>rank()</option>
			<option value="dense_rank()" <%= (request.getParameter("rank") != null && request.getParameter("rank").equals("dense_rank()")) ? "selected" : "" %>>DENSE_RANK()</option>
			<option value="row_number()" <%= (request.getParameter("rank") != null && request.getParameter("rank").equals("row_number()")) ? "selected" : "" %>>ROW_NUMBER()</option>
		</select>
		<button type="submit">전송</button>
	</form>
	<table class="table table-hover">
		<tr>
			<th>번호</th>
			<th>아이디</th>
			<th>이름</th>
			<th>급여</th>
			<th>급여순위</th>
			<th>급여랭크</th>
		</tr>
		<%
			for(HashMap<String,Object> m : list){
		%>
				<tr>
					<td><%=(Integer)m.get("번호") %></td>
					<td><%=m.get("아이디") %></td>
					<td><%=m.get("이름") %></td>
					<td><%=(Integer)m.get("급여") %>달러</td>
					<td><%=(Integer)m.get("급여순위") %>위</td>
					<td><%=(Integer)m.get("급여랭크") %>등급</td>
				</tr>
		<%
			}
		%>
	</table>
	
	<!--  페이징 -->
	<%
		int pagePerPage = 5;
		int startPage = (currentPage-1)/pagePerPage*pagePerPage+1;
		int endPage = startPage+(pagePerPage-1);
		int lastPage = totalRow/rowPerPage;
		if(totalRow%rowPerPage!=0){
			lastPage++;
		}
		if(endPage > lastPage){
			endPage=lastPage;
		}
	%>
	<div style="text-align: center;">
	<%
		if(startPage>1){
				
	%>
			<a class="btn btn-primary" href="<%=request.getContextPath() %>/rankNtileList.jsp?currentPage=<%=startPage-pagePerPage%>&rank=<%=rank%>">이전</a>
	<%	
		}
	%>
	<%
		for(int i = startPage; i<=endPage; i++){
	%>
			<a class="btn btn-primary" href="<%=request.getContextPath() %>/rankNtileList.jsp?currentPage=<%=i%>&rank=<%=rank%>"><%=i %></a>
	<%
		}
		if(endPage<lastPage){
	%>
			<a class="btn btn-primary" href="<%=request.getContextPath() %>/rankNtileList.jsp?currentPage=<%=pagePerPage+startPage%>&rank=<%=rank%>">다음</a>
	<%
		}
	%>
	</div>
	</div>
</body>
</html>
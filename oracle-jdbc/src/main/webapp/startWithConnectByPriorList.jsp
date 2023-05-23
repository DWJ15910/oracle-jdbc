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
	String sql = "select 번호,레벨,이름,직속상관아이디,루트노드 From (select rownum 번호,level 레벨,first_name 이름, manager_id 직속상관아이디, sys_connect_by_path(first_name, '-') 루트노드 from employees start with manager_id is null connect by prior employee_id = manager_id) where 번호 BETWEEN ? and ?";
	
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1,startRow);
	stmt.setInt(2,endRow);
	ResultSet rs = stmt.executeQuery();
	
	//리스트 제작
	ArrayList<HashMap<String,Object>> list = new ArrayList<>();
	while(rs.next()){
		HashMap<String,Object> m = new HashMap<String, Object>();
		m.put("번호",rs.getInt("번호"));
		m.put("레벨",rs.getInt("레벨"));
		m.put("이름",rs.getString("이름"));
		m.put("직속상관아이디",rs.getInt("직속상관아이디"));
		m.put("루트노드",rs.getString("루트노드"));
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
	<h1>인사 관리표</h1>
	<table class="table table-hover">
		<tr>
			<th>번호</th>
			<th>레벨</th>
			<th>이름</th>
			<th>직속상관아이디</th>
			<th>루트노드</th>
		</tr>
		<%
			for(HashMap<String,Object> m : list){
		%>
				<tr>
					<td><%=(Integer)m.get("번호") %></td>
					<td><%=(Integer)m.get("레벨") %>레벨</td>
					<td><%=m.get("이름") %></td>
					<td><%=(Integer)m.get("직속상관아이디") %></td>
					<td><%=m.get("루트노드") %></td>
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
				<a class="btn btn-primary" href="<%=request.getContextPath() %>/startWithConnectByPriorList.jsp?currentPage=<%=startPage-pagePerPage%>">이전</a>
		<%	
			}
		%>
		<%
			for(int i = startPage; i<=endPage; i++){
		%>
				<a class="btn btn-primary" href="<%=request.getContextPath() %>/startWithConnectByPriorList.jsp?currentPage=<%=i%>"><%=i %></a>
		<%
			}
			if(endPage<lastPage){
		%>
				<a class="btn btn-primary" href="<%=request.getContextPath() %>/startWithConnectByPriorList.jsp?currentPage=<%=pagePerPage+startPage%>">다음</a>
		<%
			}
		%>
		</div>
	</div>
</body>
</html>
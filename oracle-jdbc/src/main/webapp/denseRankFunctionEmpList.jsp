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
	
	//DENSE RANK 펑선 리스트 출력
	String denseSql = "SELECT 번호, 아이디, 이름, 급여, 급여순위 " +
				"FROM (SELECT rownum 번호, 아이디, 이름, 급여, 급여순위 " +
				"FROM (SELECT employee_id 아이디, last_name 이름, salary 급여, DENSE_RANK() OVER (ORDER BY salary DESC) 급여순위 FROM employees)) " +
				"WHERE 번호 BETWEEN ? AND ?";
	
	PreparedStatement denseStmt = conn.prepareStatement(denseSql);
	denseStmt.setInt(1,startRow);
	denseStmt.setInt(2,endRow);
	ResultSet denseRs = denseStmt.executeQuery();
	
	//리스트 제작
	ArrayList<HashMap<String,Object>> list2 = new ArrayList<>();
	while(denseRs.next()){
		HashMap<String,Object> m2 = new HashMap<String, Object>();
		m2.put("번호",denseRs.getInt("번호"));
		m2.put("아이디",denseRs.getString("아이디"));
		m2.put("이름",denseRs.getString("이름"));
		m2.put("급여",denseRs.getInt("급여"));
		m2.put("급여순위",denseRs.getInt("급여순위"));
		list2.add(m2);
	}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>DENSE_RANK()</h1>
	<table>
		<tr>
			<th>번호</th>
			<th>아이디</th>
			<th>이름</th>
			<th>급여</th>
			<th>급여순위</th>
		</tr>
		<%
			for(HashMap<String,Object> m2 : list2){
		%>
				<tr>
					<td><%=(Integer)m2.get("번호") %></td>
					<td><%=m2.get("아이디") %></td>
					<td><%=m2.get("이름") %></td>
					<td><%=(Integer)m2.get("급여") %></td>
					<td><%=(Integer)m2.get("급여순위") %></td>
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
		if(startPage>1){
	%>
			<a href="<%=request.getContextPath() %>/denseRankFunctionEmpList.jsp?currentPage=<%=startPage-pagePerPage%>">이전</a>
	<%	
		}
	%>
	<%
		for(int i = startPage; i<=endPage; i++){
	%>
			<a href="<%=request.getContextPath() %>/denseRankFunctionEmpList.jsp?currentPage=<%=i%>"><%=i %></a>
	<%
		}
		if(endPage<lastPage){
	%>
			<a href="<%=request.getContextPath() %>/denseRankFunctionEmpList.jsp?currentPage=<%=pagePerPage+startPage%>">다음</a>
	<%
		}
	%>
</body>
</html>
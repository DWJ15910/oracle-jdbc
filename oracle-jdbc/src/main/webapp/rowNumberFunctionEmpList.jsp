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
	
	//row number 펑선 리스트 출력
	String rownumSql = "SELECT 번호, 아이디, 이름, 급여, 급여순위 " +
				"FROM (SELECT rownum 번호, 아이디, 이름, 급여, 급여순위 " +
				"FROM (SELECT employee_id 아이디, last_name 이름, salary 급여, ROW_NUMBER() OVER (ORDER BY salary DESC) 급여순위 FROM employees)) " +
				"WHERE 번호 BETWEEN ? AND ?";
	
	PreparedStatement rownumStmt = conn.prepareStatement(rownumSql);
	rownumStmt.setInt(1,startRow);
	rownumStmt.setInt(2,endRow);
	ResultSet rownumRs = rownumStmt.executeQuery();
	
	//리스트 제작
	ArrayList<HashMap<String,Object>> list3 = new ArrayList<>();
	while(rownumRs.next()){
		HashMap<String,Object> m3 = new HashMap<String, Object>();
		m3.put("번호",rownumRs.getInt("번호"));
		m3.put("아이디",rownumRs.getString("아이디"));
		m3.put("이름",rownumRs.getString("이름"));
		m3.put("급여",rownumRs.getInt("급여"));
		m3.put("급여순위",rownumRs.getInt("급여순위"));
		list3.add(m3);
	}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>ROW_NUMBER()</h1>
	<table>
		<tr>
			<th>번호</th>
			<th>아이디</th>
			<th>이름</th>
			<th>급여</th>
			<th>급여순위</th>
		</tr>
		<%
			for(HashMap<String,Object> m3 : list3){
		%>
				<tr>
					<td><%=(Integer)m3.get("번호") %></td>
					<td><%=m3.get("아이디") %></td>
					<td><%=m3.get("이름") %></td>
					<td><%=(Integer)m3.get("급여") %></td>
					<td><%=(Integer)m3.get("급여순위") %></td>
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
			<a href="<%=request.getContextPath() %>/rowNumberFunctionEmpList.jsp?currentPage=<%=startPage-pagePerPage%>">이전</a>
	<%	
		}
	%>
	<%
		for(int i = startPage; i<=endPage; i++){
	%>
			<a href="<%=request.getContextPath() %>/rowNumberFunctionEmpList.jsp?currentPage=<%=i%>"><%=i %></a>
	<%
		}
		if(endPage<lastPage){
	%>
			<a href="<%=request.getContextPath() %>/rowNumberFunctionEmpList.jsp?currentPage=<%=pagePerPage+startPage%>">다음</a>
	<%
		}
	%>
</body>
</html>
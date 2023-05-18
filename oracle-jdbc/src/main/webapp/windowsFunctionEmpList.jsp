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
	
	//펑선 리스트 출력
	String sql = "SELECT 번호,아이디,이름,급여,전체급여평균,전체급여합계,전체사원수 FROM (select rownum 번호,employee_id 아이디, last_name 이름, salary 급여, "+
				    "round(avg(salary) over(),1) 전체급여평균,"+
				    "sum(salary) over() 전체급여합계,"+
				    "count(*) over() 전체사원수 from employees) WHERE 번호 between ? and ?";
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
		m.put("접체급여평균",rs.getDouble("전체급여평균"));
		m.put("전체급여합계",rs.getInt("전체급여합계"));
		m.put("전체사원수",rs.getInt("전체사원수"));
		list.add(m);
	}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<table>
		<tr>
			<th>번호</th>
			<th>아이디</th>
			<th>이름</th>
			<th>급여</th>
			<th>접체급여평균</th>
			<th>전체급여합계</th>
			<th>전체사원수</th>
		</tr>
		<%
			for(HashMap<String,Object> m : list){
		%>
				<tr>
					<td><%=(Integer)m.get("번호") %></td>
					<td><%=m.get("아이디") %></td>
					<td><%=m.get("이름") %></td>
					<td><%=(Integer)m.get("급여") %></td>
					<td><%=(Double)m.get("접체급여평균") %></td>
					<td><%=(Integer)m.get("전체급여합계") %></td>
					<td><%=(Integer)m.get("전체사원수") %></td>
				</tr>
		<%
			}
		%>
	</table>
	
	<!--  페이징 -->
	<%
		//페이징 네비게이션에 출력될 페이지의 수
		int pagePerPage = 5;
		//페이징 네비게이션의 시작부분
		int startPage = (currentPage-1)/pagePerPage*pagePerPage+1;
		//페이징 네비게이션의 끝부분
		int endPage = startPage+(pagePerPage-1);
		//페이징 네비게이션 출력의 마지막 페이지
		int lastPage = totalRow/rowPerPage;
		
		//토탈 행의 수를 한페이지당 출력될 게시물의 행의 수로 나눴을때 0이 아니면 lastPage를 +1하여 페이지가 하나더 출력가능도록 한다
		if(totalRow%rowPerPage!=0){
			lastPage++;
		}
		//lastPage가 endPage보다 작을 때 endPage에 lastPage값을 넣어서 startPage~lastPage까지만 출력가능하도록 값 교체
		if(endPage > lastPage){
			endPage=lastPage;
		}
		
		//이전 버튼의 경우에는 startPage가 1보다 클때만 출력가능하도록
		if(startPage>1){
	%>
			<a href="<%=request.getContextPath() %>/windowsFunctionEmpList.jsp?currentPage=<%=startPage-pagePerPage%>">이전</a>
	<%	
		}
	%>
	<%	//페이징 네비게이션에서 pagePerPage만큼 갯수가 나오도록 반복문 작성
		for(int i = startPage; i<=endPage; i++){
	%>
			<a href="<%=request.getContextPath() %>/windowsFunctionEmpList.jsp?currentPage=<%=i%>"><%=i %></a>
	<%
		}
		// 다음 버튼의 경우에는 lastPage가 endPage보다 클경우에만 출력가능하도록하여 마지막 페이징 네비게이션 전 까지만 출력가능하도록 변경
		if(endPage<lastPage){
	%>
			<a href="<%=request.getContextPath() %>/windowsFunctionEmpList.jsp?currentPage=<%=pagePerPage+startPage%>">다음</a>
	<%
		}
	%>
</body>
</html>
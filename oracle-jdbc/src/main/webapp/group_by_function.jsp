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
	
	//sql문 부서별 급여관련 데이터와 부서인원 데이터 출력하는 쿼리문 작성
	String sql = "SELECT department_id, job_id, count(*) FROM employees GROUP BY department_id,job_id";
	String rollSql = "SELECT department_id, job_id, count(*) FROM employees GROUP BY rollup(department_id,job_id)";
	String cubeSql = "SELECT department_id, job_id, count(*) FROM employees GROUP BY cube(department_id,job_id)";
	
	PreparedStatement stmt = conn.prepareStatement(sql);
	PreparedStatement rollStmt = conn.prepareStatement(rollSql);
	PreparedStatement cubeStmt = conn.prepareStatement(cubeSql);
	
	System.out.println(stmt);
	System.out.println(rollStmt);
	System.out.println(cubeStmt);
	
	ResultSet rs = stmt.executeQuery();
	ResultSet rollRs = rollStmt.executeQuery();
	ResultSet cubeRs = cubeStmt.executeQuery();
	
	//키,값 형식으로 가져올 값 들을 선언 (object는 여러 타입 변수선언가능)
	ArrayList<HashMap<String,Object>> list = new ArrayList<HashMap<String,Object>>();
	while(rs.next()){
		HashMap<String,Object> m = new HashMap<String, Object>();
		m.put("부서ID",rs.getInt("department_id"));
		m.put("직급ID",rs.getString("job_id"));
		m.put("합계",rs.getInt("count(*)"));
		list.add(m);
	}
	ArrayList<HashMap<String,Object>> list2 = new ArrayList<HashMap<String,Object>>();
	while(rollRs.next()){
		HashMap<String,Object> m2 = new HashMap<String, Object>();
		m2.put("부서ID",rollRs.getInt("department_id"));
		m2.put("직급ID",rollRs.getString("job_id"));
		m2.put("합계",rollRs.getInt("count(*)"));
		list2.add(m2);
	}
	ArrayList<HashMap<String,Object>> list3 = new ArrayList<HashMap<String,Object>>();
	while(cubeRs.next()){
		HashMap<String,Object> m3 = new HashMap<String, Object>();
		m3.put("부서ID",cubeRs.getInt("department_id"));
		m3.put("직급ID",cubeRs.getString("job_id"));
		m3.put("합계",cubeRs.getInt("count(*)"));
		list3.add(m3);
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
		<div class="row">
			<div class="col-sm-4">
				<h3>Employees table GROUP BY Function</h3>
				<table border="1">
					<tr>
						<td>부서ID</td>
						<td>직급ID</td>
						<td>합계</td>
					</tr>
					<%
						for(HashMap<String,Object> m:list){
					%>
							<tr>
								<td><%=(Integer)m.get("부서ID") %></td>
								<td><%=m.get("직급ID") %></td>
								<td><%=(Integer)m.get("합계") %></td>
							</tr>
					<%
						}
					%>
				</table>
			</div>
			<div class="col-sm-4">
				<h3>Employees table GROUP BY Function rollup</h3>
				<table border="1">
					<tr>
						<td>부서ID</td>
						<td>직급ID</td>
						<td>합계</td>
					</tr>
					<%
						for(HashMap<String,Object> m2:list2){
					%>
							<tr>
								<td><%=(Integer)m2.get("부서ID") %></td>
								<td><%=m2.get("직급ID") %></td>
								<td><%=(Integer)m2.get("합계") %></td>
							</tr>
					<%
						}
					%>
				</table>
			</div>
			<div class="col-sm-4">
				<h3>Employees table GROUP BY Function cube</h3> 
				<table border="1">
					<tr>
						<td>부서ID</td>
						<td>직급ID</td>
						<td>합계</td>
					</tr>
					<%
						for(HashMap<String,Object> m3:list3){
					%>
							<tr>
								<td><%=(Integer)m3.get("부서ID") %></td>
								<td><%=m3.get("직급ID") %></td>
								<td><%=(Integer)m3.get("합계") %></td>
							</tr>
					<%
						}
					%>
				</table>
			</div>
		</div><!-- row -->
	</div>
</body>
</html>
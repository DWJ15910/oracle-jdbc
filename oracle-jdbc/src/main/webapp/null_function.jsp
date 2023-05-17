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
	String sql1 = "SELECT name,nvl(first_time,0) result FROM onepiece";
	String sql2 = "SELECT name,nvl2(first_time,'success','fail') result FROM onepiece";
	String sql3 = "SELECT name,nullif(forth_time,100) result FROM onepiece";
	String sql4 = "SELECT name,coalesce(first_time,second_time,third_time,forth_time) result FROM onepiece";

	PreparedStatement stmt1 = conn.prepareStatement(sql1);
	PreparedStatement stmt2 = conn.prepareStatement(sql2);
	PreparedStatement stmt3 = conn.prepareStatement(sql3);
	PreparedStatement stmt4 = conn.prepareStatement(sql4);
	
	ResultSet rs1 = stmt1.executeQuery();
	ResultSet rs2 = stmt2.executeQuery();
	ResultSet rs3 = stmt3.executeQuery();
	ResultSet rs4 = stmt4.executeQuery();

	//키,값 형식으로 가져올 값 들을 선언 (object는 여러 타입 변수선언가능)
	ArrayList<HashMap<String,Object>> list1 = new ArrayList<HashMap<String,Object>>();
	while(rs1.next()){
		HashMap<String,Object> m1 = new HashMap<String, Object>();
		m1.put("이름",rs1.getString("name"));
		m1.put("결과",rs1.getInt("result"));
		list1.add(m1);
	}
	
	ArrayList<HashMap<String,Object>> list2 = new ArrayList<HashMap<String,Object>>();
	while(rs2.next()){
		HashMap<String,Object> m2 = new HashMap<String, Object>();
		m2.put("이름",rs2.getString("name"));
		m2.put("결과",rs2.getString("result"));
		list2.add(m2);
	}
	
	ArrayList<HashMap<String,Object>> list3 = new ArrayList<HashMap<String,Object>>();
	while(rs3.next()){
		HashMap<String,Object> m3 = new HashMap<String, Object>();
		m3.put("이름",rs3.getString("name"));
		m3.put("결과",rs3.getInt("result"));
		list3.add(m3);
	}
	
	ArrayList<HashMap<String,Object>> list4 = new ArrayList<HashMap<String,Object>>();
	while(rs4.next()){
		HashMap<String,Object> m4 = new HashMap<String, Object>();
		m4.put("이름",rs4.getString("name"));
		m4.put("결과",rs4.getInt("result"));
		list4.add(m4);
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
			<div class="col-sm-6">
				<h3>1</h3>
				<table border="1">
					<tr>
						<td>이름</td>
						<td>결과</td>
					</tr>
					<%
						for(HashMap<String,Object> m1:list1){
					%>
							<tr>
								<td><%=m1.get("이름") %></td>
								<td><%=(Integer)m1.get("결과") %></td>
							</tr>
					<%
						}
					%>
				</table>
			</div>
			<div class="col-sm-6">
				<h3>2</h3>
				<table border="1">
					<tr>
						<td>이름</td>
						<td>결과</td>
					</tr>
					<%
						for(HashMap<String,Object> m2:list2){
					%>
							<tr>
								<td><%=m2.get("이름") %></td>
								<td><%=m2.get("결과") %></td>
							</tr>
					<%
						}
					%>
				</table>
			</div>
		</div>
		<div class="row">
			<div class="col-sm-6">
				<h3>3</h3>
				<table border="1">
					<tr>
						<td>이름</td>
						<td>결과</td>
					</tr>
					<%
						for(HashMap<String,Object> m3:list3){
					%>
							<tr>
								<td><%=m3.get("이름") %></td>
								<td><%=(Integer)m3.get("결과") %></td>
							</tr>
					<%
						}
					%>
				</table>
			</div>
			<div class="col-sm-6">
				<h3>4</h3>
				<table border="1">
					<tr>
						<td>이름</td>
						<td>결과</td>
					</tr>
					<%
						for(HashMap<String,Object> m4:list4){
					%>
							<tr>
								<td><%=m4.get("이름") %></td>
								<td><%=(Integer)m4.get("결과") %></td>
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
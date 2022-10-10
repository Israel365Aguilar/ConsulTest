<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.sql.*"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
        //CONECTANDO A LA BASE DE DATOS
        Connection con;
        String url="jdbc:mysql://localhost:3306/patio365";
        String Driver="com.mysql.jdbc.Driver";
        String user="root";
        String clave="";
        Class.forName(Driver);
        con=DriverManager.getConnection(url,user,clave);
        
          HttpSession misession= request.getSession(true);
    
    String usuario = "";
    String bodega = "";
    int tipoUsuario = 0;
    int idBodega = Integer.parseInt(request.getParameter("idBodega"));//System.out.println("recibe idBodega: "+idBodega);
    int inventarioActivo = 0;
    if(misession.getAttribute("id_login") == null){
        response.sendRedirect("login.html");
    }
    else{
        PreparedStatement psLogin;
        ResultSet rsLogin;
        psLogin=con.prepareStatement("select bodega.idBodega, bodega.nombre as bodega, login.tipo as tipoUsuario, login.usuario, login.id_login, if((select status from inventario where status = 0  and idBodega = login.idBodega limit 1) = 0, if(inventario.status = 0, 1, 0), 1) as status from login left join (select * from inventario where status = 0 GROUP BY id_login) as inventario on inventario.id_login = login.id_login left join bodega on bodega.idBodega = login.idBodega where login.id_login = '"+misession.getAttribute("id_login")+"'");
        rsLogin=psLogin.executeQuery();
        if (rsLogin.next()){
            if(rsLogin.getInt("status") == 1 || rsLogin.getInt("tipoUsuario") == 2){
                usuario = rsLogin.getString("usuario");//System.out.println("usuario:"+usuario);
                tipoUsuario = rsLogin.getInt("tipoUsuario");//System.out.println("tipoUsuario:"+tipoUsuario);
                bodega = rsLogin.getString("bodega");//System.out.println("bodega:"+bodega);
               
                
                if(rsLogin.getInt("status") == 0){
                    inventarioActivo = 1;
                }
            }
            else{
                out.print("<script>alert('User Locked by Inventory'); window.location='logout.jsp'; </script>");
            }
        }  
    }
System.out.println("parametros:");

//int mostrarReporteTR = Integer.parseInt(request.getParameter("mostrarReporteTR"));System.out.println("1."+mostrarReporteTR);
String fechaInicioRTR = request.getParameter("fechaInicioRTR");System.out.println("2."+fechaInicioRTR);
String fechaFinRTR = request.getParameter("fechaFinRTR");System.out.println("3."+fechaFinRTR);
String truckPlatesTR = request.getParameter("truckPlatesTR");System.out.println("4."+truckPlatesTR);
int transporteRTR = Integer.parseInt(request.getParameter("transporteRTR"));System.out.println("5."+transporteRTR);     
//int customerRTR = Integer.parseInt(request.getParameter("customerRTR"));System.out.println("6."+customerRTR);
int statusRTR = Integer.parseInt(request.getParameter("statusRTR"));System.out.println("7."+statusRTR);

int LicenceEntryReporteTR= Integer.parseInt(request.getParameter("LicenceEntryReporteTR"));System.out.println("8."+LicenceEntryReporteTR);
int DrivernameEntryReporteTR= Integer.parseInt(request.getParameter("DrivernameEntryReporteTR"));System.out.println("9."+DrivernameEntryReporteTR);

String cadenaConsultaTR = "";
if(!truckPlatesTR.equals("")){
    cadenaConsultaTR = cadenaConsultaTR + " and tr.placas_tracto='" + truckPlatesTR + "'";
}

if(transporteRTR != 0){
    cadenaConsultaTR = cadenaConsultaTR + " and tr.transporte='" + transporteRTR + "'";
}

/*if(customerRTR != 0){
    cadenaConsultaTR = cadenaConsultaTR + " and a.cliente='" + customerRTR + "'";
}*/

if(statusRTR == 0){//IN
    System.out.println("IN");
   cadenaConsultaTR = "( \n"
+ "SELECT tr.id_tracto, tr.idBodega, tr.id_arribo, a.`status`, t.nombre as transporte, a.no_caja, tr.fecha as fechaEntrada, ifnull(tr.fecha_s, '') as fechaSalida,  \n"
+ "if(a.cargado = 1, 'Yes', 'No') as pickUp, a.operacion, tr.placas_tracto, tr.no_tracto, tr.chofer, tr.licencia,  \n"
+ "if(tr.tipo=1, 'DOCUMENTATION', 'TRAILER') AS tiopOperacion, tr.chofer AS driverNameEntry, tr.licencia, a.cliente   \n"
+ "FROM tractos tr  \n"
+ "LEFT JOIN arribo a ON a.id_arribo = tr.id_arribo  \n"
+ "LEFT JOIN transporte t ON t.id_transporte=a.transporte    \n"
+ "WHERE tr.fecha BETWEEN '"+ fechaInicioRTR +"' and '" + fechaFinRTR + " 23:59:59'  AND tr.id_arribo!=0  \n"
+ cadenaConsultaTR + "  \n"
+ "and tr.idBodega= "+idBodega+"   \n"
+ "ORDER BY tr.fecha DESC \n"
+ ") \n"
+ "UNION \n"
+ "( \n"
+ "SELECT tr.id_tracto, tr.idBodega, tr.id_arribo, '', t.nombre as transporte, '', tr.fecha as fechaEntrada, ifnull(tr.fecha_s, '') as fechaSalida,  \n"
+ "'', '', tr.placas_tracto, tr.no_tracto, tr.chofer, tr.licencia, \n"
+ "if(tr.tipo=1, 'DOCUMENTATION', 'TRAILER') AS tiopOperacion, tr.chofer AS driverNameEntry, tr.licencia,''   \n"
+ "FROM tractos tr  \n"
+ "LEFT JOIN transporte t ON t.id_transporte=tr.transporte  \n"
+ "WHERE tr.fecha BETWEEN '"+ fechaInicioRTR +"' and '" + fechaFinRTR + " 23:59:59'  AND tr.id_arribo=0  \n"
+ cadenaConsultaTR + " \n"
+ "and tr.idBodega= "+idBodega+"   \n"
+ "ORDER BY tr.fecha DESC \n"
+ ")";
}else if(statusRTR == 1){//RELEASED
    System.out.println("RELEASED");
    cadenaConsultaTR = "( \n"
+ "SELECT tr.id_tracto, tr.idBodega, tr.id_arribo, a.`status`, t.nombre as transporte, a.no_caja, tr.fecha as fechaEntrada, ifnull(tr.fecha_s, '') as fechaSalida,  \n"
+ "if(a.cargado = 1, 'Yes', 'No') as pickUp, a.operacion, tr.placas_tracto, tr.no_tracto, tr.chofer, tr.licencia,  \n"
+ "if(tr.tipo=1, 'DOCUMENTATION', 'TRAILER') AS tiopOperacion, tr.chofer AS driverNameEntry, tr.licencia, a.cliente   \n"
+ "FROM tractos tr  \n"
+ "LEFT JOIN arribo a ON a.id_arribo = tr.id_arribo  \n"
+ "LEFT JOIN transporte t ON t.id_transporte=a.transporte    \n"
+ "WHERE tr.fecha_s BETWEEN '"+ fechaInicioRTR +"' and '" + fechaFinRTR + " 23:59:59'  AND tr.id_arribo!=0  \n"
+ cadenaConsultaTR + "  \n"
+ "and tr.idBodega= "+idBodega+"   \n"
+ "ORDER BY tr.fecha_s DESC \n"
+ ") \n"
+ "UNION \n"
+ "( \n"
+ "SELECT tr.id_tracto, tr.idBodega, tr.id_arribo, '', t.nombre as transporte, '', tr.fecha as fechaEntrada, ifnull(tr.fecha_s, '') as fechaSalida,  \n"
+ "'', '', tr.placas_tracto, tr.no_tracto, tr.chofer, tr.licencia, \n"
+ "if(tr.tipo=1, 'DOCUMENTATION', 'TRAILER') AS tiopOperacion, tr.chofer AS driverNameEntry, tr.licencia,''   \n"
+ "FROM tractos tr  \n"
+ "LEFT JOIN transporte t ON t.id_transporte=tr.transporte  \n"
+ "WHERE tr.fecha_s BETWEEN '"+ fechaInicioRTR +"' and '" + fechaFinRTR + " 23:59:59'  AND tr.id_arribo=0  \n"
+ cadenaConsultaTR + " \n"
+ "and tr.idBodega= "+idBodega+"   \n"
+ "ORDER BY tr.fecha_s DESC \n"
+ ")";
}

System.out.println("--cadenaConsultaTR:\n"+cadenaConsultaTR);

String armandoTablaDesK = "";
        String armandoTablaMob = "";
        PreparedStatement psC;
        ResultSet rsC;
        
        psC = con.prepareStatement(cadenaConsultaTR);
        
        rsC = psC.executeQuery();
        while(rsC.next()){
            
            int statusBase = rsC.getInt("status");
            String statusTexto = "";
            if(statusBase == 0){
                 statusTexto = "IN";
            }
            else{
                statusTexto = "RELEASED";
            }
            
            int costoTexto = 0;
            
            armandoTablaDesK = armandoTablaDesK 
                        + "<tr>"
                            + "<td>" + rsC.getString("no_tracto") + "</td>"
                            + "<td>" + rsC.getString("cliente") + "</td>"
                            + "<td>" + rsC.getString("transporte") + "</td>"
                            + "<td>" + rsC.getString("placas_tracto") + "</td>"
                            + "<td>" + rsC.getString("fechaEntrada") + "</td>"
                            + "<td>" + rsC.getString("fechaSalida") + "</td>"
                            + "<td>" + rsC.getString("pickUp") + "</td>"
                            + "<td>" + rsC.getString("tiopOperacion") + "</td>"
                            + "<td >" + rsC.getString("id_arribo") + "</td>"
                            + "<td>" + rsC.getString("no_caja") + "</td>";
            
                            if(LicenceEntryReporteTR == 1){
                                armandoTablaDesK = armandoTablaDesK + "<td>" + rsC.getString("licencia") + "</td>";
                            }
                            if(DrivernameEntryReporteTR == 1){
                                armandoTablaDesK = armandoTablaDesK + "<td>" + rsC.getString("driverNameEntry") + "</td>";
                            }
            
                            //armandoTablaDesK = armandoTablaDesK + "<td><a onclick=\"mostrarModal('divArchivos'); verArchivos(" + rsC.getString("id_arribo") + ");\" style='cursor: pointer'><img src='images/carpeta.png' width='25' height='25'></a></td>";
              
            
            armandoTablaDesK = armandoTablaDesK  + "</tr>";
            
            
            armandoTablaMob = armandoTablaMob + ""        
                + "<div class='rTable2' id='mobil'>"
                    + "<div class='rTableRow2'>"
                        + "<div class='rTableHead2'>No. Tracto</div>"
                        + "<div class='rTableHead2'>Customer</div>"
                        + "<div class='rTableHead2'>Carrier</div>"
                        + "<div class='rTableHead2'>Truck Plates</div>"
                        + "<div class='rTableHead2'>Entry</div>"
                        + "<div class='rTableHead2'>Departure</div>"
                        + "<div class='rTableHead2'>Pick Up</div>"
                        + "<div class='rTableHead2'>Operation Type</div>"
                        + "<div class='rTableHead2'>Reference</div>"
                        + "<div class='rTableHead2'>Trailer</div>";
            
                        if(LicenceEntryReporteTR == 1){
                             armandoTablaMob = armandoTablaMob + "<div class='rTableHead2'>Licence Entry</div>";
                        }
                        if(DrivernameEntryReporteTR == 1){
                            armandoTablaMob = armandoTablaMob + "<div class='rTableHead2'>Driver Name Entry</div>";
                        }
                            
                            //armandoTablaMob = armandoTablaMob + "<div class='rTableHead2'>Files</div>";
              
            
                    armandoTablaMob = armandoTablaMob +  "</div>"
                    + "<div class='rTableRow2'>"
                        + "<div class='rTableCell2'>" + rsC.getString("no_tracto") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("cliente") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("transporte") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("placas_tracto") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("fechaEntrada") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("fechaSalida") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("pickUp") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("tiopOperacion") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("id_arribo") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("no_caja") + "</div>";
                    
                    if(LicenceEntryReporteTR == 1){
                        armandoTablaMob = armandoTablaMob + "<div class='rTableCell2'>" + rsC.getString("licencia") + "</div>";
                    }
                    if(DrivernameEntryReporteTR == 1){
                        armandoTablaMob = armandoTablaMob + "<div class='rTableCell2'>" + rsC.getString("driverNameEntry") + "</div>";
                    }
                    
                            //armandoTablaMob = armandoTablaMob + "<div class='rTableCell2'><a onclick=\"mostrarModal('divArchivos'); verArchivos(" + rsC.getString("id_arribo") + ");\" style='cursor: pointer'><img src='images/carpeta.png' width='25' height='25'></a></div>";

                    armandoTablaMob = armandoTablaMob  + "</div>"         
                + "</div>";
 
            
        }
        
        String encabezadoTabla = ""
                + "<div class='rTable' id='desktop'>"
                    + "<table id='customers'>"
                       + "<tr >"
                            + "<th>No. Tracto</th>"
                            + "<th>Customer</th>"
                            + "<th>Carrier</th>"
                            + "<th>Truck Plates</th>"
                            + "<th>Entry</th>"
                            + "<th>Departure</th>"
                            + "<th>Pick Up</th>"
                            + "<th>Operation Type</th>"
                            + "<th>Reference</th>"
                            + "<th>Trailer</th>";
                            
                            if(LicenceEntryReporteTR == 1){
                                encabezadoTabla = encabezadoTabla + "<th>Licence Entry</th>";
                            }
                            if(DrivernameEntryReporteTR == 1){
                                encabezadoTabla = encabezadoTabla + "<th>Driver Name Entry</th>";
                            }
                            //encabezadoTabla = encabezadoTabla + "<th>Files</th>";
                            
                            
        encabezadoTabla = encabezadoTabla + "</tr>";
        
        String pieTabla = ""
                + "</table>"
           + "</div>";
        
        out.print(encabezadoTabla + armandoTablaDesK + pieTabla);
        out.print(armandoTablaMob);
        
 %>

</head>
<body>
<% 
    con.close();
    %>
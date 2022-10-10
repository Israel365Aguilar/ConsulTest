<%@ page import="java.util.*" %>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.text.ParseException"%>
<%@page import="java.text.SimpleDateFormat"%>

<%@page import="java.sql.*"%>
<%@page import="javax.servlet.http.HttpServlet"%>
<%@page import="javax.servlet.http.HttpServletRequest"%>
<%@page import="javax.servlet.http.HttpServletResponse"%>
<%@page import="javax.servlet.http.HttpSession"%>

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
    int idBodega = 0;
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
                usuario = rsLogin.getString("usuario");
                tipoUsuario = rsLogin.getInt("tipoUsuario");
                
                if(rsLogin.getInt("idBodega") != 0){
                    bodega = rsLogin.getString("bodega");
                    idBodega = rsLogin.getInt("idBodega");
                }
                else{
                    PreparedStatement psB;
                    ResultSet rsB;
                    psB = con.prepareStatement("select bodega.idBodega, bodega.nombre as bodega from bodega where idBodega = '"+request.getParameter("idBodega")+"'");
                    rsB = psB.executeQuery();
                    rsB.next();
                    
                    bodega = rsB.getString("bodega");
                    idBodega = rsB.getInt("idBodega");
                    
                }
                
                
                if(rsLogin.getInt("status") == 0){
                    inventarioActivo = 1;
                }
            }
            else{
                out.print("<script>alert('User Locked by Inventory'); window.location='logout.jsp'; </script>");
            }
        }  
    }
    
     Calendar cal = Calendar.getInstance();
    
     int mes = 0;
    String mesMostrar = "";
    mes = cal.get(cal.MONTH) + 1;
    if(mes < 10){
        mesMostrar = "0" + mes;
    }
    else{
        mesMostrar = "" + mes;
    }
    
    int dia = 0;
    String diaMostrar = "";
    dia = cal.get(cal.DATE);
    if(dia < 10){
        diaMostrar = "0" + dia;
    }
    else{
        diaMostrar = "" + dia;
    }


    String fechaActual = cal.get(cal.YEAR) + "-"+mesMostrar + "-" + diaMostrar;
    
    PreparedStatement ps59;
ResultSet rs59;
ps59=con.prepareStatement("select * from transporte where status=1 and nombre !='' order by nombre");       

PreparedStatement ps10;
ResultSet rs10;
ps10 = con.prepareStatement("select * from cliente where status=1 and id_cliente not in (SELECT idCliente FROM clientebloqueado WHERE idBodega ="+idBodega+") order by nombre");

%>
<style>
    #tipo_reporte {
        width: 100%;
        display: inline-block;
        padding: 5px;
    }

    #tipo_reporte input[type=radio] {
        display: none;
    }

    #tipo_reporte label {

        margin: 4px;
        padding: 8px;
        background: #B6BAC3;
        color: #4C3000;
        width: 45%;
        min-width: 100px;
        cursor: pointer;
        display: inline-block;
    }

    #tipo_reporte input[type=radio]:checked + label {
        background: #1743C4;
        color: #FAFAFA;
        display: inline-block;
    }
</style>



<!-- Modal content -->
    <div class="modal-content">
        <div class="modal-header">
          <span onclick="ocultarModal('reportes')" class="close">&times;</span>
          <h2>Get Report <%=bodega %></h2>
        </div>
        <!---->
        <div id="tipo_reporte" align="center">
            <input type="radio" id="pregunta1" name="reportes" value="0" checked>
            <label for="pregunta1">TRAILERS</label>
            <input type="radio" id="pregunta2" name="reportes" value="2">
            <label for="pregunta2">TRUCKS</label>
        </div>
        <!---->
        <div id="trailer_content">
            <div class="modal-body">
                <form action="/Patio365VL1/descarga" method="POST" target="_blank">
                <input type="hidden" id="idBodega" name="idBodega" value="<%=idBodega%>">
                
                <div class="campo">
                    <div class="calendario">
                        <label for="revision">Initial date</label><br>
                        <input type="date" id="fechaInicioR" name="fechaInicioR" value="<%=fechaActual%>">
                    </div>
                    <div class="calendario">
                        <label for="revision">Final date</label><br>
                        <input type="date" id="fechaFinR" name="fechaFinR" value="<%=fechaActual%>">
                    </div>
                </div>
                <div class="campo">  
                    <label for="Num-Trailer">Trailer Number</label>
                    <input type="text" id="noTrailerR" name="noTrailerR">
                </div>
                <div class="campo">  
                    <label for="Transport">Carrier</label>
                    <select id="transporteR" name="transporteR"> 
                      <option value="0">All Carriers</option>
                           <% 
                            rs59=ps59.executeQuery();
                            while(rs59.next()){
                                out.println("<option value='"+rs59.getInt("id_transporte")+"'>"+rs59.getString("nombre")+"</option>");
                            } %>
                    </select> 
                </div>
                <div class="campo">  
                    <label for="Customer">Customer</label>
                    <select id="customerR" name="customerR">
                        <option value="0">All Customer</option>
                            <%
                            rs10 = ps10.executeQuery();
                            while(rs10.next()){
                                out.println("<option value='"+rs10.getInt("id_cliente")+"'>"+rs10.getString("nombre")+"</option>");
                            } %>
                    </select> 
                </div>
                <div class="campo">  
                    <label for="Status">Status</label>
                    <select id="statusR" name="statusR"> 
                          <option value="0">IN</option>
                          <option value="1">RELEASED</option>
                    </select> 
                </div>
                <div class="campo">  
                    <label for="Status">To show</label>
                    <div class="radio-group">
                                <label>
                                    <input class="radio-group__option" type="radio" id="mostrarReporteA" name="mostrarReporte" value="0" onchange="mostrarMovimi()" checked="checked">
                                    <label class="radio-group__label" for="mostrarReporteA">
                                        Arrive
                                    </label>

                                    <input class="radio-group__option" type="radio" id="mostrarReporteB" name="mostrarReporte" value="1" onchange="mostrarMovimi()">
                                    <label class="radio-group__label" for="mostrarReporteB">
                                        Movements
                                    </label>
                                </label>
                        </div>
                </div><br>
                
                <div id="mostrarColumnas" style="display: none; color: #273746">
                      <table style="width:100%">
                            <tr style="width: 100%;">      
                                <td>
                                    <div id="mostrarCamposMovimientos1" style="display: none;">
                                        <input type="checkbox" id="movementsReporte" name="movementsReporte" value="1"> Movement
                                    </div>
                                </td>
                                <td>
                                    <div id="mostrarCamposMovimientos2" style="display: none;">
                                        <input type="checkbox" id="fechaMovimientoReporte" name="fechaMovimientoReporte" value="1"> Movement Date
                                    </div>
                                </td>
                                <td>
                                    <div id="mostrarCamposMovimientos3" style="display: none;">
                                        <input type="checkbox" id="editorReporte" name="editorReporte" value="1"> Editor
                                    </div>
                                </td>
                                <td>
                                    <div id="mostrarCamposMovimientos4" style="display: none;">
                                        <input type="checkbox" id="costMovementReporte" name="costMovementReporte" value="1"> Cost Movement
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <input type="checkbox" id="placasTrailerReporte" name="placasTrailerReporte" value="1"> Trailer plates
                                </td>
                                <td>
                                    <input type="checkbox" id="selloReporte" name="selloReporte" value="1"> Seal
                                </td>
                                <td>
                                    <input type="checkbox" id="candadoReporte" name="candadoReporte" value="1"> Pad lock
                                </td>
                           
                                 <td>
                                    <input type="checkbox" id="numeroReporte" name="numeroReporte" value="1"> Location Number
                                 </td>   
                            </tr>
                            <tr>
                                <td>
                                    <input type="checkbox" id="letraReporte" name="letraReporte" value="1"> Location Letter
                                </td>
                                <td>
                                    <input type="checkbox" id="numeroTruckReporte" name="numeroTruckReporte" value="1"> Truck Number
                                </td>
                                
                            
                                <td>
                                    <input type="checkbox" id="placasTruckReporte" name="placasTruckReporte" value="1"> Truck Plates
                                </td>
                                 <td>
                                    <input type="checkbox" id="choferReporte" name="choferReporte" value="1"> Driver Name
                                 </td>
                            </tr>
                            <tr>
                                <td>
                                    <input type="checkbox" id="licenciaReporte" name="licenciaReporte" value="1"> Licence
                                </td>
                                <td>
                                    <input type="checkbox" id="diasReporte" name="diasReporte" value="1"> Days
                                </td>
                                <td>
                                    <input type="checkbox" id="statusReporte" name="statusReporte" value="1"> Status
                                </td>
                                <td>
                                    <input type="checkbox" id="costoReporte" name="costoReporte" value="1"> Cost Days
                                </td>
                                
                            </tr>
                            <tr>
                               
                                <td>
                                    <input type="checkbox" id="seguimientoReporte" name="seguimientoReporte" value="1"> Tracing
                                </td>
                                <td>
                                    <input type="checkbox" id="comentarioEntrada" name="comentarioEntrada" value="1"> Entry Comment
                                </td>
                                <td>
                                    <input type="checkbox" id="comentarioMovimientos" name="comentarioMovimientos" value="1"> Comments Movements
                                </td>
                                <td>
                                    <input type="checkbox" id="comentarioSalida" name="comentarioSalida" value="1"> Release Comment
                                </td>
                            </tr>
                            

                             <tr>
                                <td>
                                    <input type="checkbox" id="fechaAutorizacion" name="fechaAutorizacion" value="1"> Authorization Date
                                </td>
                                <td>
                                    <input type="checkbox" id="FechaEntradaVSAutorizacion" name="FechaEntradaVSAutorizacion" value="1"> Ent vs Aut Date
                                </td>
                                <td>
                                    <input type="checkbox" id="FechaAutorizacionVSSalida" name="FechaAutorizacionVSSalida" value="1"> Aut vs Rel Date
                                </td>
                                <td>
                                    <input type="checkbox" id="FechaEntradaVSSalida" name="FechaEntradaVSSalida" value="1"> Ent vs Rel Date
                                </td>
                            </tr>
                            
                            
                            
                      </table>
                </div>
                <br>    
                <div style="text-align: center; display: block;" id="mostrarMas">
                    <a style="cursor:pointer" onclick="mostrarCamposBoton()">
                        <img  src="images/abajo.png" alt="+" style="height: 18px; width: 18px">
                    </a>
                </div>
                    
                <div style="text-align: center; display: none;" id="mostrarMenos">
                    <a style="cursor:pointer" onclick="mostrarCamposBoton()">
                        <img src="images/arriba.png" alt="+" style="height: 18px; width: 18px">
                    </a>
                </div>
          
          
            <div class="enlace">
                <a class="btn-a" onclick="actualizaRegistros(<%=idBodega%>)" style="cursor:pointer; width: 80%">SEARCH</a>
                
                <button type="submit" title="Export to Excel" >
                    <img src="images/excel.png" alt="Export to Excel" style="height: 15px; width:18px">
                </button>
            </div>
        </form>
                <div id="tablaReportes" style="overflow-x: auto;">
        <%
        
        String armandoTablaDesK = "";
        String armandoTablaMob = "";
        PreparedStatement psC;
        ResultSet rsC;
        
        psC = con.prepareStatement("SELECT id_arribo, cliente.nombre as cliente, transporte.nombre as transporte, no_caja, arribo.fecha as fechaEntrada, ifnull(arribo.fecha_s, '') as fechaSalida, if(cargado = 1, 'Yes', 'No') as cargado, operacion FROM arribo left JOIN cliente on cliente.id_cliente=arribo.cliente LEFT JOIN transporte ON transporte.id_transporte=arribo.transporte WHERE fecha >= DATE_FORMAT(now(), '%Y-%m-%d') and fecha <= DATE_FORMAT(now(), '%Y-%m-%d 23:59:59') and arribo.idBodega= "+ idBodega + " ORDER BY fecha DESC");
        
        rsC = psC.executeQuery();
        while(rsC.next()){
            
            armandoTablaDesK = armandoTablaDesK 
                        + "<tr>"
                            + "<td >" + rsC.getString("id_arribo") + "</td>"
                            + "<td>" + rsC.getString("cliente") + "</td>"
                            + "<td>" + rsC.getString("transporte") + "</td>"
                            + "<td>" + rsC.getString("no_caja") + "</td>"
                            + "<td>" + rsC.getString("fechaEntrada") + "</td>"
                            + "<td>" + rsC.getString("fechaSalida") + "</td>"
                            + "<td>" + rsC.getString("cargado") + "</td>"
                            + "<td>" + rsC.getString("operacion") + "</td>"
                            + "<td><a onclick=\"mostrarModal('divArchivos'); verArchivos(" + rsC.getString("id_arribo") + ");\" style='cursor: pointer'><img src='images/carpeta.png' width='25' height='25'></a></td>"

                        + "</tr>";
            
            
            armandoTablaMob = armandoTablaMob + ""        
                + "<div class='rTable2' id='mobil'>"
                    + "<div class='rTableRow2'>"
                        + "<div class='rTableHead2'>No.</div>"
                        + "<div class='rTableHead2'>Custumer</div>"
                        + "<div class='rTableHead2'>Carrier</div>"
                        + "<div class='rTableHead2'>Trailer No.</div>"
                        + "<div class='rTableHead2'>Entry</div>"
                        + "<div class='rTableHead2'>Departure</div>"
                        + "<div class='rTableHead2'>Load?</div>"
                        + "<div class='rTableHead2'>Operation</div>"
                        + "<div class='rTableHead2'>Files</div>"
                    + "</div>"
                    + "<div class='rTableRow2'>"
                        + "<div class='rTableCell2'>" + rsC.getString("id_arribo") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("cliente") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("transporte") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("no_caja") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("fechaEntrada") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("fechaSalida") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("cargado") + "</div>"
                        + "<div class='rTableCell2'>" + rsC.getString("operacion") + "</div>"
                        + "<div class='rTableCell2'><a onclick=\"mostrarModal('divArchivos'); verArchivos(" + rsC.getString("id_arribo") + ");\" style='cursor: pointer'><img src='images/carpeta.png' width='20' height='20'></a></div>"
                    + "</div>"         
                + "</div>";
 
            
        }
        
        String encabezadoTabla = ""
                + "<div class='rTable' id='desktop'>"
                    + "<table id='customers'>"
                       + "<tr >"
                            + "<th>No.</th>"
                            + "<th>Custumer</th>"
                            + "<th>Carrier</th>"
                            + "<th>Trailer No.</th>"
                            + "<th>Entry</th>"
                            + "<th>Departure</th>"
                            + "<th>Load?</th>"
                            + "<th>Operation</th>"
                            + "<th>Files</th>"
                        + "</tr>";
        
        String pieTabla = ""
                + "</table>"
           + "</div>";
        
        out.print(encabezadoTabla + armandoTablaDesK + pieTabla);
        out.print(armandoTablaMob);
        %> 
            </div>
            </div>
        </div>
        <div id="trucks_content" style="display:none">
            <div class="modal-body">
            <!---------------------------------------------->    
            <form action="/Patio365VL1/descarga" method="POST" target="_blank">
                <input type="hidden" id="idBodegaTR" name="idBodegaTR" value="<%=idBodega%>">
                <div class="campo">
                    <div class="calendario">
                        <label for="revisionTR">Initial date</label><br>
                        <input type="date" id="fechaInicioRTR" name="fechaInicioRTR" value="<%=fechaActual%>">
                    </div>
                    <div class="calendario">
                        <label for="revision">Final date</label><br>
                        <input type="date" id="fechaFinRTR" name="fechaFinRTR" value="<%=fechaActual%>">
                    </div>
                </div><br>
                <div class="campo">  
                    <label for="Num-TrailerTR">Truck Plates</label>
                    <input type="text" id="truckPlatesTR" name="truckPlatesTR">
                </div>
                <div class="campo">  
                    <label for="TransportTR">Carrier</label>
                    <select id="transporteRTR" name="transporteRTR"> 
                      <option value="0">All Carriers</option>
                           <% 
                            rs59=ps59.executeQuery();
                            while(rs59.next()){
                                out.println("<option value='"+rs59.getInt("id_transporte")+"'>"+rs59.getString("nombre")+"</option>");
                            } %>
                    </select> 
                </div>
                <!--<div class="campo">  
                    <label for="CustomerTR">Customer</label>
                    <select id="customerRTR" name="customerRTR">
                        <option value="0">All Customer</option>
                            <%
                            /*rs10 = ps10.executeQuery();
                            while(rs10.next()){
                                out.println("<option value='"+rs10.getInt("id_cliente")+"'>"+rs10.getString("nombre")+"</option>");
                            } */%>
                    </select> 
                </div>-->
                <div class="campo">  
                    <label for="StatusTR">Status</label>
                    <select id="statusRTR" name="statusRTR"> 
                          <option value="0">IN</option>
                          <option value="1">RELEASED</option>
                    </select> 
                </div>
                <div class="campo">  
                    <label for="StatusTR">To show</label>
                    <div class="radio-group">
                        <label>
                            <input class="radio-group__option" type="radio" id="mostrarReporteATR" name="mostrarReporte" value="2" onchange="mostrarMovimiTR()" checked="checked">
                                <label class="radio-group__label" for="mostrarReporte">
                                    Arrive
                                </label>
                         </label>
                    </div>
                </div><br>
                <div id="mostrarColumnasTR" style="display: none; color: #273746">
                      <table style="width:100%">
                            <tr>
                                <!--<td>
                                    <input type="checkbox" id="NoTractoTR" name="NoTractoTR" value="1"> No. Tracto
                                </td>-->
                                <td>
                                    <input type="checkbox" id="DrivernameEntryReporteTR" name="DrivernameEntryReporteTR" value="1"> Driver Name Entry
                                </td> 
                                <td>
                                    <input type="checkbox" id="LicenceEntryReporteTR" name="LicenceEntryReporteTR" value="1"> Licence Entry
                                </td>
                            </tr>
                      </table>
                </div>
                <br>
                <div style="text-align: center; display: block;" id="mostrarMasTR">
                    <a style="cursor:pointer" onclick="mostrarCamposBotonTR()">
                        <img  src="images/abajo.png" alt="+" style="height: 18px; width: 18px">
                    </a>
                </div>
                <div style="text-align: center; display: none;" id="mostrarMenosTR">
                    <a style="cursor:pointer" onclick="mostrarCamposBotonTR()">
                        <img src="images/arriba.png" alt="+" style="height: 18px; width: 18px">
                    </a>
                </div>
                <div class="enlace">
                    <a class="btn-a" onclick="actualizaRegistrosTR(<%=idBodega%>)" style="cursor:pointer; width: 80%">SEARCH</a>

                    <button type="submit" title="Export to Excel" >
                        <img src="images/excel.png" alt="Export Truks Report to Excel" style="height: 15px; width:18px">
                    </button>
                </div>
            </form>
            <div id="tablaReportesTR" style="overflow-x: auto;">
            <%
                String armandoTablaDesKTR = "";
                String armandoTablaMobTR = "";
                PreparedStatement psCTR;
                ResultSet rsCTR;
                String sql_trucks = "( \n"
+ "SELECT tr.id_tracto, tr.id_arribo,transporte.nombre as transporte, a.no_caja, tr.fecha as fechaEntrada, ifnull(tr.fecha_s, '') as fechaSalida,   \n"
+ "if(a.cargado = 1, 'Yes', 'No') as pickUp, a.operacion, tr.placas_tracto,if(tr.tipo=1, 'DOCUMENTATION', 'TRAILER') AS tiopOperacion, tr.no_tracto,a.cliente  \n"
+ "FROM tractos tr   \n"
+ "LEFT JOIN arribo a ON a.id_arribo = tr.id_arribo   \n"
+ "LEFT JOIN transporte ON transporte.id_transporte=a.transporte    \n"
+ "WHERE tr.fecha >= DATE_FORMAT(now(), '%Y-%m-%d') AND tr.fecha <= DATE_FORMAT(now(), '%Y-%m-%d 23:59:59')  AND tr.id_arribo!=0 \n"
+ "and tr.idBodega= "+idBodega+"  ORDER BY tr.fecha DESC  \n"
+ ")  \n"
+ "UNION  \n"
+ "(  \n"
+ "SELECT tr.id_tracto, tr.id_arribo,transporte.nombre as transporte, '', tr.fecha as fechaEntrada, ifnull(tr.fecha_s, '') as fechaSalida,   \n"
+ "'', '', tr.placas_tracto,if(tr.tipo=1, 'DOCUMENTATION', 'TRAILER') AS tiopOperacion, tr.no_tracto,''  \n"
+ "FROM tractos tr   \n"
+ "LEFT JOIN transporte ON transporte.id_transporte=tr.transporte    \n"
+ "WHERE tr.fecha >= DATE_FORMAT(now(), '%Y-%m-%d') AND tr.fecha <= DATE_FORMAT(now(), '%Y-%m-%d 23:59:59')  AND tr.id_arribo=0  \n"
+ "and tr.idBodega= "+idBodega+" ORDER BY tr.fecha DESC  \n"
+ ")";
                System.out.println("--sql_trucks-->"+sql_trucks);
                psCTR = con.prepareStatement(sql_trucks);
        
                rsCTR = psCTR.executeQuery();
                while(rsCTR.next()){
                    armandoTablaDesKTR = armandoTablaDesKTR 
                        + "<tr>"
                            + "<td>" + rsCTR.getString("no_tracto") + "</td>"
                            + "<td>" + rsCTR.getString("cliente") + "</td>"
                            + "<td>" + rsCTR.getString("transporte") + "</td>"
                            + "<td>" + rsCTR.getString("placas_tracto") + "</td>"
                            + "<td>" + rsCTR.getString("fechaEntrada") + "</td>"
                            + "<td>" + rsCTR.getString("fechaSalida") + "</td>"
                            + "<td>" + rsCTR.getString("pickUp") + "</td>"
                            + "<td>" + rsCTR.getString("tiopOperacion") + "</td>"
                            + "<td>" + rsCTR.getString("id_arribo") + "</td>"
                            + "<td>" + rsCTR.getString("no_caja") + "</td>"
                            //+ "<td><a onclick=\"mostrarModal('divArchivos'); verArchivos(" + rsCTR.getString("id_arribo") + ");\" style='cursor: pointer'><img src='images/carpeta.png' width='25' height='25'></a></td>"

                        + "</tr>";
                    
                    armandoTablaMobTR = armandoTablaMobTR + ""  
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
                        + "<div class='rTableHead2'>Trailer</div>"
                    + "</div>"
                    + "<div class='rTableRow2'>"
                        + "<div class='rTableCell2'>" + rsCTR.getString("no_tracto") + "</div>"
                        + "<div class='rTableCell2'>" + rsCTR.getString("cliente") + "</div>"
                        + "<div class='rTableCell2'>" + rsCTR.getString("transporte") + "</div>"
                        + "<div class='rTableCell2'>" + rsCTR.getString("placas_tracto") + "</div>"
                        + "<div class='rTableCell2'>" + rsCTR.getString("fechaEntrada") + "</div>"
                        + "<div class='rTableCell2'>" + rsCTR.getString("fechaSalida") + "</div>"
                        + "<div class='rTableCell2'>" + rsCTR.getString("pickUp") + "</div>"
                        + "<div class='rTableCell2'>" + rsCTR.getString("tiopOperacion") + "</div>"
                        + "<div class='rTableCell2'>" + rsCTR.getString("id_arribo") + "</div>"
                        + "<div class='rTableCell2'>" + rsCTR.getString("no_caja") + "</div>"
                        //+ "<div class='rTableCell2'><a onclick=\"mostrarModal('divArchivos'); verArchivos(" + rsCTR.getString("id_arribo") + ");\" style='cursor: pointer'><img src='images/carpeta.png' width='20' height='20'></a></div>"
                    + "</div>"         
                + "</div>";
 
            
                }//whilw
        
        String encabezadoTablaTR = ""
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
                            + "<th>Trailer</th>"
                        + "</tr>";
        
        String pieTablaTR = ""
                + "</table>"
           + "</div>";
        
        out.print(encabezadoTablaTR + armandoTablaDesKTR + pieTablaTR);
        out.print(armandoTablaMobTR);
        %>
            </div>
            <!---------------------------------------------->  
            </div>
        </div>
    </div>
            
            
            
            <script>
               function mostrarMovimi(){
                    if( $('#mostrarReporteB').prop('checked') ) {
                        document.getElementById("mostrarCamposMovimientos1").style.display = 'block';
                        document.getElementById("mostrarCamposMovimientos2").style.display = 'block';
                        document.getElementById("mostrarCamposMovimientos3").style.display = 'block';
                        document.getElementById("mostrarCamposMovimientos4").style.display = 'block';
                    }
                    else{
                        document.getElementById("mostrarCamposMovimientos1").style.display = 'none';
                        document.getElementById("mostrarCamposMovimientos2").style.display = 'none';
                        document.getElementById("mostrarCamposMovimientos3").style.display = 'none';
                        document.getElementById("mostrarCamposMovimientos4").style.display = 'none';
                    }
                   
               }
               
                $("#tipo_reporte input").change(function () {
                    if ($(this).is(':checked')) {

                        if ($(this).val() == 2) {
                            $("#trailer_content").css("display", "none");
                            $("#trucks_content").css("display", "block");
                        }else {
                            $("#trailer_content").css("display", "block");
                            $("#trucks_content").css("display", "none");
                        }
                    }
                });
               
                </script>
                
                <% 
    con.close();
    %>
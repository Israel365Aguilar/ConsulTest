<%@page import="Modelo.Conexion"%>
<%@ page import="java.util.*" %>


<%@page import="java.sql.*"%>


<% 
    
    //CONECTANDO A LA BASE DE DATOS
    Conexion c = new Conexion();
    Connection con = c.getConnection();
        
    
    String nombreInventario = "";
    String fechaInventario = "";
    
    String usuario = "";
    String bodega = "";
    int tipoUsuario = 0;
    int idBodega = 0;
    int inventarioActivo = 0;
    int inventario = 0;
    
    HttpSession misession= request.getSession(true);
    if(misession.getAttribute("id_login") == null){
        response.sendRedirect("login.html");
    }
    else{
        
        String consulta_log = "select "
            + "bodega.idBodega, "
            + "bodega.nombre as bodega, "
            + "login.tipo as tipoUsuario, "
            + "login.usuario, "
            + "login.id_login, "
            + "if((select status from datosinventario where status = 0 and idBodega = login.idBodega limit 1) = 0, if(inventario.status = 0, 1, 0), 1) as status, "
            + "ifnull(inventarioB.status, 1) as inventario "
            + "from login "
            + "left join (select * from datosinventario where status = 0 GROUP BY id_login) as inventario on inventario.id_login = login.id_login "
            + "left join (select * from datosinventario where status = 0) as inventarioB on inventarioB.idBodega = login.idBodega "
            + "left join bodega on bodega.idBodega = login.idBodega "
            + "where login.id_login = '"+misession.getAttribute("id_login")+"'";System.out.println("consulta_log>>"+consulta_log);
        PreparedStatement psLogin=con.prepareStatement(consulta_log);
        ResultSet rsLogin=psLogin.executeQuery();
        if (rsLogin.next()){
            if(rsLogin.getInt("status") == 1 || rsLogin.getInt("tipoUsuario") == 2){
                usuario = rsLogin.getString("usuario");
                tipoUsuario = rsLogin.getInt("tipoUsuario");
                bodega = rsLogin.getString("bodega");
                idBodega = rsLogin.getInt("idBodega");
                inventario = rsLogin.getInt("inventario");
                
                
                if(rsLogin.getInt("status") == 0){
                    inventarioActivo = 1;
                }
                
                
                if(inventario == 0){
                    String consulta_inve = "SELECT "
                        + "if(login.nombre != '', concat(login.nombre, ' ', login.apellidos), login.usuario) as nombreInventario, "
                        + "fechaInicio as fechaInventario "
                        + "FROM datosinventario "
                        + "left join login on login.id_login = datosinventario.id_login "
                        + "WHERE datosinventario.status = 0 and datosinventario.idBodega = " + idBodega;
                    
                    PreparedStatement psInv = con.prepareStatement(consulta_inve);
                    ResultSet rsInv = psInv.executeQuery();
                    rsInv.next();

                    nombreInventario = rsInv.getString("nombreInventario");
                    fechaInventario = rsInv.getString("fechaInventario");
                }
            }
            else{
                out.print("<script>alert('User Locked by Inventory'); window.location='logout.jsp'; </script>");
            }
        }
        else{
            out.print("<script>alert('Session expired'); window.location='logout.jsp'; </script>");
        }
    }


    Calendar cal = Calendar.getInstance();

    Formatter mes_f = new Formatter();
    String mesMostrar = String.valueOf(mes_f.format("%02d", cal.get(cal.MONTH) + 1));

    Formatter dia_f = new Formatter();
    String diaMostrar = String.valueOf(dia_f.format("%02d", cal.get(cal.DATE)));

    String yearActual = String.valueOf(cal.get(cal.YEAR));
    String fechaActual = yearActual + "-"+mesMostrar + "-" + diaMostrar;

    
    String mesActual = yearActual + "-" + mesMostrar;
    
    int ordinalDay = cal.get(Calendar.DAY_OF_YEAR);
    int weekDay = cal.get(Calendar.DAY_OF_WEEK) - 1; // Sunday = 0
    int semanaMostrar = (ordinalDay - weekDay + 10) / 7;
    String semanaActual = "";
    if(semanaMostrar < 10){
        semanaActual = yearActual + "-W0" + semanaMostrar;
    }else{
        semanaActual = yearActual + "-W" + semanaMostrar;
    }
       
    out.print("<script>"
        + "var fechaActualInicio = '" + fechaActual + "'; "
        + "var fechaActualFin = '" + fechaActual + "'; "
        + "var semanaActualInicio = '" + semanaActual + "'; "
        + "var semanaActualFin = '" + semanaActual + "'; "
        + "var mesActualInicio = '" + mesActual + "'; "
        + "var mesActualFin = '" + mesActual + "';</script>");
%>

<!DOCTYPE html>
<html lang="en-US">
<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Grupo 365 | Control de Patios</title>
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,600,600i,700,700i,800,800i&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Open+Sans+Condensed:300,300i,700&display=swap" rel="stylesheet">  
    <!--The following script tag downloads a font from the Adobe Edge Web Fonts server for use within the web page. We recommend that you do not modify it.-->
    <script src="http://use.edgefonts.net/source-sans-pro:n2:default.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/normalize/5.0.0/normalize.min.css">
    <link href="https://fonts.googleapis.com/css?family=Titillium+Web:300,700" rel="stylesheet">

    <link rel="stylesheet prefetch" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" type="text/css" href="css/flaticon.css">

    <link rel="stylesheet" href="Menu/css/style.css">
    <link rel="stylesheet" href="css/css-index.css">
    <link rel="icon" type="image/png" href="images/ico.png" />

   <!-- <script src="js/autocompletarNew3.js?a=2"></script>-->
    <script src="js/js-index.js"></script>  
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <link rel="stylesheet" href="css/inicio.css">
    <style>
    .zoom {
      transition: transform .2s;
      margin: 0 auto;
      cursor: pointer
    }
    .zoom:hover {
      -ms-transform: scale(1.5); /* IE 9 */
      -webkit-transform: scale(1.5); /* Safari 3-8 */
      transform: scale(1.5); 
    }
    </style>
</head>

<%if(tipoUsuario == 6){%>
    <body onload="actualizarBody()">
<%}else{%>
    <body>
<%}%>
 
<!-- Main Container -->
<div class="container" style="width: 100%;"> 
  <!-- Navigation -->
    <div class="wrapper">
        <nav class="site-nav">
            <h1 class="logo" id="logo">&nbsp;<img src="images/Logo-Grupo365.svg" alt=""></h1>
      <h1 class="logo2" id="logo"><img src="images/logo-wms-02.svg" alt="">&nbsp;</h1>
        </nav>
    </div>
</div> 

<!-- Modal Cargando -->
<div id="divCargando_x" class="modal" style="opacity: 0.8; z-index: 9999; background-color: black;"data-backdrop="static" data-keyboard="false">
    <center>
        <input type="hidden" id="inpt_idbodega" value="<%=idBodega%>" >
        <input type="hidden" id="inpt_tipousuario" value="<%=tipoUsuario%>">
        <input type="hidden" id="inpt_inventarioactivo" value="<%=inventarioActivo%>">
        <img src="images/spinner.gif" style="margin-top:10%; width:5%"><br><br>
        <span id="texto_cargando" style="color:white;font-weight: bold;font-size: 150%;"></span>
    </center>
</div>


<%if(tipoUsuario != 8){%>
<div class="position-fixed">
    <div style="white-space: normal; border: 1px solid #FFFFFF;">
        <div>
            <a onclick="mostrar('divBuscaPrincipal')" style="cursor:pointer;" id="imagenBuscar">
                <img src="images/buscar.png" class="iconFot">
            </a>
        </div>
        <div style="display: none;" id='divBuscaPrincipal'>
            <input type='text' placeholder="Search" onkeyup='buscarEventosPrincipal(this.value)' id='buscaPrincipal' style="background: #FFFFFF">
        </div>
    </div>
    
    <div style="white-space: normal; border: 1px solid #FFFFFF;">
        <div>
            <a onclick="mostrar('contenedorTemporal')" style="cursor:pointer;">
                <img src="images/temporal.png" class="iconFot" id="imagenTemporal">
            </a>
        </div>
        <div id="contenedorTemporal" style="display: none; border: #226EA3 2px solid;" class="contenedorTemporal">
            <%
            //Ubicacion Temporal   
            PreparedStatement psT;
            ResultSet rsT;
            psT = con.prepareStatement("select no_caja, ubicacion.numero as ubicacion, temporal from arribo left join ubicacion on ubicacion.id_ubicacion = arribo.ubicacion where arribo.status=0 and arribo.idBodega = '"+idBodega+"' and arribo.temporal != '0' order by no_caja");
            rsT=psT.executeQuery();
            if(rsT.next()){
             out.print("<table style='width:100%;'><tr style='background-color: #226EA3; color: #FFFFFF'><th>Trailer Number</th><th>Last Location</th><th>New Location</th></tr>");
            }
            rsT=psT.executeQuery();
            while(rsT.next()){
             out.print("<tr><td>"+rsT.getString("no_caja")+"</td><td>"+rsT.getString("ubicacion")+"</td><td>"+rsT.getString("temporal")+"</td></tr>");
            }
            rsT=psT.executeQuery();
            if(rsT.next()){
             out.print("</table>");
            }
            rsT=psT.executeQuery();
            if(!rsT.next()){
             out.print("<h4>No temporary records</h4>");
            } %>
        </div>
    </div>
    <%if(idBodega == 2){%>  
    <div style="white-space: normal; border: 1px solid #FFFFFF;">
        <div>
            <a onclick="mostrarModal('mostrarSeguimiento'); buscarSeguimiento();" style="cursor:pointer;">
                <img src="images/seguimiento.png" class="iconFot">
            </a>
        </div>
    </div>
    <%}%>
    <%//if(idBodega == 1){%>  
    <div style="white-space: normal; border: 1px solid #FFFFFF;">
        <div>
            <a onclick="mostrarModal('mostrarAgenda'); buscarAgenda();" style="cursor:pointer;">
                <img src="images/agenda.png" class="iconFot">
            </a>
        </div>
    </div>
    <%//}%>
        
</div>
<%
}%>

<div class="divb" style="z-index: 1;"><b><%=usuario%></b><a href="logout.jsp" class="button">Logout</a></div>

<%if(tipoUsuario != 6){%>
    <div class="container">
        <%if(tipoUsuario == 8){
            out.print("<div class='seccion1'><h4>Dashboard</h4></div>");
        }
        else{
            out.print("<div class='seccion1'><h4>Yard / Dock control</h4></div>");
            out.print("<center><h2>" + bodega + "</h2></center>");
        }
         %>   

        <div class="contenedor">  
            <%if(tipoUsuario != 8){%>
            <div class="secciones2" style="border-top: 1px solid #bdbdbd; border-bottom: 1px solid #bdbdbd;" ondrop="drop(event)" ondragover="allowDrop(event)">
                <div class="seccion1" style="display: block;"><h5 style="font-size: 21px;">Symbology</h5></div>
               <div class="flex">
                <div><div class="modulos"><img src="images/camion-naranja-04.svg" alt=""/></div><br><span>Empty/Unload</span></div>        
                <div><div class="modulos"><img src="images/camion-verde-03.svg" alt=""/></div><br><span>Full/Load</span></div>
                  <div><div class="modulos"><img src="images/camion-gris-01.svg" alt=""/></div><br><span>Empty/Pending</span></div> 
                <div><div class="modulos"><img src="images/available-01.svg" alt=""/></div><br><span>Available</span></div>
               </div> 
            </div>
            <%}%>
            <div class="secciones2" style="border-top: 1px solid #bdbdbd; border-bottom: 1px solid #e0e0e0; background-color: #d9d9d9;" ondrop="drop(event)" ondragover="allowDrop(event)">
                <div class="seccion1" style="display: block;"><h5 style="font-size: 21px;">Actions</h5></div>
               
                <% if(inventario == 0){
                    if(inventarioActivo == 1){
                        out.print("Inventory in Process by " + nombreInventario + " " + fechaInventario + "<br>");
                    }
                    else{
                         out.print("Inventory in Process" + fechaInventario + "<br>");
                    }
                }
                %>

                <%if((tipoUsuario == 1 || tipoUsuario == 2) && inventarioActivo != 1){%>
                   <button onClick="mostrarModal('agregarNuevoArribo'); addNew(0);">Add trailer + truck</button>
                   <button onClick="mostrarModal('agregarNuevoArribo'); addTrailerOn();">Add truck</button>
                   <button onClick="mostrarModal('reportes'); mostrarContenidoReporte();">Reports</button>
                   <a class="button2" href="movements2.jsp">Movements</a>
                   <button onClick="mostrarModal('liberarTractor'); mostrarContenidoLiberarTractor();">Trucks</button>
                   <button onClick="mostrarModal('liberarTrailers'); mostrarContenidoLiberarTrailer()">Trailers</button>
                   <button onClick="mostrarModal('inventario'); buscarEventos2();">Inventory</button>
                   <a class="button2" href="admin.jsp">Admin</a>
                   <button onClick="mostrarModal('tcs'); buscarTCS();">TCS</button>
                   <button onClick="mostrarModal('slam'); buscarSLAM();">SLAM</button>
                   <a class="button2" href="pre_registro.jsp">Pre-Registration</a>
                   <a class="button2" href="pendiente.jsp">Pending</a>
                <%}else if(tipoUsuario == 3){%>
                   <button onClick="mostrarModal('reportes'); mostrarContenidoReporte('');">Reports</button>
               <%}else if(tipoUsuario == 4 || tipoUsuario == 10){%>
                   <button onClick="mostrarModal('agregarNuevoArribo'); addNew(0);">Add trailer + truck</button>
                   <button onClick="mostrarModal('agregarNuevoArribo'); addTrailerOn();">Add truck</button>
                   <button onClick="mostrarModal('reportes'); mostrarContenidoReporte('');">Reports</button>
                   <button onClick="mostrarModal('liberarTractor'); mostrarContenidoLiberarTractor();">Trucks</button>
                   <button onClick="mostrarModal('liberarTrailers'); mostrarContenidoLiberarTrailer();">Trailers</button>
                   <button onClick="mostrarModal('inventario'); buscarEventos2();">Inventory</button>
                   <a class="button2" href="pre_registro.jsp">Pre-Registration</a>
               <%}
               else if((tipoUsuario == 1 || tipoUsuario == 2) && inventarioActivo == 1){%>
               <a href="#" onclick="cancelarInventarioTI();" class="btn-a" style="background-color: #E14F4F;">Cancel Inventory</a>
               <%}else if(tipoUsuario == 7 ){%>
                <button onClick="mostrarModal('reportes'); mostrarContenidoReporte('');">Reports</button>
               <button onClick="mostrarModal('inventario'); buscarEventos2();">Inventory</button>
               <a class="button2" href="pre_registro.jsp">Pre-Registration</a>
               <%}else if(tipoUsuario == 9){%>
                    <button onClick="mostrarModal('reportes'); mostrarContenidoReporte('');">Reports</button>
                    <button onClick="mostrarModal('liberarTrailers'); mostrarContenidoLiberarTrailer();">Trailers</button>
                    <button onClick="mostrarModal('inventario'); buscarEventos2();">Inventory</button>
                    <a class="button2" href="pre_registro.jsp">Pre-Registration</a>
               <%}else if(tipoUsuario == 8 ){%>
                    <button onClick="mostrarModal('tcs'); buscarTCS();">TCS</button>
                    <button onClick="mostrarModal('slam'); buscarSLAM();">SLAM</button>
                    <button onClick="mostrarModal('reportes'); mostrarContenidoReporte(1);">CARGO</button>
                    <button onClick="mostrarModal('reportes'); mostrarContenidoReporte(2);">CSL</button>
               <%}%>
            </div>
        </div>
    </div>  
 <%
 }
 %>
                     
<div id="todosLugares">   
<%
    /*
    
String fondoRojo = "";
PreparedStatement loc;
ResultSet rloc;

    int cont = 1;
    PreparedStatement locX = con.prepareStatement("select nombre, tipo, idLocalidad from localidad WHERE idBodega = '"+idBodega+"' ORDER BY orden ASC");
    ResultSet rlocX = locX.executeQuery();
    while(rlocX.next()){     
        String nombreLocalidad = rlocX.getString("nombre");
        int idLocalidad = rlocX.getInt("idLocalidad");
        
        if(rlocX.getInt("tipo") == 0)
            out.print("<div class='contenedor'><div class='andenes' id='test'>");
        else{
            if(rlocX.getInt("tipo") == 2)
                out.print("<div class='contenedor'>");
            
        
            int div = cont % 2;
            div ++;
            out.print("<div class='secciones' id='seccion"+div+"'>"); 
            cont ++;
            int largo = nombreLocalidad.length();
            int tamano = (largo * 15) + 30;
            
            out.print("<div class='tercio' style='position:absolute; width: "+tamano+"px;'><span>" + nombreLocalidad + "</span></div>");
        }
        
        String consulta_loc = "select "
                + "ubicacion.tipo, "
                + "ubicacion.numero, "
                + "ubicacion.status, "
                + "ubicacion.id_ubicacion, "
                + "arribo.id_arribo, "
                + "tractos.no_tracto, "
                + "arribo.tipoArribo, "
                + "arribo.no_caja, "
                + "dias, "
                + "TIMEDIFF(now(), arribo.fecha) as diferenciaHora "
                
                + "from localidad "
                + "left join ubicacion on ubicacion.idLocalidad = localidad.idLocalidad "
               
                + "left join (select * from arribo where temporal = 0 AND status = 0 and registro = 0) as arribo on arribo.status = 0 and arribo.ubicacion = ubicacion.id_ubicacion  "
                + "left join tractos on tractos.id_arribo = arribo.id_arribo "
               
                + "where localidad.idLocalidad = '"+idLocalidad+"' and ubicacion.idBodega = '"+idBodega+"' ORDER BY LENGTH(id_ubicacion), id_ubicacion";

        loc = con.prepareStatement(consulta_loc);
        rloc = loc.executeQuery();
        while(rloc.next()){
            String n = rloc.getString("numero");
                int 
                    id_ubicacion = rloc.getInt("id_ubicacion"),
                    id_arribo = rloc.getInt("id_arribo"),
                    diferenciaHora = rloc.getInt("diferenciaHora"),
                    arr = rloc.getInt("dias"),
                    tipo = rloc.getInt("tipo");
                
                String 
                    imagen = "",
                    globo = "",
                    caja="",
                    agregar = "",
                    editarMover = "",
                    colorCirculo = "",
                    claseDiv = "",
                    divDragable = "",
                    globoIzquierdo = "";
                
                fondoRojo = "";
               
               int number_mov = 0;
               
              if(tipo == 1 )
                imagen = "<img src='images/rampa-10.svg' alt=''/>";   
              else if(rloc.getInt("status") == 0){ 
                   claseDiv = "claseDiv";
                   divDragable = "id='div_"+id_ubicacion+"'";
  
                  imagen = "<img src='images/available-01.svg' alt''/>";
                  agregar = "<li class='context-menu__item' id='myBtn2'><a onclick='addNew("+id_ubicacion+");' style='color: #fff; cursor:pointer;'><i class='fa fa-edit'></i> Add</a></li>";
              }
              else{
                  
                  if(rloc.getInt("tipoArribo") == 0)
                      caja = rloc.getString("no_caja");
                  else
                      caja = rloc.getString("no_tracto");
                  
                          
                    if(diferenciaHora >= 1)
                        fondoRojo = "fondoRojo";
                    
                    if(arr <= 2)
                        colorCirculo = "dotAzul dot";                
                    else if(arr >= 3 && arr <= 5)
                        colorCirculo = "dotNaranja dot";                
                    else if(arr >= 6 && arr <= 100)
                        colorCirculo = "dotRojo dot";                
                    else
                          colorCirculo = "dotAmarillo"; 

                    
                   
                    
                    imagen = "<img class='claseCoche' id='imagen_"+id_arribo+"' src='images/camion-gris-01.svg' alt=''/>";

                   
                        
                    globo = "<span class='globo'><span class='" + colorCirculo + "'><p>" + arr + "</p></span></span>";

                    
                   
                    editarMover = "<li class='context-menu__item' id='myBtn3'><a onclick='editarArribo(" + id_ubicacion + ");' style='color: #fff; cursor: pointer;'><i class='fa fa-edit'></i> Edit</a></li><li class='context-menu__item' id='myBtn4'><a onclick ='moverArribo(" + id_ubicacion + ");' style='color: #fff; cursor: pointer;'><i class='fa fa-angle-double-right'></i> Move</a></li>";
                     
              }
              
              
              
              
              
             out.print("<a class='test' value='"+id_ubicacion+"' id='ubicacion_"+id_ubicacion+"'>"
                         +"<div "+divDragable+" class='modulos "+claseDiv+"'>"
                             +"<span class='top'>"
                                 +n
                             +"</span>"
                             +"<span class='bottom'>"
                                 +caja
                             +"</span>"
                             +globoIzquierdo
                             +globo
                             +imagen
                         +"</div>"  
                     +"</a>");
                     
            if((tipoUsuario == 1 || tipoUsuario == 2 || tipoUsuario == 4 || tipoUsuario == 10) && inventarioActivo != 1){
            out.print("<div class='context-menu hide' id='rmenu"+id_ubicacion+"' >"
                        +"<ul class='context-menu__items'>"
                            +agregar
                            +editarMover
                            +"<li class='context-menu__item' value='"+id_ubicacion+"' style='cursor: pointer'>"
                                +"<i class='fa fa-times' value='"+id_ubicacion+"'></i> Close"
                            +"</li>"
                        +"</ul>"
                     +"</div>");
            }

        } 
        
        out.print("</div>");
        if(rlocX.getInt("tipo") == 0 || rlocX.getInt("tipo") == 2)
           out.print("</div>");
    }
    */
 %>
 <br>   
</div>
 
 <div id="cargando" class="modal" style="background-color: #FFFFFF; opacity:0.6;  z-index: 9999;">
    <center>
        <img src="images/cargando.gif" style="margin-top:10%; width:15%">
    </center>
</div>
 
<div id="inventario" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <span onclick="ocultarModal('inventario')" class="close">&times;</span>
            <h2>Inventory</h2>
        </div>   
        <div class="modal-body">
            <input type='text' placeholder="Search" onkeyup='buscarEventos2()' id='buscandoE2'>
            <div id="Eventos2" ></div> <!-- Contenedor Inventario --> 
        </div>
    </div>
</div>
 

 
 
 
  <div id="tcs" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <span onclick="ocultarModal('tcs')" class="close">&times;</span>
            <h2>TCS</h2>
        </div>   
        <div class="modal-body">
            <div class="campo">

                <div class="calendario radio-group" style="width: 33%">
                    <label for="revision">Date period</label><br>
                    <label>
                        <input id="opt_1" class="radio-group__option" type="radio" name="periodoTCS" onchange="actualizarPeriodoTCS()" value="1" checked="checked">
                        <label class="radio-group__label" for="opt_1">
                          Day
                        </label>

                        <input id="opt_2" class="radio-group__option" type="radio" name="periodoTCS" onchange="actualizarPeriodoTCS()" value="2">
                        <label class="radio-group__label" for="opt_2">
                          Week
                        </label>

                        <input id="opt_3" class="radio-group__option" type="radio" name="periodoTCS" onchange="actualizarPeriodoTCS()" value="3">
                        <label class="radio-group__label" for="opt_3">
                          Month
                        </label>
                    </label>
                </div>
                <div class="calendario" style="width: 33%">
                    <label for="revision">To show</label><br>
                        <label>
                        <input class="radio-group__option" type="radio" id="graficaTCSa"  name="graficaTCS" onchange="buscarTCS()" value="0" checked="checked">
                        <label class="radio-group__label" for="graficaTCSa">
                          Records
                        </label>

                        <input class="radio-group__option" type="radio" id="graficaTCSb" name="graficaTCS" onchange="buscarTCS()" value="1">
                        <label class="radio-group__label" for="graficaTCSb">
                          Chart
                        </label>
                    </label>
                </div>
                
                
                
                
                <div class="calendario" id="dicCantidad" style="display: none; width: 33%">
                    <label for="revision">Count</label><br>
                    <label>
                        <input class="radio-group__option" type="radio" id="cantidadTCSa"  name="cantidadTCS" onchange="buscarTCS()" value="0" checked="checked">
                        <label class="radio-group__label" for="cantidadTCSa">
                          Records
                        </label>

                        <input class="radio-group__option" type="radio" id="cantidadTCSb" name="cantidadTCS" onchange="buscarTCS()" value="1">
                        <label class="radio-group__label" for="cantidadTCSb">
                          Amount
                        </label>
                </div>
            </div><br>
            
            <div id="divDescargarReporte" style="display: block;">
                <div class="campo">
                    <form action="/PATIO/descargarConsulta" method="POST" target="_blank">
                        <input type="hidden" id="consultaDescarga"  name="consultaDescarga" value="">

                        <label class="radio-group__label" style="background: #2196F3;">Download
                              <input type='submit' value='Download' style="display: none; ">
                        </label>
                    </form>
                </div>
            </div>
            
            <div id="divTipo" style="display: none;">
            <div class="campo">
               <div class="calendario radio-group" style="width: 33%">
                        <label for="revision">Group by</label><br>
                        <label>
                        <input class="radio-group__option" type="radio" id="tipoTCSa" name="tipoTCS" onchange="buscarTCS();" value="1" checked="checked">
                        <label class="radio-group__label" for="tipoTCSa">
                          Date
                        </label>

                        <input class="radio-group__option" type="radio" id="tipoTCSb" name="tipoTCS" onchange="buscarTCS();" value="2">
                        <label class="radio-group__label" for="tipoTCSb">
                          Invoices
                        </label>
                        
                        <input class="radio-group__option" type="radio" id="tipoTCSc" name="tipoTCS" onchange="buscarTCS();" value="3">
                        <label class="radio-group__label" for="tipoTCSc">
                          Customer
                        </label>
                        </label>
                </div>
                <div class="campo">    
                    <form action="/PATIO/descargarArchivo64" method="POST" target="_blank">
                        <div id='formularioDescargar'></div>
                        
                        
                        <label class="radio-group__label" style="background: #2196F3;">Download
                              <input type='submit' value='Download' style="display: none; ">
                        </label>
                    </form>
                    </div>
                </div><br>
            </div>
            
            <div class="campo">
                <div class="calendario">
                    <label for="revision">Initial date</label><br>
                    <input type="date" id="fechaInicioTCS" name="fechaInicioTCS" value="<%=fechaActual%>" onchange="buscarTCS()">
                </div>
                <div class="calendario">
                    <label for="revision">Final date</label><br>
                    <input type="date" id="fechaFinTCS" name="fechaFinTCS" value="<%=fechaActual%>" onchange="buscarTCS()">
                </div>
            </div>  
            <input type='text' placeholder="Search" onkeyup='buscarTCS()' id='idBuscarTCS'>
            
            
            <div id="contenidoTCS" ></div> <!-- Contenedor Inventario --> 
        </div>
    </div>
</div>
                
  <div id="slam" class="modal"><!-- Inicio Modal SLAM -->
    <div class="modal-content">
        <div class="modal-header">
            <span onclick="ocultarModal('slam')" class="close">&times;</span>
            <h2>SLAM</h2>
        </div>   
        <div class="modal-body">
            
            
            <form action="/PATIO/verSLAM.jsp" method="POST" target="_blank">
            <div class="campo">

                <div class="calendario radio-group" style="width: 50%">
                    <label for="revision">Date period</label><br>
                    <label>
                        <input id="periodoSLAM_1" class="radio-group__option" type="radio" name="periodoSLAM" onchange="actualizarPeriodoSLAM()" value="1" checked="checked">
                        <label class="radio-group__label" for="periodoSLAM_1">
                          Day
                        </label>

                        <input id="periodoSLAM_2" class="radio-group__option" type="radio" name="periodoSLAM" onchange="actualizarPeriodoSLAM()" value="2">
                        <label class="radio-group__label" for="periodoSLAM_2">
                          Week
                        </label>

                        <input id="periodoSLAM_3" class="radio-group__option" type="radio" name="periodoSLAM" onchange="actualizarPeriodoSLAM()" value="3">
                        <label class="radio-group__label" for="periodoSLAM_3">
                          Month
                        </label>
                    </label>
                </div>
                <div class="calendario" style="width: 50%">
                    <label for="revision">To show</label><br>
                        <label>
                        <input class="radio-group__option" type="radio" id="graficaSLAMa"  name="graficaSLAM" onchange="buscarSLAM()" value="0" checked="checked">
                        <label class="radio-group__label" for="graficaSLAMa">
                          Records
                        </label>

                        <input class="radio-group__option" type="radio" id="graficaSLAMb" name="graficaSLAM" onchange="buscarSLAM()" value="1">
                        <label class="radio-group__label" for="graficaSLAMb">
                          Chart
                        </label>
                    </label>
                </div>
            </div><br>
                <div class="campo">
                    <div style="width: 70%">
                        <div class="calendario radio-group" >
                                 <label for="revision">Group by</label><br>
                                 <label>
                                     <input class="radio-group__option" type="radio" id="tipoSLAMz" name="tipoSLAM" onchange="buscarSLAM();" value="0">
                                     <label class="radio-group__label" for="tipoSLAMz">
                                         Todo
                                     </label>

                                     <input class="radio-group__option" type="radio" id="tipoSLAMa" name="tipoSLAM" onchange="buscarSLAM();" value="1" checked="checked">
                                     <label class="radio-group__label" for="tipoSLAMa">
                                         Pedimento
                                     </label>

                                     <input class="radio-group__option" type="radio" id="tipoSLAMb" name="tipoSLAM" onchange="buscarSLAM();" value="2">
                                     <label class="radio-group__label" for="tipoSLAMb">
                                         Remesa
                                     </label>

                                     <input class="radio-group__option" type="radio" id="tipoSLAMc" name="tipoSLAM" onchange="buscarSLAM();" value="3">
                                     <label class="radio-group__label" for="tipoSLAMc">
                                         Documento
                                     </label>

                                     <input class="radio-group__option" type="radio" id="tipoSLAMd" name="tipoSLAM" onchange="buscarSLAM();" value="4">
                                     <label class="radio-group__label" for="tipoSLAMd">
                                         Contenedor
                                     </label>

                                     <input class="radio-group__option" type="radio" id="tipoSLAMe" name="tipoSLAM" onchange="buscarSLAM();" value="5">
                                     <label class="radio-group__label" for="tipoSLAMe">
                                         Consolidado
                                     </label>

                                 </label>
                         </div>
                    </div>
                    <div style="width: 30%">
                        <div class="calendario radio-group">
                                <label for="revision">To show</label><br>
                                <label>


                                    <input class="radio-group__option" type="radio" id="tipoOpeSLAMa" name="tipoOpeSLAM" onchange="buscarSLAM();" value="" checked="checked">
                                    <label class="radio-group__label" for="tipoOpeSLAMa">
                                        ALL
                                    </label>

                                    <input class="radio-group__option" type="radio" id="tipoOpeSLAMb" name="tipoOpeSLAM" onchange="buscarSLAM();" value="IMP">
                                    <label class="radio-group__label" for="tipoOpeSLAMb">
                                        IMP
                                    </label>

                                    <input class="radio-group__option" type="radio" id="tipoOpeSLAMc" name="tipoOpeSLAM" onchange="buscarSLAM();" value="EXP">
                                    <label class="radio-group__label" for="tipoOpeSLAMc">
                                        EXP
                                    </label>



                                </label>
                        </div>
                    </div>
                </div><br>
                
                <div class="campo">
                    <div style="width: 35%">
                        <div class="calendario radio-group">
                                <label for="revision">Group by</label><br>
                                <label>


                                    <input class="radio-group__option" type="radio" id="mostrarSLAMa" name="mostrarSLAM" onchange="buscarSLAM();" value="1" checked="checked">
                                    <label class="radio-group__label" for="mostrarSLAMa">
                                        Date
                                    </label>

                                    <input class="radio-group__option" type="radio" id="mostrarSLAMb" name="mostrarSLAM" onchange="buscarSLAM();" value="2">
                                    <label class="radio-group__label" for="mostrarSLAMb">
                                        Customer
                                    </label>
                                    
                                    <input class="radio-group__option" type="radio" id="mostrarSLAMc" name="mostrarSLAM" onchange="buscarSLAM();" value="3">
                                    <label class="radio-group__label" for="mostrarSLAMc">
                                        Office
                                    </label>

                                   



                                </label>
                        </div>
                    </div>

                    <div style="width: 25%">
                        <select name="bodegaMostrar" id="bodegaMostrar" style="width:80%" onchange='buscarSLAM()'>
                            <option value="">Todos</option>
                            <option value="810">ALTAMIRA</option>
                            <option value="800">COLOMBIA</option>
                            <option value="510">LAZARO CARDENAS</option>
                            <option value="240">NUEVO LAREDO</option>
                            <option value="731">SAN LUIS</option>
                            <option value="380">TAMPICO</option>
                            <option value="650,651">TOLUCA</option>
                            <option value="430">VERACRUZ</option>
                            <option value="160">MANZANILLO</option>
                            <option value="520">MONTERREY</option>
                            
                        </select>
                    </div>
                    
                    
                    <div style="width: 30%">
                        <label class="radio-group__label" style="background: #2196F3;">Extend
                            <input type='submit' value='Download' style="display: none; ">
                        </label>
                    </div>
                </div>
                
                
                <div class="campo">
                <div class="calendario">
                    <label for="revision">Initial date</label><br>
                    <input type="date" id="fechaInicioSLAM" name="fechaInicioSLAM" value="<%=fechaActual%>" onchange="buscarSLAM()">
                </div>
                <div class="calendario">
                    <label for="revision">Final date</label><br>
                    <input type="date" id="fechaFinSLAM" name="fechaFinSLAM" value="<%=fechaActual%>" onchange="buscarSLAM()">
                </div>
            </div>
             <input type='text' placeholder="Search" onkeyup='buscarSLAM()' id='idBuscarSLAM' name='idBuscarSLAM'>
                
             
                
                
                
            
            
            
             
             
             
                <div id="mostrarColumnasSlam" style="display: none; color: #273746">
                      <table style="width:100%">
                            <tr>
                                    <td><input type="checkbox" id="descripcion_bodegaSLAM" name="descripcion_bodegaSLAM" value="1" onchange='buscarSLAM()'> descripcion_bodega
                                    <td><input type="checkbox" id="consolidadoSLAM" name="consolidadoSLAM" value="1" onchange='buscarSLAM()'> consolidado
                                    <td><input type="checkbox" id="sellosSLAM" name="sellosSLAM" value="1" onchange='buscarSLAM()'> sellos
                                    <td><input type="checkbox" id="facturaSLAM" name="facturaSLAM" value="1" onchange='buscarSLAM()'> factura
                            </tr>
                            <tr>
                                    <td><input type="checkbox" id="bill_of_ladingSLAM" name="bill_of_ladingSLAM" value="1" onchange='buscarSLAM()'> bill_of_lading
                                    <td><input type="checkbox" id="linea_americanaSLAM" name="linea_americanaSLAM" value="1" onchange='buscarSLAM()'> linea_americana
                                    <td><input type="checkbox" id="fecha_entradaSLAM" name="fecha_entradaSLAM" value="1" onchange='buscarSLAM()'> fecha_entrada
                                    <td><input type="checkbox" id="hora_entradaSLAM" name="hora_entradaSLAM" value="1" onchange='buscarSLAM()'> hora_entrada
                            </tr>
                            <tr>
                                    <td><input type="checkbox" id="fecha_pagoSLAM" name="fecha_pagoSLAM" value="1" onchange='buscarSLAM()'> fecha_pago
                                    <td><input type="checkbox" id="hora_pagoSLAM" name="hora_pagoSLAM" value="1" onchange='buscarSLAM()'> hora_pago
                                    <td><input type="checkbox" id="hora_cruceSLAM" name="hora_cruceSLAM" value="1" onchange='buscarSLAM()'> hora_cruce
                                    <td><input type="checkbox" id="placasSLAM" name="placasSLAM" value="1" onchange='buscarSLAM()'> placas
                            </tr>
                            <tr>
                                    <td><input type="checkbox" id="inea_mexicanaSLAM" name="inea_mexicanaSLAM" value="1" onchange='buscarSLAM()'> inea_mexicana
                                    <td><input type="checkbox" id="peso_kgsSLAM" name="peso_kgsSLAM" value="1" onchange='buscarSLAM()'> peso_kgs
                                    <td><input type="checkbox" id="bultosSLAM" name="bultosSLAM" value="1" onchange='buscarSLAM()'> bultos
                                    <td><input type="checkbox" id="contenedoresSLAM" name="contenedoresSLAM" value="1" onchange='buscarSLAM()'> contenedores
                            </tr>
                            <tr>
                                    <td><input type="checkbox" id="usuarioSLAM" name="usuarioSLAM" value="1" onchange='buscarSLAM()'> usuario
                                    <td><input type="checkbox" id="inbondSLAM" name="inbondSLAM" value="1" onchange='buscarSLAM()'> inbond
                                    <td><input type="checkbox" id="referencia_ebSLAM" name="referencia_ebSLAM" value="1" onchange='buscarSLAM()'> referencia_eb
                                    <td><input type="checkbox" id="soiaSLAM" name="soiaSLAM" value="1" onchange='buscarSLAM()'> soia
                            </tr>
                            <tr>
                                    <td><input type="checkbox" id="reconocimientoSLAM" name="reconocimientoSLAM" value="1" onchange='buscarSLAM()'> Reconocimiento
                                    <td><input type="checkbox" id="observacionesSLAM" name="observacionesSLAM" value="1" onchange='buscarSLAM()'> Observaciones
                                    <td><input type="checkbox" id="fechaCargaSLAM" name="fechaCargaSLAM" value="1" onchange='buscarSLAM()'> Fecha Carga
                                    <td><input type="checkbox" id="bodegaSLAM" name="bodegaSLAM" value="1" onchange='buscarSLAM()'> Bodega
                            </tr>
                      </table>
                </div>
             </form>   
             <div id="agrupadorColumnas" style="display: block;">
                <div style="text-align: center; display: block;" id="mostrarMas">
                    <a style="cursor:pointer" onclick="mostrarCamposBotonSlam()">
                        <img  src="images/abajo.png" alt="+" style="height: 18px; width: 18px">
                    </a>
                </div>
                    
                <div style="text-align: center; display: none;" id="mostrarMenos">
                    <a style="cursor:pointer" onclick="mostrarCamposBotonSlam()">
                        <img src="images/arriba.png" alt="+" style="height: 18px; width: 18px">
                    </a>
                </div>
            </div> 
             
          
<script>
 function mostrarCamposBotonSlam(){
     if(document.getElementById('mostrarColumnasSlam').style.display == 'block'){
         document.getElementById('mostrarColumnasSlam').style.display = 'none';
     }
     else{
         document.getElementById('mostrarColumnasSlam').style.display = 'block';
     }
 }          
</script>
            
            
            <div id="contenidoSLAM" ></div> <!-- Contenedor Inventario --> 
        </div>
    </div>
</div>  <!-- Fin Modal SLAM -->                    
      

<div id="liberarTrailersView" class="modal" style="z-index: 10;"></div><!-- Release Trailers View-->
<div id="liberarTrailers" class="modal"></div><!-- Release Trailers -->
<div id="liberarTractor" class="modal"></div><!-- Release Trucks -->
<div id="reportes" class="modal"></div><!-- Get Report -->
<div id="divCerrarInventario" ></div>  <!-- Cierre de invetario -->
 
<div id="agregarNuevoArribo" class="modal" style="z-index: 10;"></div>
<div id="divEditarArribo" class="modal" style="z-index: 10;"></div>
<div id="divMoverArribo" class="modal" style="z-index: 10;"></div>


<!---->

                    
<div id="divArchivos" class="modal" style="z-index: 10;"></div>
<!---->

 <div id="mostrarSeguimiento" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <span onclick="ocultarModal('mostrarSeguimiento')" class="close">&times;</span>
            <h2>Tracing</h2>
        </div>   
        <div class="modal-body">
            <input type='text' placeholder="Search" onkeyup='buscarSeguimiento()' id='idBuscarSeguimiento'>
            <div id="divSeguimiento" ></div> <!-- Contenedor Inventario --> 
        </div>
    </div>
</div>

<div id="mostrarAgenda" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <span onclick="ocultarModal('mostrarAgenda')" class="close">&times;</span>
            <h2>Agenda</h2>
        </div>   
        <div class="modal-body">
            <input type='text' placeholder="Search" onkeyup='buscarAgenda()' id='idBuscarAgenda'>
            <div id="divAgenda" >
            </div> <!-- Contenedor Inventario --> 
        </div>
    </div>
    
</div>










 
 <div id="moverDinamico" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <span onclick="cerrarActualizar();" class="close">&times;</span>
            <h2>Move Trailer</h2>
        </div>   
        <div class="modal-body">
            
            <div id="divMoverDinamico" ></div> <!-- Contenedor Inventario --> 
        </div>
    </div>
</div>

<div id="divGenerarExcel"></div><!-- Para Descargar reportes genericos -->

<script src="http://code.jquery.com/jquery-1.7.2.min.js"></script>
<script src="http://code.jquery.com/ui/1.8.21/jquery-ui.min.js"></script>

<script src="js/jquery.ui.touch-punch.min.js"></script>

<script>      
     function cerrarActualizar(){
        buscarEventosPrincipalDinamico();
        ocultarModal('moverDinamico');
    }
    
    function buscarEventosPrincipalDinamico(){
        $.ajax({
            url: 'lugaresPrincipalNew.jsp',
            type: 'POST',
            data: {palabraBuscar: ''},
            success:function(data){
                $('#todosLugares').html(data);
                cerrarModalx("divCargando_x");
            }
        });
    }
      
</script>































<!-- Main Container Ends -->
<!--<script src="https://code.jquery.com/jquery-3.2.0.min.js"></script>-->
<script src="js/autocompletarNew3.js?a=3"></script>
 
<script>
    
    function buscarSeguimiento(){
        var idBuscarSeguimiento = $('#idBuscarSeguimiento').val();
        $.ajax({
            url: 'mostrarSeguimiento.jsp',
            type: 'POST',
		data: {
                    idBuscarSeguimiento: idBuscarSeguimiento
                },
		success:function(data){
                    $('#divSeguimiento').show();
                    $('#divSeguimiento').html(data);
            }
	});
    }
     
     
    
    
    
    
function dibujarDetallado() {
  
      var data = google.visualization.arrayToDataTable(cantidadesGraficaBarras);


      var view = new google.visualization.DataView(data);
      view.setColumns(multidatosGraficaBarras);

       var options = {
       
        legend: { position: 'top'},
        bar: { groupWidth: '75%' },
        isStacked: true,
      };
      var chart = new google.visualization.ColumnChart(document.getElementById("divGraficaBarras"));
      
   
      google.visualization.events.addListener(chart, 'ready', function () {
         document.getElementById('formularioDescargar').innerHTML = "<input type='hidden' name='nombreArchivo' value='"+chart.getImageURI()+"'>";
      });
      
      chart.draw(view, options);
  }

var contadorCargando = "";
function comprobarCargando(){
    if(document.getElementById('cargando').style.display == 'block'){
        ocultarModal('cargando');
        alert('Error, try again');
    }
}   
function actualizarBody(){
    setTimeout(buscarEventosPrincipal(""), 10000);
}

</script> 
  
 <script>
    function actualizarPeriodoTCS(){
        var periodoTCS = $('input:radio[name=periodoTCS]:checked').val();
        
        var fechaInicio = "";
        var fechaFin = "";
        var tipoFecha = "";
        if(periodoTCS == 1 ){
            tipoFecha = "date";            
            fechaInicio = fechaActualInicio;
            fechaFin = fechaActualFin;
        }
        else if(periodoTCS == 2){
            tipoFecha = "week";
            fechaInicio = semanaActualInicio;
            fechaFin = semanaActualFin;
        }
        else if(periodoTCS == 3){
            tipoFecha = "month";
            fechaInicio = mesActualInicio;
            fechaFin = mesActualFin;
        }
        
        document.getElementById("fechaInicioTCS").type = tipoFecha;
        document.getElementById("fechaFinTCS").type = tipoFecha;
        
        document.getElementById("fechaInicioTCS").value = fechaInicio;
        document.getElementById("fechaFinTCS").value = fechaFin;
        
         buscarTCS();
    } 
     
     
     
     function buscarTCS(){
        var periodoTCS = $('input:radio[name=periodoTCS]:checked').val();
        var fechaInicio = $('#fechaInicioTCS').val();
        var fechaFin = $('#fechaFinTCS').val();
        
        if(periodoTCS == 1 ){        
            fechaActualInicio = fechaInicio;
            fechaActualFin = fechaFin;
        }
        else if(periodoTCS == 2){
            semanaActualInicio = fechaInicio;
            semanaActualFin = fechaFin;
        }
        else if(periodoTCS == 3){
            mesActualInicio = fechaInicio;
            mesActualFin = fechaFin;
        }
        
        var palabraBuscar = $('#idBuscarTCS').val();
        
         
        
        var graficaTCS = $('input:radio[name=graficaTCS]:checked').val();
        if(graficaTCS == 1) {
            document.getElementById("dicCantidad").style.display = "block";
            document.getElementById("divTipo").style.display = "block";
            document.getElementById("divDescargarReporte").style.display = "none";
            
        }
        else{
            document.getElementById("dicCantidad").style.display = "none";
            document.getElementById("divTipo").style.display = "none";
            document.getElementById("divDescargarReporte").style.display = "block";
        }
        
        var cantidadTCS = $('input:radio[name=cantidadTCS]:checked').val();
        var tipoTCS = $('input:radio[name=tipoTCS]:checked').val();
        
        
        $.ajax({
            url: 'verTCS.jsp',
            type: 'POST',
		data: {
                    tipoTCS: tipoTCS,
                    periodoTCS: periodoTCS,
                    palabraBuscar: palabraBuscar, 
                    fechaInicio: fechaInicio, 
                    fechaFin: fechaFin,
                    graficaTCS: graficaTCS,
                    cantidadTCS: cantidadTCS
                },
		success:function(data){
                    $('#contenidoTCS').show();
                    $('#contenidoTCS').html(data);
            }
	});
     }
     
     function liberarTrailer(idArribo){
        contF = 1;
        $.ajax({
			url: 'viewTrailerNew.jsp',
			type: 'POST',
			data: {idArribo: idArribo},
			success:function(data){
				$('#liberarTrailersView').show();
				$('#liberarTrailersView').html(data);
			}
	});
     }
    function mostrarContenidoLiberarTrailer(){
         $.ajax({
			url: 'liberarTrailerNew.jsp',
			type: 'POST',
			data: {},
			success:function(data){
				$('#liberarTrailers').show();
				$('#liberarTrailers').html(data);
			}
	});
     }
     
    function mostrarContenidoLiberarTractor(){
         $.ajax({
			url: 'liberarTruckNew.jsp',
			type: 'POST',
			data: {},
			success:function(data){
				$('#liberarTractor').show();
				$('#liberarTractor').html(data);
			}
	});
     }
     
     function liberarTruckBoton(id_tracto){
         $.ajax({
			url: 'releaset.jsp',
			type: 'POST',
			data: {id: id_tracto},
			success:function(data){
				$('#liberarTractorAct').show();
				$('#liberarTractorAct').html(data);
			}
	});
         
     }
     
     function mostrarContenidoReporte(idBodega){
         abrirModalx("divCargando_x","Loading. Please wait...");
         $.ajax({
			url: 'reporteNew.jsp',
			type: 'POST',
			data: {idBodega: idBodega},
			success:function(data){
                            cerrarModalx("divCargando_x");
				$('#reportes').show();
				$('#reportes').html(data);
			},
                        error: function(XMLHttpRequest, textStatus, errorThrown) { 
                            cerrarModalx("divCargando_x");
                        } 
	});
     }
     
     function editarArribo(idLugar){
        //document.querySelector("#formeditarribo").reset(); 
        //$('#padlock').html('');
        $.ajax({
			url: 'editNew.jsp',
			type: 'POST',
			data: {idLugar: idLugar},
			success:function(data){
				$('#divEditarArribo').show();
				$('#divEditarArribo').html(data);
			}
	});
        document.getElementById("rmenu"+idLugar).className = "hide";
        /*abrirModalx("divCargando_x","Loading. Please wait...");
        let parametros = new FormData();
        parametros.append('script_name', 'index.jsp');
        parametros.append('tipo_operacion', 'CONSULTAR_INFORMACION_GENERAL');
        parametros.append('idLugar', idLugar);
        fetch("LoadEditNew", {
            method: 'POST',
            body: parametros
        }).then(response => {
            if (response.ok) {
                return response.json();
            } else {
                throw new Error(response.status);
            }
        }).then(data => {
            if (data['res'].length > 0) {
                document.getElementById('id_numero').textContent = data['res'][0]['numero'];
                //document.getElementById('inpt_id_arribo').value = data['res'][0]['id_arribo'];
                document.querySelector('[name="customer"]').value = data['res'][0]['cliente'];
                document.querySelector('[name="carrier"]').value = data['res'][0]['transporte'];
                document.querySelector('[name="trailer-number"]').value = data['res'][0]['no_caja'];
                document.querySelector('[name="id_arribo"]').value = data['res'][0]['id_arribo'];
                document.querySelector('[name="trailer-plates"]').value = data['res'][0]['placas_caja'];
                document.querySelector('[name="loaded"]').value = data['res'][0]['cargado'];
                if(data['res'][0]['cargado'] == "0"){
                    document.getElementById('sello').style.display = "none";
                }else{
                    document.getElementById('sello').style.display = "";
                }
                document.querySelector('[name="seal"]').value = data['res'][0]['sello'];
                document.querySelector('[name="padlock"]').add(new Option(data['res'][0]['candado'], data['res'][0]['candado'], false, true));
                document.querySelector('[name="carrier-truck"]').value = data['res'][0]['last_transporte'];
                document.querySelector('[name="truck-number"]').value = data['res'][0]['no_tracto'];
                document.querySelector('[name="truck-plates"]').value = data['res'][0]['placas_tracto'];
                document.querySelector('[name="driver-name"]').value = data['res'][0]['chofer'];
                document.querySelector('[name="licence"]').value = data['res'][0]['licencia'];
                if(data['res'][0]['status_tracto'] == "0"){
                    document.querySelector('[name="truck_s"]').value = "IN YARD";
                }else{
                    document.querySelector('[name="truck_s"]').value = "RELEASED";
                }
                document.querySelector('[name="op-type"]').value = data['res'][0]['operacion'];
                document.querySelector('[name="location"]').value = data['res'][0]['numero'];
                document.querySelector('[name="location1"]').value = data['res'][0]['ubicacion'];
                document.querySelector('[name="fechaEntrada"]').value = data['res'][0]['fechaEntrada'];
                document.querySelector('[name="horaEntrada"]').value = data['res'][0]['horaEntrada'];
                document.querySelector('[name="comments"]').value = data['res'][0]['comentarios'];
                
            }//
            cerrarModalx("divCargando_x");
            $('#divEditarArribo').show();
            document.getElementById("rmenu"+idLugar).className = "hide"
        }).catch(error => {
            cerrarModalx("divCargando_x");
            console.log(error);
        });*/
    }
    
     
    function moverArribo(idLugar){
         $.ajax({
			url: 'moveNew.jsp',
			type: 'POST',
			data: {idLugar: idLugar},
			success:function(data){
				$('#divMoverArribo').show();
				$('#divMoverArribo').html(data);
			}
	});
        document.getElementById("rmenu"+idLugar).className = "hide";
     }
     
     
                    
        function addTrailerOn(){
                $.ajax({
			url: 'addTrailerNew.jsp',
			type: 'POST',
			data: {},
			success:function(data){
				$('#agregarNuevoArribo').show();
				$('#agregarNuevoArribo').html(data);
			}
		});
                        
        }
                    
                    
                
                
     
     
     function addNew(idLugar){
         contF = 1;
         $('#liberarTrailersView').html('');
         $.ajax({
			url: 'addNew.jsp',
			type: 'POST',
			data: {idLugar: idLugar},
			success:function(data){
				$('#agregarNuevoArribo').show();
				$('#agregarNuevoArribo').html(data);
			}
		});
                document.getElementById("rmenu"+idLugar).className = "hide";
     }

     function verArchivos(id_arribo){
         //var id_arribo = document.getElementById('inpt_id_arribo').value;
         //var id_arribo = document.getElementById('id_arribo').value;
         console.log("-id_arribo:"+id_arribo);
         $.ajax({
            url: 'contenedorArchivos.jsp',
            type: 'POST',
            data: {id_arribo: id_arribo},
            success:function(data){
		$('#divArchivos').show();
		$('#divArchivos').html(data);
            }
        });
     }

                        function consultaArea(cliente){
                            $.ajax({
                            url: 'consultaArea.jsp',
                            type: 'POST',
                            data: {cliente: cliente},
                            success:function(data){
                              $('#divConsultaArea').html(data);
                              consultaSeccion('No data');
                            }
                          });
                        }
                        
                        function consultaSeccion(seccion){
                            $.ajax({
                            url: 'consultaSeccionNew.jsp',
                            type: 'POST',
                            data: {seccion: seccion},
                            success:function(data){
                              $('#location').html(data);
                            }
                          });
                        }
                        
                        function buscarEventosPrincipal(palabraBuscar){
                            if(palabraBuscar.length < 3){
                                palabraBuscar = '';
                            }
                            
                            $.ajax({
                                    url: 'lugaresPrincipalNew.jsp',
                                    type: 'POST',
                                    data: {palabraBuscar: palabraBuscar},
                                    success:function(data){
                                        $('#todosLugares').html(data);
                                        ubicarDiv('todosLugares');
                                    }
                                });
                        }
                        
                        function ubicarDiv(lugar){
                            var targetOffset = $('#' + lugar).offset().top;
                            $('html,body').animate({scrollTop: targetOffset}, 1000);
                        }
                        
                    
    
function actualizaRegistros(idBodega){
    abrirModalx("divCargando_x","Loading. Please wait...");
        if( $('#placasTrailerReporte').prop('checked') ) {
            var placasTrailerReporte = 1;
        }else{
            var placasTrailerReporte = 0;
        }
        
        if( $('#selloReporte').prop('checked') ) {
            var selloReporte = 1;
        }else{
            var selloReporte = 0;
        }
        
        if( $('#candadoReporte').prop('checked') ) {
            var candadoReporte = 1;
        }else{
            var candadoReporte = 0;
        }
        
        if( $('#numeroReporte').prop('checked') ) {
            var numeroReporte = 1;
        }else{
            var numeroReporte = 0;
        }
        
        if( $('#letraReporte').prop('checked') ) {
            var letraReporte = 1;
        }else{
            var letraReporte = 0;
        }
        
        if( $('#numeroTruckReporte').prop('checked') ) {
            var numeroTruckReporte = 1;
        }else{
            var numeroTruckReporte = 0;
        }
        
        if( $('#placasTruckReporte').prop('checked') ) {
            var placasTruckReporte = 1;
        }else{
            var placasTruckReporte = 0;
        }
        
        if( $('#choferReporte').prop('checked') ) {
            var choferReporte = 1;
        }else{
            var choferReporte = 0;
        }
        
        if( $('#licenciaReporte').prop('checked') ) {
            var licenciaReporte = 1;
        }else{
            var licenciaReporte = 0;
        }
        
        if( $('#diasReporte').prop('checked') ) {
            var diasReporte = 1;
        }else{
            var diasReporte = 0;
        }
        
        if( $('#statusReporte').prop('checked') ) {
            var statusReporte = 1;
        }else{
            var statusReporte = 0;
        }
        
        if( $('#costoReporte').prop('checked') ) {
            var costoReporte = 1;
        }else{
            var costoReporte = 0;
        }
        
        if( $('#seguimientoReporte').prop('checked') ) {
            var seguimientoReporte = 1;
        }else{
            var seguimientoReporte = 0;
        }
        
        if( $('#movementsReporte').prop('checked') ) {
            var movementsReporte = 1;
        }else{
            var movementsReporte = 0;
        }
        
        if( $('#fechaMovimientoReporte').prop('checked') ) {
            var fechaMovimientoReporte = 1;
        }else{
            var fechaMovimientoReporte = 0;
        }
        
        if( $('#editorReporte').prop('checked') ) {
            var editorReporte = 1;
        }else{
            var editorReporte = 0;
        }
        
         if( $('#costMovementReporte').prop('checked') ) {
            var costMovementReporte = 1;
        }else{
            var costMovementReporte = 0;
        }
        
        
        if( $('#mostrarReporteB').prop('checked') ) {
            var mostrarReporte = 1;
        }else{
            var mostrarReporte = 0;
        }
        
        
        
        
        
        var comentarioEntrada = 0;
        if( $('#comentarioEntrada').prop('checked') )
            comentarioEntrada = 1;
        
        var comentarioMovimientos = 0;
        if( $('#comentarioMovimientos').prop('checked') )
            comentarioMovimientos = 1;
        
        var comentarioSalida = 0;
        if( $('#comentarioSalida').prop('checked') )
            comentarioSalida = 1;
        
        var fechaAutorizacion = 0;
        if( $('#fechaAutorizacion').prop('checked') )
            fechaAutorizacion = 1;
        
        var FechaEntradaVSAutorizacion = 0;
        if( $('#FechaEntradaVSAutorizacion').prop('checked') )
            FechaEntradaVSAutorizacion = 1;
        
        var FechaAutorizacionVSSalida = 0;
        if( $('#FechaAutorizacionVSSalida').prop('checked') )
            FechaAutorizacionVSSalida = 1;
        
        var FechaEntradaVSSalida = 0;
        if( $('#FechaEntradaVSSalida').prop('checked') )
            FechaEntradaVSSalida = 1;
       
        
        
        
        
        
        var fechaInicioR = document.getElementById("fechaInicioR").value;
        var fechaFinR = document.getElementById("fechaFinR").value;
        var noTrailerR = document.getElementById("noTrailerR").value;
        var transporteR = document.getElementById("transporteR").value;
        var customerR = document.getElementById("customerR").value;
        var statusR = document.getElementById("statusR").value;
        $.ajax({
           url: 'consultaReportes.jsp',
           type: 'POST',
           dataType: 'html',
           data: 
           {
                idBodega: idBodega,
                fechaInicioR: fechaInicioR,
                fechaFinR: fechaFinR,
                noTrailerR: noTrailerR,
                transporteR: transporteR,
                customerR: customerR,
                statusR: statusR,
                placasTrailerReporte: placasTrailerReporte,
                selloReporte: selloReporte,
                candadoReporte: candadoReporte,
                numeroReporte: numeroReporte,
                letraReporte: letraReporte,
                numeroTruckReporte: numeroTruckReporte,
                placasTruckReporte: placasTruckReporte,
                choferReporte: choferReporte,
                licenciaReporte: licenciaReporte,
                diasReporte: diasReporte,
                statusReporte: statusReporte,
                costoReporte: costoReporte,
                seguimientoReporte: seguimientoReporte,
                comentarioEntrada: comentarioEntrada,
                comentarioMovimientos: comentarioMovimientos,
                comentarioSalida: comentarioSalida,
                fechaAutorizacion: fechaAutorizacion,
                FechaEntradaVSAutorizacion: FechaEntradaVSAutorizacion,
                FechaAutorizacionVSSalida: FechaAutorizacionVSSalida,
                FechaEntradaVSSalida: FechaEntradaVSSalida,
                
                
                
                movementsReporte: movementsReporte,
                fechaMovimientoReporte: fechaMovimientoReporte,
                editorReporte: editorReporte,
                costMovementReporte: costMovementReporte,
                
                mostrarReporte: mostrarReporte,
           },
           cache: false,
           
           success:function(res){
               cerrarModalx("divCargando_x");
                $('#tablaReportes').show();
                $('#tablaReportes').html(res);
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) { 
                cerrarModalx("divCargando_x");
            } 
        });
}//actualizaRegistros

function actualizaRegistrosTR(idBodega){
    abrirModalx("divCargando_x","Loading. Please wait...");
       
        if( $('#LicenceEntryReporteTR').prop('checked') ) {
            var LicenceEntryReporteTR = 1;
        }else{
            var LicenceEntryReporteTR = 0;
        }
        
        if( $('#DrivernameEntryReporteTR').prop('checked') ) {
            var DrivernameEntryReporteTR = 1;
        }else{
            var DrivernameEntryReporteTR = 0;
        }
        
        if( $('#mostrarReporteBTR').prop('checked') ) {
            var mostrarReporteTR = 1;
        }else{
            var mostrarReporteTR = 0;
        }
        
        /*if( $('#NoTractoTR').prop('checked') ) {
            var NoTractoTR = 1;
        }else{
            var NoTractoTR = 0;
        }*/
        
        var fechaInicioRTR = document.getElementById("fechaInicioRTR").value;
        var fechaFinRTR = document.getElementById("fechaFinRTR").value;
        var truckPlatesTR = document.getElementById("truckPlatesTR").value;
        var transporteRTR = document.getElementById("transporteRTR").value;
        //var customerRTR = document.getElementById("customerRTR").value;
        var statusRTR = document.getElementById("statusRTR").value;
        $.ajax({
           url: 'consultaReportesTR.jsp',//REPORTE TRACTOS
           type: 'POST',
           dataType: 'html',
           data: 
           {
                idBodega: idBodega,
                fechaInicioRTR: fechaInicioRTR,
                fechaFinRTR: fechaFinRTR,
                truckPlatesTR: truckPlatesTR,
                transporteRTR: transporteRTR,
                //customerRTR: customerRTR,
                statusRTR: statusRTR,
                mostrarReporteTR: mostrarReporteTR,
                LicenceEntryReporteTR: LicenceEntryReporteTR,
                DrivernameEntryReporteTR:DrivernameEntryReporteTR,
                //NoTractoTR: NoTractoTR,
           },
           cache: false,
           
           success:function(res){
               cerrarModalx("divCargando_x");
                $('#tablaReportesTR').show();
                $('#tablaReportesTR').html(res);
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) { 
                cerrarModalx("divCargando_x");
            } 
        });

}//actualizaRegistrosTR



function mostrarCamposBoton(){
    if(document.getElementById('mostrarColumnas').style.display == "none"){
        document.getElementById('mostrarColumnas').style.display = "block";
        document.getElementById('mostrarMenos').style.display = "block";
        document.getElementById('mostrarMas').style.display = "none";
    }
    else{
        document.getElementById('mostrarColumnas').style.display = "none";
        document.getElementById('mostrarMenos').style.display = "none";
        document.getElementById('mostrarMas').style.display = "block";
    }
}

function mostrarCamposBotonTR(){
    if(document.getElementById('mostrarColumnasTR').style.display == "none"){
        document.getElementById('mostrarColumnasTR').style.display = "block";
        document.getElementById('mostrarMenosTR').style.display = "block";
        document.getElementById('mostrarMasTR').style.display = "none";
    }
    else{
        document.getElementById('mostrarColumnasTR').style.display = "none";
        document.getElementById('mostrarMenosTR').style.display = "none";
        document.getElementById('mostrarMasTR').style.display = "block";
    }
}


function inventariosPrevios(idBodega){       
      $.ajax({
        url: 'mostrarInventarios.jsp',
        type: 'POST',
        data: {
               idBodega: idBodega
        },
        success:function(data){
            $('#Eventos2').show();
            $('#Eventos2').html(data);
        }
    });
}

function descargarInventario(id_datosInventario){
    document.getElementById('direccioncompleta').value = "inventarios/inventario_" + id_datosInventario + ".pdf";
    document.getElementById("formDescargaInventario").submit();
}




//Inicio Licence
function autocompletarLicence() {

	var minimo_letras = 0; 
	var palabraLicence = $('#licence').val();
	if (palabraLicence.length >= minimo_letras && palabraLicence != '') {
		$.ajax({
			url: 'consultaLicence.jsp',
			type: 'POST',
			data: {
                            palabraLicence:palabraLicence
                        },
			success:function(data){
				$('#listaTextLicence').show();
				$('#listaTextLicence').html(data);
                                datosRelacionados();
			}
		});
	} else {
		//ocultamos la lista
		$('#listaTextLicence').hide();
                mostrarDatosLicencia(0, '', '', '', '');
	}
}

function mostraTextLicence(id){
    document.getElementById('licence').value = document.getElementById('inputTextLicence'+id).value;
    $('#listaTextLicence').hide();
    
    datosRelacionados()
}
//Fin Licence

function datosRelacionados(){
    var licencia = $('#licence').val();
    
        $.ajax({
            url: 'completarDatosLicence.jsp',
            type: 'POST',
            data: {
                licencia: licencia
            },
            success:function(data){
                $('#divCerrarInventario').show();
                $('#divCerrarInventario').html(data);
            }
        });
}


function mostrarDatosLicencia(transporte, nombreTransporte, no_tracto, placas_tracto, chofer){
    if($("#transporte_add").val() != 1){
        $('#carrier-truck').val(transporte);
        $('#textTruckCarrier').val(nombreTransporte);
    }
    
        $('#truck-number').val(no_tracto);
    
        $('#truck-plates').val(placas_tracto);
    
        $('#driver-name').val(chofer);     
}

function mostrarDatosLicenciaC(){
    if($("#transporte_add").val() != 1){
        $('#carrier-truck').val($('#transporteLicencia').val());
        $('#textTruckCarrier').val($('#nombreTransporteLicencia').val());
    }
    
        $('#truck-number').val($('#no_tractoLicencia').val());
    
        $('#truck-plates').val($('#placas_tractoLicencia').val());
    
        $('#driver-name').val($('#choferLicencia').val());  
}

function escribirArribo(idArribo){
   var idLugar = 0;
    contF = 1;
         $('#liberarTrailersView').html('');
         $.ajax({
			url: 'addNew.jsp',
			type: 'POST',
			data: {
                            idLugar: idLugar, 
                            idArriboEscrito: idArribo},
			success:function(data){
				$('#agregarNuevoArribo').show();
				$('#agregarNuevoArribo').html(data);
			}
		});
                 mostrarModal('agregarNuevoArribo'); 
}












function buscarSLAM(){
        var descripcion_bodegaSLAM = 0; if( $('#descripcion_bodegaSLAM').prop('checked') )  descripcion_bodegaSLAM =  $('#descripcion_bodegaSLAM').val();
        var consolidadoSLAM = 0; if( $('#consolidadoSLAM').prop('checked') )  consolidadoSLAM =  $('#consolidadoSLAM').val();
        var sellosSLAM = 0; if( $('#sellosSLAM').prop('checked') )  sellosSLAM =  $('#sellosSLAM').val();
        var facturaSLAM = 0; if( $('#facturaSLAM').prop('checked') )  facturaSLAM =  $('#facturaSLAM').val();
        var bill_of_ladingSLAM = 0; if( $('#bill_of_ladingSLAM').prop('checked') )  bill_of_ladingSLAM =  $('#bill_of_ladingSLAM').val();
        var linea_americanaSLAM = 0; if( $('#linea_americanaSLAM').prop('checked') )  linea_americanaSLAM =  $('#linea_americanaSLAM').val();
        var fecha_entradaSLAM = 0; if( $('#fecha_entradaSLAM').prop('checked') )  fecha_entradaSLAM =  $('#fecha_entradaSLAM').val();
        var hora_entradaSLAM = 0; if( $('#hora_entradaSLAM').prop('checked') )  hora_entradaSLAM =  $('#hora_entradaSLAM').val();
        var fecha_pagoSLAM = 0; if( $('#fecha_pagoSLAM').prop('checked') )  fecha_pagoSLAM =  $('#fecha_pagoSLAM').val();
        var hora_pagoSLAM = 0; if( $('#hora_pagoSLAM').prop('checked') )  hora_pagoSLAM =  $('#hora_pagoSLAM').val();
        var hora_cruceSLAM = 0; if( $('#hora_cruceSLAM').prop('checked') )  hora_cruceSLAM =  $('#hora_cruceSLAM').val();
        var placasSLAM = 0; if( $('#placasSLAM').prop('checked') )  placasSLAM =  $('#placasSLAM').val();
        var inea_mexicanaSLAM = 0; if( $('#inea_mexicanaSLAM').prop('checked') )  inea_mexicanaSLAM =  $('#inea_mexicanaSLAM').val();
        var peso_kgsSLAM = 0; if( $('#peso_kgsSLAM').prop('checked') )  peso_kgsSLAM =  $('#peso_kgsSLAM').val();
        var bultosSLAM = 0; if( $('#bultosSLAM').prop('checked') )  bultosSLAM =  $('#bultosSLAM').val();
        var contenedoresSLAM = 0; if( $('#contenedoresSLAM').prop('checked') )  contenedoresSLAM =  $('#contenedoresSLAM').val();
        var usuarioSLAM = 0; if( $('#usuarioSLAM').prop('checked') )  usuarioSLAM =  $('#usuarioSLAM').val();
        var inbondSLAM = 0; if( $('#inbondSLAM').prop('checked') )  inbondSLAM =  $('#inbondSLAM').val();
        var referencia_ebSLAM = 0; if( $('#referencia_ebSLAM').prop('checked') )  referencia_ebSLAM =  $('#referencia_ebSLAM').val();
        var soiaSLAM = 0; if( $('#soiaSLAM').prop('checked') )  soiaSLAM =  $('#soiaSLAM').val();
        var reconocimientoSLAM = 0; if( $('#reconocimientoSLAM').prop('checked') )  reconocimientoSLAM =  $('#reconocimientoSLAM').val();
        var observacionesSLAM = 0; if( $('#observacionesSLAM').prop('checked') )  observacionesSLAM =  $('#observacionesSLAM').val();
        var fechaCargaSLAM = 0; if( $('#fechaCargaSLAM').prop('checked') )  fechaCargaSLAM =  $('#fechaCargaSLAM').val();
        var bodegaSLAM = 0; if( $('#bodegaSLAM').prop('checked') )  bodegaSLAM =  $('#bodegaSLAM').val();
        
        var fechaInicioSLAM = $('#fechaInicioSLAM').val();
        var fechaFinSLAM = $('#fechaFinSLAM').val();
        var idBuscarSLAM = $('#idBuscarSLAM').val();
        var bodegaMostrar = $('#bodegaMostrar').val();
        
        var tipoOpeSLAM = $('input:radio[name=tipoOpeSLAM]:checked').val();
        var tipoSLAM = $('input:radio[name=tipoSLAM]:checked').val();
        var periodoSLAM = $('input:radio[name=periodoSLAM]:checked').val();
        var graficaSLAM = $('input:radio[name=graficaSLAM]:checked').val();
        var mostrarSLAM = $('input:radio[name=mostrarSLAM]:checked').val();
        
        if(graficaSLAM == 1){
            document.getElementById("agrupadorColumnas").style.display = "none";
        }   
        else{
            document.getElementById("agrupadorColumnas").style.display = "block";
        }
            
        
        $.ajax({
            url: 'verSLAM.jsp',
            type: 'POST',
            data: { 
                    tipoOpeSLAM: tipoOpeSLAM,
                    graficaSLAM: graficaSLAM,
                    periodoSLAM: periodoSLAM,
                    tipoSLAM: tipoSLAM,
                    descripcion_bodegaSLAM: descripcion_bodegaSLAM,
                    consolidadoSLAM: consolidadoSLAM,
                    sellosSLAM: sellosSLAM,
                    facturaSLAM: facturaSLAM,
                    bill_of_ladingSLAM: bill_of_ladingSLAM,
                    linea_americanaSLAM: linea_americanaSLAM,
                    fecha_entradaSLAM: fecha_entradaSLAM,
                    hora_entradaSLAM: hora_entradaSLAM,
                    fecha_pagoSLAM: fecha_pagoSLAM,
                    hora_pagoSLAM: hora_pagoSLAM,
                    hora_cruceSLAM: hora_cruceSLAM,
                    placasSLAM: placasSLAM,
                    inea_mexicanaSLAM: inea_mexicanaSLAM,
                    peso_kgsSLAM: peso_kgsSLAM,
                    bultosSLAM: bultosSLAM,
                    contenedoresSLAM: contenedoresSLAM,
                    usuarioSLAM: usuarioSLAM,
                    inbondSLAM: inbondSLAM,
                    referencia_ebSLAM: referencia_ebSLAM,
                    soiaSLAM: soiaSLAM,
                    reconocimientoSLAM: reconocimientoSLAM,
                    observacionesSLAM: observacionesSLAM,
                    fechaCargaSLAM: fechaCargaSLAM,
                    fechaInicioSLAM: fechaInicioSLAM, 
                    fechaFinSLAM: fechaFinSLAM,
                    bodegaSLAM: bodegaSLAM,
                    idBuscarSLAM: idBuscarSLAM,
                    mostrarSLAM: mostrarSLAM,
                    bodegaMostrar: bodegaMostrar
                },
            success:function(data){
                    $('#contenidoSLAM').show();
                    $('#contenidoSLAM').html(data);
            }
    });
}

    function actualizarPeriodoSLAM(){
        var periodoSLAM = $('input:radio[name=periodoSLAM]:checked').val();
        
        var fechaInicio = "";
        var fechaFin = "";
        var tipoFecha = "";
        if(periodoSLAM == 1 ){
            tipoFecha = "date";            
            fechaInicio = fechaActualInicio;
            fechaFin = fechaActualFin;
        }
        else if(periodoSLAM == 2){
            tipoFecha = "week";
            fechaInicio = semanaActualInicio;
            fechaFin = semanaActualFin;
        }
        else if(periodoSLAM == 3){
            tipoFecha = "month";
            fechaInicio = mesActualInicio;
            fechaFin = mesActualFin;
        }
        
        document.getElementById("fechaInicioSLAM").type = tipoFecha;
        document.getElementById("fechaFinSLAM").type = tipoFecha;
        
        document.getElementById("fechaInicioSLAM").value = fechaInicio;
        document.getElementById("fechaFinSLAM").value = fechaFin;
        
         buscarSLAM();
}

function eliminarReferencia(id){
    var opcion = confirm("Delete the motion?");
    if (opcion == true) {
        $('#contenidoSLAM').load('verSLAM.jsp',{
            idEliminar: id,
        });
    } 
}


function reGuardarArribo(idarribore, idpasore){
    clearInterval(contadorCargando);
    
    if(idpasore != 6){
        alert("Step " + idpasore + " failed " + idarribore);
    }
    else{
        alert("Email not sent, retry? " + idarribore);
    }
    
    console.log("idarribore:"+ idarribore );
    
    var formDataArriboRe = new FormData(document.getElementById("formarribo"));
    formDataArriboRe.append("idarribore", idarribore); 
    formDataArriboRe.append("idpasore", idpasore);  
    formDataArriboRe.append("dato", "valor");
    
    //console.log(formDataArriboRe);
    $.ajax({
        url: "insertarNew.jsp",
        type: "post",
        dataType: "html",
        data: formDataArriboRe,
        cache: false,
        contentType: false,
        processData: false
    })
    .done(function(res){
        $("#todosLugares").html(res);
    });
}
    </script>
    
<script>
$("body").on('click', '.descargarReporte', function(event) {
    var consulta = $(this).val();
    $('#divGenerarExcel').load('generarExcel.jsp',{
	        consulta: consulta
    },
        function(){
            $("#divGenerarExcel").html("<form action='descargarArchivo' method='post' target='_blank' id='formDescargaTodo'><input type='hidden' name='direccioncompleta' value='reportes/reporte.xls'></form>");
            $("#formDescargaTodo").submit();
        }
    );
}); 

function buscarAgenda(){
    var idBuscarAgenda = $('#idBuscarAgenda').val();
    $('#divAgenda').load('agenda.jsp',{
	idBuscarAgenda: idBuscarAgenda
    });
}


function escribirAgenda(idAgenda){
   var idLugar = 0;
    contF = 1;
         $('#liberarTrailersView').html('');
         $.ajax({
			url: 'addNew.jsp',
			type: 'POST',
			data: {
                            idLugar: idLugar, 
                            idAgenda: idAgenda},
			success:function(data){
				$('#agregarNuevoArribo').show();
				$('#agregarNuevoArribo').html(data);
			}
		});
                 mostrarModal('agregarNuevoArribo'); 
}




$(document).ready(function () {
    abrirModalx("divCargando_x","Loading. Please wait...");
    cargar_camiones();
    draggable_droppable();
    //detalles_anden();
});

function cargar_camiones(){
    var idBodega = document.getElementById('inpt_idbodega').value;
    var tipoUsuario = document.getElementById('inpt_tipousuario').value;
    var inventarioActivo = document.getElementById('inpt_inventarioactivo').value;
    
    let parametros = new FormData();
    parametros.append('idBodega', idBodega);
    parametros.append('tipoUsuario', tipoUsuario);
    parametros.append('inventarioActivo', inventarioActivo);
    fetch("consulta_camiones", {
        method: "POST",
        body: parametros
    }).then(response => {
        if (response.ok) {
            return response.text();
        } else {
            throw new Error(response.status);
        }
    }).then(data => {
        let respuesta = data.trim();
        //$('#tabla_tbody_andenes').html(respuesta);
        document.getElementById("todosLugares").innerHTML = respuesta;
        detalles_anden();
    }).catch(error => {
        console.log('error¡Lo sentimos!Ocurrio un error al eliminar cita en el servidor.');
    })
    /*$.ajax({
        data:{
            'idBodega' : idBodega,
            'tipoUsuario' : tipoUsuario,
            'inventarioActivo' : inventarioActivo
        },
        type: 'post',
	url: 'consulta_camiones'
    }).done(function(msg){
        alert("msg:"+msg);
        $('#tabla_tbody').html(msg);;
    });*/
}


function detalles_anden(){
    
    $.ajax({
	url: 'consulta_proncipal_detalles',
	type: 'POST',
        dataType: "json",
	success:function(data){
            $(data.data).each(function () { 


                if(this.tipo_ubicacion == 0){
                    
                    var divDragable = "";
                    var claseDiv = "";
                    var colorF = "";
                    
                    var caja = "";
                    var globoIzquierdo = "";
                    
                    var globo = "";
                    var imagen = "";
                    var agregar = "";
                    var editarMover = "";
                    
                    if(this.status == 0){
                        claseDiv = "claseDiv";
                        divDragable = "id='div_"+this.id_ubicacion+"'";

                        imagen = "<img src='images/available-01.svg' alt''/>";
                        agregar = "<li class='context-menu__item' id='myBtn2'><a onclick='addNew("+this.id_ubicacion+");' style='color: #fff; cursor:pointer;'><i class='fa fa-edit'></i> Add</a></li>";
                    }
                    else{
                        
                        if(this.tipoArribo == 0)
                            caja = this.no_caja;
                        else
                            caja = this.no_tracto;

                        var colorCirculo ="";
                        if(this.dias <= 2)
                            colorCirculo = "dotAzul dot";                
                        else if(this.dias >= 3 && this.dias <= 5)
                            colorCirculo = "dotNaranja dot";                
                        else if(this.dias >= 6 && this.dias <= 100)
                            colorCirculo = "dotRojo dot";                
                        else
                            colorCirculo = "dotAmarillo";
 
                            if(this.number_arribos == 1 && this.cargado == 0)
                                imagen = "<img class='claseCoche' id='imagen_"+this.id_arribo+"' src='images/camion-gris-01.svg' alt=''/>";
                            else if(this.number_arribos > 0 && this.cargado == 1)
                                imagen = "<img class='claseCoche' id='imagen_"+this.id_arribo+"' src='images/camion-verde-03.svg' alt=''/>";
                            else if(this.number_arribos > 1 && this.cargado == 0)
                                imagen = "<img class='claseCoche' id='imagen_"+this.id_arribo+"' src='images/camion-naranja-04.svg' alt=''/>";

                        globo = "<span class='globo'><span class='" + colorCirculo + "'><p>" + this.dias + "</p></span></span>";

                        if(this.number_mov1 != 0)
                            globoIzquierdo = "<span class='globoIzquierdo'><span class='dot' style='background-color: #33C006;'><p>" + this.number_mov1 + "</p></span></span>";

                        editarMover = "<li class='context-menu__item' id='myBtn3'><a onclick='editarArribo(" + this.id_ubicacion + ");' style='color: #fff; cursor: pointer;'><i class='fa fa-edit'></i> Edit</a></li><li class='context-menu__item' id='myBtn4'><a onclick ='moverArribo(" + this.id_ubicacion + ");' style='color: #fff; cursor: pointer;'><i class='fa fa-angle-double-right'></i> Move</a></li>";
                    }
           
                    var numero = $("#ubicacion_"+this.id_ubicacion).find(".top").text();
                    
                    if(this.number_mov2 > 0)
                        colorF = "style='border:4px solid yellow;'";
            
                    $("#ubicacion_"+this.id_ubicacion).html(""          
                        +"<div "+divDragable+" class='modulos "+claseDiv+"' "+colorF+">"
                             +"<span class='top'>"
                                 +numero
                             +"</span>"
                             +"<span class='bottom'>"
                                 +caja
                             +"</span>"
                             +globoIzquierdo
                             +globo
                             +imagen
                         +"</div>");
                     
                    $("#rmenu"+this.id_ubicacion).html(""
                        +"<ul class='context-menu__items'>"
                            +agregar
                            +editarMover
                            +"<li class='context-menu__item' value='"+this.id_ubicacion+"' style='cursor: pointer'>"
                                +"<i class='fa fa-times' value='"+this.id_ubicacion+"'></i> Close"
                            +"</li>"
                        +"</ul>");
                }
            })
            
             draggable_droppable();
             cerrarModalx("divCargando_x");
	}
    });
}






var leftImg = 0;
var topImg = 0; 

function draggable_droppable(){
    $('.claseCoche').draggable({
            start:function() {
                $(this).css("backgroundColor", 'blue');
                $(this).css("opacity", '0.5');
                $(this).css("z-index", "1");
                leftImg = $(this).css("left");
                topImg = $(this).css("top");
            },
            revert: function(){
                if(event == false){
                    $(this).css("left", leftImg);
                    $(this).css("top", topImg);
                }

                $(this).css("backgroundColor", '');
                $(this).css("opacity", '');
            }
    });


    $( ".claseDiv" ).droppable({
            over:function(evento, ui) {
                $(this).css("border", "3px dotted #555");
            },
            drop: function( evento, ui ) {
                $(this).css("border", "");

                var id_div = $(this).droppable()[0].id;
                var id_imagen = ui.draggable[0].id;

                var id_ubicacion = id_div.replace("div_", "");
                var id_arribo = id_imagen.replace("imagen_", "");

                $('#divMoverDinamico').load('moverDinamico.jsp',{
                    id_ubicacion: id_ubicacion,
                    id_arribo: id_arribo,
                });
                mostrarModal('moverDinamico');
             },
             out: function( evento, ui ) {
                 $(this).css("border", "");
             }
    });
}

</script>

<script>
    //--> Abre modal cargando
    function abrirModalx(div, texto) {
        $("#texto_cargando").html(texto);
        $('#' + div).css("display", "block");
    }
    function cerrarModalx(div) {
        $('#' + div).css("display", "none");
    }
</script>
<script type="text/javascript">
function mostrar_sello(){
    var cargado = document.getElementById('loaded').value;
    if (cargado=='1') {
        document.getElementById('sello').style.display='';
    } else {
        document.getElementById('sello').style.display='none';
    }
}

function editCampos(){
    var formData = new FormData(document.getElementById("formeditarribo"));                       
    formData.append("dato", "valor");
    $.ajax({
        url: "modifyNew.jsp",
        type: "post",
        dataType: "html",
        data: formData,
        cache: false,
        contentType: false,
        processData: false
    })
    .done(function(res){
        $("#todosLugares").html(res);
    });
}
</script>        
    </body>
</html>

 

                

<% 
    con.close();
%>
package excel;


import java.io.File;
import java.io.FileOutputStream;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;

import java.sql.PreparedStatement;
import java.sql.ResultSet;

import Servlet.direccion;
import Modelo.Conexion;
import java.io.FileNotFoundException;
import java.sql.Connection;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import javax.servlet.http.HttpServletRequest;







import java.io.File;
import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.ClientAnchor;
import org.apache.poi.ss.usermodel.CreationHelper;
import org.apache.poi.ss.usermodel.Drawing;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Picture;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.CellType;

import java.sql.PreparedStatement;
import java.sql.ResultSet;

import Servlet.direccion;
import Modelo.Conexion;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.LinkedHashMap;

import javax.servlet.http.HttpServletRequest;
import org.apache.commons.io.IOUtils;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.Font;

-- CONSULTA DESDE MAIN

public class xlsx extends Conexion {
    -- CPDIGO DESDE CODE TEST
    direccion actualizaUbicacion = new direccion();
    String direccion = actualizaUbicacion.mostrar();

    public String ejecutar(HttpServletRequest request)throws SQLException, FileNotFoundException {
        

      // VARABLES TAP #2
      int transporteTR = 0;
      String consulta = "", fechaInicioTR="", fechaFinTR="", truckPlatesTR="";
      
      //VARIABLES TAB #1
      int idBodega=0, transporteR=0, customerR=0, statusR=0;
      String fechaInicioR = "", fechaFinR="", noTrailerR="";
        
        
        Conexion c = new Conexion();
        Connection con = c.getConnection();

        CONEXION NUEVOS CAAMBIOS DESDE LA RAMA DE MAIN 
        
        int mostrarReporte = Integer.parseInt(request.getParameter("mostrarReporte"));
        
        if(mostrarReporte == 2)
        {
            /* RECUPERACIÓN VARIABLES TRACTO */
            fechaInicioTR = request.getParameter("fechaInicioRTR cambios desde la TAMA MAIN");
            fechaFinTR = request.getParameter("fechaFinRTR");
            truckPlatesTR = request.getParameter("truckPlatesTR");
            transporteTR = Integer.parseInt(request.getParameter("transporteRTR"));
            idBodega = Integer.parseInt(request.getParameter("idBodegaTR CAMBIOS DESDE TAMA CODE TEST"));
            
            // AGREGAR FILTROS FALTANTES CON CONSULTA
            if(!truckPlatesTR.equals(""))
                consulta += " AND tractos.placas_tracto='"+truckPlatesTR+"'";
            if(transporteTR != 0)
                consulta += " AND tractos.transporte='"+transporteTR+"'";
        }else{
            /* VARIABLES DE RECUPERACIÓN DE FORMULARIO */
            fechaInicioR = request.getParameter("fechaInicioR");
            fechaFinR = request.getParameter("fechaFinR");
            noTrailerR = request.getParameter("noTrailerR");

            idBodega = Integer.parseInt(request.getParameter("idBodega"));
            transporteR = Integer.parseInt(request.getParameter("transporteR"));
            customerR = Integer.parseInt(request.getParameter("customerR"));
            statusR = Integer.parseInt(request.getParameter("statusR"));


             if(!noTrailerR.equals(""))
                consulta += " and arribo.no_caja='" + noTrailerR + "'";

            if(transporteR != 0)
                consulta += " and arribo.transporte='" + transporteR + "'";

            if(customerR != 0)
                consulta += " and arribo.cliente='" + customerR + "'";
        }
        

     -- CAMBIO EN CONDIGO DE TEST PARA FUSION DE CODIGO CONSULTAS TEST
    


        if(mostrarReporte == 1){//Movimientos
            if(statusR == 0){//Base en fecha entrada
                consulta = "SELECT arribo.id_arribo as IdArribo, if(arribo.status = 1, 'Liberado', 'Dentro') as Estatus, arribo.dias as Dias, cliente.nombre as Cliente, transporte.nombre as Transporte, no_caja as NoCaja, arribo.fecha as FechaEntrada, ifnull(arribo.fecha_s, '') as FechaSalida, if(cargado = 1, 'Yes', 'No') as Cargado, operacionSalida as Operacion, arribo.placas_caja as PlacasCaja, arribo.sello as Sello, ifnull(candado.numero, 0) as Candado, ubicacion.numero as NumeroUbicacion, ubicacion.seccion as SeccionUbicacion, tractos.no_tracto as NoTracto, tractos.placas_tracto as PlacasTracto, tractos.chofer as Chofer, tractos.licencia as Licencia, if(seguimientoarribo.idArriboOld = arribo.id_arribo, seguimientoarribo.idArriboNew, seguimientoarribo.idArriboOld) as idArriboSeg, arribo.comentarios AS ComentarioEntrada, (SELECT group_concat(comentario) FROM comentarios WHERE (tipo = 1 OR tipo = 2 or tipo = 3) AND id_arribo = arribo.id_arribo) AS ComentariosMovimientos, (SELECT group_concat(comentario) FROM comentarios WHERE (tipo = 4) AND id_arribo = arribo.id_arribo) AS ComentarioSalida, arribo.fecha_a_s AS FechaAutorizacion, TIMESTAMPDIFF(MINUTE,arribo.fecha,arribo.fecha_a_s) AS FechaEntradaVSAutorizacion, TIMESTAMPDIFF(MINUTE,arribo.fecha_a_s,arribo.fecha_s) AS FechaAutorizacionVSSalida, TIMESTAMPDIFF(MINUTE,arribo.fecha,arribo.fecha_s) AS FechaEntradaVSSalida, ubicacionP.numero as UbicacionPasada, ubicacionN.numero as NuevaUbicacion, movimiento.fecha as FechaMovimiento, if(login.nombre = '', login.usuario, CONCAT(login.nombre, ' ', login.apellidos)) AS Editor, if(movimiento.costo = 1, 'Yes', 'No') as CostoMovimiento, ifnull(motivoscost.descripcion, '') AS MotivoCobroMovimiento, (SELECT COUNT(*) FROM movimiento AS mov WHERE mov.id_arribo = arribo.id_arribo AND costo = 1) AS TotalConCosto, (SELECT COUNT(*) FROM movimiento AS mov WHERE mov.id_arribo = arribo.id_arribo AND costo = 0) AS TotalSinCosto FROM arribo INNER JOIN movimiento ON movimiento.id_arribo = arribo.id_arribo left join login on login.id_login = movimiento.idLoginEditor left join ubicacion as ubicacionP on ubicacionP.id_ubicacion = movimiento.p_ubicacion left join ubicacion as ubicacionN on ubicacionN.id_ubicacion = movimiento.n_ubicacion left JOIN cliente on cliente.id_cliente=arribo.cliente LEFT JOIN transporte ON transporte.id_transporte=arribo.transporte LEFT JOIN tractos ON tractos.id_tracto = arribo.id_arribo LEFT JOIN candado ON candado.id_candado = arribo.candado LEFT JOIN ubicacion ON ubicacion.id_ubicacion = arribo.ubicacion LEFT JOIN seguimientoarribo on seguimientoarribo.idArriboOld = arribo.id_arribo or seguimientoarribo.idArriboNew = arribo.id_arribo LEFT JOIN motivoscost ON motivoscost.id = movimiento.motivo WHERE arribo.fecha BETWEEN '" + fechaInicioR + "' and '" + fechaFinR + " 23:59:59' " + consulta + " and arribo.idBodega= "+ idBodega + " ORDER BY arribo.fecha DESC";
            }
            else if(statusR == 1){//Base en fecha Salida
                // CAMBIA NOMBRE DE TABLA Operacion_Salida as Operacion Y FECHA_S HACER CAMBIOS CON VARIABLE 
                consulta = "SELECT arribo.id_arribo as IdArribo, if(arribo.status = 1, 'Liberado', 'Dentro') as Estatus, arribo.dias as Dias, cliente.nombre as Cliente, transporte.nombre as Transporte, no_caja as NoCaja, arribo.fecha as FechaEntrada, ifnull(arribo.fecha_s, '') as FechaSalida, if(cargado = 1, 'Yes', 'No') as Cargado, operacion as Operacion, arribo.placas_caja as PlacasCaja, arribo.sello as Sello, ifnull(candado.numero, 0) as Candado, ubicacion.numero as NumeroUbicacion, ubicacion.seccion as SeccionUbicacion, tractos.no_tracto as NoTracto, tractos.placas_tracto as PlacasTracto, tractos.chofer as Chofer, tractos.licencia as Licencia, if(seguimientoarribo.idArriboOld = arribo.id_arribo, seguimientoarribo.idArriboNew, seguimientoarribo.idArriboOld) as idArriboSeg, arribo.comentarios AS ComentarioEntrada, (SELECT group_concat(comentario) FROM comentarios WHERE (tipo = 1 OR tipo = 2 or tipo = 3) AND id_arribo = arribo.id_arribo) AS ComentariosMovimientos, (SELECT group_concat(comentario) FROM comentarios WHERE (tipo = 4) AND id_arribo = arribo.id_arribo) AS ComentarioSalida, arribo.fecha_a_s AS FechaAutorizacion, TIMESTAMPDIFF(MINUTE,arribo.fecha,arribo.fecha_a_s) AS FechaEntradaVSAutorizacion, TIMESTAMPDIFF(MINUTE,arribo.fecha_a_s,arribo.fecha_s) AS FechaAutorizacionVSSalida, TIMESTAMPDIFF(MINUTE,arribo.fecha,arribo.fecha_s) AS FechaEntradaVSSalida, ubicacionP.numero as UbicacionPasada, ubicacionN.numero as NuevaUbicacion, movimiento.fecha as FechaMovimiento, if(login.nombre = '', login.usuario, CONCAT(login.nombre, ' ', login.apellidos)) AS Editor, if(movimiento.costo = 1, 'Yes', 'No') as CostoMovimiento, ifnull(motivoscost.descripcion, '') AS MotivoCobroMovimiento, (SELECT COUNT(*) FROM movimiento AS mov WHERE mov.id_arribo = arribo.id_arribo AND costo = 1) AS TotalConCosto, (SELECT COUNT(*) FROM movimiento AS mov WHERE mov.id_arribo = arribo.id_arribo AND costo = 0) AS TotalSinCosto FROM arribo INNER JOIN movimiento ON movimiento.id_arribo = arribo.id_arribo left join login on login.id_login = movimiento.idLoginEditor left join ubicacion as ubicacionP on ubicacionP.id_ubicacion = movimiento.p_ubicacion left join ubicacion as ubicacionN on ubicacionN.id_ubicacion = movimiento.n_ubicacion left JOIN cliente on cliente.id_cliente=arribo.cliente LEFT JOIN transporte ON transporte.id_transporte=arribo.transporte LEFT JOIN tractos ON tractos.id_tracto = arribo.id_arribo LEFT JOIN candado ON candado.id_candado = arribo.candado LEFT JOIN ubicacion ON ubicacion.id_ubicacion = arribo.ubicacion LEFT JOIN seguimientoarribo on seguimientoarribo.idArriboOld = arribo.id_arribo or seguimientoarribo.idArriboNew = arribo.id_arribo LEFT JOIN motivoscost ON motivoscost.id = movimiento.motivo WHERE arribo.fecha_s BETWEEN '" + fechaInicioR + "' and '" + fechaFinR + " 23:59:59' " + consulta + " and arribo.idBodega= "+ idBodega + " ORDER BY arribo.fecha_s DESC";
            }
        }
        else if(mostrarReporte == 0){//ARRIBOS
            if(statusR == 0){//FECHA DE ENTRADA
                consulta = "SELECT arribo.id_arribo as IdArribo, if(arribo.status = 1, 'Liberado', 'Dentro') as Estatus, arribo.dias as Dias, cliente.nombre as Cliente, transporte.nombre as Transporte, no_caja as NoCaja, arribo.fecha as FechaEntrada, ifnull(arribo.fecha_s, '') as FechaSalida, if(cargado = 1, 'Yes', 'No') as Cargado, operacion as Operacion, arribo.placas_caja as PlacasCaja, arribo.sello as Sello, ifnull(candado.numero, 0) as Candado, ubicacion.numero as NumeroUbicacion, ubicacion.seccion as SeccionUbicacion, tractos.no_tracto as NoTracto, tractos.placas_tracto as PlacasTracto, tractos.chofer as Chofer, tractos.licencia as Licencia, if(seguimientoarribo.idArriboOld = arribo.id_arribo, seguimientoarribo.idArriboNew, seguimientoarribo.idArriboOld) as idArriboSeg, arribo.comentarios AS ComentarioEntrada, (SELECT group_concat(comentario) FROM comentarios WHERE (tipo = 1 OR tipo = 2 or tipo = 3) AND id_arribo = arribo.id_arribo) AS ComentariosMovimientos, (SELECT group_concat(comentario) FROM comentarios WHERE (tipo = 4) AND id_arribo = arribo.id_arribo) AS ComentarioSalida, arribo.fecha_a_s AS FechaAutorizacion, TIMESTAMPDIFF(MINUTE,arribo.fecha,arribo.fecha_a_s) AS FechaEntradaVSAutorizacion, TIMESTAMPDIFF(MINUTE,arribo.fecha_a_s,arribo.fecha_s) AS FechaAutorizacionVSSalida, TIMESTAMPDIFF(MINUTE,arribo.fecha,arribo.fecha_s) AS FechaEntradaVSSalida FROM arribo left JOIN cliente on cliente.id_cliente=arribo.cliente LEFT JOIN transporte ON transporte.id_transporte=arribo.transporte LEFT JOIN tractos ON tractos.id_tracto = arribo.id_arribo LEFT JOIN candado ON candado.id_candado = arribo.candado LEFT JOIN ubicacion ON ubicacion.id_ubicacion = arribo.ubicacion LEFT JOIN seguimientoarribo on seguimientoarribo.idArriboOld = arribo.id_arribo or seguimientoarribo.idArriboNew = arribo.id_arribo WHERE arribo.fecha BETWEEN '" + fechaInicioR + "' and '" + fechaFinR + " 23:59:59' " + consulta + " and arribo.idBodega= "+ idBodega + " ORDER BY arribo.fecha DESC";
            }
            else if(statusR == 1){// FECHA DE SALIDA
                // CAMBIA ESTATUS Y ALGUNOS NOMBRES DE TABLA
                consulta = "SELECT arribo.status, arribo.dias, arribo.id_arribo, cliente.nombre as cliente, transporte.nombre as transporte, no_caja, arribo.fecha as fechaEntrada, ifnull(arribo.fecha_s, '') as fechaSalida, if(cargado = 1, 'Yes', 'No') as cargado, operacion, arribo.placas_caja, arribo.sello, ifnull(candado.numero, 0) as candado, ubicacion.numero as numeroUbicacion, ubicacion.seccion as seccionUbicacion, tractos.no_tracto, tractos.placas_tracto, tractos.chofer, tractos.licencia, if(seguimientoarribo.idArriboOld = arribo.id_arribo, seguimientoarribo.idArriboNew, seguimientoarribo.idArriboOld) as idArriboSeg, arribo.comentarios AS comentarioEntrada, (SELECT group_concat(comentario) FROM comentarios WHERE (tipo = 1 OR tipo = 2 or tipo = 3) AND id_arribo = arribo.id_arribo) AS comentarioMovimientos, (SELECT group_concat(comentario) FROM comentarios WHERE (tipo = 4) AND id_arribo = arribo.id_arribo) AS comentarioSalida, arribo.fecha_a_s AS fechaAutorizacion, TIMESTAMPDIFF(MINUTE,arribo.fecha,arribo.fecha_a_s) AS FechaEntradaVSAutorizacion, TIMESTAMPDIFF(MINUTE,arribo.fecha_a_s,arribo.fecha_s) AS FechaAutorizacionVSSalida, TIMESTAMPDIFF(MINUTE,arribo.fecha,arribo.fecha_s) AS FechaEntradaVSSalida FROM arribo left JOIN cliente on cliente.id_cliente=arribo.cliente LEFT JOIN transporte ON transporte.id_transporte=arribo.transporte LEFT JOIN tractos ON tractos.id_tracto = arribo.id_arribo LEFT JOIN candado ON candado.id_candado = arribo.candado LEFT JOIN ubicacion ON ubicacion.id_ubicacion = arribo.ubicacion LEFT JOIN seguimientoarribo on seguimientoarribo.idArriboOld = arribo.id_arribo or seguimientoarribo.idArriboNew = arribo.id_arribo WHERE arribo.fecha_s BETWEEN '" + fechaInicioR + "' and '" + fechaFinR + " 23:59:59' " + consulta + " and arribo.idBodega= "+ idBodega + " ORDER BY arribo.fecha_s DESC";
            }
        }else if(mostrarReporte == 2){ // REPORTE PARA TRAILER O DOCUMENTOS
            consulta = "(SELECT tractos.id_tracto AS ID_TRACTO, "
                + " DATE(tractos.fecha) AS TRACTO_DATE, TIME(tractos.fecha) AS TRACTO_HOUR, "
                +"operacion AS OPERATION, no_caja AS CONTAINER_NUMBER, arribo.placas_caja AS CONTAINER_PLATES, arribo.sello AS STAMP, " 
                +"tractos.no_tracto AS TRACTO_NUMBER, tractos.placas_tracto AS TRACTO_PLATES, "
                +"cliente.nombre AS CUSTUMER, transporte.nombre AS CARRIER, " 
                +"arribo.status AS STATUS, " 
                +"tractos.licencia AS LICENSE_ENTRY, " 
                +"tractos.chofer AS NAME_ENTRY_DRIVE, "
                +"IF(cargado = 1, 'Yes', 'No') AS PICK_UP, "
                +"IF(tractos.tipo = 0 OR tractos.tipo IS NULL , 'Trailer', 'Documentacion') AS TYPE, "
                + "DATE(arribo.fecha) AS ENTRY_DATE_ARRIVAL, TIME(arribo.fecha) AS ENTRY_HOUR_ARRIVAL, "
                + "IFNULL(DATE(arribo.fecha_s), '') AS EXIT_DATE_ARRIVAL, TIME(arribo.fecha_s) AS EXIT_HOUR_ARRIVAL "
                +"FROM tractos "
                +"LEFT JOIN arribo ON tractos.id_arribo = arribo.id_arribo "
                +"LEFT JOIN cliente ON cliente.id_cliente = arribo.cliente " 
                +"LEFT JOIN transporte ON transporte.id_transporte = tractos.transporte " 
                +"LEFT JOIN ubicacion ON ubicacion.id_ubicacion = arribo.ubicacion  WHERE  DATE_FORMAT(arribo.fecha , '%Y-%m-%d') "
                +"BETWEEN '"+ fechaInicioTR +"' AND '"+ fechaFinTR +"'"+consulta+"  AND arribo.idBodega= '"+ idBodega +"' ORDER BY tractos.fecha DESC) "
                +" "
                +"UNION " 
                +" "
                +"(SELECT tractos.id_tracto AS ID_TRACTO, "
                + " DATE(tractos.fecha) AS TRACTO_DATE, TIME(tractos.fecha) AS TRACTO_HOUR, "
                +"operacion AS OPERATION, no_caja AS CONTAINER_NUMBER, arribo.placas_caja AS CONTAINER_PLATES, arribo.sello AS STAMP, " 
                +"tractos.no_tracto AS TRACTO_NUMBER, tractos.placas_tracto AS TRACTO_PLATES, "
                +"cliente.nombre AS CUSTUMER, transporte.nombre AS CARRIER, " 
                +"arribo.status AS STATUS, " 
                +"tractos.licencia AS LICENSE_ENTRY, " 
                +"tractos.chofer AS NAME_ENTRY_DRIVE, "
                +"IF(cargado = 1, 'Yes', 'No') AS PICK_UP, "
                +"IF(tractos.tipo = 0 OR tractos.tipo IS NULL , 'Trailer', 'Documentacion') AS TYPE, "
                + "DATE(arribo.fecha) AS ENTRY_DATE_ARRIVAL, TIME(arribo.fecha) AS ENTRY_HOUR_ARRIVAL, "
                + "IFNULL(DATE(arribo.fecha_s), '') AS EXIT_DATE_ARRIVAL, TIME(arribo.fecha_s) AS EXIT_HOUR_ARRIVAL "
                +"FROM tractos "
                +"LEFT JOIN arribo ON tractos.id_arribo = arribo.id_arribo "
                +"LEFT JOIN cliente ON cliente.id_cliente = arribo.cliente " 
                +"LEFT JOIN transporte ON transporte.id_transporte = tractos.transporte " 
                +"WHERE tractos.id_arribo = 0 " 
                +"AND "
                +"DATE_FORMAT(tractos.fecha , '%Y-%m-%d') "
                +"BETWEEN '"+ fechaInicioTR +"' AND '"+ fechaFinTR +"'"+consulta+" AND tractos.idBodega= '"+ idBodega +"'  ORDER BY tractos.fecha DESC) " 
                +"; ";
        }
        
        /* CORRECCIÓN DE CONSULTA GENERAL  */
        System.out.println("CONSULTA: \n" + consulta);
        

        //Crear libro de trabajo en blanco
        Workbook workbook = new HSSFWorkbook();

        //Crea hoja nueva
        Sheet sheet = workbook.createSheet("hoja1");

        //Por cada línea se crea un arreglo de objetos (Object[])
        Map<Integer, Object[]> datos = new TreeMap<Integer, Object[]>();
                
        ArrayList<String> filas = new ArrayList<String>();
        
   
                
        //--> estilo de letra
        Font cellFont = workbook.createFont();
        cellFont.setColor(IndexedColors.WHITE.getIndex());
        cellFont.setBold(true);
                
        //--> Color de fondo de celda
        CellStyle encabezado  = workbook.createCellStyle();
                encabezado.setFont(cellFont);
                encabezado.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
                encabezado.setFillPattern(FillPatternType.SOLID_FOREGROUND);
                
                CellStyle gris  = workbook.createCellStyle();
                gris.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
                gris.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            
            
        try {
            InputStream is = new FileInputStream(direccion + "bodega/" + idBodega + "/logo.png");
            byte[] bytes = IOUtils.toByteArray(is);
            int pictureIdx = workbook.addPicture(bytes, Workbook.PICTURE_TYPE_PNG);
            is.close();
            CreationHelper helper = workbook.getCreationHelper();
            Drawing drawing = sheet.createDrawingPatriarch();

            ClientAnchor anchor = helper.createClientAnchor();
            anchor.setAnchorType(ClientAnchor.AnchorType.MOVE_AND_RESIZE);
            anchor.setCol1(0);
            anchor.setDy1(100);
            anchor.setRow1(0);
            anchor.setCol2(2);
            anchor.setRow2(2);
            Picture pict = drawing.createPicture(anchor, pictureIdx);
            pict.resize(2.0, 2.0);
        }catch (IOException ex) {
            Logger.getLogger(xlsx.class.getName()).log(Level.SEVERE, null, ex);
        }
                
          
        PreparedStatement ps = con.prepareStatement(consulta);
        ResultSet rs = ps.executeQuery();
        rs.next();
                  
        //Encabezado de las columnas
        for (int x = 1; x <= rs.getMetaData().getColumnCount(); x++)
            filas.add(rs.getMetaData().getColumnLabel(x));
        
        int cont = 1;
        datos.put(cont, filas.toArray());
        filas.clear();
               
        //Contenido de la consulta
        rs = ps.executeQuery();
        while(rs.next()) {
            for (int x = 1; x <= rs.getMetaData().getColumnCount(); x++)
                filas.add(rs.getString(x));
            
            cont ++;
            datos.put(cont, filas.toArray());
            filas.clear();
        }
                
                
        int numeroRenglon = 5;

        Set<Integer> keySet = datos.keySet();
        Iterator<Integer> iter = keySet.iterator();
        while (iter.hasNext()) {
            int key = iter.next();
            Row row = sheet.createRow(numeroRenglon++);
            Object[] arregloObjetos = datos.get(key);
            int numeroCelda = 0;
            
            for (Object obj : arregloObjetos) {
                Cell cell = row.createCell(numeroCelda++);
                
                if(numeroRenglon == 6)
                cell.setCellStyle(encabezado);
            else if(numeroRenglon > 6)
                cell.setCellStyle(gris);
                
                if (obj instanceof String) {
                    cell.setCellValue((String) obj);
                } else if (obj instanceof Integer) {
                    cell.setCellValue((Integer) obj);
                }
            }
        }
        
        try {
            //Se genera el documento
            FileOutputStream out = new FileOutputStream(new File(direccion + "excel/report.xls"));
            workbook.write(out);
            out.close();
            
            return "Correct";
        } catch (Exception e) {
            e.printStackTrace();
            return "Error";
        }
    }  
}
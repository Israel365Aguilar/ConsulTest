package Servlet;


import javax.servlet.annotation.WebServlet;
import java.io.FileInputStream;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServlet;

import javax.servlet.ServletException;
import java.io.IOException;

import excel.xlsx;



@WebServlet("/descarga")

public class descargar extends HttpServlet {
    
    direccion actualizaUbicacion = new direccion();
    String direccion = actualizaUbicacion.mostrar();

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
             
             xlsx genera = new xlsx();
             try{
                 genera.ejecutar(request);
             }
             catch(Exception e)
             { 
                e.printStackTrace();
             }   
             
             
             
		try
                {
                    String nFile = "report.xls";		
                    FileInputStream archivo = new FileInputStream(direccion + "excel/"+nFile); 
                    int longitud = archivo.available();
                    byte[] datos = new byte[longitud];
                    archivo.read(datos);
                    archivo.close();
                    
                    int mostrarReporte = Integer.parseInt(request.getParameter("mostrarReporte"));
                    System.out.println("MOSTRA REPO: " + mostrarReporte);
                    
                    //INCIAR VARIABLES
                    int statusR = 0;
                    String fechaInicioR = "", fechaFinR=""; 
                    
                    if(mostrarReporte == 2)
                    {
                         fechaInicioR = request.getParameter("fechaInicioRTR");
                         fechaFinR = request.getParameter("fechaFinRTR");
                         statusR = Integer.parseInt(request.getParameter("statusRTR"));
                    }else{
                         fechaInicioR = request.getParameter("fechaInicioR");
                         fechaFinR = request.getParameter("fechaFinR");
                         statusR = Integer.parseInt(request.getParameter("statusR"));
                    }
                    

                    String cadenaNombre = fechaInicioR + "_" + fechaFinR;
                    
                    if(statusR == 0){
                        cadenaNombre = cadenaNombre + "_" + "IN_";
                    }
                    else{
                        cadenaNombre = cadenaNombre + "_" + "RELEASED_";
                    }
 
                    String nuevoNombre = cadenaNombre + nFile;
                    response.setContentType("application/octet-stream");
                    response.setHeader("Content-Disposition","attachment;filename=" + nuevoNombre);    

                    ServletOutputStream ouputStream = response.getOutputStream();
                    ouputStream.write(datos);
                    ouputStream.flush();
                    ouputStream.close();

                   response.getWriter().print("<p>Respuesta del servlet</p>");
                }
                catch(Exception e)
                { 
                    e.printStackTrace();
                }    
	}
}
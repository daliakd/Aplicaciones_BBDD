package lsi.ubu.servicios;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.util.Date;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import lsi.ubu.excepciones.CompraBilleteTrenException;
import lsi.ubu.util.PoolDeConexiones;

public class ServicioImpl implements Servicio {
	private static final Logger LOGGER = LoggerFactory.getLogger(ServicioImpl.class);

	@Override
	public void anularBillete(Time hora, java.util.Date fecha, String origen, String destino, int nroPlazas, int ticket)
			throws SQLException {
		PoolDeConexiones pool = PoolDeConexiones.getInstance();

		/* Conversiones de fechas y horas */
		java.sql.Date fechaSqlDate = new java.sql.Date(fecha.getTime());
		java.sql.Timestamp horaTimestamp = new java.sql.Timestamp(hora.getTime());

		Connection con = null;
		PreparedStatement st = null;
		ResultSet rs = null;

		con = pool.getConnection();
        LOGGER.info("------------------------Ejecutando.--------------------------");                
    	try {
	        // Obtener el ID del recorrido
	        st = con.prepareStatement("SELECT idRecorrido FROM recorridos WHERE estacionOrigen = ? AND estacionDestino = ?");
	        st.setString(1, origen);
	        st.setString(2, destino);
	        rs = st.executeQuery();
	        int idRecorrido = -1;
	        if (rs.next()) {
	            idRecorrido = rs.getInt("idRecorrido");
	        } else {
	            throw new CompraBilleteTrenException(CompraBilleteTrenException.NO_EXISTE_VIAJE);
	        }
	        rs.close();
	        st.close();
	
	        // Obtener el ID del viaje
	        st = con.prepareStatement("SELECT idViaje FROM viajes v JOIN recorridos r ON v.idRecorrido = r.idRecorrido WHERE "
	        		+ "v.idRecorrido = ? AND "
	        		+ "v.fecha = ? AND "
	        		+ "TO_CHAR(r.horaSalida, 'HH24:MI') = TO_CHAR(?, 'HH24:MI')");
	        
	        st.setInt(1, idRecorrido);
	        st.setDate(2, fechaSqlDate);
	        st.setTimestamp(3, horaTimestamp);
	        rs = st.executeQuery();
	        int idViaje = -1;
	        if (rs.next()) {
	            idViaje = rs.getInt("idViaje");
	        } else {
	            throw new CompraBilleteTrenException(CompraBilleteTrenException.NO_EXISTE_VIAJE);
	        }
	
	        // Buscar el idViaje correspondiente al ticket en la tabla tickets
	        st = con.prepareStatement("SELECT idViaje FROM tickets WHERE idTicket = ?");
	        st.setInt(1, ticket);
	        rs = st.executeQuery();
	        if (rs.next()) {
	            idViaje = rs.getInt("idViaje");
	        } else {
	            throw new CompraBilleteTrenException(CompraBilleteTrenException.NO_EXISTE_VIAJE);
	        }
	        rs.close();
	        st.close();

	        // Obtener información del viaje usando el idViaje obtenido
	        st = con.prepareStatement("SELECT nPlazasLibres FROM viajes WHERE idViaje = ?");
	        st.setInt(1, idViaje);
	        rs = st.executeQuery();
	        int nPlazasLibres = -1;
	        if (rs.next()) {
	            nPlazasLibres = rs.getInt("nPlazasLibres");
	        } else {
	            throw new CompraBilleteTrenException(CompraBilleteTrenException.NO_EXISTE_VIAJE);
	        }
	        rs.close();
	        st.close();

	        // Aumentar el número de plazas libres para el viaje correspondiente
	        String sql = "UPDATE viajes SET nPlazasLibres = ? WHERE idViaje = ?";
	        st = con.prepareStatement(sql);
	        st.setInt(1, nPlazasLibres + nroPlazas); // Incrementar el número de plazas libres
	        st.setInt(2, idViaje);
	        int rowCount = st.executeUpdate();

	        if (rowCount == 0) {
	            throw new CompraBilleteTrenException(CompraBilleteTrenException.NO_EXISTE_VIAJE);
	        }

	        LOGGER.info("Se ha anulado correctamente el billete.");
	
	        con.commit(); // Confirmar la transacción
	    } finally {
	        // Cerrar recursos
	        if (rs != null) rs.close();
	        if (st != null) st.close();
	        if (con != null) con.close();
		}
	}

	@Override
	public void comprarBillete(Time hora, Date fecha, String origen, String destino, int nroPlazas) throws SQLException {
	    PoolDeConexiones pool = PoolDeConexiones.getInstance();

	    // Conversiones de fechas y horas
	    java.sql.Date fechaSqlDate = new java.sql.Date(fecha.getTime());
	    java.sql.Timestamp horaTimestamp = new java.sql.Timestamp(hora.getTime());

	    Connection con = null;
	    PreparedStatement st = null;
	    ResultSet rs = null;
	    try {
	        con = pool.getConnection();
	        LOGGER.info("------------------------Ejecutando.--------------------------");                

	        // Obtener el ID del recorrido
	        st = con.prepareStatement("SELECT idRecorrido FROM recorridos WHERE estacionOrigen = ? AND estacionDestino = ?");
	        st.setString(1, origen);
	        st.setString(2, destino);
	        rs = st.executeQuery();
	        int idRecorrido = -1;
	        if (rs.next()) {
	            idRecorrido = rs.getInt("idRecorrido");
	        } else {
	            throw new CompraBilleteTrenException(CompraBilleteTrenException.NO_EXISTE_VIAJE);
	        }
	        rs.close();
	        st.close();

	        // Obtener el ID del viaje
	        st = con.prepareStatement("SELECT idViaje, nPlazasLibres, horaSalida, precio FROM viajes v JOIN recorridos r ON v.idRecorrido = r.idRecorrido WHERE "
	        		+ "v.idRecorrido = ? AND "
	        		+ "v.fecha = ? AND "
	        		+ "TO_CHAR(r.horaSalida, 'HH24:MI') = TO_CHAR(?, 'HH24:MI')");
	        
	        st.setInt(1, idRecorrido);
	        st.setDate(2, fechaSqlDate);
	        st.setTimestamp(3, horaTimestamp);
	        rs = st.executeQuery();
	        int idViaje = -1;
	        int nPlazasLibres = -1;
	        double precioRecorrido = -1;
	        if (rs.next()) {
	            idViaje = rs.getInt("idViaje");
	            nPlazasLibres = rs.getInt("nPlazasLibres");
	            precioRecorrido = rs.getDouble("precio");
	        } else {
	            throw new CompraBilleteTrenException(CompraBilleteTrenException.NO_EXISTE_VIAJE);
	        }

	        // Verificar si hay suficientes plazas libres
	        if (nPlazasLibres < nroPlazas) {
	            throw new CompraBilleteTrenException(CompraBilleteTrenException.NO_PLAZAS);
	        }

	        // Actualizar el número de plazas libres
	        st = con.prepareStatement("UPDATE viajes SET nPlazasLibres = ? WHERE idViaje = ?");
	        st.setInt(1, nPlazasLibres - nroPlazas);
	        st.setInt(2, idViaje);
	        st.executeUpdate();
	        st.close();
	        
	        // Obtener la fecha de compra (hoy)
	        java.util.Date fechaActual = new java.util.Date();
	        java.sql.Date fechaCompraSqlDate = new java.sql.Date(fechaActual.getTime());
	        
	        // Calcular el precio total del billete
	        double precioTotal = nroPlazas * precioRecorrido;

	        // Insertar una nueva fila en la tabla de tickets
	        st = con.prepareStatement("INSERT INTO tickets (idTicket, idViaje, fechaCompra, cantidad, precio) VALUES (seq_tickets.nextval, ?, ?, ?, ?)");
	        st.setInt(1, idViaje);
	        st.setDate(2, fechaCompraSqlDate);
	        st.setInt(3, nroPlazas);
	        st.setDouble(4, precioTotal);
	        st.executeUpdate();
	        LOGGER.info("Se ha comprado correctamente el billete.");

	        con.commit(); // Confirmar la transacción

	    //} catch (SQLException e) {
	      //  if (con != null) {
	        //    con.rollback(); // Deshacer la transacción en caso de error
	        //}
	    } finally {
	        // Cerrar recursos
	        if (rs != null) rs.close();
	        if (st != null) st.close();
	        if (con != null) con.close();
	    }
		
	}

}

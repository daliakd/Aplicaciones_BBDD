DROP TABLE CONDUCTOR CASCADE CONSTRAINTS;

DROP TABLE INCIDENCIA CASCADE CONSTRAINTS;

DROP TABLE TIPOINCIDENCIA CASCADE CONSTRAINTS;

DROP TABLE VEHICULO CASCADE CONSTRAINTS;


CREATE TABLE VEHICULO(
	IDAUTO VARCHAR(3) PRIMARY KEY,
	NOMBRE VARCHAR(50) NOT NULL UNIQUE,
	DIRECCION VARCHAR(100),
  	CP VARCHAR(5),
 	CIUDAD VARCHAR(20)
);

CREATE TABLE CONDUCTOR(
	NIF VARCHAR(10) PRIMARY KEY,
	NOMBRE VARCHAR(50) NOT NULL,
	APELLIDO VARCHAR(50) NOT NULL,
	DIRECCION VARCHAR(100),
  	CP VARCHAR(5),
 	CIUDAD VARCHAR(20),
	PUNTOS NUMERIC(3,0) DEFAULT 12,
	IDAUTO VARCHAR(3),
	FOREIGN KEY (IDAUTO) REFERENCES VEHICULO(IDAUTO)
);

CREATE TABLE TIPOINCIDENCIA(
	ID INTEGER PRIMARY KEY,
	DESCRIPCION VARCHAR(30),
	VALOR INTEGER
);

CREATE TABLE INCIDENCIA(
	FECHA TIMESTAMP,
	NIF VARCHAR(10),
	ANOTACION CLOB,
	IDTIPO INTEGER,
	PRIMARY KEY (FECHA, NIF),
	FOREIGN KEY (NIF) REFERENCES CONDUCTOR(NIF),
	FOREIGN KEY (IDTIPO) REFERENCES TIPOINCIDENCIA(ID)
);

INSERT INTO VEHICULO VALUES ('ABC', 'FORD', 'Avda. Palencia 45', '09001', 'Burgos');
INSERT INTO VEHICULO VALUES ('XYZ', 'MERCEDES', 'C/Obdulio 2', '09001', 'Burgos');
INSERT INTO VEHICULO VALUES ('MNP', 'CITROEN', 'C/Progreso 10', '09001', 'Burgos');

INSERT INTO TIPOINCIDENCIA VALUES (0, 'Ajuste', -1);
INSERT INTO TIPOINCIDENCIA VALUES (1, 'Muy grave', 12);
INSERT INTO TIPOINCIDENCIA VALUES (2, 'Grave', 6);
INSERT INTO TIPOINCIDENCIA VALUES (3, 'Moderada', 3);
INSERT INTO TIPOINCIDENCIA VALUES (4, 'Leve', 1);

INSERT INTO CONDUCTOR VALUES ('10000000A', 'Juana', 'Manzanal', 'C/Vitoria 56', '09003', 'Burgos', 12, 'ABC');
INSERT INTO CONDUCTOR VALUES ('10000000B', 'Javier', 'Calle', 'C/Vitoria 57', '09003', 'Burgos', 6, 'ABC');
INSERT INTO CONDUCTOR VALUES ('10000000C', 'Jimena', 'Plaza', 'C/Vitoria 58', '09003', 'Burgos', 3, 'ABC');

INSERT INTO CONDUCTOR VALUES ('20000000A', 'Paloma', 'Del Barrio', 'C/Vitoria 56', '09003', 'Burgos', 12, 'XYZ');
INSERT INTO CONDUCTOR VALUES ('20000000B', 'Pedro', 'Medina', 'C/Vitoria 57', '09003', 'Burgos', 12, 'XYZ');
INSERT INTO CONDUCTOR VALUES ('20000000C', 'Pablo', 'Torquemada', 'C/Vitoria 58', '09003', 'Burgos', 3, 'XYZ');

INSERT INTO CONDUCTOR VALUES ('30000000A', 'Raquel', 'Del Barrio', 'C/Vitoria 56', '09003', 'Burgos', 9, 'MNP');
INSERT INTO CONDUCTOR VALUES ('30000000B', 'Rosa', 'Manzanedo', 'C/Vitoria 57', '09003', 'Burgos', 6, 'MNP');
INSERT INTO CONDUCTOR VALUES ('30000000C', 'Roberto', 'Manzanita', 'C/Vitoria 58', '09003', 'Burgos', 0, 'MNP');

-- Simulamos una multa sobre el usuario '10000000A'
INSERT INTO INCIDENCIA VALUES (TO_TIMESTAMP( '11-04-2019 12:00:00', 'DD-MM-YYYY HH24:MI:SS'), '10000000A',  'Exceso de velocidad en calzada de pueblo', 2);
-- Y actualizamos los puntos en función de la sanción por el tipo de incidencia
UPDATE CONDUCTOR SET PUNTOS=PUNTOS - (SELECT VALOR FROM TIPOINCIDENCIA WHERE ID=2) WHERE NIF = '10000000A';

-- Insertamos incidencias que ya están descontadas en los datos iniciales del resto de conductores
INSERT INTO INCIDENCIA VALUES (TO_TIMESTAMP( '12-04-2019 11:00:00', 'DD-MM-YYYY HH24:MI:SS'), '10000000B', 'Falta grave con semáforo', 2); 
INSERT INTO INCIDENCIA VALUES (TO_TIMESTAMP( '12-04-2019 12:00:00', 'DD-MM-YYYY HH24:MI:SS'), '10000000C', 'Falta grave con semáforo', 2);
INSERT INTO INCIDENCIA VALUES (TO_TIMESTAMP( '12-04-2019 13:00:00', 'DD-MM-YYYY HH24:MI:SS'), '10000000C', 'Falta grave posterior con semáforo', 3); 

INSERT INTO INCIDENCIA VALUES (TO_TIMESTAMP( '12-04-2019 12:00:00', 'DD-MM-YYYY HH24:MI:SS'), '20000000C', 'Falta grave con semáforo', 2);
INSERT INTO INCIDENCIA VALUES (TO_TIMESTAMP( '12-04-2019 13:00:00', 'DD-MM-YYYY HH24:MI:SS'), '20000000C', 'Falta grave posterior con semáforo', 3);

INSERT INTO INCIDENCIA VALUES (TO_TIMESTAMP( '13-04-2019 14:00:00', 'DD-MM-YYYY HH24:MI:SS'), '30000000A', 'Falta moderada', 3);
INSERT INTO INCIDENCIA VALUES (TO_TIMESTAMP( '13-04-2019 15:00:00', 'DD-MM-YYYY HH24:MI:SS'), '30000000B', 'Falta grave', 2);
INSERT INTO INCIDENCIA VALUES (TO_TIMESTAMP( '13-04-2019 16:00:00', 'DD-MM-YYYY HH24:MI:SS'), '30000000C', 'Falta muy grave', 1);

COMMIT;
EXIT
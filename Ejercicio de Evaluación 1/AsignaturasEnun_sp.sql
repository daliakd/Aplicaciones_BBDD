drop table asignaturas cascade constraints;

create table asignaturas(
  idAsignatura  integer,
  nombre        varchar(20) not null,
  titulacion    varchar(20),
  ncreditos     integer,
  constraint PK_Asignaturas primary key ( idAsignatura, titulacion ),
  constraint UNQ_Asignaturas unique (nombre, titulacion) 
);

create or replace procedure insertaAsignatura(
  v_idAsignatura integer, v_nombreAsig varchar, v_titulacion varchar, v_ncreditos integer) is

begin

  -- Inserto tabla de asignaturas con los parámetros de entrada dados
  INSERT INTO asignaturas VALUES (
    v_idAsignatura,
    v_nombreAsig,
    v_titulacion,
    v_ncreditos
  );

  exception
    -- Capturo y manejo las excepciones
    WHEN DUP_VAL_ON_INDEX THEN
      -- OPCION DE SOLUCIÓN 1
      -- Verifico si es por clave primaria o por clave única
      DECLARE
        count_registros INTEGER;
      BEGIN
        -- Busco si es violación de clave primaria, es decir que ya había un registro con esos datos id+titulacion
        SELECT COUNT(*) INTO count_registros
        FROM asignaturas
        WHERE idAsignatura = v_idAsignatura AND titulacion = v_titulacion;

        -- Si hay un registro, es violación de clave primaria, sino de nombre
        IF count_registros > 0 THEN
          -- Violación de clave primaria
          RAISE_APPLICATION_ERROR(-20000, 'La asignatura con idAsignatura='||v_idAsignatura||' esta repetida en la titulacion '||v_titulacion||'.');
        ELSE
          -- por descarte, violación de restricción única
          RAISE_APPLICATION_ERROR(-20001, 'La asignatura con nombre='||v_nombreAsig||' esta repetida en la titulacion '||v_titulacion||'.');
        END IF;
      END;
  end;

end insertaAsignatura;
/

-- IMPLEMENTAMOS LA VERSIÓN 2 DE LA SOLUCIÓN
create or replace procedure insertaAsignatura_v2(
  v_idAsignatura integer, v_nombreAsig varchar, v_titulacion varchar, v_ncreditos integer) is
begin

  -- Inserto tabla de asignaturas con los parámetros de entrada dados
  INSERT INTO asignaturas VALUES (
    v_idAsignatura,
    v_nombreAsig,
    v_titulacion,
    v_ncreditos
  );

 exception
    -- Capturo y manejo las excepciones
    WHEN DUP_VAL_ON_INDEX THEN
      -- OPCION DE SOLUCIÓN 2
      BEGIN
        -- Miramos la variable de sistema SQLERRM para ver el código que nos ha dejado ahí
        IF SQLERRM LIKE '%PK_Asignaturas%' THEN
          -- Violación de clave primaria
          RAISE_APPLICATION_ERROR(-20000, 'La asignatura con idAsignatura='||v_idAsignatura||' esta repetida en la titulacion '||v_titulacion||'.');
        ELSE
          -- por descarte, violación de restricción única
          RAISE_APPLICATION_ERROR(-20001, 'La asignatura con nombre='||v_nombreAsig||' esta repetida en la titulacion '||v_titulacion||'.');
        END IF;
      END;
  end;

end insertaAsignatura;
/

--juego de pruebas automáticas
create or replace procedure test_asignaturas is
  begin
      begin --bloque comun de inicializaciones
        delete from asignaturas;
        insert into asignaturas values ( 1, 'ALGEBRA', 'GRADO INFORMATICA', 6);
        insert into asignaturas values ( 1, 'ALGEBRA', 'GRADO MECANICA', 6);
        commit;
      end;
      
      begin
        insertaAsignatura ( 2, 'ALGEBRA', 'GRADO INFORMATICA', 6);
        dbms_output.put_line('Mal: No detecta error combinacion nombre asignatura + titulación repetida');
      exception
        when others then
          if sqlcode=-20001 then
            dbms_output.put_line('Bien: si detecta error combinacion nombre asignatura + titulación repetida');
            dbms_output.put_line(SQLERRM);
            dbms_output.put_line('');
          else
            dbms_output.put_line('Mal: No detecta error combinacion nombre asignatura + titulación repetida');
            dbms_output.put_line('error='||SQLCODE||'=>'||SQLERRM);
          end if;
      end;
      
      begin
        insertaAsignatura ( 1, 'PROGRAMACION', 'GRADO INFORMATICA', 6);
        dbms_output.put_line('Mal: No detecta error combinacion id asignatura + titulación repetida');
      exception
        when others then
           if sqlcode=-20000 then
            dbms_output.put_line('Bien: si detecta error combinacion id asignatura + titulación repetida');
            dbms_output.put_line(SQLERRM);
            dbms_output.put_line('');
          else
            dbms_output.put_line('Mal: No detecta error combinacion id asignatura + titulación repetida');
            dbms_output.put_line('error='||SQLCODE||'=>'||SQLERRM);
          end if;
      end;
      
      declare
        v_valorEsperado varchar(100):='1ALGEBRAGRADO INFORMATICA6#1ALGEBRAGRADO MECANICA6#2PROGRAMACIONGRADO INFORMATICA6';
        v_valorActual   varchar(100);
      begin
       insertaAsignatura ( 2, 'PROGRAMACION', 'GRADO INFORMATICA', 6);
       rollback; --por si se olvido hacer commit en insertaAsignatura

        SELECT listagg(idAsignatura||nombre||titulacion||ncreditos, '#')
          within group (order by idAsignatura, titulacion) todoJunto
        into v_valorActual
        FROM asignaturas;
      
        
        if v_valorEsperado=v_valorActual then
          dbms_output.put_line('Bien: Caso sin excepciones computado correctamente');
        else
          dbms_output.put_line('Mal: Caso sin excepciones computado incorrectamente');
          dbms_output.put_line('Valor actual=  '||v_valorActual);
          dbms_output.put_line('Valor esperado='||v_valorEsperado);
        end if;
        
   exception
        when others then
          dbms_output.put_line('Mal: Salta excepcion en el caso correcto');
          dbms_output.put_line('error='||SQLCODE||'=>'||SQLERRM);     
    end;
    
  end;
  /

set serveroutput on
exec test_asignaturas;
select * from asignaturas;
commit;

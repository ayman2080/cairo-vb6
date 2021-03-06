/*

Lo primero es guardar como NO SEAN GILI....

Nota: todos los ejemplos se basan en un listado sobre la tabla proyecto

Completen los pasos en secuencia:

1)
lsTransporte         Reemplazar por el nombre del sp ejemplo lsProyecto
2)
trans_id          Reemplazar por el nombre del pk de la tabla a listar ejemplo proy_id
3)
ram_id_transporte      Reemplazar por el nombre de la tabla a listar ejemplo ram_id_Proyecto (incluyan 'ram_id_')
4)
Transporte Reemplazar por el nombre de la tabla a listar ejemplo Proyecto
5)
34      Reemplazar por el tbl_id de la tabla a listar ejemplo 2005 para la tabla proyecto. 
                  Para saber el id de la tabla a listar usen:

                        select tbl_id,tbl_nombrefisico,tbl_nombre from tabla where tbl_nombrefisico like '%Transporte%'

Para testear:

lsTransporte 'N594'

select * from rama where ram_nombre like '%transporte%'

*/
if exists (select * from sysobjects where id = object_id(N'[dbo].[lsTransporte]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[lsTransporte]

go
create procedure lsTransporte (

@@trans_id      varchar(255)

)as 

declare @trans_id int
declare @ram_id_transporte int

declare @clienteID   int
declare @IsRaiz     tinyint

exec sp_ArbConvertId @@trans_id, @trans_id out, @ram_id_transporte out

if @ram_id_transporte <> 0 begin

  exec sp_ArbIsRaiz @ram_id_transporte, @IsRaiz out

  if @IsRaiz = 0 begin

    exec sp_GetRptId @clienteID out
    exec sp_ArbGetAllHojas @ram_id_transporte, @clienteID

  end else begin

    set @ram_id_transporte = 0
    set @clienteID = 0
  end

end else begin

  set @clienteID = 0

end

select *

-- Listado de columnas que corresponda  

from 

-- Listado de tablas que corresponda  
  Transporte

where 
      (Transporte.trans_id = @trans_id or @trans_id=0)

-- Arboles
and   (
          (exists(select rptarb_hojaid 
                  from rptArbolRamaHoja 
                  where
                       rptarb_cliente = @clienteID
                  and  tbl_id = 34 -- tbl_id de Transporte
                  and  rptarb_hojaid = Transporte.trans_id
                 ) 
           )
        or 
           (@ram_id_transporte = 0)
       )
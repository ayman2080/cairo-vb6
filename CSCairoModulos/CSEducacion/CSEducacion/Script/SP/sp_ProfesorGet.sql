SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_ProfesorGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_ProfesorGet]
GO

/*

sp_ProfesorGet 7

*/

create procedure sp_ProfesorGet
(
  @@prof_id   int
)
as
begin

  select   Profesor.*,
          Persona.*, 
           dpto_nombre, 
           prov_nombre,
           suc_nombre,
          prsdt_nombre,
          pro_nombre

  from  Profesor inner join Persona               on Profesor.prs_id  = Persona.prs_id
                 left  join Proveedor              on Persona.prov_id   = Proveedor.prov_id
                 left  join Sucursal               on Persona.suc_id    = Sucursal.suc_id
                 left  join Departamento           on Persona.dpto_id   = Departamento.dpto_id
                 left  join PersonaDocumentoTipo  on Persona.prsdt_id = PersonaDocumentoTipo.prsdt_id
                 left  join Provincia             on Persona.pro_id   = Provincia.pro_id

  where prof_id= @@prof_id

end

go
set quoted_identifier off 
go
set ansi_nulls on 
go


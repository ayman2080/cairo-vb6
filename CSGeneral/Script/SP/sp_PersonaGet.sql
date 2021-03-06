SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_PersonaGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_PersonaGet]
GO

/*

sp_PersonaGet 7

*/

create procedure sp_PersonaGet
(
  @@prs_id              int
)
as
begin

  select   Persona.*, 
           dpto_nombre,
           cli_nombre, 
           prov_nombre,
           suc_nombre,
          prsdt_nombre,
          pro_nombre

  from Persona left join Cliente                 on Persona.cli_id    = Cliente.cli_id
               left join Proveedor              on Persona.prov_id   = Proveedor.prov_id
               left join Sucursal               on Persona.suc_id    = Sucursal.suc_id
               left join Departamento           on Persona.dpto_id   = Departamento.dpto_id
               left join PersonaDocumentoTipo    on Persona.prsdt_id = PersonaDocumentoTipo.prsdt_id
               left join Provincia              on Persona.pro_id   = Provincia.pro_id

  where prs_id= @@prs_id

end

go
set quoted_identifier off 
go
set ansi_nulls on 
go


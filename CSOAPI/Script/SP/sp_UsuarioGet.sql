SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_UsuarioGet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_UsuarioGet]
GO

/*

sp_UsuarioGet 7

*/

create procedure sp_UsuarioGet
(
  @@us_id              int
)
as
begin

  select Usuario.*, 
         prs_nombre,
         suc_nombre

  from Usuario left join Persona       on Usuario.prs_id  = Persona.prs_id
               left join Sucursal     on Usuario.suc_id  = Sucursal.suc_id

  where us_id= @@us_id

end

go
set quoted_identifier off 
go
set ansi_nulls on 
go


SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_Web_GetHelp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_Web_GetHelp]
GO

/*

select * from reporte

sp_Web_GetHelp 28

*/

create procedure sp_Web_GetHelp
(
  @@tbl_id           int
) 
as
begin

  declare @col_nombre varchar(255)
  declare @col_id     varchar(255)
  declare @tbl_nombre varchar(255)

  select @col_nombre = tbl_camponombre, 
         @col_id = tbl_campoid, 
         @tbl_nombre = tbl_nombrefisico
  from Tabla
  where tbl_id = @@tbl_id

  declare @sqlstmt varchar (5000)

  set @sqlstmt = 'select ' + @col_id + ',' + @col_nombre + ' from ' + @tbl_nombre
  exec (@sqlstmt)
end
go
set quoted_identifier off 
go
set ansi_nulls on 
go


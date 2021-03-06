if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_EquipoDetalleDelete ]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_EquipoDetalleDelete ]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

 sp_EquipoDetalleDelete  '',-1,0,7

 sp_EquipoDetalleDelete  '',0,0,7

*/

create procedure sp_EquipoDetalleDelete  (
  @@ed_id          int
)
as
begin

  begin transaction

  delete EquipoDetalleItem where ed_id = @@ed_id
  if @@error <> 0 goto ControlError

  delete EquipoDetalle where ed_id = @@ed_id
  if @@error <> 0 goto ControlError

  commit transaction

  return
ControlError:

  raiserror ('Ha ocurrido un error al borrar el Detalle de Equipo. sp_EquipoDetalleDelete .', 16, 1)
  rollback transaction

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


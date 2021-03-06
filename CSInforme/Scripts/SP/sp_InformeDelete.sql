if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_InformeDelete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_InformeDelete]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

 sp_InformeDelete '',-1,0,7

 sp_InformeDelete '',0,0,7

*/

create procedure sp_InformeDelete (
  @@inf_id          int
)
as
begin

  begin transaction

  declare @pre_id int

  select @pre_id = pre_id from Informe where inf_id = @@inf_id

  if @pre_id is not null begin

    delete permiso where pre_id = @pre_id
    if @@error <> 0 goto ControlError

    update informe set pre_id=null where inf_id = @@inf_id
  
    delete Prestacion where pre_id = @pre_id
    if @@error <> 0 goto ControlError
  end

  delete ReporteParametro where rpt_id in (select rpt_id from reporte where inf_id = @@inf_id)
  if @@error <> 0 goto ControlError

  delete Reporte where rpt_id in (select rpt_id from reporte where inf_id = @@inf_id)
  if @@error <> 0 goto ControlError

  delete InformeGroups where inf_id = @@inf_id
  if @@error <> 0 goto ControlError

  delete InformeHiperlinks where inf_id = @@inf_id
  if @@error <> 0 goto ControlError

  delete InformeOrders where inf_id = @@inf_id
  if @@error <> 0 goto ControlError

  delete InformeParametro where inf_id = @@inf_id
  if @@error <> 0 goto ControlError

  delete InformeSumaries where inf_id = @@inf_id
  if @@error <> 0 goto ControlError

  delete Informe where inf_id = @@inf_id
  if @@error <> 0 goto ControlError

  commit transaction

  return
ControlError:

  raiserror ('Ha ocurrido un error al borrar el informe. sp_InformeDelete.', 16, 1)
  rollback transaction

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


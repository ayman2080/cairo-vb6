if exists (select * from sysobjects where id = object_id(N'[dbo].[sp_DocOrdenCompraSetEstado]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_DocOrdenCompraSetEstado]

/*

select  sum(oci_pendientefac) from OrdenCompraItem where oc_id=6

select * from OrdenCompraItem where oc_id=9

  select * from Ordencompra

 sp_DocOrdenCompraSetEstado 9

*/

go
create procedure sp_DocOrdenCompraSetEstado (
  @@oc_id       int,
  @@Select      tinyint = 0,
  @@est_id      int = 0 out 
)
as

begin

  if @@oc_id = 0 return

  declare @est_id          int
  declare @prov_id          int
  declare @pendiente       decimal (18,6)
  declare @creditoTotal    decimal (18,6)
  declare @llevaFirma     tinyint
  declare @firmado        tinyint
  declare @deuda          decimal (18,6)
  declare @doc_id         int
  declare @doc_llevafirma tinyint

  declare @estado_pendiente         int set @estado_pendiente         =1
  declare @estado_pendienteCredito  int set @estado_pendienteCredito  =3
  declare @estado_pendienteFirma    int set @estado_pendienteFirma    =4
  declare @estado_finalizado        int set @estado_finalizado        =5
  declare @estado_anulado           int set @estado_anulado           =7

  select @prov_id = prov_id, @firmado = oc_firmado, @est_id = est_id, @doc_id = doc_id
  from OrdenCompra where oc_id = @@oc_id

  select @doc_llevafirma = doc_llevafirma from Documento where doc_id = @doc_id

  if @est_id <> @estado_anulado begin

    -- Si el documento requiere firma y el comprobante no esta firmado
    -- y no esta finalizado (puede ser que se finalizo y luego se modifico el documento
    -- para que requiera firma en cuyo caso no se exige firma para documentos finalizados)
    if @firmado = 0 and @doc_llevafirma <> 0 and @est_id <> @estado_finalizado begin             
      set @est_id = @estado_pendienteFirma 
    end
    else begin                                
      -- Se obtiene la deuda del comprobante
      select @deuda = round(sum(oci_pendientefac),2) from OrdenCompraItem where oc_id = @@oc_id

      -- Si el comprobante no tiene deuda se finaliza
      if IsNull(@deuda,0)<=0 begin
        set @est_id = @estado_finalizado          
      end else begin
        -- Se obtiene la deuda del Proveedor
        select @pendiente = sum(provcc_importe) from ProveedorCacheCredito where prov_id = @prov_id
        -- Se obtiene el credito del Proveedor
        select @creditoTotal = prov_creditototal from Proveedor where prov_id = @prov_id
        -- Si debe mas que el credito concedido al Proveedor
        if @pendiente > @creditoTotal begin  
          set @est_id = @estado_pendienteCredito 

        -- sino solo pendiente
        end else begin
          set @est_id = @estado_pendiente
        end
      end
    end
  
    update OrdenCompra set est_id = @est_id
    where oc_id = @@oc_id
  
  end

  set @@est_id = @est_id  
  if @@Select <> 0 select @est_id

  return
ControlError:

  raiserror ('Ha ocurrido un error al actualizar el estado de la orden de compra. sp_DocOrdenCompraSetEstado.', 16, 1)

end
GO
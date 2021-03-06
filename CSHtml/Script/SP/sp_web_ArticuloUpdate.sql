SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_ArticuloUpdate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_ArticuloUpdate]
GO

/*

sp_web_ArticuloUpdate 
                  1, --wart_id,
                  'bbbbbbbbbbb', --wart_titulo,
                  'aaaaaaaa', --wart_copete,
                  'aaaaaaaaaa', --wart_texto,
                  '20040421', --wart_fecha,
                  '', --wart_origen,
                  '', --wart_origenurl,
                  '', --wart_imagen,
                  1, --wartt_id,
                  7, --us_id,
                  0

*/

create Procedure sp_web_ArticuloUpdate (
     @@wart_id                int,
     @@wart_titulo            varchar(100),
     @@wart_copete            varchar(1000),
 
     @@wart_texto0            varchar(8000),
     @@wart_texto1            varchar(8000),
     @@wart_texto2            varchar(8000),
     @@wart_texto3            varchar(8000),
     @@wart_texto4            varchar(8000),
     @@wart_texto5            varchar(8000),
     @@wart_texto6            varchar(8000),
     @@wart_texto7            varchar(8000),
     @@wart_texto8            varchar(8000),
     @@wart_texto9            varchar(8000),

     @@wart_fecha            varchar(20),
     @@wart_fechaVto          varchar(20),

    @@wart_origen            varchar(255),

    @@wart_origenurl        varchar(255),
    @@wart_imagen            varchar(255),
    @@wartt_id              int,

    @@us_id                  int,
    @@rtn                   int out
) 
as

  /* select tbl_id,tbl_nombrefisico from tabla where tbl_nombrefisico like '%%'*/
  exec sp_HistoriaUpdate 25000, @@wart_id, @@us_id, 2

   set @@wart_titulo      = isnull(@@wart_titulo,'')
  set @@wart_copete      = isnull(@@wart_copete,'')

set @@wart_texto0      =      isnull(@@wart_texto0,'')
set @@wart_texto1      =      isnull(@@wart_texto1,'')
set @@wart_texto2      =      isnull(@@wart_texto2,'')
set @@wart_texto3      =      isnull(@@wart_texto3,'')
set @@wart_texto4      =      isnull(@@wart_texto4,'')
set @@wart_texto5      =      isnull(@@wart_texto5,'')
set @@wart_texto6      =      isnull(@@wart_texto6,'')
set @@wart_texto7      =      isnull(@@wart_texto7,'')
set @@wart_texto8      =      isnull(@@wart_texto8,'')
set @@wart_texto9      =      isnull(@@wart_texto9,'')

  set @@wart_origen      = isnull(@@wart_origen,'')
  set @@wart_origenurl  = isnull(@@wart_origenurl,'')
  set @@wart_imagen      = isnull(@@wart_imagen,'')

  if @@wart_id = 0 begin

    exec SP_DBGetNewId 'webArticulo', 'wart_id', @@wart_id out, 0

    insert into webArticulo (
                              wart_id,
                              wart_titulo,
                              wart_copete,
                              wart_texto,
                              wart_fecha,
                              wart_fechavto,
                              wart_origen,
                              wart_origenurl,
                              wart_imagen,
                              us_id,
                              wartt_id,
                              warte_id
                            )
                    values  (
                              @@wart_id,
                              @@wart_titulo,
                              @@wart_copete,

                              '', -- se llena al final

                              @@wart_fecha,
                              @@wart_fechavto,
                              @@wart_origen,
                              @@wart_origenurl,
                              @@wart_imagen,
                              @@us_id,
                              @@wartt_id,
                              1 -- En edicion
                            )
  end else begin

      update webArticulo set
                              wart_titulo      = @@wart_titulo,
                              wart_copete      = @@wart_copete,
                              wart_texto       = '', -- Se llena al final
                              wart_fecha      = @@wart_fecha,
                              wart_fechavto    = @@wart_fechavto,
                              wart_origen      = @@wart_origen,
                              wart_origenurl  = @@wart_origenurl,
                              wart_imagen      = @@wart_imagen,
                              us_id            = @@us_id,
                              wartt_id        = @@wartt_id
      where wart_id = @@wart_id
  end

  declare @ptrval binary(16)
  
  select @ptrval = textptr(wart_texto) from webArticulo where wart_id = @@wart_id

  updatetext webArticulo.wart_texto @ptrval null 0 @@wart_texto0 
  updatetext webArticulo.wart_texto @ptrval null 0 @@wart_texto1
  updatetext webArticulo.wart_texto @ptrval null 0 @@wart_texto2
  updatetext webArticulo.wart_texto @ptrval null 0 @@wart_texto3
  updatetext webArticulo.wart_texto @ptrval null 0 @@wart_texto4
  updatetext webArticulo.wart_texto @ptrval null 0 @@wart_texto5
  updatetext webArticulo.wart_texto @ptrval null 0 @@wart_texto6
  updatetext webArticulo.wart_texto @ptrval null 0 @@wart_texto7
  updatetext webArticulo.wart_texto @ptrval null 0 @@wart_texto8
  updatetext webArticulo.wart_texto @ptrval null 0 @@wart_texto9

  set @@rtn = @@wart_id

go
set quoted_identifier off 
go
set ansi_nulls on 
go


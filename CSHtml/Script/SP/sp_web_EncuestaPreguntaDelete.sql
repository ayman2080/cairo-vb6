SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_web_EncuestaPreguntaDelete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_web_EncuestaPreguntaDelete]
GO

/*
select * from Encuesta
sp_web_EncuestaPreguntaDelete 1,10,0

*/

create Procedure sp_web_EncuestaPreguntaDelete
(
  @@ecp_id   int
) 
as

  delete EncuestaRespuesta 
  where exists(select * from EncuestaPreguntaItem 
               where ecpi_id = EncuestaRespuesta.ecpi_id 
                 and ecp_id = @@ecp_id
              )
  delete EncuestaPreguntaItem where ecp_id = @@ecp_id 
  delete EncuestaPregunta where ecp_id = @@ecp_id 

go
set quoted_identifier off 
go
set ansi_nulls on 
go


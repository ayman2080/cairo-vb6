if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_hlpw_agenda]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_hlpw_agenda]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

        select agn_id,
               agn_nombre   as Nombre,
               agn_codigo   as Codigo
        from Agenda 
  
        where (exists (select * from EmpresaAgenda where agn_id = Agenda.agn_id) or 1 = 1)

  select us_empresaex from usuario

 sp_hlpw_agenda 1,2,'100',-1,1

 sp_hlpw_agenda 1,'',0

*/

create procedure sp_hlpw_agenda (
  @@us_id           int,
  @@emp_id          int,
  @@filter           varchar(255)  = '',
  @@check            smallint       = 0
)
as
begin
  set nocount on

  if @@check <> 0 begin
  
    select   agn_id,
            agn_nombre        as [Nombre],
            agn_codigo         as [Codigo]

    from Agenda

    where (agn_nombre = @@filter or agn_codigo = @@filter)
      and activo <> 0
      and (exists (select per_id from Permiso
                where  pre_id = pre_id_propietario
                   and (Permiso.us_id = @@us_id
                        or (exists(select rol_id from UsuarioRol where rol_id = Permiso.rol_id and us_id = @@us_id))
                        )
               )
          )

  end else begin

      select top 50
             agn_id,
             agn_nombre   as Nombre,
             agn_codigo   as Codigo
      from Agenda 

      where (agn_codigo like '%'+@@filter+'%' or agn_nombre like '%'+@@filter+'%' or @@filter = '')
      and (exists (select per_id from Permiso
                where  pre_id = pre_id_propietario
                   and (Permiso.us_id = @@us_id
                        or (exists(select rol_id from UsuarioRol where rol_id = Permiso.rol_id and us_id = @@us_id))
                        )
               )
          )

  end    

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

